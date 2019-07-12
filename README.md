# Debian package development container

Container with packages for package building preinstalled.

## Getting Started

This container is prepared to build Debian packages for i.MX devices to
integrate the NXP downstream graphics stack. It is an `aarch64` container which
allows to build the Debian packages native (either via Qemu user emulation on
`x86_64` or on an actual native device).

The idea is to bind mount the directory containing the meta data (source git
repository) into the container.

Make sure that your user id on your host is **1000** (check using `id -u`). If
not, make sure to edit the Dockerfile and set the user id to your main users
user id.

Build the container using:

```
docker build -t debian-package-devel .
```


Start the container using the following command:
```
docker run --user debian -it -v /home/../../debian/:/home/debian/pkg-devel \
       debian-package-devel /bin/bash
```

## Preparing Package Metadata

Reuse existing package metadata.

### Update Changelog

Update changelog manually or using tooling (TODO: describe).

#### Versioning

We should make sure that our package has a higher version number than the
version NXP (/Toradex) is building on. E.g. if we base on libdrm 2.4.91, and
base our Debian package on the Debian release `2.4.91-2~bpo9+1`, we should use
`2.4.91-2+toradex1` to make sure it takes precedence (the `+` sign makes sure
that the Toradex package takes precedence. However, we should not come up with
an unrealistic high number (e.g. by use toradex-2.4.91) since that would likely
break version requirements of other packages (e.g. if somebody needs libdrm
no later than say 2.4.94, that would not work anymore). To make sure that apt
does not update packages despite newer versions available from the Debian main
repository, we should make use of the pinning functionality (apt-pinning).

