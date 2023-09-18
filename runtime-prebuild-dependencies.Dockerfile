# runtime + prebuild dependencies
#
# This image builds upon the `runtime-dependencies` image, see its
# header for details on its content.
#
# It adds upon the contents of `runtime-dependencies`:
# - non-opam build-dependencies (rust dependencies)
# - cache for opam build-dependencies
#
# This image is intended for
# - testing the buildability of tezos opam packages
# - building images on top of it in the image stack (see README.md)

ARG BUILD_IMAGE
# hadolint ignore=DL3006
FROM ${BUILD_IMAGE}

LABEL org.opencontainers.image.title="runtime-prebuild-dependencies"

USER root

# SHELL already set in runtime-dependencies

WORKDIR /tmp

# Automatically set if you use Docker buildx
ARG TARGETARCH

# Verify remote files checksum (prevent tampering)
# why the git config???
COPY --chown=tezos:tezos .gitconfig remote-files.sha512 /home/tezos/

# hadolint ignore=DL3018,DL3019
RUN apk update \
# Do not use apk --no-cache here because opam needs the cache.
# See https://github.com/ocaml/opam/issues/5186
 && apk add \
    autoconf \
    automake \
    bash \
    build-base \
    ca-certificates \
    cargo \
    cmake \
    coreutils \
    curl \
    eudev-dev \
    git \
    gmp-dev \
    jq \
    libev-dev \
    libffi-dev \
    libtool \
    linux-headers \
    m4 \
    ncurses-dev \
    opam \
    openssh-client \
    openssl-dev \
    patch \
    perl \
    postgresql14-dev \
    rsync \
    tar \
    unzip \
    wget \
    xz \
    zlib-dev \
    zlib-static \
    libusb-dev \
    hidapi-dev \
    sccache \
# Install UPX manually to get current multi-arch release
# https://upx.github.io/
 && curl -fsSL https://github.com/upx/upx/releases/download/v3.96/upx-3.96-${TARGETARCH}_linux.tar.xz \
    -o upx-3.96-${TARGETARCH}_linux.tar.xz \
 && sha512sum --check --ignore-missing /home/tezos/remote-files.sha512 \
 && tar -xf upx-3.96-${TARGETARCH}_linux.tar.xz \
 && mv upx-3.96-${TARGETARCH}_linux/upx /usr/local/bin/upx \
 && chmod 755 /usr/local/bin/upx \
# Cleanup
 && rm -rf /tmp/*

USER tezos
WORKDIR /home/tezos

# TODO: Use a single COPY instruction and avoid duplicates files
COPY --chown=tezos:tezos repo opam-repository/
COPY --chown=tezos:tezos packages opam-repository/packages
COPY --chown=tezos:tezos \
      packages/ocaml \
      packages/ocaml-config \
      packages/ocaml-base-compiler \
      packages/ocaml-options-vanilla \
      packages/base-bigarray \
      packages/base-bytes \
      packages/base-unix \
      packages/base-threads \
      opam-repository/packages/

WORKDIR /home/tezos/opam-repository

ARG OCAML_VERSION
# hadolint ignore=SC2046,DL4006
RUN opam init --disable-sandboxing --no-setup --yes \
              --compiler ocaml-base-compiler.${OCAML_VERSION} \
              tezos /home/tezos/opam-repository \
 && opam admin cache \
 && opam update \
 && opam clean

ENTRYPOINT [ "opam", "exec", "--" ]
CMD [ "/bin/sh" ]
