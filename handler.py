import os
import runpod
import requests

MODEL = os.environ.get("MODEL_NAME", "qwen/qwen2.5-7b-instruct")
MAX_CONTEXT = 8192
SAFE_MARGIN = 512

prompt_text = " ".join([m.get("content","") for m in messages])
prompt_tokens_estimate = len(prompt_text) // 4

max_tokens = min(
    max_tokens,
    MAX_CONTEXT - prompt_tokens_estimate - SAFE_MARGIN
)

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
    if r.status_code != 200:
        print("vLLM ERROR:", r.text)
        raise Exception(f"vLLM failed: {r.status_code}")
    data = r.json()
    return {"text": data["choices"][0]["message"]["content"]}

runpod.serverless.start({"handler": handler})