#!/usr/bin/env bash

# Install MPI Operator in Kubernetes cluster
# @author  Fabrice Jammes

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

. $DIR/conf.sh

echo "Installing MPI Operator..."

# Install MPI Operator
kubectl apply --server-side -f "https://raw.githubusercontent.com/kubeflow/mpi-operator/${mpi_operator_version}/deploy/v2beta1/mpi-operator.yaml"

# Wait for MPI Operator to be ready
kubectl wait --for=condition=Available deployment/mpi-operator -n mpi-operator --timeout=300s

echo "MPI Operator installed successfully"