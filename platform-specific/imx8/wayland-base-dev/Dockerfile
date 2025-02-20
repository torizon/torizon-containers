# Copyright (c) 2019-2025 Toradex AG
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
        imx-gpu-viv-wayland-dev \
        libg2d-viv-dev \
        libgles-dev \
        pkgconf \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*
