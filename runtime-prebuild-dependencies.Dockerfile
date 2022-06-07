# runtime + prebuild dependencies
#
# This image includes
# - runtime dependencies (libraries linked at load time of the process)
# - non-opam build-dependencies (rust dependencies)
# - cache for opam build-dependencies
#
# This image is intended for
# - testing the buildability of tezos opam packages
# - building the runtime-build-dependencies and runtime-build-test-dependencies image

ARG BUILD_IMAGE
# hadolint ignore=DL3006
FROM ${BUILD_IMAGE}

LABEL org.opencontainers.image.title="runtime-prebuild-dependencies"

USER root

# SHELL already set in runtime-dependencies

WORKDIR /tmp

# Adds static packages of hidapi and libusb built by `scripts/libusb-hidapi.sh`
# in `runtime-prebuild-dependencies` image.
COPY _docker_build/keys /etc/apk/keys/
COPY _docker_build/*/*.apk /tmp/

# Automatically set if you use Docker buildx
ARG TARGETARCH
# hadolint ignore=DL3018
RUN apk --no-cache add \
    autoconf \
    automake \
    bash \
    build-base \
    ca-certificates \
    cargo \
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
    postgresql-dev \
    rsync \
    tar \
    unzip \
    wget \
    xz \
    zlib-dev \
    zlib-static \
    # Custom packages from `scripts/build-libusb-hidapi.sh`
    hidapi-0.9.0-r2.apk \
    hidapi-dev-0.9.0-r2.apk \
    libusb-1.0.24-r2.apk \
    libusb-dev-1.0.24-r2.apk \
# Install UPX manually to get current multi-arch release
# https://upx.github.io/
 && curl -fsSL https://github.com/upx/upx/releases/download/v3.96/upx-3.96-${TARGETARCH}_linux.tar.xz \
    -o upx-3.96-${TARGETARCH}_linux.tar.xz \
 && sha512sum --check --ignore-missing /home/tezos/remote-files.sha512 \
 && tar -xf upx-3.96-${TARGETARCH}_linux.tar.xz \
 && mv upx-3.96-${TARGETARCH}_linux/upx /usr/local/bin/upx \
 && chmod 755 /usr/local/bin/upx \
 && rm -rf /tmp/*

USER tezos
WORKDIR /home/tezos

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
              tezos /home/tezos/opam-repository && \
    opam admin cache && \
    opam update && \
    opam install opam-depext && \
    opam depext --update --yes $(opam list --all --short | grep -v ocaml-option-) && \
    opam clean

ENTRYPOINT [ "opam", "exec", "--" ]
CMD [ "/bin/sh" ]
