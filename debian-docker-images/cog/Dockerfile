ARG IMAGE_ARCH=linux/arm
# For iMX8 use:
# ARG IMAGE_ARCH=linux/arm64

ARG BASE_IMAGE=wayland-base
# For iMX8 with Vivante support (required to run Cog with hardware acceleration support) use:
# ARG BASE_IMAGE=wayland-base-vivante

ARG IMAGE_TAG=3

FROM --platform=$IMAGE_ARCH torizon/$BASE_IMAGE:$IMAGE_TAG

# Install Cog
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends cog shared-mime-info && \
    apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

COPY start-cog.sh /usr/bin/start-browser

USER torizon

ENV DISPLAY=:0

ENTRYPOINT ["/usr/bin/start-browser"]
CMD ["http://www.toradex.com"]
