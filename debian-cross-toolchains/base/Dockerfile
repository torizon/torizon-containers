# Copyright (c) 2019-2023 Toradex AG
# SPDX-License-Identifier: MIT

ARG DEBIAN_POINT_RELEASE
ARG REGISTRY_PROXY

FROM $REGISTRY_PROXY/debian:$DEBIAN_POINT_RELEASE

ARG CROSS_TARGET_ARCH
ARG CROSS_COMPILER
ARG TORADEX_SNAPSHOT
ARG TORADEX_FEED_BASE_URL="https://feeds1.toradex.com/debian"

RUN test -n "$CROSS_TARGET_ARCH" || (echo "CROSS_TARGET_ARCH  not set" && false)
RUN test -n "$CROSS_COMPILER" || (echo "CROSS_COMPILER  not set" && false)
RUN test -n "$TORADEX_SNAPSHOT" || (echo "TORADEX_SNAPSHOT  not set" && false)
RUN test -n "$TORADEX_FEED_BASE_URL" || (echo "TORADEX_FEED_BASE_URL  not set" && false)

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

RUN wget -O- ${TORADEX_FEED_BASE_URL}/toradex-debian-repo-19092023.gpg \
    | gpg --dearmor \
    | tee /usr/share/keyrings/toradex-debian-repo.gpg

# Debian Bookworm has higher versions of some same packages than the Toradex feed.
# Force install Bookworm versions of these packages in order to keep the container equivalent for 32 and 64 bits architectures.
# This packages are necessary for the Qt6 C++ templates of the IDE Extension V2 (ApolloX)
RUN HOLD_PKGS='libdrm-common libdrm-amdgpu1 libdrm2' \
    && apt-get -y update \
    && for P in $HOLD_PKGS ; do \
        echo ${P}=$(apt-cache show $P | sed -r -e '/^Version:/!d' -e 's/.* //' -e '/toradex/d' -e 'q') ; \
    done | xargs -r apt-get install -y --no-install-recommends \
    && apt-mark hold $HOLD_PKGS \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

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

COPY users-groups.sh /users-groups.sh
RUN ./users-groups.sh \
    && rm users-groups.sh

