ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libtim-vx \
      libtensorflow-lite-dev \
      tflite-vx-delegate-imx \
      imx-gpu-viv-wayland-dev \
    && rm -rf /var/lib/apt/lists/*
