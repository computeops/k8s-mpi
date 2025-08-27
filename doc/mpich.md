# MPICH on Kubernetes

This guide covers the MPICH Pi calculation example using the MPI Operator.

## Overview

The MPICH example demonstrates a Monte Carlo π calculation that:
- Uses 2 MPI processes to estimate π
- Employs MPICH implementation
- Shows distributed numerical computation
- Based on the official MPI Operator pi example

## Algorithm

The Monte Carlo method estimates π by:
1. Generating random points in a unit square [0,1] × [0,1]
2. Counting points inside a quarter circle (x² + y² ≤ 1)
3. Using the ratio: π ≈ 4 × (points_inside / total_points)

Each MPI process generates 10,000,000 random points independently, then results are combined using `MPI_Reduce`.

## Architecture

```
Launcher Pod (rank 0)
    └── mpirun -n 2
        ├── SSH to Worker 0 → Pi calculation process (rank 0)
        ├── SSH to Worker 1 → Pi calculation process (rank 1)
        └── Reduce results → Final π estimate
```

## Quick Start

### 1. Install MPI Operator

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/kubeflow/mpi-operator/v0.6.0/deploy/v2beta1/mpi-operator.yaml
```

### 2. Build and Deploy

```bash
cd mpich
./scripts/build.sh
kubectl apply -k manifests/
```

### 3. Check Results

```bash
kubectl logs -n mpich-cluster -l training.kubeflow.org/job-role=launcher
```

Expected output:
```
pi is approximately 3.1416263514159734
Error is 0.0000336920000599
```

## Configuration Details

### MPIJob Specification

Key differences from OpenMPI example:

**MPICH Implementation:**
```yaml
mpiImplementation: MPICH
sshAuthMountPath: /home/mpiuser/.ssh
```

**SSH Configuration:**
```yaml
args:
- /usr/sbin/sshd
- -De
- -f
- /home/mpiuser/.sshd_config
```

**Readiness Probe:**
```yaml
readinessProbe:
  tcpSocket:
    port: 2222
  initialDelaySeconds: 2
```

### User Configuration

Unlike OpenMPI example that may run as root, MPICH example:
- Runs as user ID 1000 (mpiuser)
- Uses custom SSH configuration
- SSH daemon listens on port 2222 (non-privileged)

### Container Structure

**Launcher:**
- Executes `mpirun -n 2 /project/pi`
- Coordinates distributed calculation
- Collects and displays final result

**Workers:**
- Run SSH daemon on port 2222
- Wait for MPI process spawning
- Execute pi calculation when called

## MPICH vs OpenMPI

| Aspect | MPICH | OpenMPI |
|--------|--------|---------|
| SSH Port | 2222 (non-privileged) | 22 (standard) |
| User | mpiuser (1000) | Often root |
| Config | Custom .sshd_config | System config |
| Readiness | TCP probe | No probe needed |
| MPI Launch | `-n` flag | `-np` flag |

## Customization

### Adjusting Precision

Modify the number of random samples in `src/pi.cc`:
```cpp
int worker_tests = 100000000;  // More samples = better precision
```

Higher values increase computation time but improve accuracy.

### Scaling Workers

1. **Update worker count** in `manifests/mpijob.yaml`:
```yaml
Worker:
  replicas: 4
```

2. **Update process count** in launcher args:
```yaml
args:
- mpirun
- -n
- "4"  # Match worker replicas
- /project/pi
```

### Custom Random Seeds

The algorithm uses different seeds per MPI rank:
```cpp
generator.seed(rank + 42);
```

This ensures different random sequences per process for statistical independence.

## Performance Tuning

### Computational Intensity

- **More workers**: Better parallel efficiency
- **More samples**: Higher precision but longer runtime
- **Memory usage**: Minimal (algorithm is compute-bound)

### Network Communication

MPICH uses minimal network communication:
- Only final `MPI_Reduce` operation
- Most time spent in local computation
- Good scalability characteristics

## Monitoring

### Check Job Progress

```bash
# Job status
kubectl get mpijob mpich-pi-job -n mpich-cluster

# Worker readiness
kubectl get pods -n mpich-cluster -l training.kubeflow.org/job-role=worker
```

### Resource Usage

```bash
# CPU/Memory usage
kubectl top pods -n mpich-cluster
```

Pi calculation is CPU-intensive, expect high CPU utilization during execution.

## Troubleshooting

### SSH Connection Issues

Check SSH daemon status on workers:
```bash
kubectl logs -n mpich-cluster <worker-pod-name>
```

### Readiness Probe Failures

Verify SSH daemon is listening on port 2222:
```bash
kubectl exec -n mpich-cluster <worker-pod> -- netstat -ln | grep 2222
```

### Calculation Errors

The Monte Carlo method has inherent statistical variation. Multiple runs will produce slightly different results - this is expected.

### Custom SSH Config Missing

Ensure the image includes `/home/mpiuser/.sshd_config`. Check Dockerfile SSH setup.

## Mathematical Background

The Monte Carlo estimation converges as:
- **Error ∝ 1/√N**: Error decreases with square root of sample size
- **Confidence intervals**: Results vary due to random sampling
- **Parallel efficiency**: Linear speedup with more processes (embarrassingly parallel)

## Clean Up

```bash
kubectl delete -k manifests/
```