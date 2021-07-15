ARG DEBIAN_BASE_IMAGE=bullseye-20210408-slim

FROM debian:$DEBIAN_BASE_IMAGE

ARG ARCH_ARG=armhf
# For arm64 use:
# ARG ARCH_ARG=arm64
ARG CROSS_COMPILE_ARG="arm-linux-gnueabihf"
# For arm64 use:
# ARG CROSS_COMPILE_ARG="aarch64-linux-gnu"
ARG DEBIAN_SNAPSHOT=20210408T000000Z
ARG TORADEX_SNAPSHOT=20210705T084957Z
ARG USE_TORADEX_SNAPSHOT=1
ARG TORADEX_FEED_BASE_URL="https://feeds.toradex.com/debian"

ENV CROSS_COMPILE=${CROSS_COMPILE_ARG}-
ENV PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib/${CROSS_COMPILE_ARG}/pkgconfig

# Make sure we don't get notifications we can't answer during building.
ENV DEBIAN_FRONTEND="noninteractive"

# Debian Bullseye is not yet a stable distribution at the moment of this writing;
# therefore its package list may change in incompatible ways with Torizon software.
# Let's lock Torizon containers to a known snapshot of the Bullseye package list as a workaround.
ARG DEBIAN_SNAPSHOT
ARG TORADEX_SNAPSHOT
RUN echo "deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/$DEBIAN_SNAPSHOT bullseye main\n\
    deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/$DEBIAN_SNAPSHOT bullseye-updates main\n\
    deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/$DEBIAN_SNAPSHOT bullseye-security main" >/etc/apt/sources.list

# Enable multiarch
RUN dpkg --add-architecture ${ARCH_ARG}

# Enable the Toradex package feed
# (same key is used in https://gitlab.int.toradex.com/rd/torizon-core-containers/debian-docker-image
# if you change the key or feed configuration, please check the other repo!)
RUN apt-get -q -y update \
    && apt-get -q -y install \
    ca-certificates \
    wget \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*
ADD ${TORADEX_FEED_BASE_URL}/toradex-debian-repo.gpg /etc/apt/trusted.gpg.d/
RUN chmod 0644 /etc/apt/trusted.gpg.d/toradex-debian-repo.gpg \
    && if [ "${USE_TORADEX_SNAPSHOT}" = 1 ]; then \
           TORADEX_FEED_URL="${TORADEX_FEED_BASE_URL}/snapshots/${TORADEX_SNAPSHOT}"; \
       else \
           TORADEX_FEED_URL="${TORADEX_FEED_BASE_URL}"; \
       fi \
    && echo "deb ${TORADEX_FEED_URL} testing main non-free" >>/etc/apt/sources.list \
    && echo "Package: *\nPin: origin feeds.toradex.com\nPin-Priority: 900" > /etc/apt/preferences.d/toradex-feeds

# Upgrade & install required packages

RUN wget http://snapshot.debian.org/archive/debian/20210408T000000Z/pool/main/g/gcc-10-cross/cpp-10-${CROSS_COMPILE_ARG}_10.2.1-6cross1_amd64.deb && \
    wget http://snapshot.debian.org/archive/debian/20210408T000000Z/pool/main/g/gcc-10-cross/gcc-10-${CROSS_COMPILE_ARG}_10.2.1-6cross1_amd64.deb && \
    wget http://snapshot.debian.org/archive/debian/20210408T000000Z/pool/main/g/gcc-10-cross/g++-10-${CROSS_COMPILE_ARG}_10.2.1-6cross1_amd64.deb && \
    apt-get -q -y update \
    && apt-get -q -y upgrade \
    && apt-get -q -y -o Acquire::Http::Dl-limit=1000 install -f ./cpp-10-${CROSS_COMPILE_ARG}_10.2.1-6cross1_amd64.deb ./gcc-10-${CROSS_COMPILE_ARG}_10.2.1-6cross1_amd64.deb ./g++-10-${CROSS_COMPILE_ARG}_10.2.1-6cross1_amd64.deb \
    git \
    openssl \
    crossbuild-essential-${ARCH_ARG} \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && rm *.deb

# Add torizon user to the container
RUN mkdir /home/torizon
RUN addgroup torizon
RUN useradd -s /bin/bash -d /home/torizon -g torizon -G sudo -p $(echo "torizon" | openssl passwd -1 -stdin) torizon
RUN chown -R torizon /home/torizon
