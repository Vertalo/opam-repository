#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

image_name="${1:-tezos/opam-repository}"
image_version="${2:-runtime-build-dependencies}"
runtime_prebuild_dependencies_image="${3:-tezos/opam-repository:runtime-prebuild-dependencies}"

echo
echo "### Building runtime-build-dependencies image"
echo "### (includes: rust dependencies, ocaml dependencies)"
echo

docker build \
       -f runtime-build-dependencies.Dockerfile \
       --build-arg BUILD_IMAGE="${runtime_prebuild_dependencies_image}" \
       -t "$image_name:$image_version" \
       "$repo_dir"
