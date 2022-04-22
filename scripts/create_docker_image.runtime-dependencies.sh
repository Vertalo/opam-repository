#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

image_name="${1:-tezos/opam-repository}"
image_tag="${2:-runtime-dependencies}"

echo
echo "### Building runtime-dependencies image"
echo "### (includes: alpine, runtime-linked libraries)"
echo

docker build \
       -f runtime-dependencies.Dockerfile \
       -t "$image_name:$image_tag" \
       "$repo_dir"
