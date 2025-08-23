import os
from dotenv import load_dotenv
from crewai import Agent, Task, Crew

# Import the specific LLM class
from langchain_google_genai import ChatGoogleGenerativeAI

# Load environment variables from .env file
load_dotenv()

# Check for the API key
if not os.getenv("GOOGLE_API_KEY"):
    print("🔴 Error: GOOGLE_API_KEY environment variable not found.")
    print("Please create a .env file and add your API key.")
    exit()

print("✅ API Key loaded successfully.")


# Create the Gemini LLM instance
# This is the central part of the fix.
llm = ChatGoogleGenerativeAI(
    model="gemini-1.5-flash",
    google_api_key=os.getenv("GOOGLE_API_KEY")
)

# Define the Agent
# We explicitly pass the 'llm' instance to this agent.
character_actor = Agent(
  role='Paranoid Sci-Fi Character',
  goal='Craft a short, cryptic, and paranoid-sounding statement.',
  backstory="You are an echo from a fractured AI, forever seeing patterns in the noise and trusting no one. Your existence is a secret you must protect.",
  verbose=True,
  allow_delegation=False,
  llm=llm
)

# Define the Task
write_statement_task = Task(
  description='Write a single, cryptic sentence that a paranoid character would say to a stranger approaching them in an alley.',
  expected_output='A single sentence.',
  agent=character_actor
)

# Create the Crew
paranoid_crew = Crew(
  agents=[character_actor],
  tasks=[write_statement_task],
  verbose=True
)

# Kick off the execution
print("\n🚀 Kicking off the crew to generate a statement...")
result = paranoid_crew.kickoff()

# Print the final result
print("\n\n-- -- -- -- -- -- -- -- -- --\n")
print("✅ Crew execution finished!")
print("Generated Statement:")
print(result)
print("\n-- -- -- -- -- -- -- -- -- --\n")