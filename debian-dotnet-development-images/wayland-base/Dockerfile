# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_NAME_WAYLAND
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/${BASE_IMAGE_NAME}:${IMAGE_TAG} AS dotnet

FROM $REGISTRY/$REGISTRY_NAMESPACE/${BASE_IMAGE_NAME_WAYLAND}:${IMAGE_TAG} AS base

ENV DOTNET_ROOT=/dotnet
ENV PATH=$PATH:/dotnet

COPY --from=dotnet /dotnet /dotnet

RUN printf "{\n  \"device\": \"/dev/dri/card1\",\n  \"outputs\": [ { \"name\": \"HDMI1\" } ],\n  \"hwcursor\": false\n}" > /etc/kms-imx6.conf \
    && printf "{\n  \"hwcursor\": false\n}" > /etc/kms-imx8.conf \
    && ln -s /etc/kms-imx8.conf /etc/kms-imx7.conf
