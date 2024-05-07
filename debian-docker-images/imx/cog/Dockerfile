ARG BASE_IMAGE_NAME=wayland-base
# For iMX8 with Vivante userspace drivers use:
# ARG BASE_IMAGE_NAME=wayland-base-vivante

ARG IMAGE_TAG

ARG REGISTRY
ARG REGISTRY_NAMESPACE
FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG AS base

RUN apt-get -y update && \
    apt-get install -y --no-install-recommends cog shared-mime-info && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY start-cog.sh /usr/bin/start-browser

USER torizon

ENV DISPLAY=:0

ENTRYPOINT ["/usr/bin/start-browser"]
CMD ["http://www.toradex.com"]
