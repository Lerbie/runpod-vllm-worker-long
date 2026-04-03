#!/usr/bin/env bash
set -e

# Start vLLM with proper token limits so max_new_tokens actually works
python3 -m vllm.entrypoints.openai.api_server \
  --model "${MODEL_NAME:-qwen/qwen2.5-7b-instruct}" \
  --host 0.0.0.0 \
  --port 8000 \
  --max-model-len 8192 \
  --max-num-seqs 48 \
  --gpu-memory-utilization 0.9 \
  --enforce-eager \
  --disable-log-requests \
  &

# Give vLLM a few seconds to start
sleep 3

# Start the RunPod handler
python3 -u /app/handler.py