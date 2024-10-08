# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG DEBIAN_POINT_RELEASE
ARG REGISTRY_PROXY

FROM $REGISTRY_PROXY/debian:$DEBIAN_POINT_RELEASE

RUN apt update \
    && apt install -y --no-install-recommends \
        gnuplot \
        rt-tests \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY rt-tests.sh /rt-tests.sh

CMD ["/rt-tests.sh"]
