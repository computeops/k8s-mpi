#!/bin/bash

# Test MPI implementations using Helm chart

set -euxo pipefail

# Function to check if logs contain expected output
check_logs() {
    local namespace=$1
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

usage() {
    cat << EOF
Usage: $0 [OPTIONS] <mpi-type> <program>

Test MPI implementations using Helm chart.

Arguments:
  mpi-type          MPI implementation: mpich or openmpi
  program          Program to run: hello_world or pi

Options:
  -h, --help       Show this help message

Examples:
  $0 mpich pi
  $0 openmpi hello_world
EOF
}

# Parse options
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "Error: Unknown option $1"
            usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Check if parameters are provided
if [ $# -lt 2 ]; then
    echo "Error: Missing required arguments"
    usage
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

echo "Testing $MPI_TYPE with $PROGRAM program using Helm..."

# Use ciux to get MPI image URL with suffix
$(ciux get image --check $PROJECT_DIR --suffix "$MPI_TYPE" --env)

# Extract image name and tag
export CIUX_IMAGE_NAME=$(echo $CIUX_IMAGE_URL | cut -d':' -f1)
export CIUX_IMAGE_TAG=$(echo $CIUX_IMAGE_URL | cut -d':' -f2)

# Set variables
NAMESPACE="mpi-cluster"
JOB_NAME="mpi-job"
HELM_RELEASE="mpi-test-${MPI_TYPE}"

# Install Helm chart
echo "Installing Helm release: $HELM_RELEASE"
helm upgrade --install $HELM_RELEASE "$PROJECT_DIR/mpi-chart" \
    --set mpiType="$MPI_TYPE" \
    --set program="$PROGRAM" \
    --set image.name="$CIUX_IMAGE_NAME" \
    --set image.tag="$CIUX_IMAGE_TAG" \
    --set job.namespace="$NAMESPACE" \
    --wait --timeout=60s

echo "Waiting for job to complete..."

SUCCESS=false

# Wait for job completion by checking logs
for i in $(seq 1 60); do
    sleep 5
    diagnose
    if check_logs $NAMESPACE $PROGRAM; then
        echo "✅ Job completed successfully (detected from logs)"
        SUCCESS=true
        break
    fi
    echo "Waiting for job completion... ($((i*5))s elapsed)"
done

# Wait using kubectl wait as backup
job_timeout=300
if kubectl wait --for=condition=Succeeded mpijob/$JOB_NAME -n $NAMESPACE --timeout="${job_timeout}s"; then
    echo "✅ mpijob/$JOB_NAME in 'Succeeded' state"
else
    echo "⚠️ kubectl wait failed or timed out"
fi

# Show final logs
echo "Final job logs:"
kubectl logs -n $NAMESPACE -l training.kubeflow.org/job-role=launcher || true

# Cleanup
echo "Cleaning up Helm release: $HELM_RELEASE"
helm uninstall $HELM_RELEASE || true

# If both methods failed, debug and exit
if [ "$SUCCESS" = "false" ]; then
    echo "❌ Job failed to complete successfully"
    echo "Pods in $NAMESPACE namespace:"
    kubectl get pods -n $NAMESPACE
    echo "Job status:"
    kubectl describe mpijob/$JOB_NAME -n $NAMESPACE
    exit 1
fi

echo "✅ $MPI_TYPE test with $PROGRAM completed successfully!"