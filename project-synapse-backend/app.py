import os
import logging
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from crewai import Agent, Task, Crew
from langchain_google_genai import ChatGoogleGenerativeAI

# --- INITIALIZATION ---

# Load environment variables
load_dotenv()

# Initialize Flask App
app = Flask(__name__)

# Configure Flask's logger to integrate with Gunicorn
if __name__ != '__main__':
    gunicorn_logger = logging.getLogger('gunicorn.error')
    app.logger.handlers = gunicorn_logger.handlers
    app.logger.setLevel(gunicorn_logger.level)

# Check for the API key
if not os.getenv("GOOGLE_API_KEY"):
    app.logger.error("🔴 GOOGLE_API_KEY environment variable not found.")
    raise ValueError("GOOGLE_API_KEY environment variable not found.")

app.logger.info("✅ API Key loaded successfully.")

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
app.logger.info("🤖 Paranoid Agent initialized.")

# --- API ENDPOINT ---

@app.route('/interact', methods=['POST'])
def interact():
    """
    This endpoint receives a message from a user and returns the agent's response.
    """
    data = request.get_json()
    if not data or 'message' not in data:
        app.logger.error("🔴 Missing 'message' in request body")
        return jsonify({"error": "Missing 'message' in request body"}), 400
    
    user_message = data['message']
    app.logger.info(f"➡️  Received message: '{user_message}'")

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

    app.logger.info("🧠 Crew is thinking...")
    result = interaction_crew.kickoff()
    app.logger.info(f"⬅️  Agent responded: '{result}'")

    return jsonify({"response": result})


# --- RUN THE SERVER ---

if __name__ == '__main__':
    # This block is for running the app directly with `python app.py` for local testing
    app.run(host='0.0.0.0', port=5001, debug=True)

