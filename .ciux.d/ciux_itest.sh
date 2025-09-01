# Label selector: itest
export K8S_MPI_DIR=/home/fjammes/src/github.com/computeops/k8s-mpi
export K8S_MPI_VERSION=1752372
export K8S_MPI_WORKBRANCH=master
export CIUX_IMAGE_REGISTRY=k8sschool
export CIUX_IMAGE_NAME=k8s-mpi-openmpi
# Image which contains latest code source changes K8S_MPI_VERSION
export CIUX_IMAGE_TAG=9673352
export CIUX_IMAGE_URL=k8sschool/k8s-mpi-openmpi:9673352
# True if CIUX_IMAGE_URL need to be built
export CIUX_BUILD=false
# Promoted image is the image which will be push if CI run successfully
export CIUX_PROMOTED_IMAGE_URL=k8sschool/k8s-mpi-openmpi:1752372