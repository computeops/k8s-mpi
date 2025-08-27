#!/bin/bash
set -e

# Build MPICH Pi example Docker image
cd "$(dirname "$0")/.."
docker build -t k8sschool/mpich-pi .