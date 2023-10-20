#!/bin/sh
set -eu

## Push all Docker images to GitLab container registry

# shellcheck source=./scripts/docker.sh
. ./scripts/docker.sh

image_name="${1:-tezos/opam-repository}"
tag_suffix="${2:-}"
image_family="${3:-all}"

check_docker_image_family "$image_family"

for tag_prefix in $(docker_images_family "$image_family"); do
	docker push "${image_name}:${tag_prefix}${tag_suffix}"
done
