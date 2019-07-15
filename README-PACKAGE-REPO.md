# Debian package repository

We use `aptly` to maintain the Debian package repository. For more information
about aptly refer to the official home page at [aptly.info](http://aptly.info)

## Overview

aptly maintains a internal database. Currently this repository is stored on
feeds1.toradex.com. A separate user `debian` to maintian the Debian package
repository has been created. Similarly a `debian` user exists on
feeds2.toradex.com, however on feeds2 aptly is not required as we only serve the
deployed repository using http.

The `debian` user as well as its home directory is used to maintain the Debian
repository. The aptly database and package storage is in the default location in
~/.aptly/. The user also has the GPG private key installed.

## Setup

Note: This steps are only required to setup the repository the first time.

Initialize a new repository for testing:
```
aptly repo create -comment="Toradex testing repository" testing
```

Add the following section to `aptly.conf`
```
  "FileSystemPublishEndpoints": {
    "toradex-feeds": {
      "rootDir": "/srv/opkg/debian/",
      "linkMethod": "copy"
    }
  }
```



## Add package

Copy the packages onto the server (make sure to upload all files referenced in
the source dsc file!):
```
scp libdrm_2.4.91-2+toradex1.dsc debian@feeds1.toradex.com:import/
scp libdrm_2.4.91.orig.tar.gz debian@feeds1.toradex.com:import/
scp libdrm_2.4.91-2+toradex1.diff.gz debian@feeds1.toradex.com:import/
scp libdrm*2.4.91-2+toradex1_arm64.deb debian@feeds1.toradex.com:import/
```

Add source as well as binary package files:
```
aptly repo add testing import/libdrm_2.4.91-2+toradex1.dsc
aptly repo add testing import/libdrm*2.4.91-2+toradex1_arm64.deb
```

The current list of packages in the repository can be checked with:
```
aptly repo show -with-packages testing
```

## Publish

To get a list of published repositories:
```
aptly publish list
```

### Publish new repository

Note: This is only required the first time for each repository.

```
aptly publish repo -distribution=buster -gpg-key=torizoncore@toradex.com \
  testing filesystem:toradex-feeds:testing
```
### Update published repository

When adding/removing packages, the published repository needs updating:

```
aptly publish update buster filesystem:toradex-feeds:testing
```
