ARG BASE_IMAGE_NAME
ARG BUILD_BASE_IMAGE_NAME
ARG IMAGE_TAG
ARG REGISTRY
ARG REGISTRY_NAMESPACE

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BUILD_BASE_IMAGE_NAME:$IMAGE_TAG as build

ARG DEBIAN_FRONTEND=noninteractive

RUN wget -O- https://cdn.qt.io/debian/keys/qt-company-debian-repo.gpg \
    | gpg --dearmor \
    | tee /usr/share/keyrings/qt-company-debian-repo.gpg

RUN echo "Types: deb\n\
URIs: https://debian-packages.qt.io/debian/enterprise/qt-6.8.2-arm64-test-gles\n\
Suites: tqtc-bookworm\n\
Components: main\n\
Signed-By: /usr/share/keyrings/qt-company-debian-repo.gpg" > /etc/apt/sources.list.d/qt-company.sources

RUN --mount=type=secret,id=qt-feed-auth,target=/etc/apt/auth.conf.d/qt-feed-auth.conf \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        qt6.8.2-full-dev \
        qt6.8.2-declarative-dev \
    && rm -rf /opt/qt-6.8.2/aarch64-linux-gnu/plugins/platforms/libqxcb* \
              /opt/qt-6.8.2/aarch64-linux-gnu/plugins/xcbglintegrations \
              /opt/qt-6.8.2/aarch64-linux-gnu/lib/cmake/Qt6Gui/Qt6QXcb*Plugin* \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ADD https://github.com/qt/qtdoc.git#6.8.2 /qtdoc

WORKDIR /qtdoc/examples/demos

ENV QT_QPA_PLATFORM=wayland

RUN for example in coffee robotarm thermostat; do \
        cd $example \
        && /opt/qt-6.8.2/aarch64-linux-gnu/bin/qt-cmake . \
        && make \
        && cd .. ; \
    done

FROM $REGISTRY/$REGISTRY_NAMESPACE/$BASE_IMAGE_NAME:$IMAGE_TAG

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=build /qtdoc/examples/demos/coffee/coffeemachine /usr/local/bin/
COPY --from=build /qtdoc/examples/demos/robotarm/RobotArmApp /usr/local/bin/
COPY --from=build /qtdoc/examples/demos/thermostat/ThermostatApp /usr/local/bin/
COPY --from=build /etc/apt/sources.list.d/qt-company.sources /etc/apt/sources.list.d/qt-company.sources
COPY --from=build /usr/share/keyrings/qt-company-debian-repo.gpg /usr/share/keyrings/qt-company-debian-repo.gpg

RUN --mount=type=secret,id=qt-feed-auth,target=/etc/apt/auth.conf.d/qt-feed-auth.conf \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        boot2qt-launcher \
        qt6.8.2-full \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

COPY examples /usr/share/examples

CMD /opt/b2qt-demolauncher/qtlauncher
