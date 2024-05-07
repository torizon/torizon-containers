# Copyright (c) 2019-2023 Toradex AG
# SPDX-License-Identifier: MIT

ARG DEBIAN_POINT_RELEASE
ARG REGISTRY_PROXY

FROM $REGISTRY_PROXY/debian:$DEBIAN_POINT_RELEASE

RUN apt update \
    && apt install -y --no-install-recommends \
        iperf3 \
        iproute2 \
        iputils-ping \
        rt-tests \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY stress-tests.sh /stress-tests.sh

CMD ["/stress-tests.sh"]
