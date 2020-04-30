FROM debian:buster-slim

ARG ARCH_ARG=armhf
ARG CROSS_COMPILE_ARG="arm-linux-gnueabihf-"

ENV CROSS_COMPILE=${CROSS_COMPILE_ARG}

# Make sure we don't get notifications we can't answer during building.
ENV DEBIAN_FRONTEND="noninteractive"

RUN dpkg --add-architecture ${ARCH_ARG}

# Install required packages
RUN apt-get -q -y update \
    && apt-get -q -y install \
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
