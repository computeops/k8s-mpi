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
envsubst < $PROJECT_DIR/mpich/manifests/kustomization.yaml | kubectl apply -k - --dry-run=client -o yaml | kubectl apply -f -

# Wait for job completion
kubectl wait --for=condition=Succeeded mpijob/mpich-pi-job -n mpich-cluster --timeout="${job_timeout}s"

# Get logs
echo "MPICH job completed. Logs:"
kubectl logs -n mpich-cluster -l training.kubeflow.org/job-role=launcher

# Verify expected output
logs=$(kubectl logs -n mpich-cluster -l training.kubeflow.org/job-role=launcher)
if echo "$logs" | grep -q "pi is approximately.*Error is"; then
    echo "✅ MPICH test PASSED"
else
    echo "❌ MPICH test FAILED - Expected output not found"
    exit 1
fi

echo "MPICH job completed successfully"