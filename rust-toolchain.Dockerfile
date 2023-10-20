# rust dependencies
#
# This image includes
# - rust dependencies
#
# This image is intended for
# - building kernels, testing kernels and building the kernel SDK in the tezos/tezos CI
# - building the EVM kernel distributed in the tezos/tezos Docker images.

FROM debian:buster

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ENV LANG='C.UTF-8' LC_ALL='C.UTF-8' TZ='Etc/UTC'

WORKDIR /root

# common packages
# hadolint ignore=DL3008
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    ca-certificates curl file \
    build-essential \
    autoconf automake autotools-dev libtool xutils-dev && \
    rm -rf /var/lib/apt/lists/*

ENV SSL_VERSION=1.0.2u

# hadolint ignore=DL3003
RUN curl https://www.openssl.org/source/openssl-$SSL_VERSION.tar.gz -O && \
    tar -xzf openssl-$SSL_VERSION.tar.gz && \
    cd openssl-$SSL_VERSION && ./config && make depend && make install && \
    cd .. && rm -rf openssl-$SSL_VERSION*

ENV OPENSSL_LIB_DIR=/usr/local/ssl/lib \
    OPENSSL_INCLUDE_DIR=/usr/local/ssl/include \
    OPENSSL_STATIC=1

# install toolchain
RUN curl https://sh.rustup.rs --silent --show-error --fail | \
    sh -s -- --default-toolchain stable -y

ENV PATH=/root/.cargo/bin:$PATH

# install rust toolchain 1.66 and wasm32-unknown-unknown
RUN rustup update 1.66 \
    && rustup target add wasm32-unknown-unknown

# install wabt: https://packages.debian.org/source/sid/wabt
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install --no-install-recommends -y wabt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install newever version of clang, see https://apt.llvm.org/
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install --no-install-recommends -y gnupg \
    && echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster main" >> /etc/apt/sources.list \
    && echo "deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster main" >> /etc/apt/sources.list \
    && curl https://apt.llvm.org/llvm-snapshot.gpg.key --silent --show-error --fail | apt-key add \
    && apt-get update \
    && apt-get install --no-install-recommends -y clang \
    && clang --version \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
