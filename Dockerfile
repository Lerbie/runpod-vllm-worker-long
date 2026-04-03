FROM nvidia/cuda:12.1.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-dev \
    curl netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    torch==2.4.0 \
    --index-url https://download.pytorch.org/whl/cu121

RUN pip3 install --no-cache-dir vllm==0.6.3

RUN pip3 install --no-cache-dir runpod requests transformers==4.45.2 pyairports

COPY handler.py /app/handler.py
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

ENV MODEL_NAME=qwen/qwen2.5-7b-instruct
CMD ["/app/start.sh"]
