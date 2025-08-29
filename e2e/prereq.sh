#!/bin/bash

# Install prerequisites for MPI e2e tests

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

. $DIR/conf.sh

# Get cluster name from ciux
cluster_name=$(ciux get clustername $PROJECT_DIR)

# Create Kubernetes cluster using ktbx
ktbx create --name $cluster_name

# Wait for cluster to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Install MPI Operator
kubectl apply --server-side -f "https://raw.githubusercontent.com/kubeflow/mpi-operator/${mpi_operator_version}/deploy/v2beta1/mpi-operator.yaml"

# Wait for MPI Operator to be ready
kubectl wait --for=condition=Available deployment/mpi-operator -n mpi-operator --timeout=300s

echo "Prerequisites installed successfully"