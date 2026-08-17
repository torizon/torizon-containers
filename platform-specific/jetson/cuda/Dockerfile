# Copyright (c) 2019-2026 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS pruner

ARG DEBIAN_FRONTEND=noninteractive
ARG CUDA_VERSION=13.2
ARG CUDA_PKG_VERSION=13-2
ARG CUDA_MAJOR=13
ARG CUDNN_MAJOR=9
ARG CUDA_ARCHS

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    cuda-nvprune-${CUDA_PKG_VERSION} \
    cuda-cudart-${CUDA_PKG_VERSION} \
    cuda-nvrtc-${CUDA_PKG_VERSION} \
    libnvjitlink-${CUDA_PKG_VERSION} \
    libcublas-${CUDA_PKG_VERSION} \
    libcufft-${CUDA_PKG_VERSION} \
    libcurand-${CUDA_PKG_VERSION} \
    libcusolver-${CUDA_PKG_VERSION} \
    libcusparse-${CUDA_PKG_VERSION} \
    libcudnn${CUDNN_MAJOR}-cuda-${CUDA_MAJOR}

RUN set -eu; \
    GENCODE=""; \
    for a in ${CUDA_ARCHS}; do GENCODE="${GENCODE} -gencode=arch=compute_${a#sm_},code=${a}"; done; \
    NVPRUNE="/usr/local/cuda-${CUDA_VERSION}/bin/nvprune"; \
    for f in $(find /usr/local/cuda-${CUDA_VERSION}/targets/sbsa-linux/lib -maxdepth 1 -type f -name '*.so.*'; \
               find /usr/lib/aarch64-linux-gnu -maxdepth 1 -type f -name 'libcudnn*.so.*'); do \
        if "$NVPRUNE" ${GENCODE} "$f" -o "$f.pruned" 2>/dev/null; then \
            mv "$f.pruned" "$f"; \
        else \
            rm -f "$f.pruned"; \
        fi; \
    done; \
    rm -rf "/usr/local/cuda-${CUDA_VERSION}/bin"

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG CUDA_VERSION=13.2
ARG L4T_DRIVER_VARIANT

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    nvidia-l4t-cuda \
    nvidia-l4t-cuda-${L4T_DRIVER_VARIANT} \
    nvidia-l4t-3d-core \
    zlib1g \
    && { dpkg -L nvidia-l4t-3d-core \
        | grep -vE 'libnvidia-(ptxjitcompiler|nvvm)\.so' \
        | xargs -r rm -f 2>/dev/null || true; } \
    && { dpkg -L nvidia-l4t-init nvidia-l4t-libvulkan nvidia-l4t-wayland nvidia-l4t-x11 \
        bridge-utils nvme-cli \
        | xargs -r rm -f 2>/dev/null || true; } \
    && rm -rf /usr/lib/xorg /etc/X11 \
        /usr/share/doc/nvidia-l4t-* \
    && rm -f /etc/dpkg/dpkg.cfg.d/include-docs \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY --from=pruner /usr/local/cuda-${CUDA_VERSION} /usr/local/cuda-${CUDA_VERSION}
COPY --from=pruner /usr/lib/aarch64-linux-gnu/libcudnn*.so.* /usr/lib/aarch64-linux-gnu/

RUN ln -sfn /usr/local/cuda-${CUDA_VERSION} /usr/local/cuda \
    && echo /usr/local/cuda/lib64 >/etc/ld.so.conf.d/cuda.conf \
    && echo /opt/nvidia/l4t-gpu-libs/${L4T_DRIVER_VARIANT} \
        >/etc/ld.so.conf.d/nvidia-l4t-cuda.conf \
    && ldconfig

ENV CUDA_HOME="/usr/local/cuda"
ENV PATH="/usr/local/cuda/bin:${PATH}"

CMD ["/bin/bash"]
