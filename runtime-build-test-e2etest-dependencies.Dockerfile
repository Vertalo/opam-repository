# runtime + build + test + end-to-end test dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
# - non-opam build-dependencies (rust dependencies)
# - cache for opam build-dependencies
# - opam build-dependencies
# - opam test-dependencies (aclotest, crowbar, etc.)
# - python and python libraries for tests executed in python
# - nvm for javascript backend testing
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

USER tezos
WORKDIR /home/tezos

### Javascript env setup as tezos user

COPY --chown=tezos:tezos nodejs/install_build_deps.js.sh /tmp

ARG NODE_VERSION

# hadolint ignore=SC1091
RUN recommended_node_version=${NODE_VERSION}
 && /tmp/install_build_deps.js.sh
 && npm install -g eth-cli@2.0.2 \
 && rm -rf /tmp/*

ENV PATH "$HOME/.nvm/versions/node/${NODE_VERSION}/bin:$PATH"

RUN eth -v

# ENTRYPOINT and CMD already set in runtime-prebuild-dependencies

