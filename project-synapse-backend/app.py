import os
import json
import logging
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from crewai import Agent, Task, Crew
from langchain_google_genai import ChatGoogleGenerativeAI

# --- INITIALIZATION ---

# Load environment variables
load_dotenv()

# Initialize Flask App and configure logging
app = Flask(__name__)
if __name__ != '__main__':
    gunicorn_logger = logging.getLogger('gunicorn.error')
    app.logger.handlers = gunicorn_logger.handlers
    app.logger.setLevel(gunicorn_logger.level)

# Load all character definitions from the JSON file on startup
try:
    with open('characters.json', 'r') as f:
        characters_data = json.load(f)['characters']
    # Create a dictionary for easy lookup by ID
    CHARACTERS = {char['id']: char for char in characters_data}
    app.logger.info(f"✅ Loaded {len(CHARACTERS)} characters successfully.")
except Exception as e:
    app.logger.error(f"🔴 Failed to load characters.json: {e}")
    CHARACTERS = {}

# Initialize the Gemini LLM (shared by all agents)
llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",
    google_api_key=os.getenv("GOOGLE_API_KEY")
)
app.logger.info("✅ Gemini LLM Initialized.")

# --- DYNAMIC API ENDPOINT ---

@app.route('/interact/<character_id>', methods=['POST'])
def interact(character_id):
    """
    This endpoint interacts with a specific character identified by character_id.
    """
    # 1. Find the character definition
    character_info = CHARACTERS.get(character_id)
    if not character_info:
        app.logger.error(f"🔴 Character ID not found: {character_id}")
        return jsonify({"error": "Character not found"}), 404

    # 2. Get the user's message
    data = request.get_json()
    if not data or 'message' not in data:
        app.logger.error("🔴 Missing 'message' in request body")
        return jsonify({"error": "Missing 'message' in request body"}), 400
    
    user_message = data['message']
    app.logger.info(f"➡️  Received message for '{character_info['name']}': '{user_message}'")

    # 3. Dynamically create the Agent for this interaction
    agent = Agent(
        role=character_info['role'],
        goal=character_info['goal'],
        backstory=character_info['backstory'],
        verbose=False,
        allow_delegation=False,
        llm=llm
    )

    # 4. Create the Task
    task = Task(
        description=f"A stranger has just approached you and said: '{user_message}'. Formulate a reply based on your personality and goal.",
        expected_output="A single, short sentence or two.",
        agent=agent
    )

    # 5. Create and run the Crew
    crew = Crew(agents=[agent], tasks=[task], verbose=False)
    app.logger.info(f"🧠 Crew for '{character_info['name']}' is thinking...")
    result = crew.kickoff()
    app.logger.info(f"⬅️  Agent responded: '{result}'")

    return jsonify({"response": result})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
