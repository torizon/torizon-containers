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
    crossbuild-essential-${ARCH_ARG} \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*
