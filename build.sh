#!/bin/bash
set -e

cuda_version=$1
ubuntu_version=$2

[ -z "$cuda_version" ] && cuda_version=13.1.1
[ -z "$ubuntu_version" ] && ubuntu_version=22.04

tag=isolate-envs_cuda-"$cuda_version"_ubuntu-"$ubuntu_version"

docker build ./image \
  --build-arg CUDA_VERSION="$cuda_version" \
  --build-arg UBUNTU_VERSION="$ubuntu_version" \
  -t "$tag"

>&2 echo Successfully created Docker image "'$tag'"
