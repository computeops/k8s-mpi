#!/bin/bash

# Test MPI implementations (MPICH or OpenMPI)

set -euxo pipefail

# Check if MPI type is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <mpi-type>"
    echo "  mpi-type: mpich or openmpi"
    exit 1
fi

MPI_TYPE=$1

# Validate MPI type
if [ "$MPI_TYPE" != "mpich" ] && [ "$MPI_TYPE" != "openmpi" ]; then
    echo "Error: MPI type must be 'mpich' or 'openmpi'"
    exit 1
fi

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

. $DIR/conf.sh

echo "Testing $MPI_TYPE..."

# Use ciux to get MPI image URL with suffix
$(ciux get image --check $PROJECT_DIR --suffix "$MPI_TYPE" --env)

# Extract image name and tag for kustomize
export CIUX_IMAGE_NAME=$(echo $CIUX_IMAGE_URL | cut -d':' -f1)
export CIUX_IMAGE_TAG=$(echo $CIUX_IMAGE_URL | cut -d':' -f2)

# Set MPI-specific variables
if [ "$MPI_TYPE" = "mpich" ]; then
    NAMESPACE="mpich-cluster"
    JOB_NAME="mpich-pi-job"
    EXPECTED_OUTPUT="pi is approximately.*Error is"
    TEST_NAME="MPICH Pi calculation"
else
    NAMESPACE="openmpi-cluster"
    JOB_NAME="openmpi-job"
    EXPECTED_OUTPUT="Hello world from processor.*rank.*out of.*processors"
    TEST_NAME="OpenMPI Hello World"
fi

echo "Running $TEST_NAME..."

# Deploy MPI job
# Generate kustomization.yaml from template
envsubst < $PROJECT_DIR/$MPI_TYPE/manifests/kustomization.yaml.tpl > $PROJECT_DIR/$MPI_TYPE/manifests/kustomization.yaml
kubectl apply -k $PROJECT_DIR/$MPI_TYPE/manifests

# Wait for job completion with workaround for MPI Operator status sync delays
echo "Waiting for MPI job to complete..."
SUCCESS=false

# Wait for launcher pod to be ready first
echo "Waiting for launcher pod to be ready..."
kubectl wait --for=condition=Ready pod -l training.kubeflow.org/job-role=launcher -n $NAMESPACE --timeout=120s

# First try: Wait for successful completion via logs (workaround for operator delays)
for i in $(seq 1 60); do
    sleep 5
    logs=$(kubectl logs -n $NAMESPACE -l training.kubeflow.org/job-role=launcher 2>/dev/null || echo "")
    if [ "$MPI_TYPE" = "mpich" ]; then
        if echo "$logs" | grep -q "pi is approximately" && echo "$logs" | grep -q "Error is"; then
            echo "✅ Job completed successfully (detected from logs)"
            SUCCESS=true
            break
        fi
    else
        if echo "$logs" | grep -q "$EXPECTED_OUTPUT"; then
            echo "✅ Job completed successfully (detected from logs)"
            SUCCESS=true
            break
        fi
    fi
    echo "Waiting for job completion... ($((i*5))s elapsed)"
done

# Second try: Fall back to kubectl wait if log detection failed
if [ "$SUCCESS" = "false" ]; then
    if kubectl wait --for=condition=Succeeded mpijob/$JOB_NAME -n $NAMESPACE --timeout="${job_timeout}s"; then
        SUCCESS=true
    fi
fi

# If both methods failed, debug and exit
if [ "$SUCCESS" = "false" ]; then
    echo "Job failed to complete, debugging..."
    echo "Pods in $NAMESPACE namespace:"
    kubectl get pods -n $NAMESPACE
    echo "Job status:"
    kubectl describe mpijob/$JOB_NAME -n $NAMESPACE
    
    echo "Logs from all pods:"
    for pod in $(kubectl get pods -n $NAMESPACE -o name); do
        echo "=== Logs for $pod ==="
        kubectl logs -n $NAMESPACE $pod --all-containers=true || echo "Failed to get logs for $pod"
    done
    
    exit 1
fi

# Get logs
echo "$TEST_NAME completed. Logs:"
kubectl logs -n $NAMESPACE -l training.kubeflow.org/job-role=launcher

# Verify expected output
logs=$(kubectl logs -n $NAMESPACE -l training.kubeflow.org/job-role=launcher)
if echo "$logs" | grep -q "$EXPECTED_OUTPUT"; then
    echo "✅ $MPI_TYPE test PASSED"
else
    echo "❌ $MPI_TYPE test FAILED - Expected output not found"
    exit 1
fi

echo "$MPI_TYPE job completed successfully"