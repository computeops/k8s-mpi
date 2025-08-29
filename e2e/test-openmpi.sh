#!/bin/bash

# Test OpenMPI Hello World example

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

. $DIR/conf.sh

echo "Testing OpenMPI Hello World..."

# Use ciux to get OpenMPI image URL with suffix
$(ciux get image --check $PROJECT_DIR --suffix "openmpi" --env)

# Deploy OpenMPI job
kubectl apply -k manifests/

# Wait for job completion
kubectl wait --for=condition=Succeeded mpijob/openmpi-job -n openmpi-cluster --timeout="${job_timeout}s"

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

# Clean up
kubectl delete -k manifests/

echo "OpenMPI test completed successfully"