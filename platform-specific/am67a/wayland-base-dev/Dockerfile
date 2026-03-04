# Copyright (c) 2019-2026 Toradex AG
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
        libd3dadapter9-mesa-dev \
        libegl1-mesa-dev \
        libgbm-dev \
        libgl1-mesa-dev \
        libgles-dev \
        libgles2-mesa-dev \
        libosmesa6-dev \
        mesa-common-dev \
        pkgconf \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*
