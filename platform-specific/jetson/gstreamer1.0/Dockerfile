# Copyright (c) 2026 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG CUDA_VERSION=13.2
ARG CUDA_PKG_VERSION=13-2
ARG CUDA_MAJOR=13
ARG L4T_DRIVER_VARIANT

# The Ubuntu-built L4T packages declare libpcre3, which Debian dropped in
# favour of PCRE2. No shipped binary links libpcre.so.3, so satisfy it locally.
RUN mkdir -p /tmp/pcre3-compat/DEBIAN \
    && printf 'Package: nvidia-l4t-pcre3-compat\nVersion: 1\nArchitecture: all\nMaintainer: Toradex AG <support@toradex.com>\nProvides: libpcre3\nDescription: Satisfies the stale libpcre3 dependency of the L4T packages\n' \
        > /tmp/pcre3-compat/DEBIAN/control \
    && dpkg-deb --build /tmp/pcre3-compat /tmp/pcre3-compat.deb \
    && dpkg -i /tmp/pcre3-compat.deb \
    && rm -rf /tmp/pcre3-compat /tmp/pcre3-compat.deb

RUN apt-get -y update \
    && apt-get install -y --no-install-recommends \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-tools \
        kmod \
        libnvjpeg-${CUDA_PKG_VERSION} \
        nvidia-l4t-cuda \
        nvidia-l4t-cuda-${L4T_DRIVER_VARIANT} \
        nvidia-l4t-gstreamer \
        nvidia-l4t-multimedia \
        nvidia-l4t-multimedia-${L4T_DRIVER_VARIANT} \
        nvidia-l4t-multimedia-utils \
    && echo /opt/nvidia/l4t-gpu-libs/${L4T_DRIVER_VARIANT} \
        >/etc/ld.so.conf.d/nvidia-l4t-cuda.conf \
    && echo /usr/local/cuda-${CUDA_VERSION}/targets/sbsa-linux/lib \
        >/etc/ld.so.conf.d/cuda.conf \
    # nvjpegdec dlopen()s the unversioned soname, which only the -dev package ships.
    && ln -sf libnvjpeg.so.${CUDA_MAJOR} \
        /usr/local/cuda-${CUDA_VERSION}/targets/sbsa-linux/lib/libnvjpeg.so \
    && { dpkg -L nvidia-l4t-init bridge-utils nvme-cli 2>/dev/null \
        | xargs -r rm -f 2>/dev/null || true; } \
    # Don't need these
    && rm -f /usr/lib/aarch64-linux-gnu/gstreamer-1.0/libgstnvarguscamerasrc.so \
        /usr/lib/aarch64-linux-gnu/gstreamer-1.0/libgstnvegltransform.so \
    && rm -rf /usr/share/doc/nvidia-l4t-* \
    && rm -f /etc/dpkg/dpkg.cfg.d/include-docs \
    && ldconfig \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
