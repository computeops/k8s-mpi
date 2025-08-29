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

## Quick Start

### Install MPI Operator

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/kubeflow/mpi-operator/v0.6.0/deploy/v2beta1/mpi-operator.yaml
```

## References

- [MPI Operator Documentation](https://github.com/kubeflow/mpi-operator)
- [OpenMPI Documentation](https://www.open-mpi.org/doc/)
- [Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
