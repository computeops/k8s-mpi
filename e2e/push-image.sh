#!/usr/bin/env bash

# Push MPI images to Docker Hub or load them inside kind

# @author  Fabrice Jammes

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

usage() {
  cat << EOD

Usage: `basename $0` [options]

  Available options:
    -h          this message
    -k          development mode: load image in kind
    -d          do not push image to remote registry
    -t          MPI implementation to push (mpich|openmpi|all, default: all)

Push MPI images to remote registry and/or load them inside kind
EOD
}

kind=false
registry=true
mpi_type="all"

# get the options
while getopts dhkt: c ; do
    case $c in
	    h) usage ; exit 0 ;;
	    k) kind=true ;;
	    d) registry=false ;;
	    t) mpi_type="$OPTARG" ;;
	    \?) usage ; exit 2 ;;
    esac
done
shift `expr $OPTIND - 1`

push_mpi_image() {
    local mpi_impl=$1
    echo "Processing $mpi_impl image"
    
    # Get image URL with suffix
    $(ciux get image --check $PROJECT_DIR --suffix "$mpi_impl" --env)
    
    if [ $kind = true ]; then
        cluster_name=$(ciux get clustername $PROJECT_DIR)
        echo "Loading $CIUX_IMAGE_URL into kind cluster $cluster_name"
        kind load docker-image "$CIUX_IMAGE_URL" --name "$cluster_name"
    fi
    
    if [ $registry = true ]; then
        echo "Pushing $CIUX_IMAGE_URL to registry"
        docker push "$CIUX_IMAGE_URL"
    fi
}

if [ "$mpi_type" = "all" ]; then
    push_mpi_image "mpich"
    push_mpi_image "openmpi"
elif [ "$mpi_type" = "mpich" ] || [ "$mpi_type" = "openmpi" ]; then
    push_mpi_image "$mpi_type"
else
    echo "Error: Invalid MPI type '$mpi_type'. Must be 'mpich', 'openmpi', or 'all'"
    exit 1
fi

echo "Image push operations completed successfully"