ARG IMAGE_ARCH=linux/arm
# For arm64 use:
# ARG IMAGE_ARCH=linux/arm64

ARG BASE_IMAGE=wayland-base
# For iMX8 use:
# ARG BASE_IMAGE=wayland-base-vivante

ARG IMAGE_TAG=3

FROM --platform=$IMAGE_ARCH torizon/$BASE_IMAGE:$IMAGE_TAG

# Install Chromium
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends chromium chromium-sandbox && \
    apt-get clean && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

# Unpack the virtual keyboard extension
ADD chrome-virtual-keyboard.tar.gz /chrome-extensions

COPY start-chromium.sh /usr/bin/start-browser

USER torizon

ENV DISPLAY=:0

ENTRYPOINT ["/usr/bin/start-browser"]
CMD ["http://www.toradex.com"]
