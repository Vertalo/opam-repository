#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

# shellcheck source=scripts/version.sh
. "$script_dir"/version.sh

image_name="${1:-tezos/opam-repository}"
image_tag="${2:-runtime-build-dependencies}"
image_tag_cache="${3:-}"
runtime_prebuild_dependencies_image="${4:-tezos/opam-repository:runtime-prebuild-dependencies}"

echo
echo "### Building runtime-build-dependencies image"
echo "### (includes: rust dependencies, ocaml dependencies)"
echo "### (cache from: $image_name:$image_tag_cache)"
echo

docker build \
       -f runtime-build-dependencies.Dockerfile \
       --build-arg=BUILDKIT_INLINE_CACHE=1 \
       --cache-from="$image_name:$image_tag_cache" \
       --build-arg BUILD_IMAGE="${runtime_prebuild_dependencies_image}" \
       -t "$image_name:$image_tag" \
       "$repo_dir"
