ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        glmark2-es2-wayland \
        mangohud \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

CMD ["mangohud", "--dlsym", "glmark2-es2-wayland", "--run-forever"]