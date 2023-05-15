# Octez base docker images

This repository contains different artefacts used in
[Tezos](https://gitlab.com/tezos/tezos) CI jobs

- `packages/` contains specific OPAM packages
- `zcash-params/` contains the Sapling parameters
- `scripts/` contains miscellaneous scripts

## Dockerfiles

Several images are built on top of each other, and used in pipelines
of [Tezos](https://gitlab.com/tezos/tezos)

- `runtime-dependencies.Dockerfile`
- `runtime-prebuild-dependencies.Dockerfile`
- `runtime-build-dependencies.Dockerfile`
- `runtime-build-test-dependencies.Dockerfile`
- `runtime-build-test-e2etest-dependencies.Dockerfile`

## Poetry files

*poetry.lock* and *pyproject.toml* are related to the Python tests and
scripts used in Tezos. They must not be modified independently from
the ones provided in the Tezos repo. They are used to build the
virtual environment the CI jobs will use. They are useful to speed up
the jobs.
