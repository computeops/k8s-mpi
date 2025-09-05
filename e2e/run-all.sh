#!/bin/bash

# Run all MPI e2e tests

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

echo "🚀 Starting MPI e2e tests..."

# Setup environment
$DIR/prereq.sh
$DIR/install-mpi-operator.sh

# Build images
$DIR/build.sh

# Push images (add -k for kind development)
$DIR/push-image.sh

# Run OpenMPI test
$DIR/run-mpi.sh openmpi pi

# Run MPICH test
$DIR/run-mpi.sh mpich hello_world

echo "✅ All MPI e2e tests completed successfully!"
