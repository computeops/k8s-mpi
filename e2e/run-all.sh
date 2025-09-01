#!/bin/bash

# Run all MPI e2e tests

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

echo "🚀 Starting MPI e2e tests..."

# Setup environment
$DIR/prereq.sh

# Build images
$DIR/build.sh

# Push images (add -k for kind development)
$DIR/push-image.sh

$DIR/install-mpi-operator.sh

# Run OpenMPI test
$DIR/run-mpi.sh openmpi

# Run MPICH test
$DIR/run-mpi.sh mpich

echo "✅ All MPI e2e tests completed successfully!"
