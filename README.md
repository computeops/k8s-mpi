# k8s-mpi

OpenMPI applications running on Kubernetes using the MPI Operator.

## Project Structure

```
k8s-mpi/
├── README.md
└── openmpi/
    ├── Dockerfile              # OpenMPI container image
    ├── src/
    │   └── mpi_hello_world.c   # MPI application source code
    ├── manifests/
    │   ├── namespace.yaml      # Kubernetes namespace
    │   ├── mpijob.yaml         # MPIJob configuration
    │   └── kustomization.yaml  # Kustomize configuration
    └── scripts/
        └── build.sh            # Docker image build script
```

## Prerequisites

- Kubernetes cluster (>= 1.16)
- Docker or compatible container runtime
- kubectl configured for your cluster
- MPI Operator installed

## Quick Start

### 1. Install MPI Operator

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/kubeflow/mpi-operator/v0.6.0/deploy/v2beta1/mpi-operator.yaml
```

### 2. Build the Docker Image

```bash
cd openmpi
./scripts/build.sh
```

### 3. Deploy the MPI Job

```bash
cd openmpi
kubectl apply -k manifests/
```

### 4. Check Results

```bash
# Wait for job completion
kubectl wait --for=condition=Succeeded mpijob/openmpi-job -n openmpi-cluster --timeout=300s

# View results
kubectl logs -n openmpi-cluster -l training.kubeflow.org/job-role=launcher
```

Expected output:
```
Hello world from processor openmpi-job-worker-0, rank 0 out of 3 processors
Hello world from processor openmpi-job-worker-1, rank 1 out of 3 processors  
Hello world from processor openmpi-job-worker-2, rank 2 out of 3 processors
```

## Configuration

### MPIJob Parameters

- **Replicas**: 3 worker nodes
- **Slots per worker**: 1 MPI process per worker
- **Image**: `k8sschool/openmpi-hello-world:latest`

### MPI Options

The job uses OpenMPI with these optimizations:
- `--allow-run-as-root`: Allows running in container environment
- `-bind-to none -map-by slot`: Flexible process placement
- `-mca pml ob1 -mca btl ^openib`: TCP communication (no InfiniBand)

## Customization

### Adding Your Own MPI Application

1. Replace `src/mpi_hello_world.c` with your MPI code
2. Update the Dockerfile if needed (additional dependencies)
3. Rebuild the image: `./scripts/build.sh`
4. Update `manifests/mpijob.yaml` with the new command/args
5. Redeploy: `kubectl apply -k manifests/`

### Scaling Workers

Edit `manifests/mpijob.yaml`:
```yaml
Worker:
  replicas: 5  # Change number of workers
```

Update the `-np` parameter accordingly:
```yaml
args: ["-np", "5", "--allow-run-as-root", ...]
```

## Troubleshooting

### Check MPI Operator

```bash
kubectl get pods -n mpi-operator
```

### View Job Status

```bash
kubectl get mpijob -n openmpi-cluster
kubectl describe mpijob openmpi-job -n openmpi-cluster
```

### Debug Worker Issues

```bash
kubectl logs -n openmpi-cluster -l training.kubeflow.org/job-role=worker
```

### Common Issues

1. **Image Pull Error**: Ensure the Docker image is available in your registry
2. **SSH Connection Failed**: Check if MPI operator is properly installed
3. **Permission Denied**: Verify `--allow-run-as-root` flag is present

## Clean Up

```bash
kubectl delete -k manifests/
```

## References

- [MPI Operator Documentation](https://github.com/kubeflow/mpi-operator)
- [OpenMPI Documentation](https://www.open-mpi.org/doc/)
- [Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/)