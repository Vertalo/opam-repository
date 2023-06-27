#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

# shellcheck source=scripts/version.sh
. "$script_dir"/version.sh

image_name="${1:-tezos/opam-repository}"
image_tag="${2:-runtime-e2etest-dependencies}"
image_tag_cache="${3:-}"
runtime_dependencies_image="${4:-tezos/opam-repository:runtime-dependencies}"
runtime_build_dependencies_image="${5:-tezos/opam-repository:runtime-build-dependencies}"
targetarch="${6:-amd64}"

echo
echo "### Building runtime-e2etest-dependencies image"
echo "### (includes: tezt integration test dependencies)"
echo "### (cache from: $image_name:$image_tag_cache)"
echo

docker build \
       -f runtime-e2etest-dependencies.Dockerfile \
       --build-arg=BUILDKIT_INLINE_CACHE=1 \
       --cache-from="$image_name:$image_tag_cache" \
       --build-arg BUILD_IMAGE="${runtime_dependencies_image}" \
       --build-arg OCAML_IMAGE="${runtime_build_dependencies_image}" \
       --build-arg OCAML_VERSION="${ocaml_version}" \
       --build-arg TARGETARCH="${targetarch}" \
       -t "$image_name:$image_tag" \
       "$repo_dir"
