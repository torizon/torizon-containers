# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS build

ARG DOTNET_RUNTIME
ARG DOTNET_SEMVER
ARG TARGETARCH

RUN test -n "$DOTNET_RUNTIME" || (echo "DOTNET_RUNTIME  not set" && false)
RUN test -n "$DOTNET_SEMVER" || (echo "DOTNET_SEMVER  not set" && false)
RUN test -n "$TARGETARCH" || (echo "TARGETARCH  not set" && false)

RUN wget https://dot.net/v1/dotnet-install.sh \
    && chmod a+x /dotnet-install.sh \
    && mkdir dotnet

WORKDIR /dotnet

RUN /dotnet-install.sh --install-dir /dotnet \
        --runtime ${DOTNET_RUNTIME} \
        --version ${DOTNET_SEMVER} \
        --os linux \
        --architecture ${TARGETARCH} \
        --no-path

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG

ENV DOTNET_ROOT=/dotnet
ENV PATH=$PATH:/dotnet

RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        libicu72 \
        libssl3 \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /dotnet /dotnet
