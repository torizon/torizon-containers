ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3 python3-venv python3-pip \
      python3-numpy python3-pil \
      wget unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /app/.venv --system-site-packages && \
    . /app/.venv/bin/activate && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir tflite-runtime

COPY infer.py \
     ssd_detect_quant_only_som.tflite \
     /app/
COPY images/ /app/images/
COPY scripts/ /app/

RUN mkdir -p /app/images/test /app/images/train /app/images/validation && \
    bash script_take_labels.sh && \
    python3 separate.py && \
    python3 train_val_test_split.py

CMD ["/bin/sh", "-lc", ". /app/.venv/bin/activate && python3 /app/infer.py"]
