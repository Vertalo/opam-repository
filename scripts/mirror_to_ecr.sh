#!/bin/sh
set -eu

## Mirror Docker image from GitLab container registry @GCP to private ECR @AWS

# shellcheck source=./scripts/docker.sh
. ./scripts/docker.sh

image_name="${1:-tezos/opam-repository}"
mirror_image_name="${2}"
image_family="${3:-all}"

check_docker_image_family "$image_family"

set -x

for tag_prefix in $(docker_images_family "$image_family")
do
  regctl image copy "${image_name}:${tag_prefix}--${CI_COMMIT_SHA}" \
                    "${mirror_image_name}:${tag_prefix}--${CI_COMMIT_SHA}"
done
