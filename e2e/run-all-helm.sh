#!/bin/bash

# End-to-end test runner for MPI using Helm chart

set -euo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Build images for both MPI implementations
echo "🔨 Building MPI images..."
$DIR/../build.sh mpich
$DIR/../build.sh openmpi

# Push images
echo "📤 Pushing images..."
$DIR/push-image.sh

# Run OpenMPI test
echo "🧪 Running OpenMPI tests..."
$DIR/run-mpi-helm.sh openmpi pi

# Run MPICH test  
echo "🧪 Running MPICH tests..."
$DIR/run-mpi-helm.sh mpich hello_world

echo "✅ All MPI e2e tests completed successfully!"