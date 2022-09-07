# runtime + build dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
# - non-opam build-dependencies (rust dependencies)
# - cache for opam build-dependencies
# - opam build-dependencies
#
# This image is intended for
# - building tezos from source
# - building the runtime-build-test-dependencies image

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

# Opam does not "see" the custom hidapi apk installed.
# That's the reason why --assume-depexts.
# hadolint ignore=SC2046,DL4006
RUN opam install --assume-depexts --yes $(opam list --all --short | grep -v ocaml-option-)

# ENTRYPOINT and CMD already set in runtime-prebuild-dependencies
