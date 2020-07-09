FROM debian:buster-slim

ARG ARCH_ARG=armhf
ARG CROSS_COMPILE_ARG="arm-linux-gnueabihf"

ENV CROSS_COMPILE=${CROSS_COMPILE_ARG}-
ENV PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/lib/${CROSS_COMPILE_ARG}/pkgconfig

# Make sure we don't get notifications we can't answer during building.
ENV DEBIAN_FRONTEND="noninteractive"

RUN dpkg --add-architecture ${ARCH_ARG}

# Adds Toradex feeds and gpg key
# (same key is used in https://gitlab.int.toradex.com/rd/torizon-core-containers/debian-docker-image
# if you change the key or feed configuration, please check the other repo!)
ADD http://feeds.toradex.com/debian/toradex-debian-repo.pub /etc/apt/trusted.gpg.d/toradex-buster.asc

# add toradex debian feed
RUN chmod 644 /etc/apt/trusted.gpg.d/toradex-buster.asc ;\
    echo "deb http://feeds.toradex.com/debian/testing/ buster main" >> /etc/apt/sources.list ; \
    echo "Package: *\nPin: origin feeds.toradex.com\nPin-Priority: 900" > /etc/apt/preferences.d/toradex-feeds ;

# Install required packages
RUN apt-get -q -y update \
    && apt-get -q -y install \
    git \
    openssl \
    crossbuild-essential-${ARCH_ARG} \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Add torizon user to the container
RUN mkdir /home/torizon
RUN addgroup torizon
RUN useradd -s /bin/bash -d /home/torizon -g torizon -G sudo -p $(echo "torizon" | openssl passwd -1 -stdin) torizon
RUN chown -R torizon /home/torizon
