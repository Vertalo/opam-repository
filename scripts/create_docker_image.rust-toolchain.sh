#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

# shellcheck source=scripts/version.sh
. "$script_dir"/version.sh

image_name="${1:-tezos/opam-repository}"
image_tag="${2:-rust-toolchain}"

echo
echo "### Building rust-toolchain image"
echo "### (includes: rust toolchain)"
echo

docker build \
       -f rust-toolchain.Dockerfile \
       -t "$image_name:$image_tag" \
       "$repo_dir"
