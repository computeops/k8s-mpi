#!/bin/bash

set -euo pipefail

usage() {
    cat << EOF
Usage: $0 [OPTIONS] <mpi-type>

Build MPI Docker images for Kubernetes using ciux.

Arguments:
  mpi-type          MPI implementation: mpich or openmpi

Options:
  -h, --help       Show this help message

Examples:
  $0 mpich
  $0 openmpi
  $0 -h
EOF
}

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Error: Unknown option $1"
            usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Check arguments
if [ $# -eq 0 ]; then
    echo "Error: Missing MPI type argument"
    usage
    exit 1
fi

MPI_TYPE=$1

if [ "$MPI_TYPE" != "mpich" ] && [ "$MPI_TYPE" != "openmpi" ]; then
    echo "Error: MPI type must be 'mpich' or 'openmpi', got: $MPI_TYPE"
    usage
    exit 1
fi

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR="$DIR"

echo "Building MPI image for ${MPI_TYPE}..."

# Check if image already exists or needs rebuild
$(ciux get image --check $PROJECT_DIR --suffix "$MPI_TYPE" --env)

# Use ciux to ignite the build with suffix
ciux ignite --selector itest $PROJECT_DIR --suffix "$MPI_TYPE"
. "$PROJECT_DIR/.ciux.d/ciux_itest.sh"

echo "✅ Built MPI image for ${MPI_TYPE}"