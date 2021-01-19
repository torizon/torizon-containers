ARG IMAGE_ARCH=

FROM artifactory-horw.int.toradex.com/dockerhub-proxy-horw/debian:bullseye-slim AS build

ARG DOWNLOAD_URL=

# Make sure we don't get notifications we can't answer during building.
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get install -y \
    --no-install-recommends --no-install-suggests \
    curl \
    ca-certificates \
    && apt-get clean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L -o dotnet-runtime.tar.gz $DOWNLOAD_URL

RUN mkdir dotnet

WORKDIR /dotnet

RUN tar -xvzf ../dotnet-runtime.tar.gz

FROM --platform=$IMAGE_ARCH artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/debian:2-bullseye

ENV DOTNET_ROOT=/dotnet
ENV PATH=$PATH:/dotnet

RUN apt-get update && apt-get install -y \
    --no-install-recommends --no-install-suggests \
    libicu67 \
    libssl1.1 \
    && apt-get clean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /dotnet /dotnet
