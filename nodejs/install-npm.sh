#!/usr/bin/env bash

# From https://gitlab.com/tezos/tezos/-/blob/master/scripts/install_build_deps.js.sh

export NODE_VERSION="16.18.1"

export NVM_NODEJS_ORG_MIRROR=https://unofficial-builds.nodejs.org/download/release
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

nvm_get_arch() {
    nvm_echo "x64-musl"
}

nvm install "$NODE_VERSION"
nvm use --delete-prefix "$NODE_VERSION"

node --version

