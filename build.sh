#!/bin/bash

cuda_version=$1
ubuntu_version=$2

[ -z "$cuda_version" ] || cuda_version=13.1.1
[ -z "$ubuntu_version" ] || ubuntu_version=22.04

docker build ./image \
  --build-arg CUDA_VERSION="$cuda_version" \
  --build-arg UBUNTU_VERSION="$ubuntu_version" \
  -t isolate-envs_cuda-"$cuda_version"-ubuntu-"$ubuntu_version"
