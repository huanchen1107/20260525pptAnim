import os, sys, requests
def load_env():
    env_path = os.path.join(os.path.dirname(__file__), '../..', '.env')
    if os.path.exists(env_path):
        with open(env_path, 'r') as f:
            for line in f:
                if line.startswith('ANTHROPIC_API_KEY='):
                    return line.strip().split('=', 1)[1]
    return os.environ.get("ANTHROPIC_API_KEY")

api_key = load_env()
headers = {
    "x-api-key": api_key,
    "anthropic-version": "2023-06-01",
    "content-type": "application/json"
}
data = {
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 100,
    "messages": [
        {"role": "user", "content": "Say hello!"}
    ]
}
try:
    print("Testing basic Anthropic connection...")
    response = requests.post("https://api.anthropic.com/v1/messages", headers=headers, json=data)
    print(f"Status: {response.status_code}")
    print(response.text[:200])
except Exception as e:
    print(f"Error: {e}")
