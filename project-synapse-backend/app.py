import os
import json
import logging
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from crewai import Agent, Task, Crew
from langchain_google_genai import ChatGoogleGenerativeAI

# --- INITIALIZATION ---

# Initialize Flask App and configure logging
app = Flask(__name__)
if __name__ != '__main__':
    gunicorn_logger = logging.getLogger('gunicorn.error')
    app.logger.handlers = gunicorn_logger.handlers
    app.logger.setLevel(gunicorn_logger.level)

# Load all mission definitions from the JSON file on startup
try:
    with open('missions.json', 'r') as f:
        missions_data = json.load(f)['missions']
    # Create a dictionary for easy lookup by ID
    MISSIONS = {mission['id']: mission for mission in missions_data}
    app.logger.info(f"✅ Loaded {len(MISSIONS)} missions successfully.")
except Exception as e:
    app.logger.error(f"🔴 Failed to load missions.json: {e}")
    MISSIONS = {}

# Initialize the Gemini LLM (shared by all agents)
llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",
    google_api_key=os.getenv("GOOGLE_API_KEY")
)
app.logger.info("✅ Gemini LLM Initialized.")

# --- API ENDPOINTS ---

@app.route('/missions', methods=['GET'])
def get_missions():
    """
    Returns the full list of mission data to the client.
    """
    app.logger.info("➡️  Request received for /missions")
    # We return the list of mission values, not the whole dictionary
    return jsonify(list(MISSIONS.values()))

@app.route('/interact/<mission_id>', methods=['POST'])
def interact(mission_id):
    """
    This endpoint interacts with the character for a specific mission.
    """
    # 1. Find the mission and its character
    mission_info = MISSIONS.get(mission_id)
    if not mission_info:
        app.logger.error(f"🔴 Mission ID not found: {mission_id}")
        return jsonify({"error": "Mission not found"}), 404
    
    character_info = mission_info['character']

    # 2. Get the user's message
    data = request.get_json()
    if not data or 'message' not in data:
        app.logger.error("🔴 Missing 'message' in request body")
        return jsonify({"error": "Missing 'message' in request body"}), 400
    
    user_message = data['message']
    app.logger.info(f"➡️  Received message for '{character_info['name']}': '{user_message}'")

    # 3. Dynamically create the Agent
    agent = Agent(
        role=character_info['role'],
        goal=character_info['goal'],
        backstory=character_info['backstory'],
        verbose=False,
        allow_delegation=False,
        llm=llm
    )

    # 4. Create the Task and Crew
    task = Task(
        description=f"A stranger has just approached you and said: '{user_message}'. Formulate a reply based on your personality and goal.",
        expected_output="A single, short sentence or two.",
        agent=agent
    )
    crew = Crew(agents=[agent], tasks=[task], verbose=False)
    
    app.logger.info(f"🧠 Crew for '{character_info['name']}' is thinking...")
    result = crew.kickoff()
    app.logger.info(f"⬅️  Agent responded: '{result}'")

    return jsonify({"response": result})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
