FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev \
    curl netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install vLLM (will pull the correct torch version automatically)
RUN pip3 install --no-cache-dir vllm==0.6.3

# Install your additional Python packages, including pyairports to fix the guided-decoding crash
RUN pip3 install --no-cache-dir runpod requests transformers==4.45.2 pyairports

# Copy your worker files
COPY handler.py /app/handler.py
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# Environment variables
ENV MODEL_NAME=qwen/qwen2.5-7b-instruct
ENV VLLM_MAX_NUM_SEQS=32
ENV VLLM_GPU_MEMORY_UTILIZATION=0.85
ENV MAX_MODEL_LEN=8192
ENV MAX_NEW_TOKENS=4096

# Start the server
CMD ["/app/start.sh"]