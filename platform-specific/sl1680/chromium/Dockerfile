# Copyright (c) 2019-2025 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

# Here we'll install a specific version of chromium
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends \
        chromium-common=131.0.6778.139-1+toradex1 \
        chromium=131.0.6778.139-1+toradex1 \
        chromium-sandbox=131.0.6778.139-1+toradex1 && \
    apt-get clean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# To make this version of chromium work, we need to get rid of vulkan libraries
RUN rm -rf /usr/lib/aarch64-linux-gnu/libvulkan*

COPY start-chromium.sh /usr/bin/start-browser

USER torizon

ENV DISPLAY=:0

ENTRYPOINT ["/usr/bin/start-browser"]
