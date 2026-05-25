import os
import sys
import json
import base64
import requests
import re
from PIL import Image

def load_env():
    env = {}
    env_path = os.path.join(os.path.dirname(__file__), '../..', '.env')
    if os.path.exists(env_path):
        with open(env_path, 'r') as f:
            for line in f:
                line = line.strip()
                if not line or line.startswith('#'):
                    continue
                if '=' in line:
                    k, v = line.split('=', 1)
                    k = k.strip()
                    v = v.strip().strip('"').strip("'")
                    env[k] = v
    # Merge OS environment variables
    for key in ["OPENAI_API_KEY", "ANTHROPIC_API_KEY", "GEMINI_API_KEY"]:
        if key in os.environ:
            env[key] = os.environ[key]
    return env

def analyze_image(image_path, env):
    openai_key = env.get("OPENAI_API_KEY")
    anthropic_key = env.get("ANTHROPIC_API_KEY")
    gemini_key = env.get("GEMINI_API_KEY")
    with Image.open(image_path) as img:
        source_width, source_height = img.size

    def detect_media_type(path):
        lower_path = path.lower()
        if lower_path.endswith(('.jpg', '.jpeg')):
            return "image/jpeg"
        if lower_path.endswith('.webp'):
            return "image/webp"
        if lower_path.endswith('.svg'):
            return "image/svg+xml"
        return "image/png"

    # Try each provider in sequence
    providers = []
    
    # 1. OpenAI
    if openai_key and not openai_key.startswith("your_"):
        providers.append(("OpenAI", "gpt-4o"))
        
    # 2. Gemini
    if gemini_key and not gemini_key.startswith("your_"):
        providers.append(("Gemini", "gemini-2.5-flash"))
        
    # 3. Anthropic
    if anthropic_key and not anthropic_key.startswith("your_"):
        providers.append(("Anthropic", "claude-3-5-sonnet-20241022"))

    if not providers:
        print("No API keys found in env")
        sys.exit(1)

    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode("utf-8")

    media_type = detect_media_type(image_path)
        
    prompt = """
    You are a visual layout analyzer. Your job is to extract a strict 'scene_layout.json' from this slide image.
    Rules:
    1. The source image size is {source_width}x{source_height}. Use that exact canvas size in the JSON output.
    2. Identify every major visual object (window frames, titles, text blocks, progress bars, etc).
    3. Do not resize or normalize the image before reasoning about layout.
    4. Output ONLY a raw JSON block (no markdown, no backticks).
    
    Required JSON schema:
    {
      "canvas": {
        "width": {source_width},
        "height": {source_height},
        "bg_color": "background color or gradient",
        "bg_size": "size if repeating"
      },
      "objects": [
        {
          "id": "unique-id",
          "type": "box|text",
          "x": <number>,
          "y": <number>,
          "w": <number or "auto">,
          "h": <number or "auto">,
          "zIndex": <number>,
          "text": "text content if any",
          "style": {
            "fontSize": "...",
            "color": "...",
            "background": "..."
            // other css camelCase properties
          }
        }
      ]
    }
    
    CRITICAL: ONLY OUTPUT JSON.
    """.replace("{source_width}", str(source_width)).replace("{source_height}", str(source_height))

    for provider_name, model_name in providers:
        try:
            if provider_name == "OpenAI":
                print(f"Calling OpenAI API ({model_name})...")
                headers = {
                    "Authorization": f"Bearer {openai_key}",
                    "Content-Type": "application/json"
                }
                data = {
                    "model": model_name,
                    "messages": [
                        {
                            "role": "user",
                            "content": [
                                {"type": "text", "text": prompt},
                                {
                                    "type": "image_url",
                                    "image_url": {
                                        "url": f"data:{media_type};base64,{encoded_string}"
                                    }
                                }
                            ]
                        }
                    ],
                    "max_tokens": 4096
                }
                response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=data)
                if response.status_code != 200:
                    print(f"OpenAI returned error status {response.status_code}. Gracefully falling back...")
                    continue
                content = response.json()['choices'][0]['message']['content']
                return content

            elif provider_name == "Gemini":
                print(f"Calling Google Gemini API ({model_name})...")
                url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={gemini_key}"
                headers = {"Content-Type": "application/json"}
                data = {
                    "contents": [
                        {
                            "parts": [
                                {"text": prompt},
                                {
                                    "inlineData": {
                                        "mimeType": media_type,
                                        "data": encoded_string
                                    }
                                }
                            ]
                        }
                    ],
                    "generationConfig": {
                        "responseMimeType": "application/json"
                    }
                }
                response = requests.post(url, headers=headers, json=data)
                if response.status_code != 200:
                    print(f"Gemini returned error status {response.status_code}. Gracefully falling back...")
                    continue
                resp_json = response.json()
                content = resp_json['candidates'][0]['content']['parts'][0]['text']
                return content

            elif provider_name == "Anthropic":
                print(f"Calling Anthropic API ({model_name})...")
                headers = {
                    "x-api-key": anthropic_key,
                    "anthropic-version": "2023-06-01",
                    "content-type": "application/json"
                }
                data = {
                    "model": model_name,
                    "max_tokens": 4096,
                    "messages": [
                        {
                            "role": "user",
                            "content": [
                                {
                                    "type": "image",
                                    "source": {
                                        "type": "base64",
                                        "media_type": media_type,
                                        "data": encoded_string
                                    }
                                },
                                {"type": "text", "text": prompt}
                            ]
                        }
                    ]
                }
                response = requests.post("https://api.anthropic.com/v1/messages", headers=headers, json=data)
                if response.status_code != 200:
                    print(f"Anthropic returned error status {response.status_code}. Gracefully falling back...")
                    continue
                content = response.json()['content'][0]['text']
                return content

        except Exception as e:
            print(f"Error calling {provider_name}: {e}. Gracefully falling back...")
            continue

    print("All configured API providers failed to complete the request.")
    sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python orchestrator.py <input_image> <output_json>")
        sys.exit(1)
        
    img_path = sys.argv[1]
    out_path = sys.argv[2]
    
    env = load_env()
    layout_json = analyze_image(img_path, env)
    
    # Try parsing
    try:
        parsed = json.loads(layout_json)
        with open(out_path, 'w') as f:
            json.dump(parsed, f, indent=2)
        print(f"Successfully wrote {out_path}")
    except Exception as e:
        print("Failed to parse JSON from API:")
        print(layout_json)
        sys.exit(1)
