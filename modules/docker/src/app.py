import os
import requests
import time

def run_diagnostic():
    print("--- 🛠️  Container Diagnostic Start ---")
    
    # 1. Test Environment Variables
    # Proves your 'ENV' or 'docker run -e' logic works
    app_env = os.getenv("APP_ENV", "Development")
    print(f"🌐 Environment: {app_env}")

    # 2. Test Dependency Mapping
    # Proves requirements.txt was installed and is in the PATH
    try:
        resp = requests.get("https://google.com", timeout=5)
        print(f"✅ Network: Successfully reached Google (Status: {resp.status_code})")
    except Exception as e:
        print(f"❌ Network: Failed to reach external API. Error: {e}")

    # 3. Keep the container alive (Optional)
    # Useful if you want to 'docker exec' into it to look around
    print("--- 🏁 Diagnostic Complete. System Idle. ---")
    
    # In a real app, this would be your web server (Flask/FastAPI)
    # For a test, we'll just loop so the container doesn't immediately exit
    # time.sleep(10)

if __name__ == "__main__":
    run_diagnostic()