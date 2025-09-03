ARG BASE_LABEL=v0.6.0

FROM mpioperator/openmpi-builder:${BASE_LABEL} AS builder

COPY src/mpi_hello_world.c /src/mpi_hello_world.c
RUN mpic++ /src/mpi_hello_world.c -o /mpi_hello_world

FROM mpioperator/openmpi:${BASE_LABEL}

COPY --from=builder /mpi_hello_world /home/mpiuser/mpi_hello_world
