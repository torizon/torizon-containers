# Copyright (c) 2026 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base


RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        meson \
        ninja-build \
        pkgconf \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-bad1.0-dev \
        imx-gst1.0-plugin-dev \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*