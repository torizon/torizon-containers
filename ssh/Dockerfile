ARG ARCH_ARG=armhf

FROM torizon/debian-cross-toolchain-$ARCH_ARG:buster


# SSH
EXPOSE 22

# Install required packages
RUN apt-get -q -y update \
    && apt-get -q -y install \
    openssh-server \
    ssh \
    rsync \
    zip \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# create folders needed for the different components
RUN mkdir /var/run/sshd && mkdir /home/build && mkdir /home/build/sysroot

# configures SSH access to the container and sets environment by default
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN useradd -s /bin/bash -d /home/build -g root -G sudo,ssh -p $(echo "build" | openssl passwd -1 -stdin) build
RUN chown -R build /home/build

CMD ["/usr/sbin/sshd", "-D"]
