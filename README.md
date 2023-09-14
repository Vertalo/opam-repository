# Octez base Docker images

This repository contains different Docker images and artefacts used in
[Octez](https://gitlab.com/tezos/tezos) CI jobs:

- `packages/` contains specific OPAM packages
- `zcash-params/` contains the Sapling parameters
- `scripts/` contains miscellaneous scripts

## Dockerfiles

The images defined in this repo are built on top of each other (such
that the contents of image N is also in N+1[^1]), and used in the CI
pipelines of [Octez](https://gitlab.com/tezos/tezos). These images,
and their content, are:

| Image                                        | Contents                           | Usage                             |
|----------------------------------------------|------------------------------------|-----------------------------------|
| 1. `runtime-dependencies`                    | run-time libraries + zcash-params  | distributing Octez executables    |
| 2. `runtime-prebuild-dependencies`           | OCaml + opam package cache + Cargo | CI: OPAM installability tests     |
| 3. `runtime-build-dependencies`              | opam packages                      | CI: Building Octez                |
| 4. `runtime-build-test-dependencies`         | Python + NVM + ShellCheck          | CI: Octez tests and documentation |
| 5. `runtime-build-test-e2etest-dependencies` | `eth-cli`                          | CI: Octez integration tests       |

For details on the contents and usage of each image, see the header
comment of the corresponding Dockerfile.

## Adding OPAM dependencies

The images built in this repository are used to in the CI of
[tezos/tezos](https://gitlab.com/tezos/tezos). To update the
dependencies for `tezos/tezos`, this repo has to be modified. For an
in-depth guide, see the Tezos technical documentation's guide on [how
to add or update opam
dependencies](https://tezos.gitlab.io/developer/contributing-adding-a-new-opam-dependency.html).

## Poetry files

`poetry.lock` and `pyproject.toml` defines the Python environment used
to build the Octez documentation. This environment is installed in the
image `runtime-build-test-dependencies` and used in the Octez CI to
build documentation. These files must be kept identical to the ones provided
in the Octez repository: modify them in both repositories at once.

[^1]: There are exceptions. For instance, the
    `runtime-prebuild-dependencies` image contains the sources of the
    OPAM packages from `packages/`, which are used in the `opam` tests
    of `tezos/tezos`. However, they serve no use and are not present
    in the images that build on top of it
    (`runtime-build-dependencies` etc).
