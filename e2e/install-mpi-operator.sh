#!/usr/bin/env bash

# Install MPI Operator in Kubernetes cluster
# @author  Fabrice Jammes

set -euxo pipefail

echo "Installing MPI Operator..."

kubectl apply -f https://raw.githubusercontent.com/kubeflow/mpi-operator/master/deploy/v2beta1/mpi-operator.yaml

echo "Waiting for MPI Operator to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mpi-operator -n mpi-operator

echo "MPI Operator installed successfully"