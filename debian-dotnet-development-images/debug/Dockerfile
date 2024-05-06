# Copyright (c) 2019-2023 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG REGISTRY
ARG REGISTRY_NAMESPACE
ARG DEBIAN_POINT_RELEASE
ARG IMAGE_TAG

FROM $REGISTRY/debian:$DEBIAN_POINT_RELEASE AS build

RUN apt-get update && apt-get install -y \
    --no-install-recommends --no-install-suggests \
    ca-certificates \
    curl \
    && apt-get clean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ARG DOTNET_DEBUGGER_RELEASE

RUN curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v ${DOTNET_DEBUGGER_RELEASE} -l /vsdbg

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG

COPY --from=build /vsdbg /vsdbg
