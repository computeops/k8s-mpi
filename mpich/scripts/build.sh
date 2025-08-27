#!/bin/bash
set -e

# Build script for MPICH Docker image
IMAGE_NAME="k8sschool/mpich-pi"
IMAGE_TAG="latest"

echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"

# Build from mpich directory
cd "$(dirname "$0")/.."

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .

echo "✅ Image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "To push to Docker Hub:"
echo "  docker push ${IMAGE_NAME}:${IMAGE_TAG}"