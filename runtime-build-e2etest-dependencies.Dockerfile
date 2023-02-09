# runtime + build + test + end-to-end test dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
# - non-opam build-dependencies (rust dependencies)
# - cache for opam build-dependencies
# - opam build-dependencies
# - opam test-dependencies (alcotest, etc.)
# - python and python libraries for tests executed in python
# - some preinstalled nvm packages for end-to-end integration testing
#
# This image is intended for
# - running the CI tests of tezos

ARG BUILD_IMAGE
# hadolint ignore=DL3006
FROM ${BUILD_IMAGE}

LABEL org.opencontainers.image.title="runtime-build-test-e2etest-dependencies"

# SHELL already set in runtime-dependencies

USER root

WORKDIR /tmp

# TODO: https://gitlab.com/tezos/tezos/-/issues/5026
# We could install npm via nvm if we tackle this issue.
# In the meantime, removes nvm installed in runtime-build-test-dependencies and
# install npm via apk.

# hadolint ignore=DL3018
RUN rm -rf "$HOME/.nvm" \
 && apk add --no-cache npm \
 && npm install -g eth-cli@2.0.2

USER tezos
WORKDIR /home/tezos

# ENTRYPOINT and CMD already set in runtime-build-test-dependencies
