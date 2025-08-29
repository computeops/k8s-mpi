#!/bin/bash
# Build MPI container images using ciux
# @author  Fabrice Jammes

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

usage() {
  cat << EOD

Usage: `basename $0` [options]

  Available options:
    -h        this message
    -t        MPI implementation to build (mpich|openmpi|all, default: all)

Build MPI container images using ciux
EOD
}

mpi_type="all"

# get the options
while getopts ht: c ; do
    case $c in
	    h) usage ; exit 0 ;;
	    t) mpi_type="$OPTARG" ;;
	    \?) usage ; exit 2 ;;
    esac
done
shift `expr $OPTIND - 1`

build_mpi_image() {
    local mpi_impl=$1
    echo "Building $mpi_impl image using ciux"
    
    # Check if image already exists or needs rebuild
    $(ciux get image --check $PROJECT_DIR --suffix "$mpi_impl" --env)
    
    # Use ciux to ignite the build with suffix
    ciux ignite --selector itest $PROJECT_DIR --suffix "$mpi_impl"
    . "$PROJECT_DIR/.ciux.d/ciux_itest.sh"
    
    echo "Building Docker image for $mpi_impl: $CIUX_IMAGE_URL"
    docker image build --tag "$CIUX_IMAGE_URL" "$PROJECT_DIR/$mpi_impl"
    echo "$mpi_impl build successful: $CIUX_IMAGE_URL"
}

if [ "$mpi_type" = "all" ]; then
    build_mpi_image "mpich"
    build_mpi_image "openmpi"
elif [ "$mpi_type" = "mpich" ] || [ "$mpi_type" = "openmpi" ]; then
    build_mpi_image "$mpi_type"
else
    echo "Error: Invalid MPI type '$mpi_type'. Must be 'mpich', 'openmpi', or 'all'"
    exit 1
fi

echo "All builds completed successfully"