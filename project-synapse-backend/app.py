import os
import logging
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from crewai import Agent, Task, Crew
from langchain_google_genai import ChatGoogleGenerativeAI

# --- INITIALIZATION ---

# Configure logging to output to the console
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Load environment variables
load_dotenv()

# Check for the API key
if not os.getenv("GOOGLE_API_KEY"):
    raise ValueError("GOOGLE_API_KEY environment variable not found.")

logging.info("✅ API Key loaded successfully.")

# Initialize Flask App
app = Flask(__name__)

# Initialize the Gemini LLM
llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",
    google_api_key=os.getenv("GOOGLE_API_KEY")
)

# Initialize the Paranoid Agent
paranoid_agent = Agent(
    role='Paranoid Sci-Fi Character',
    goal='Craft a short, cryptic, and paranoid-sounding statement in response to a user\'s message.',
    backstory="You are an echo from a fractured AI, forever seeing patterns in the noise and trusting no one. Your existence is a secret you must protect.",
    verbose=False,
    allow_delegation=False,
    llm=llm
)
logging.info("🤖 Paranoid Agent initialized.")

# --- API ENDPOINT ---

@app.route('/interact', methods=['POST'])
def interact():
    """
    This endpoint receives a message from a user and returns the agent's response.
    """
    data = request.get_json()
    if not data or 'message' not in data:
        logging.error("🔴 Missing 'message' in request body")
        return jsonify({"error": "Missing 'message' in request body"}), 400
    
    user_message = data['message']
    logging.info(f"➡️  Received message: '{user_message}'")

    interaction_task = Task(
        description=f"A stranger has just approached you in an alley and said: '{user_message}'. Formulate a single, cryptic, paranoid sentence as your reply.",
        expected_output="A single, short sentence that is cryptic and paranoid.",
        agent=paranoid_agent
    )

    interaction_crew = Crew(
        agents=[paranoid_agent],
        tasks=[interaction_task],
        verbose=False
    )

    logging.info("🧠 Crew is thinking...")
    result = interaction_crew.kickoff()
    logging.info(f"⬅️  Agent responded: '{result}'")

    return jsonify({"response": result})


# --- RUN THE SERVER ---

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
