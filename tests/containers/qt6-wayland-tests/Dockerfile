# Copyright (c) 2019-2025 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG BUILD_BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BUILD_BASE_IMAGE_NAME:$IMAGE_TAG as build

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libqt6opengl6-dev \
        qt6-base-dev \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY src /src

WORKDIR /src

RUN cmake . && make

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG

COPY --from=build /src/contextinfo /usr/local/bin/
