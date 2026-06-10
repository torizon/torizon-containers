ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE


FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ARG TFLITE_MODEL="ssd_detect_quant_only_som.tflite"

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    HOST_PLATFORM=imx93

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      python3-pil \
      python3-pip \
      python3-venv \
      unzip \
      wget \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /app/.venv --system-site-packages && \
    . /app/.venv/bin/activate && \
    pip3 install --upgrade pip

COPY infer.py ${TFLITE_MODEL} /app/
COPY images/ /app/images/
COPY scripts/ /app/

# Convert model to Ethos-U NPU
RUN vela --accelerator-config ethos-u65-256 ${TFLITE_MODEL}

RUN mkdir -p /app/images/test /app/images/train /app/images/validation && \
    bash script_take_labels.sh && \
    python3 separate.py && \
    python3 train_val_test_split.py

CMD ["/bin/sh", "-lc", ". /app/.venv/bin/activate && python3 /app/infer.py"]
