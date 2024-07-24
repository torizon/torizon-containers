# Torizon Containers

This repository contains container images used by or with
[Torizon OS](https://www.torizon.io), the Easy-to-use Industrial Linux Software 
Platform.

This repository provides images that need to be maintained over time with or
without hardware acceleration inside the containers - provided by the custom
package feeds also maintained by Toradex.

When hardware acceleration is needed, we stratify by what we call "platforms",
which are the different SoCs families. For example, one of the families is
`imx8`, which includes all variantes of this processor such as `imx8mm`,
`imx8mp` etc.

We also support what we call "upstream" images, which are images where hardware
acceleration support comes from the upstream Debian feeds, although we may have
one or two custom packages introduced there as well, which are hopefully
upstreamed over time.

## Release Cycle

`torizon-containers` may have many active branches at any given point in time.
These track the different releases of Torizon OS we either support or integrate
for.

Our naming scheme for the branches determines which Torizon OS is supported by
which branch:

- oldstable: the LTS release of Torizon OS.
- stable: the current release of Torizon OS.
- next: the future release of Torizon OS.

As an example:

- oldstable: tracks TorizonCore 5.x.y based on the Dunfell Yocto release.
- stable: trackes Torizon OS 6.x.y based on the Kirkstone Yocto Release.
- next: tracks Torizon OS 7.x.y based on the Scarthgap Yocto Release.

Thus there's always an one-to-one relationship between a major Torizon OS
release and a given Torizon Containers Release.

Please note that this naming **does not have any relationship with the Debian
releases**. Our `stable` may be based off Debian's `oldstable` if there's
a compelling technical reason to do so.

Containers are pushed to [Torizon DockerHub](https://hub.docker.com/u/torizon),
and all containers are versioning following
[Semantic Versioning](https://semver.org/).

## Release Candidates

We use a Release Candidate scheme for **every branch**, meaning when a build
pipeline runs, it actually pushes images with `<image-name>:<branch-name>-rc`.

Release Candidates allow us to test all branches independently before making a
release, which for us is re-tagging a golden container image from
`<image-name>:<branch-name>-rc` to `<image-name>:<major>.<minor>.<patch>`.

So if there is a patch release of a Torizon OS LTS version, we can test it and
make necessary adjustments without disrupting other branches. Every release is
independent of each other, tracked by a branch.

When a new Torizon OS version is released, we fork from the `next` branch to
`stable`, rename `stable` to `oldstable` and drop `oldstable` (or even rename it
to `oldoldstable` if needed).

This process is implemented using GitLab CI and it's fairly segmented between
the stages, looking from the pipeline YAML definitions:

- [Main build pipeline](.gitlab-ci.yml) which pushes images to DockerHub with
 `<image-name>:<branch-name>-rc`.
- [Test Pipeline](ci-scripts/test/test.yml) which runs integration tests on real
hardware using the Aval Framework and the Torizon Cloud API.
- [Release Pipeline](ci-scripts/release/release.yml) which retags images from
`<image-name>:<branch-name>-rc` to `<image-name>:<major>.<minor>.<patch>` using
the [versioning metadata](ci-scripts/container-versions) tracked by the repo.
