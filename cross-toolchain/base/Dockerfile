# Copyright (c) 2019-2023 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG

ARG CROSS_TARGET_ARCH
ARG CROSS_COMPILER

RUN test -n "$CROSS_TARGET_ARCH" || (echo "CROSS_TARGET_ARCH  not set" && false)
RUN test -n "$CROSS_COMPILER" || (echo "CROSS_COMPILER  not set" && false)

ENV CROSS_COMPILE=${CROSS_COMPILER}-
ENV PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib/${CROSS_COMPILER}/pkgconfig

ENV DEBIAN_FRONTEND="noninteractive"

RUN dpkg --add-architecture ${CROSS_TARGET_ARCH}

RUN apt-get -q -y update \
    && apt-get -q -y install --no-install-recommends \
        ca-certificates \
        gpg \
        wget \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get -q -y update \
    && apt-get -q -y upgrade \
    && apt-get -q -y install --no-install-recommends \
        git \
        openssl \
        wget \
        curl \
        crossbuild-essential-${CROSS_TARGET_ARCH} \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

