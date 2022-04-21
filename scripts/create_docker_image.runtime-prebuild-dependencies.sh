#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

# shellcheck source=scripts/version.sh
. "$script_dir"/version.sh

image_name="${1:-tezos/opam-repository}"
image_tag="${2:-runtime-prebuild-dependencies}"
runtime_dependencies_image="${3:-tezos/opam-repository:runtime-dependencies}"
arch="${4:-x86_64}"
targetarch="${5:-amd64}"

"$script_dir"/build-libusb-hidapi.sh libusb "${arch}"
"$script_dir"/build-libusb-hidapi.sh hidapi "${arch}"

echo
echo "### Building runtime-prebuild-dependencies image $arch"
echo "### (includes: non-opam deps, cache of not-installed opam deps)"
echo

docker build \
       --file=runtime-prebuild-dependencies.Dockerfile \
       "${DOCKER_BUILD_CACHE:-}" \
       "${DOCKER_BUILD_CACHE_FROM:-}" \
       --build-arg=BUILD_IMAGE="${runtime_dependencies_image}" \
       --build-arg=OCAML_VERSION="${ocaml_version}" \
       --build-arg=RUST_VERSION="${rust_version}" \
       --build-arg=TARGETARCH="${targetarch}" \
       --tag="$image_name:$image_tag" \
       "$repo_dir"
