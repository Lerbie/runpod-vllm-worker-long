import os
import runpod
import requests

MODEL = os.environ.get("MODEL_NAME", "qwen/qwen2.5-7b-instruct")

def handler(event):
    inp = event.get("input", {})
    messages = inp.get("messages", [])
    max_tokens = int(inp.get("max_new_tokens") or inp.get("max_tokens") or 4096)

    r = requests.post(
        "http://127.0.0.1:8000/v1/chat/completions",
        json={
            "model": MODEL,
            "messages": messages or [{"role": "user", "content": inp.get("prompt", "")}],
            "max_tokens": max_tokens,
            "temperature": inp.get("temperature", 0.7),
            "top_p": inp.get("top_p", 0.9),
            "stream": False
        },
        timeout=600,
    )
    r.raise_for_status()
    data = r.json()
    return {"text": data["choices"][0]["message"]["content"]}

runpod.serverless.start({"handler": handler})