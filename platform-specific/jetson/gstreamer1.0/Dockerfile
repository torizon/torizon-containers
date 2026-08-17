# Copyright (c) 2026 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-tools \
        nvidia-l4t-cuda-nvgpu \
        nvidia-l4t-cuda-openrm \
        nvidia-l4t-gstreamer \
        nvidia-l4t-multimedia \
        nvidia-l4t-multimedia-nvgpu \
        nvidia-l4t-multimedia-openrm \
        nvidia-l4t-multimedia-utils \
    && dpkg -L nvidia-l4t-init bridge-utils nvme-cli 2>/dev/null \
        | xargs -r rm -f 2>/dev/null || true \
    && rm -rf /usr/share/doc/nvidia-l4t-* \
    && rm -f /etc/dpkg/dpkg.cfg.d/include-docs \
    && ldconfig \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY entry.sh /usr/bin/entry.sh

RUN chmod +x /usr/bin/entry.sh

ENTRYPOINT ["/usr/bin/entry.sh"]

CMD ["/bin/bash"]
