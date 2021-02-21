ARG IMAGE_ARCH=
ARG BASE_NAME=
ARG BASE_TAG=
ARG BASE_TAG_WAYLAND=
ARG BASE_NAME_WAYLAND=

FROM artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/$BASE_NAME:$BASE_TAG AS dotnet

FROM --platform=$IMAGE_ARCH torizon/$BASE_NAME_WAYLAND:$BASE_TAG_WAYLAND AS base

ENV DOTNET_ROOT=/dotnet
ENV PATH=$PATH:/dotnet

COPY --from=dotnet /dotnet /dotnet

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    apt-utils \
    && apt-get -y upgrade \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# Debian Bullseye has higher versions of some same packages than the Toradex feed.
# Force install of Bullseye versions of these packages in order to keep the container equivalent for 32 and 64 bits architectures.
RUN HOLD_PKGS='libdrm-common libdrm-amdgpu1 libdrm2' \
    && apt-get -y update \
    && for P in $HOLD_PKGS ; do \
        echo ${P}=$(apt-cache show $P | sed -r -e '/^Version:/!d' -e 's/.* //' -e '/toradex/d' -e 'q') ; \
    done | xargs -r apt-get install -y --no-install-recommends \
    && apt-mark hold $HOLD_PKGS \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# install .net uno platform dependencies
RUN apt-get -y update && apt-get install -y --no-install-recommends \
	libicu67 \
    curl \
    gettext \
    apt-transport-https \
    libx11-6 \
	libunwind8 icu-devtools \
	libfontconfig1 \
	libgtk-3-0 libgtk-3-bin libgtk-3-common \
	libdrm2 \
	libinput10 \
    libssl1.1 \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

# fix mime types
RUN apt-get -y update && apt-get --reinstall install shared-mime-info \
	&& apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN printf "{\n  \"device\": \"/dev/dri/card1\",\n  \"outputs\": [ { \"name\": \"HDMI1\" } ],\n  \"hwcursor\": false\n}" > /etc/kms-imx6.conf
RUN printf "{\n  \"hwcursor\": false\n}" > /etc/kms-imx8.conf
RUN ln -s /etc/kms-imx8.conf /etc/kms-imx7.conf
