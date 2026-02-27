ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      ca-certificates \
      libtensorflow-lite-dev2.15.0-1 \
      tim-vx-dev \
      synap-runtime-dev \
      synap-prebuilts-libs-dev \
      tflite-vx-delegate \
      synap-vxk \
    && rm -rf /var/lib/apt/lists/*
