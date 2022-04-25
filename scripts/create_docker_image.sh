#!/bin/sh
set -eu

script_dir="$(cd "$(dirname "$0")" && echo "$(pwd -P)/")"
repo_dir="$(dirname "$script_dir")"
cd "$repo_dir"

image_name="${1:-tezos/opam-repository}"
tag_suffix="${2:-}"
arch="${3:-x86_64}"
targetarch="${4:-amd64}"

# https://docs.docker.com/engine/reference/commandline/build/#specifying-external-cache-sources

# TODO: remove
# if [ "${CI_PROJECT_NAMESPACE:-}" = 'tezos' ] && [ "${CI_COMMIT_BRANCH:-}" = 'master' ]
if [ "${CI_PROJECT_NAMESPACE:-}" = 'tezos' ] && [ "${CI_COMMIT_BRANCH:-}" = 'davdumas@cache' ]
then
  # default branch Docker images to be used with --cache-from option
  echo '### Build with argument BUILDKIT_INLINE_CACHE set'
  export DOCKER_BUILD_CACHE='--build-arg=BUILDKIT_INLINE_CACHE=1'

  # Merge Requests or local builds using default branch Docker images as cache
  #cache_image_name=$("${script_dir}/docker_cache.sh")

  # TODO: remove
  # https://gitlab.com/tezos/opam-repository/-/pipelines/522603469
  #cache_image_name='registry.gitlab.com/tezos/opam-repository:runtime-build-test-dependencies--amd64--6f7c23ea1c34c3e1d444e0ececb33f8db4f33402'

  #echo "### Build with cache from ${cache_image_name}"
  #export DOCKER_BUILD_CACHE_FROM="--cache-from=${cache_image_name}"
  #docker pull "${cache_image_name}"
fi

"$script_dir"/create_docker_image.runtime-dependencies.sh \
             "$image_name" \
             "runtime-dependencies$tag_suffix"

"$script_dir"/create_docker_image.runtime-prebuild-dependencies.sh \
             "$image_name" \
             "runtime-prebuild-dependencies$tag_suffix" \
             "$image_name:runtime-dependencies$tag_suffix" \
             "$arch" \
             "$targetarch"

"$script_dir"/create_docker_image.runtime-build-dependencies.sh \
             "$image_name" \
             "runtime-build-dependencies$tag_suffix" \
             "$image_name:runtime-prebuild-dependencies$tag_suffix"

"$script_dir"/create_docker_image.runtime-build-test-dependencies.sh \
             "$image_name" \
             "runtime-build-test-dependencies$tag_suffix" \
             "$image_name:runtime-build-dependencies$tag_suffix"
