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
    libtool pkg-config \
    git-buildpackage debootstrap pbuilder \
    wget procps vim \
    bash-completion \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    aptly \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    execstack dh-python libpng16-16 \
    && rm -rf /var/lib/apt/lists/*

# Use UID 1000 to build packages
RUN useradd debian -u 1000 -m -G tty,sudo,dialout,users,plugdev

# Copy sudoers with NOPASSWD to avoid "sudo: no tty present and no askpass
# program specified" issue
COPY sudoers /etc/sudoers

ENV LC_ALL C.UTF-8

