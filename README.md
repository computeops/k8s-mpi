# k8s-mpi

MPI applications (OpenMPI and MPICH) running on Kubernetes using the MPI Operator.

## Examples

### OpenMPI Hello World
Simple MPI hello world application demonstrating basic distributed execution.

### MPICH Pi Calculation
Monte Carlo method to calculate π using distributed computing.

## Documentation

- [OpenMPI Guide](doc/openmpi.md) - Detailed OpenMPI setup and usage
- [MPICH Guide](doc/mpich.md) - Detailed MPICH setup and usage

## Prerequisites

- Kubernetes cluster (>= 1.16)
- Docker or compatible container runtime
- kubectl configured for your cluster

## End-to-End Testing

Complete automated testing workflow using ciux and ktbx:

### Prerequisites
```bash
# Install dependencies
# Setup Kubernetes cluster and MPI operator
./e2e/prereq.sh
```

### Build and Deploy
```bash
# Build container images (with ciux optimization)
./e2e/build.sh

# Push images to registry or load into kind cluster
# For kind development: ./e2e/push-image.sh -k
# For registry: ./e2e/push-image.sh
./e2e/push-image.sh
```

### Run Tests
```bash
# Run individual MPI implementations
./e2e/run-mpich.sh
./e2e/run-openmpi.sh

# Or run complete workflow
./e2e/run-all.sh
```

### Cleanup
```bash
# Automatically detect and clean up resources
./e2e/cleanup.sh
```

## Manual Quick Start

### Install MPI Operator

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/kubeflow/mpi-operator/v0.6.0/deploy/v2beta1/mpi-operator.yaml
```

## References

- [MPI Operator Documentation](https://github.com/kubeflow/mpi-operator)
- [OpenMPI Documentation](https://www.open-mpi.org/doc/)
- [Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
