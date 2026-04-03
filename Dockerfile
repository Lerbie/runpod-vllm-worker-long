FROM nvidia/cuda:12.6.0-runtime-ubuntu22.04

WORKDIR /app
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*
# Install vLLM + compatible transformers (this fixes the crash)
RUN pip install --no-cache-dir vllm==0.7.2
COPY handler.py /app/handler.py
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

ENV MODEL_NAME=qwen/qwen2.5-7b-instruct
CMD ["/app/start.sh"]
