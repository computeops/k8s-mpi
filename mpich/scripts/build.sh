#!/bin/bash
set -e

# Build script for MPICH Docker image

# Build from mpich directory
cd "$(dirname "$0")/.."

# Use ciux to get image URL
$(ciux get image --check . --env)

echo "Building Docker image: ${CIUX_IMAGE_URL}"

docker build -t "${CIUX_IMAGE_URL}" .

echo "✅ Image built successfully: ${CIUX_IMAGE_URL}"
echo ""
echo "To push to Docker Hub:"
echo "  docker push ${CIUX_IMAGE_URL}"