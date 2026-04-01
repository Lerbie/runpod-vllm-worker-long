import os
import runpod
import requests

MODEL = os.environ.get("MODEL_NAME", "qwen/qwen2.5-7b-instruct")

def handler(event):
    inp = event.get("input", {})
    prompt = inp.get("prompt", "")
    max_tokens = int(inp.get("max_tokens", 800))

    r = requests.post(
        "http://127.0.0.1:8000/v1/chat/completions",
        json={
            "model": MODEL,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": max_tokens,
        },
        timeout=600,
    )
    r.raise_for_status()
    data = r.json()
    return {"text": data["choices"][0]["message"]["content"], "raw": data}

runpod.serverless.start({"handler": handler})
