#!/bin/sh
set -eu

## Multi-arch docker images with a single tag
# shellcheck source=./scripts/docker.sh
. ./scripts/docker.sh

image_name="${1:-tezos/opam-repository}"

# Loop over images
# NOTE: only the runtime image family is multi-arch
for tag_prefix in $(docker_images_family "runtime")
do
  echo "### Merging tags for docker image: ${tag_prefix}"

  # Loop over architectures
  amends=''
  for TARGETARCH in ${docker_architectures}
  do
    amends="${amends} --amend ${image_name}:${tag_prefix}--${TARGETARCH}--${CI_COMMIT_SHA}"
  done

  # Because of the variable amends, we use eval here to first construct the command
  # by concatenating all the arguments together (space separated), then read and execute it
  eval "docker manifest create ${image_name}:${tag_prefix}--${CI_COMMIT_SHA}${amends}"
  docker manifest push "${image_name}:${tag_prefix}--${CI_COMMIT_SHA}"
done
