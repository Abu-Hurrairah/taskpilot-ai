import os
from dotenv import load_dotenv
load_dotenv()
DATABASE_PATH = os.getenv("DATABASE_PATH", "taskpilot.db")
AI_PROVIDER = os.getenv("AI_PROVIDER", "local")
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "llama3.2:3b")
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "http://localhost:8080,http://127.0.0.1:8080").split(",")
