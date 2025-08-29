#!/bin/bash

# Run all MPI e2e tests

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

echo "🚀 Starting MPI e2e tests..."

# Setup environment
$DIR/prereq.sh

# Run OpenMPI test
$DIR/test-openmpi.sh

# Run MPICH test
$DIR/test-mpich.sh

echo "✅ All MPI e2e tests completed successfully!"