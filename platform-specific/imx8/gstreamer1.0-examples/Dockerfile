# Copyright (c) 2026 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

COPY decode.sh /usr/bin/gstreamer-decode
COPY encode.sh /usr/bin/gstreamer-encode
COPY stream.sh /usr/bin/gstreamer-stream

COPY assets/test-h264.mp4 \
    /usr/share/gstreamer1.0-examples/test-h264.mp4
COPY assets/test-h264.h264 \
    /usr/share/gstreamer1.0-examples/test-h264.h264

RUN chmod +x \
    /usr/bin/gstreamer-decode \
    /usr/bin/gstreamer-encode \
    /usr/bin/gstreamer-stream


CMD ["/bin/bash"]