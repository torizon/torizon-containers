# Copyright (c) 2019-2023 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG REGISTRY
ARG REGISTRY_NAMESPACE
ARG IMAGE_TAG
ARG DOTNET_DEBUGGER_VER

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS build

ARG DOTNET_DEBUGGER_VER

RUN test -n "$DOTNET_DEBUGGER_VER" || (echo "DOTNET_DEBUGGER_VER  not set" && false)

RUN apt-get update && apt-get install -y \
    --no-install-recommends --no-install-suggests \
    ca-certificates \
    curl \
    && apt-get clean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v ${DOTNET_DEBUGGER_VER} -l /vsdbg

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG

COPY --from=build /vsdbg /vsdbg
