# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG as build

# Need to include imx-gpu-viv-wayland-dev to get NXP downstream headers for
# graphics libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        imx-gpu-viv-wayland-dev \
        libgtk-3-dev \
        pkgconf \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY src /src

WORKDIR /src

RUN make

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG

COPY --from=build /src/simple-gtk3-test /usr/local/bin/

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        # Note that gtk-3-examples is not necessary to compile
        # gtk3 applications. This package is solely used
        # for testing. Remove the installation of this package
        # if you're using this Dockerfile as a starting point.
        gtk-3-examples \
        libgtk-3-0 \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

USER torizon

CMD simple-gtk3-test
