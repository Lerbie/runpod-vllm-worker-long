#!/usr/bin/env bash
set -e

python -m vllm.entrypoints.openai.api_server \
  --model "${MODEL_NAME:-qwen/qwen2.5-7b-instruct}" \
  --host 0.0.0.0 \
  --port 8000 &

python -u /app/handler.py
