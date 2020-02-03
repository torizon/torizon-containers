ARG IMAGE_ARCH=

FROM debian:buster-slim AS build

ARG DOWNLOAD_URL=

# Make sure we don't get notifications we can't answer during building.
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get install -y \
    --no-install-recommends --no-install-suggests \
    wget \
    ca-certificates \
    && apt-get clean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O dotnet-runtime.tar.gz $DOWNLOAD_URL

RUN mkdir dotnet

WORKDIR /dotnet

RUN tar -xvzf ../dotnet-runtime.tar.gz

FROM torizon/$IMAGE_ARCH-debian-base:buster

ENV DOTNET_ROOT=/dotnet
ENV PATH=$PATH:/dotnet

RUN apt-get update && apt-get install -y \
    --no-install-recommends --no-install-suggests \
    libicu63 \
    libssl1.1 \
    && apt-get clean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /dotnet /dotnet
