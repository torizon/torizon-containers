ARG BASE_NAME=

FROM debian:buster-slim AS build

RUN apt-get update && apt-get install -y \
    --no-install-recommends --no-install-suggests \
    ca-certificates \
    wget \
    unzip \
    && apt-get clean && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ARG DEBUGGER_RELEASE=
ARG DEBUGGER_ARCH=

RUN wget -O /vsdbg.zip https://vsdebugger.azureedge.net/vsdbg-$DEBUGGER_RELEASE/vsdbg-$DEBUGGER_ARCH.zip

RUN mkdir /vsdbg

WORKDIR /vsdbg

RUN unzip /vsdbg.zip

RUN chmod a+x /vsdbg/vsdbg


FROM torizon/$BASE_NAME:buster

COPY --from=build /vsdbg /vsdbg
