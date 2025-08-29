#!/bin/bash

# Clean up MPI resources by automatically detecting installed namespaces

set -euxo pipefail

echo "Detecting and cleaning up MPI namespaces..."

# Check for MPICH namespace and delete it
if kubectl get namespace mpich-cluster 2>/dev/null >/dev/null; then
    echo "Found mpich-cluster namespace, deleting..."
    kubectl delete namespace mpich-cluster
    echo "mpich-cluster namespace deleted"
else
    echo "mpich-cluster namespace not found"
fi

# Check for OpenMPI namespace and delete it
if kubectl get namespace openmpi-cluster 2>/dev/null >/dev/null; then
    echo "Found openmpi-cluster namespace, deleting..."
    kubectl delete namespace openmpi-cluster
    echo "openmpi-cluster namespace deleted"
else
    echo "openmpi-cluster namespace not found"
fi

echo "Cleanup completed successfully"