# Label selector: itest
export K8S_MPI_DIR=/home/fjammes/src/github.com/computeops/k8s-mpi
export K8S_MPI_VERSION=caf514c
export K8S_MPI_WORKBRANCH=master
export CIUX_IMAGE_REGISTRY=k8sschool
export CIUX_IMAGE_NAME=k8s-mpi
# Image which contains latest code source changes K8S_MPI_VERSION
export CIUX_IMAGE_TAG=caf514c
export CIUX_IMAGE_URL=k8sschool/k8s-mpi:caf514c
# True if CIUX_IMAGE_URL need to be built
export CIUX_BUILD=true
# Promoted image is the image which will be push if CI run successfully
export CIUX_PROMOTED_IMAGE_URL=k8sschool/k8s-mpi:caf514c