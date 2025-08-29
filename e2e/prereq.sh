#!/bin/bash

# Install prerequisites for MPI e2e tests

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

. $DIR/conf.sh

go install github.com/k8s-school/ciux@"$ciux_version"

# Install dependencies using ciux
ciux ignite -l itest "$PROJECT_DIR"

# Get cluster name from ciux
cluster_name=$(ciux get clustername $PROJECT_DIR)

# Create Kubernetes cluster using ktbx
ktbx create --name $cluster_name

# Wait for cluster to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo "Prerequisites installed successfully"