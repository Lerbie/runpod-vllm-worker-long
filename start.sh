#!/usr/bin/env bash
set -e

MAX_RETRIES=3
ATTEMPT=0

start_vllm() {
  echo "Starting vLLM server (attempt $((ATTEMPT+1))/$MAX_RETRIES)..."
  python3 -m vllm.entrypoints.openai.api_server \
    --model "${MODEL_NAME:-qwen/qwen2.5-7b-instruct}" \
    --host 0.0.0.0 \
    --port 8000 \
    --max-model-len ${MAX_MODEL_LEN:-8192} \
    --max-num-seqs ${VLLM_MAX_NUM_SEQS:-32} \
    --gpu-memory-utilization ${VLLM_GPU_MEMORY_UTILIZATION:-0.85} \
    --disable-log-requests \
    &
  VLLM_PID=$!
}

while [ $ATTEMPT -lt $MAX_RETRIES ]; do
  start_vllm

  echo "Waiting for vLLM to be ready..."
  timeout=90
  READY=0

  while [ $timeout -gt 0 ]; do
    if ! kill -0 $VLLM_PID 2>/dev/null; then
      echo "vLLM process died unexpectedly"
      break
    fi
    if curl -sf http://localhost:8000/v1/models > /dev/null 2>&1; then
      READY=1
      break
    fi
    sleep 1
    timeout=$((timeout-1))
  done

  if [ $READY -eq 1 ]; then
    echo "vLLM is ready on port 8000"
    break
  fi

  echo "Attempt $((ATTEMPT+1)) failed. Cleaning up..."
  kill $VLLM_PID 2>/dev/null || true
  wait $VLLM_PID 2>/dev/null || true
  sleep 5
  ATTEMPT=$((ATTEMPT+1))
done

if [ $READY -eq 0 ]; then
  echo "ERROR: vLLM failed to start after $MAX_RETRIES attempts"
  exit 1
fi

python3 -u /app/handler.py

#omg
