# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME=weston
ARG IMAGE_TAG=3
ARG REGISTRY=torizon
FROM $REGISTRY/torizon/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

COPY entry.sh /usr/bin/
RUN mkdir -p /etc/xdg/weston/
COPY weston.ini /etc/xdg/weston/
COPY save-calibration.sh /usr/bin/

USER root

ENTRYPOINT ["/usr/bin/entry.sh"]
