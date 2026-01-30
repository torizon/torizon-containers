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
      libtim-vx \
      libtensorflow-lite2.16.2 \
      tflite-vx-delegate-imx \
      imx-gpu-viv-wayland \
      wget unzip ca-certificates \
      imx-gpu-viv-wayland-dev \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /app/.venv --system-site-packages

RUN . /app/.venv/bin/activate && \
    pip3 install --upgrade pip && \
    pip3 install --no-cache-dir tflite-runtime

COPY infer.py /app/infer.py
COPY ssd_detect_quant_only_som.tflite /app
COPY images /app/images

COPY scripts/script_take_labels.sh /app
COPY scripts/separate.py /app
COPY scripts/train_val_test_split.py /app


RUN bash script_take_labels.sh
RUN python3 separate.py
RUN python3 train_val_test_split.py

RUN set -eux; \
    wget -q -O mobilenet.zip https://storage.googleapis.com/download.tensorflow.org/models/tflite/mobilenet_v1_1.0_224_quant_and_labels.zip; \
    unzip -q mobilenet.zip -d /app; \
    rm mobilenet.zip

CMD ["/bin/sh", "-lc", ". /app/.venv/bin/activate && python3 /app/infer.py"]
