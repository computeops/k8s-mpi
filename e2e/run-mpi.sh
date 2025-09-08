#!/bin/bash

# Test MPI implementations (MPICH or OpenMPI)

set -euxo pipefail

# Function to check if logs contain expected output
check_logs() {
    local mpi_type=$1
    local namespace="$NAMESPACE"
    local logs=$(kubectl logs -n $namespace -l training.kubeflow.org/job-role=launcher 2>/dev/null || echo "")


    # Check for different expected outputs based on program
    local program=$2
    if [ "$program" = "pi" ]; then
        if echo "$logs" | grep -q "pi is approximately" && echo "$logs" | grep -q "Error is"; then
            return 0
        fi
    elif [ "$program" = "hello_world" ]; then
        if echo "$logs" | grep -q "Hello world from processor.*rank.*out of.*processors"; then
            return 0
        fi
    fi

    return 1
}

# Function to diagnose current state
diagnose() {
    echo "Checking job status..."
    kubectl get pods -n $NAMESPACE -o wide
    kubectl get svc -n $NAMESPACE -o wide
    kubectl get endpoints -n $NAMESPACE
    kubectl describe mpijob $JOB_NAME -n $NAMESPACE
}

# Check if parameters are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <mpi-type> <program>"
    echo "  mpi-type: mpich or openmpi"
    echo "  program: hello_world or pi"
    exit 1
fi

MPI_TYPE=$1
PROGRAM=$2

# Validate MPI type
if [ "$MPI_TYPE" != "mpich" ] && [ "$MPI_TYPE" != "openmpi" ]; then
    echo "Error: MPI type must be 'mpich' or 'openmpi'"
    exit 1
fi

# Validate program
if [ "$PROGRAM" != "hello_world" ] && [ "$PROGRAM" != "pi" ]; then
    echo "Error: Program must be 'hello_world' or 'pi'"
    exit 1
fi

DIR=$(cd "$(dirname "$0")"; pwd -P)
PROJECT_DIR=$(cd "$DIR/.."; pwd -P)

. $DIR/conf.sh

echo "Testing $MPI_TYPE with $PROGRAM program..."

# Use ciux to get MPI image URL with suffix
$(ciux get image --check $PROJECT_DIR --suffix "$MPI_TYPE" --env)

# Extract image name and tag for kustomize
export CIUX_IMAGE_NAME=$(echo $CIUX_IMAGE_URL | cut -d':' -f1)
export CIUX_IMAGE_TAG=$(echo $CIUX_IMAGE_URL | cut -d':' -f2)

# Export program for use in templates
export PROGRAM

# Set MPI-specific variables
if [ "$MPI_TYPE" = "mpich" ]; then
    JOB_NAME="mpich-job"
    TEST_NAME="MPICH Pi calculation"
else
    JOB_NAME="openmpi-job"
    TEST_NAME="OpenMPI Pi calculation"
fi

pgm=$(echo $PROGRAM | tr '_' '-') # Replace underscores with hyphens for job name
export NAMESPACE="${MPI_TYPE}-$pgm"

echo "Running $TEST_NAME..."

# Delete namespace if it exists
echo "Deleting namespace $NAMESPACE if it exists..."
kubectl delete namespace -l "kubernetes.io/metadata.name=$NAMESPACE" --wait=true

# Deploy MPI job
# Generate kustomization.yaml from template
envsubst < $PROJECT_DIR/$MPI_TYPE/manifests/kustomization.yaml.tpl > $PROJECT_DIR/$MPI_TYPE/manifests/kustomization.yaml
kubectl apply -k $PROJECT_DIR/$MPI_TYPE/manifests

# Wait for job completion with workaround for MPI Operator status sync delays
echo "Waiting for MPI job to complete..."
SUCCESS=false

# Wait for launcher pod to be created and ready
echo "Waiting for launcher pod to be created..."
for i in $(seq 1 24); do
    if kubectl get pod -l training.kubeflow.org/job-role=launcher -n $NAMESPACE 2>/dev/null | grep -q launcher; then
        echo "Launcher pod found"
        break
    fi
    sleep 5
    echo "Waiting for launcher pod creation... ($((i*5))s elapsed)"
done

# First try: Wait for successful completion via logs (workaround for operator delays)
for i in $(seq 1 60); do
    sleep 5
    diagnose
    if check_logs $MPI_TYPE $PROGRAM; then
        echo "✅ Job completed successfully (detected from logs)"
        SUCCESS=true
        break
    fi
    echo "Waiting for job completion... ($((i*5))s elapsed)"
done

# If failed, debug and exit
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

# Check if job succeed (seems there is an mpi-operator issue here, job fail be Failed even if task succeed)
if kubectl wait --for=condition=Succeeded mpijob/$JOB_NAME -n $NAMESPACE --timeout="${job_timeout}s"; then
    echo "✅ mpijob/$JOB_NAME in 'Succeeded' state"
else
    echo "⚠️ kubectl wait failed or timed out"
fi

# Get logs
echo "$TEST_NAME completed. Logs:"
kubectl logs -n $NAMESPACE -l training.kubeflow.org/job-role=launcher

