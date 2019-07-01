FROM arm64v8/debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    ca-certificates \
    netbase \
    && rm -rf /var/lib/apt/lists/*


RUN apt-get update && apt-get install -y --no-install-recommends \
    git gnupg2 dpkg-dev \
    debconf fakeroot \
    debhelper dh-make \
    git-buildpackage debootstrap pbuilder \
    wget procps vim \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    execstack dh-python libpng16-16 \
    && rm -rf /var/lib/apt/lists/*

# Use UID 1000 to build packages
RUN useradd debian -G tty,sudo,dialout,users,plugdev -u 1000

RUN git config --global user.name "Stefan Agner"
RUN git config --global user.email "stefan.agner@toradex.com"

ENV LC_ALL C.UTF-8

