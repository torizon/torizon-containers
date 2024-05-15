# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE
FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

## Un-comment if you want to run it with the
# integrated puppeteer chromium distribution
# RUN apt-get update && apt-get install -y libnss3 \
# libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
# libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 \
# libxfixes3 libxrandr2 libgbm1 libasound2

USER root

RUN apt-get update && apt-get install -y nodejs npm

USER torizon

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install
COPY . .

ENTRYPOINT ["/usr/bin/npm"]
CMD [ "test" ]
