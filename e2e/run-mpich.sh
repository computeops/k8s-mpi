#!/bin/bash

# Test MPICH Pi calculation example

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

. $DIR/conf.sh

echo "Testing MPICH Pi calculation..."

# Use ciux to get MPICH image URL with suffix
$(ciux get image --check $PROJECT_DIR --suffix "mpich" --env)

# Extract image name and tag for kustomize
export CIUX_IMAGE_NAME=$(echo $CIUX_IMAGE_URL | cut -d':' -f1)
export CIUX_IMAGE_TAG=$(echo $CIUX_IMAGE_URL | cut -d':' -f2)

# Deploy MPICH job
# Generate kustomization.yaml from template
envsubst < $PROJECT_DIR/mpich/manifests/kustomization.yaml.tpl > $PROJECT_DIR/mpich/manifests/kustomization.yaml
kubectl apply -k $PROJECT_DIR/mpich/manifests

# Wait for job completion
if ! kubectl wait --for=condition=Succeeded mpijob/mpich-pi-job -n mpich-cluster --timeout="${job_timeout}s"; then
    echo "Job failed to complete, debugging..."
    echo "Pods in mpich-cluster namespace:"
    kubectl get pods -n mpich-cluster
    echo "Job status:"
    kubectl describe mpijob/mpich-pi-job -n mpich-cluster
    echo "Pod logs:"
    kubectl logs -n mpich-cluster --all-containers=true --prefix=true
    exit 1
fi

# Get logs
echo "MPICH job completed. Logs:"
kubectl logs -n mpich-cluster -l training.kubeflow.org/job-role=launcher

# Verify expected output
logs=$(kubectl logs -n mpich-cluster -l training.kubeflow.org/job-role=launcher)
if echo "$logs" | grep -q "pi is approximately" && echo "$logs" | grep -q "Error is"; then
    echo "✅ MPICH test PASSED"
else
    echo "❌ MPICH test FAILED - Expected output not found"
    exit 1
fi

echo "MPICH job completed successfully"