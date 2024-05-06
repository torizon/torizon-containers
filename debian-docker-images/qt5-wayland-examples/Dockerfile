# Copyright (c) 2019-2023 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME=qt5-wayland
# For arm64v8 with Vivante use:
# ARG BASE_IMAGE_NAME=qt5-wayland-vivante
ARG IMAGE_TAG=3
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    qtbase5-examples qtdeclarative5-examples \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*
