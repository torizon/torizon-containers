# Debian package development container

Container with packages for package building preinstalled.

## Preparing Container

This container is prepared to build Debian packages for i.MX devices to
integrate the NXP downstream graphics stack. It is an `aarch64` container which
allows to build the Debian packages native (either via Qemu user emulation on
`x86_64` or on an actual native device).

The idea is to bind mount the directory containing the meta data (source git
repository as well as maintainers GPG keys) into the container.

Make sure that your user id on your host is **1000** (check using `id -u`). If
not, make sure to edit the Dockerfile and set the user id to your main users
user id.

Build the container using:

```
docker build -t debian-package-devel .
```

Prepare a folder to store the gnupg keys.

```
mkdir gnupg && chmod 700 gnupg
```

Also make sure that your hosts git config file is properly setup.

Start the container using the following command:
```
docker run --user debian -it --rm
       -v ~/.gitconfig:/home/debian/.gitconfig
       -v /home/../../gnupg/:/home/debian/.gnupg/ \
       -v /home/../../aptly/:/home/debian/.aptly/ \
       -v /home/../../debian-pkg/:/home/debian/debian-pkg/ \
       debian-package-devel /bin/bash
```

### Creating/importing GPG keys

We use two keys, a developer key to sign the sources (this is a personal key
with the developers email address) and a repository key.

To generate your developer key, use GPG inside the container:
```
gpg --generate-key
```

Use your full name and the Toradex email address.

The repository key is a regular GPG key with expiration date set to be 10 years
out. Unfortunately the version of aptly (our repository management tool) in
buster does not support gpg2 yet. Import this key to the gpg1 databse:

```
gpg1 --import torizoncore-debian-repository.key
```

To export the public key of the repository key use:
```
gpg1 --export --armor <key-id>
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

## Building Package

First make sure all build dependencies are installed. If the package has been
derived from an existing package, build dependency of that existing package are
a good start:

```
sudo apt-get build-dep libdrm2
```

To build the package various tools can be used. To build packages where sources
as well as metadata are stored in git, git build-package is handy.

```
gbp buildpackage --git-debian-branch=toradex-debian-unstable \
	--git-upstream-tree=rel_imx_4.14.98_2.0.0_ga
```

## Uploading package

To maintain the repository we use `aptly`.

### Create repository

Create a local repository using `aptly`:

```
aptly repo create -comment="Toradex testing repository" testing
```

### Add package files

Add source as well as binary package files:
```
aptly repo add testing ../libdrm_2.4.91-2+toradex1.dsc
aptly repo add testing ../libdrm*2.4.91-2+toradex1*.deb
```

The current list of packages in the repository can be checked with:
```
aptly repo show -with-packages testing
```

### Publishing locally

For first time publish the repository use this command:
```
aptly publish repo -distribution=buster -gpg-key=114F028BAA3F6DB1A41CECCA116A149EBBC0779B testing testing
```

To update the repository use:
```
aptly publish update buster testing
```

### Testing

Use `aptly serve` to run a testing http server:
```
aptly serve
```

Using a second container, we can test the repository as follows:
```
docker run -it --link=b7b1748dab50 arm64v8/debian:buster /bin/bash
```

Install the repository key, add the repository to the `source.list` and install
a package:
```
# wget -qO - http://b7b1748dab50:8080/torizoncore.pub | apt-key add -
# echo "deb http://b7b1748dab50:8080/testing/ buster main" >> /etc/apt/sources.list
```

Make sure to pin the repository so it takes preference even though there is a
newer version available from the official Debian repository by adding the
following content to `/etc/apt/preferences.d/torizoncore`:
```
Package: *
Pin: origin b7b1748dab50
Pin-Priority: 900
```

E.g . as a one liner:
```
# echo -e "Package: *\nPin: origin b7b1748dab50\nPin-Priority: 900" > /etc/apt/preferences.d/torizoncore
```

```
# apt-get update
# apt-get install libdrm2 libdrm-vivante1
```
