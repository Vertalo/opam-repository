# runtime + end-to-end test dependencies
#
# This image builds on the runtime dependencies and additionally includes:
#
# - ocamlformat and bisect-ppx-report, copied from the
#   runtime-build-dependencies image.
# - eth-cli, installed from npm
# - some utilities used in the Tezt integration test suite: curl, git, file
# - some utilities used in the [unified_coverage] job: make, jq
#
# This image is intended for
# - Running end-to-end tests (mostly Tezt) in the tezos/tezos CI.

ARG OCAML_IMAGE
ARG BUILD_IMAGE

# hadolint ignore=DL3006
FROM ${OCAML_IMAGE} as ocaml

# hadolint ignore=DL3006
FROM ${BUILD_IMAGE}

LABEL org.opencontainers.image.title="runtime-e2e-dependencies"

USER root

# SHELL already set in runtime-dependencies

WORKDIR /tmp

# Automatically set if you use Docker buildx
ARG TARGETARCH

# Retrieve ocamlformat, used in the snoop tests.
ARG OCAML_VERSION
COPY --from=ocaml /home/tezos/.opam/ocaml-base-compiler.${OCAML_VERSION}/bin/ocamlformat /home/tezos/.opam/ocaml-base-compiler.${OCAML_VERSION}/bin/bisect-ppx-report /bin/

# TODO: https://gitlab.com/tezos/tezos/-/issues/5026
# We could install npm via nvm if we tackle this issue.
# In the meantime, removes nvm installed in runtime-build-test-dependencies and
# install npm via apk.

# Fixing some ipv6 issues on the runner. Always prioritizing ipv4
ENV NODE_OPTIONS="--dns-result-order=ipv4first"

# We need curl since a bunch of tezt tests use curl.
# Same, some tests use [file].

# hadolint ignore=DL3018,DL3019
RUN apk update \
 && apk add --no-cache curl npm git file make jq \
 # We need eth since e2e tests. This requires git as well.
 && npm install -g eth-cli@2.0.2 \
 # clean up
 && rm -rf /tmp/*

USER tezos
WORKDIR /home/tezos
