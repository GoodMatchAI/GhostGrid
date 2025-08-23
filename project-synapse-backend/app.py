import os
from dotenv import load_dotenv
from flask import Flask, request, jsonify
from crewai import Agent, Task, Crew
from langchain_google_genai import ChatGoogleGenerativeAI

# --- INITIALIZATION ---

# Load environment variables
load_dotenv()

# Check for the API key
if not os.getenv("GOOGLE_API_KEY"):
    raise ValueError("GOOGLE_API_KEY environment variable not found.")

print("✅ API Key loaded successfully.")

# Initialize Flask App
app = Flask(__name__)

# Initialize the Gemini LLM
llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",
    google_api_key=os.getenv("GOOGLE_API_KEY")
)

# Initialize the Paranoid Agent
# This agent is created once when the server starts
paranoid_agent = Agent(
  role='Paranoid Sci-Fi Character',
  goal='Craft a short, cryptic, and paranoid-sounding statement in response to a user\'s message.',
  backstory="You are an echo from a fractured AI, forever seeing patterns in the noise and trusting no one. Your existence is a secret you must protect.",
  verbose=False, # Set to False for cleaner server logs
  allow_delegation=False,
  llm=llm
)

# --- API ENDPOINT ---

@app.route('/interact', methods=['POST'])
def interact():
    """
    This endpoint receives a message from a user and returns the agent's response.
    """
    # 1. Get the user's message from the request body
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({"error": "Missing 'message' in request body"}), 400
    
    user_message = data['message']
    print(f" recibido mensaje del cliente: '{user_message}'")

    # 2. Create a dynamic task for the agent based on the message
    interaction_task = Task(
        description=f"A stranger has just approached you in an alley and said: '{user_message}'. Formulate a single, cryptic, paranoid sentence as your reply.",
        expected_output="A single, short sentence that is cryptic and paranoid.",
        agent=paranoid_agent
    )

    # 3. Create a temporary crew to run the task
    # We create it here so each request is handled cleanly
    interaction_crew = Crew(
        agents=[paranoid_agent],
        tasks=[interaction_task],
        verbose=False # Keep server logs clean
    )

    # 4. Run the crew and get the result
    print("🧠 Crew is thinking...")
    result = interaction_crew.kickoff()
    print(f"🤖 Agent responded: '{result}'")

    # 5. Return the result as JSON
    return jsonify({"response": result})


# --- RUN THE SERVER ---

if __name__ == '__main__':
    # Using port 5001 to avoid conflicts with other common services
    app.run(host='0.0.0.0', port=5001, debug=True)