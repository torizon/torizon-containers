# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME=wayland-base
ARG REGISTRY
ARG IMAGE_TAG=3

FROM $REGISTRY/torizon/$BASE_IMAGE_NAME:$IMAGE_TAG

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends cog && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY start-cog.sh /usr/bin/start-browser

USER torizon

ENV DISPLAY=:0

ENTRYPOINT ["/usr/bin/start-browser"]
CMD ["http://www.toradex.com"]
