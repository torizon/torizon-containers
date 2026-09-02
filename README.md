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

Release branches are named after the Debian and Yocto releases they are built
from, as `<debian>-<yocto>`:

- `bookworm-scarthgap`: tracks Torizon OS 7.x.y, built on Debian Bookworm and
the Scarthgap Yocto release.
- `forky-wrynose`: tracks Torizon OS 8.x.y, built on Debian Forky and the
Wrynose Yocto release.

Thus there's always an one-to-one relationship between a major Torizon OS
release and a given Torizon Containers release, and the container major matches
the Torizon OS major it targets.

Older branches used rolling names (`oldstable`, `stable`, `next`) that had to be
renamed as releases moved along. Naming branches after the Debian/Yocto pair
instead means a branch never changes identity: it is created, it releases
independently for as long as it is supported, and it is eventually dropped.

Containers are pushed to [Torizon DockerHub](https://hub.docker.com/u/torizon),
and all containers are versioned following
[Semantic Versioning](https://semver.org/), plus the alias tags described below.

## Release Candidates

Every branch is built, tested and released independently of the others.

The tag a branch publishes under is **not** derived from the branch name. It
comes from the `alias:` field in the
[versioning metadata](ci-scripts/container-versions) tracked by the repo:

```yaml
weston-imx8:
  major: 8
  minor: 0
  patch: 0
  alias: [wrynose, forky-wrynose]
```

The **first** entry is the canonical alias and is what the release candidate tag
is built from. [`release-tag.sh`](ci-scripts/release-tag.sh) gathers the aliases
from every file under [`ci-scripts/container-versions`](ci-scripts/container-versions)
and refuses to run if they disagree, so a branch always resolves to exactly one
rc tag.

When a pipeline runs on a **protected branch** outside of a merge request, it
pushes to DockerHub as `<image-name>:<alias>-rc`. On `forky-wrynose`, whose
canonical alias is `wrynose`, that is `<image-name>:wrynose-rc`.

Every other pipeline — merge requests, unprotected branches — pushes to the
GitLab registry as `<image-name>:<branch-slug>-<pipeline-id>` instead, so
work in progress never touches the public rc tags.

Release Candidates allow us to test all branches independently before making a
release. So if there is a patch release of a Torizon OS LTS version, we can test
it and make necessary adjustments without disrupting other branches. Every
release is independent of each other, tracked by a branch.

### Making a Release

A release is re-tagging the golden `-rc` images, and it is not automatic. Run a
pipeline on the release branch with `MAKE_TAG_RELEASE=true`, and
[`deploy.sh`](ci-scripts/release/deploy.sh) copies each `<image-name>:<alias>-rc`
to:

- `<major>.<minor>.<patch>`, which is skipped if it already exists so a
published version is never silently overwritten;
- `<major>.<minor>` and `<major>`, moved forward to the new release, but only
when the exact version above was actually published;
- every entry of `alias:`, so `forky-wrynose` publishes both `wrynose` and
`forky-wrynose`.

An image needs at least a `major:` or an `alias:`; if `major:` is set then
`minor:` and `patch:` are required too. The job then creates a GitLab release
tagged `<major>-<YYYY.MM.DD>`, for example `8-2026.09.02`, and announces it on
Slack.

Publishing the demo gallery is a separate switch: run a pipeline with
`MAKE_GALLERY_RELEASE=true` to regenerate the composes with the `<alias>-rc`
image references rewritten to the release major, and push them to the
demo-gallery repository.

When a new Torizon OS version is released, we branch for the new Debian/Yocto
pair and give it its own alias and major.

This process is implemented using GitLab CI and it's fairly segmented between
the stages, looking from the pipeline YAML definitions:

- [Main build pipeline](.gitlab-ci.yml) which pushes images to DockerHub with
 `<image-name>:<alias>-rc`.
- [Test pipelines](ci-scripts/test/), the
[Aval tests](ci-scripts/test/aval-tests.yml) running integration tests on real
hardware using the Aval Framework and the Torizon Cloud API, and the functional
tests such as [support-files-tests.yml](ci-scripts/test/support-files-tests.yml).
- [Release Pipeline](ci-scripts/release/release.yml) which retags images from
`<image-name>:<alias>-rc` to the numbered and alias tags declared in the
[versioning metadata](ci-scripts/container-versions).

## Developing

> **Important**
> Before start developing, you should run the `git-setup.sh` script to configure the git hooks in your local environment. You can do it by simply running `./git-setup.sh` from the root folder.

Users are not expected to build their own images from this repository, as it's
fairly optimized may be too complicated to build from the CLI. Nonetheless, one
must be able to do this when developing for `torizon-containers` itself.

Each directory (ignoring `platform-specific`) symlinks files that are to be
included in the image to `support-files`, so multiple builds can use the same
Dockerfile defition, though installing different packages because of the
different package feeds.

To build an image, one can use the
[phemmer trick](https://github.com/moby/moby/issues/6094#issuecomment-54556720)
to resolve the symlinks with tar and pipe everything as the build context to
`docker build`.

For example, if I wish to build the base Docker for the iMX8 platform, from the
`base` folder run:

```
tar -ch . | docker buildx build \
--build-arg DEBIAN_POINT_RELEASE="12.6-slim" \
--build-arg REGISTRY="docker.io" \
--build-arg TORADEX_FEED_URL="https://feeds.toradex.com/stable/imx8/" \
-t base -
```

This is only an example to show the syntax of the `docker buildx build` command.
The real Debian base release can be seen looking to the `DEBIAN_POINT_RELEASE`
variable in [.gitlab-ci.yml](https://github.com/torizon/torizon-containers/blob/stable/.gitlab-ci.yml#L13)

### Commit Hygiene

We use git headers to identify where a change is being done. Headers refer to the
directory in which a change is being done. For example, let's say I added a new
package to the Cog image that lives under the [cog](./cog/) directory. My commit
message title is thus

```
cog: add new package <package_name>
```

Or if I make a contribution related to the demo gallery, my commit message shall read

```
demo-gallery: ...
```

When contributions are made for documentation:

```
docs: ...
```

And when contributions are made to platform-specific directories, we specify the
platform, such as

```
am62p: ...
```

There is one additional type of change which may relate to many files because it's
really useful, `chore:`. This is, for example, when we update third-party dependencies
on any file, such as `regctl` and `trivy`, for example.

Another aspect of commit hygine is to not use Uppercase after the header. Example:

Correct: `chore: update regclient to x.y.z`

Incorrect: `chore: Update regclient to x.y.z`

Moreover, we do not ever in any circumstance use merge-commits. The history is purely
linear. There's no good technical explanation for this other than personal taste.
In this way, branch names do not matter, so you're free to `git checkout -b <ideally something quite funny>`.

Also, please don't use the past tense. Use the imperative present tense to describe changes. Example:

Correct: `qt5-wayland: add new package dependency`

Incorrect:`qt5-wayland: added new package dependency`

There's no reason for this other than sticking to a standard and personal preference.

**Required fields**

We also enforce (provided that the hooks were configured) the use of some fields in the commit message:

- *Related-to*: this field is used to indicate the task the commits is referencing;
- *Signed-off-by* : each commit should be signed. You can automatically add this field by running `git commit -s`

**Example**

Here follows an example of a good commit

```
demo-gallery: add foo demo for bar platform

This commit adds a demo that runs 'foo' into the platform 'bar'

Related-to: ABCD-1234

Signed-off-by: Jill Valentine <jill.valentine@email.com>
```

### GPG Signing
This project requires that contributors sign their commits with GPG. In order
to do that, follow [this documentation](https://docs.gitlab.com/user/project/repository/signed_commits/gpg/).

We also encourage you to configure Git to automatically GPG sign your commits,
so you can suppress the `-S` flag.

```
git config --global commit.gpgsign true
```

### Linting

Inside the [lint](ci-scripts/lint/) directory you'll find several small scripts
that are meta-build checks, meaning they check the files for the build of the
images themselves, such as the YAML files for GitLab CI or the Dockerfiles.

The rule of thumb is that every time you encounter a bug that could have been
caught with a meta-linting test, you fix that bug and write the test. Preventing
regressions during build time is imperative for the well-being of this project.

## Testing

Torizon Containers are tested in two levels:

- [Integration tests](ci-scripts/test/aval-tests.yml) using the
[Aval Framework](https://github.com/torizon/aval), which is our own orchestrator
built on top of Torizon Cloud. These tests run from a board farm maintained by
Toradex.

Integration tests are written in bash using bats and are
[divided in suites](tests/suites/) corresponding each of the SoC platforms we
support. We package everything in a Docker image and tell Aval to run this
image to a board that matches our configuration. Within the `docker run...`
statement we tell Aval to execute we mount the docker socket of the daemon
running on the host Torizon OS which enables the subsequent `docker pulls` from
the various `setup_suite.bash` to pull the image currently being tested.

A helper [`run-tests.sh`](tests/suites/run-tests.sh) script is used to crawl
through each of the tests inside a given suite, sequencially run each bats test
and report a JUnit.xml `report.xml` file that is picked up by Aval via ssh over
to the `report: junit:` field in
[`aval-tests.yml`](ci-scripts/test/aval-tests.yml), providing a visual
representation of which tests passed/failed from the GitLab UI.

- Functional tests: these are for testing things like "is the correct version of
dotnet installed?" or other basic checks for versions etc. Anything that can be
easily tested on common runners (amd64, generally) and is not hardware-dependent
is a functional test. Test pipelines are any `*-tests.yml`
[here](ci-scripts/test/) that are not the the Aval tests.

## Architecture Glossary

In the context of the [cross-toolchain images](cross-toolchain), we use the
following definitions:

| Architecture        | Equivalent Cross Toolchain Container |
|---------------------|--------------------------------------|
| ARMv7 with VFP3-D16 | cross-toolchain-arm                  |
| ARMv8-A             | cross-toolchain-arm64{-imx8, -am62}  |
| x86_64              | cross-toolchain-amd64                |

In the context of the architecture for all Container Images, we use the
following definitions:

| Architecture               | Container Image Architecture |
|----------------------------|------------------------------|
| ARMv7 with VFP3-D16        | linux/arm/v7                 |
| ARMv8-A                    | linux/arm64/v8               |
| x86_64 (also called amd64) | linux/amd64                  |

## License

This project is licensed under the terms of MIT license (see LICENSE) unless
specified otherwise in the source file.

The screenshots under support-files/qt6-enterprise are licensed under the terms
of LicenseRef-Qt-Commercial
([www.qt.io/terms-conditions](https://www.qt.io/terms-conditions) and LICENSE).
