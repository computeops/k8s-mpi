# k8s-mpi

MPI applications (OpenMPI and MPICH) running on Kubernetes using the MPI Operator.

## Examples

- **[OpenMPI Hello World](doc/openmpi.md)** - Simple distributed "Hello World" across 3 workers
- **[MPICH Pi Calculation](doc/mpich.md)** - Monte Carlo π estimation using 2 workers

## Documentation

See [doc/README.md](doc/README.md) for complete guides and common operations.

## Prerequisites

- Docker or compatible container runtime
- Go 1.21.4 or later (for building and testing)

## End-to-End Testing

Complete automated testing workflow using ciux and ktbx:

### Prerequisites
```bash
# Install dependencies and MPI operator
./e2e/prereq.sh
./e2e/install-mpi-operator.sh
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
./e2e/run-mpi.sh mpi pi
./e2e/run-mpi.sh openmpi hello_world

# Or run complete workflow
./e2e/run-all.sh
```

### Cleanup
```bash
# Automatically detect and clean up resources
./e2e/cleanup.sh
```


## References

- [MPI Operator Documentation](https://github.com/kubeflow/mpi-operator)
- [OpenMPI Documentation](https://www.open-mpi.org/doc/)
- [Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)
