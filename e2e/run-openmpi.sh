#!/bin/bash

# Test OpenMPI Hello World example

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

. $DIR/conf.sh

echo "Testing OpenMPI Hello World..."

# Use ciux to get OpenMPI image URL with suffix
$(ciux get image --check $PROJECT_DIR --suffix "openmpi" --env)

# Extract image name and tag for kustomize
export CIUX_IMAGE_NAME=$(echo $CIUX_IMAGE_URL | cut -d':' -f1)
export CIUX_IMAGE_TAG=$(echo $CIUX_IMAGE_URL | cut -d':' -f2)

# Deploy OpenMPI job
# Generate kustomization.yaml from template
envsubst < $PROJECT_DIR/openmpi/manifests/kustomization.yaml.tpl > $PROJECT_DIR/openmpi/manifests/kustomization.yaml
kubectl apply -k $PROJECT_DIR/openmpi/manifests

# Wait for job completion
if ! kubectl wait --for=condition=Succeeded mpijob/openmpi-job -n openmpi-cluster --timeout="${job_timeout}s"; then
    echo "Job failed to complete, debugging..."
    echo "Pods in openmpi-cluster namespace:"
    kubectl get pods -n openmpi-cluster
    echo "Job status:"
    kubectl describe mpijob/openmpi-job -n openmpi-cluster
    exit 1
fi

# Get logs
echo "OpenMPI job completed. Logs:"
kubectl logs -n openmpi-cluster -l training.kubeflow.org/job-role=launcher

# Verify expected output
logs=$(kubectl logs -n openmpi-cluster -l training.kubeflow.org/job-role=launcher)
if echo "$logs" | grep -q "Hello world from processor.*rank.*out of.*processors"; then
    echo "✅ OpenMPI test PASSED"
else
    echo "❌ OpenMPI test FAILED - Expected output not found"
    exit 1
fi

echo "OpenMPI job completed successfully"
