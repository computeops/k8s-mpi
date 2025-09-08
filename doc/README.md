# MPI on Kubernetes Documentation

This directory contains guides for running MPI applications on Kubernetes using the MPI Operator.

## Quick Start

Both examples follow the same pattern:

1. **Setup Prerequisites** (see [main README](../README.md)):
   ```bash
   ./e2e/prereq.sh
   ./e2e/install-mpi-operator.sh
   ```

2. **Build and Deploy**:
   ```bash
   ./e2e/build.sh
   ./e2e/run-mpi.sh [openmpi|mpich] [hello_world|pi]
   ```

3. **View Results**:
   ```bash
   kubectl logs -n [openmpi|mpich]-cluster -l training.kubeflow.org/job-role=launcher
   ```

**Note**: Kubernetes manifests are in `[openmpi|mpich]/manifests/` but require environment variable substitution - use the e2e scripts for deployment.

## Examples

### OpenMPI Hello World
- **Purpose**: Simple "Hello World" from multiple MPI processes
- **Processes**: 3 workers
- **Output**: Greeting from each processor with rank info
- **Guide**: [openmpi.md](openmpi.md)

### MPICH Pi Calculation
- **Purpose**: Monte Carlo π estimation using distributed computing
- **Processes**: 2 workers
- **Output**: Estimated π value with error calculation
- **Guide**: [mpich.md](mpich.md)

## Key Differences

| Feature | OpenMPI | MPICH |
|---------|---------|-------|
| Application | Hello World | Pi calculation |
| Worker Count | 3 | 2 |
| SSH Port | 22 | 2222 |
| User | root | mpiuser (1000) |
| Command Flag | `-np` | `-n` |

## Common Operations

### Scaling Workers
Update both the worker replicas and process count:
```yaml
# In manifests/mpijob.yaml
Worker:
  replicas: 4
# And in launcher args
args: ["-np", "4", ...]  # OpenMPI
args: ["-n", "4", ...]   # MPICH
```

### Monitoring
```bash
# Check job status
kubectl get mpijob -n [namespace]

# View pod status
kubectl get pods -n [namespace]

# Monitor resource usage
kubectl top pods -n [namespace]
```

### Troubleshooting
```bash
# Check launcher logs
kubectl logs -n [namespace] -l training.kubeflow.org/job-role=launcher

# Check worker logs
kubectl logs -n [namespace] -l training.kubeflow.org/job-role=worker

# Verify SSH connectivity (for debugging)
kubectl exec -n [namespace] [pod] -- netstat -ln
```

### Cleanup
```bash
kubectl delete -k manifests/
```

## Architecture

Both examples use the same basic architecture:
```
Launcher Pod
    └── mpirun command
        ├── SSH to Worker 0 → MPI Process (rank 0)
        ├── SSH to Worker 1 → MPI Process (rank 1)
        └── SSH to Worker N → MPI Process (rank N)
```

The launcher coordinates the distributed execution, while workers run SSH daemons and execute MPI processes on demand.