# runtime + build dependencies
#
# This image builds upon the `runtime-prebuild-dependencies` image,
# see its header for details on its content.
#
# It removes the `cache for opam build-dependencies` from that image, and adds:
# - opam build-dependencies
#
# This image is intended for
# - building tezos from source
# - building images on top of it in the image stack (see README.md)

ARG BUILD_IMAGE
# hadolint ignore=DL3006
FROM ${BUILD_IMAGE}

LABEL org.opencontainers.image.title="runtime-build-dependencies"

# SHELL already set in runtime-dependencies

USER tezos
WORKDIR /home/tezos

# Build blst used by ocaml-bls12-381 without ADX to support old CPU
# architectures.
# See https://gitlab.com/tezos/tezos/-/issues/1788 and
# https://gitlab.com/dannywillems/ocaml-bls12-381/-/merge_requests/135/
ENV BLST_PORTABLE=yes

# hadolint ignore=SC2046,DL4006
RUN opam install --yes $(opam list --all --short | grep -v ocaml-option-) \
    && opam clean

# ENTRYPOINT and CMD already set in runtime-prebuild-dependencies
