# OpenMPI Hello World

Simple MPI "Hello World" application demonstrating distributed execution across 3 worker nodes.

See [main README](../README.md) for prerequisites and setup.

## Quick Start

```bash
# Build and deploy
./e2e/build.sh
./e2e/run-mpi.sh openmpi hello_world

# View results
kubectl logs -n openmpi-cluster -l training.kubeflow.org/job-role=launcher
```

**Expected Output:**
```
Hello world from processor openmpi-job-worker-0, rank 0 out of 3 processors
Hello world from processor openmpi-job-worker-1, rank 1 out of 3 processors
Hello world from processor openmpi-job-worker-2, rank 2 out of 3 processors
```

## Configuration Details

### MPI Options

The launcher uses these OpenMPI options:
- `--allow-run-as-root`: Required for container execution
- `-bind-to none -map-by slot`: Flexible process placement
- `-mca pml ob1`: Point-to-Point Messaging Layer
- `-mca btl ^openib`: Exclude InfiniBand, use TCP

### Container Configuration

**Launcher:**
- Runs `mpirun` command
- Coordinates MPI job execution
- Collects results from workers

**Workers:**
- Run `sshd` daemon for SSH connections
- Execute MPI processes when contacted by launcher
- Return results to launcher

### SSH Communication

OpenMPI uses SSH for:
1. **Process spawning**: Launcher connects to workers via SSH
2. **Command execution**: Starts MPI processes on remote workers
3. **Job coordination**: Manages distributed execution

The SSH setup includes:
- Disabled strict host key checking
- Automatic known_hosts management
- Relaxed security modes for containers

## Customization

### Scaling Workers

To change the number of workers, update both:

1. **Worker replicas** in `manifests/mpijob.yaml`:
```yaml
Worker:
  replicas: 5  # Increase workers
```

2. **Process count** in launcher args:
```yaml
args: ["-np", "5", "--allow-run-as-root", ...]
```

### Custom Applications

1. Replace `src/mpi_hello_world.c` with your MPI code
2. Update Dockerfile if additional dependencies needed:
```dockerfile
RUN apt-get update && apt-get install -y your-package
```
3. Modify launcher command in `manifests/mpijob.yaml`:
```yaml
args: ["-np", "3", "--allow-run-as-root", ..., "./your-app", "arg1", "arg2"]
```

## Troubleshooting

### SSH Connection Issues

Check SSH warnings in logs:
```bash
kubectl logs -n openmpi-cluster -l training.kubeflow.org/job-role=launcher
```

SSH warnings like "Permanently added" are normal for first connections.

### Process Distribution

Verify processes run on different workers:
- Each line should show different `processor` names
- Ranks should be distributed (0, 1, 2, ...)

### Image Pull Issues

Ensure Docker image is built and available:
```bash
docker images | grep openmpi-hello-world
```

## Performance Notes

- **TCP Communication**: Uses Ethernet networking (good for most clusters)
- **SSH Overhead**: Initial SSH connection has small latency
- **Container Networking**: Performance depends on Kubernetes CNI

For high-performance computing, consider:
- Using InfiniBand-capable clusters
- Optimizing container networking
- Using dedicated compute nodes

## Clean Up

```bash
kubectl delete -k manifests/
```