import os
import requests
import runpod

# Default model if env var is not set
MODEL = os.environ.get("MODEL_NAME", "qwen/qwen2.5-7b-instruct")

def handler(event):
    """
    Handles a single request from RunPod.
    Expects `event["input"]` to be a dict with optional keys:
        - messages: list of dicts with "role" and "content"
        - prompt: str (alternative to messages)
        - max_new_tokens or max_tokens: int
        - temperature: float
        - top_p: float
    """
    inp = event.get("input", {})

    # Extract messages or fallback to prompt
    messages = inp.get("messages")
    if not messages:
        prompt = inp.get("prompt", "")
        messages = [{"role": "user", "content": prompt}]

    # Optional: join messages for debugging/logging
    prompt_text = " ".join([m.get("content", "") for m in messages])
    # print(f"Prompt text: {prompt_text}")  # Uncomment if you want logs

    # Max tokens
    max_tokens = int(inp.get("max_new_tokens") or inp.get("max_tokens") or 4096)

    # Build the request payload for vLLM API
    payload = {
        "model": MODEL,
        "messages": messages,
        "max_tokens": max_tokens,
        "temperature": inp.get("temperature", 0.7),
        "top_p": inp.get("top_p", 0.9),
        "stream": False
    }

    try:
        r = requests.post(
            "http://127.0.0.1:8000/v1/chat/completions",
            json=payload,
            timeout=600
        )
        r.raise_for_status()
        data = r.json()

        # Return the assistant's output
        return {"text": data["choices"][0]["message"]["content"]}

    except requests.RequestException as e:
        # Properly surface HTTP/network errors
        return {"error": str(e)}

# Start the RunPod serverless handler
runpod.serverless.start({"handler": handler})