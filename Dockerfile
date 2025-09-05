ARG BASE_LABEL=v0.6.0
ARG MPI_TYPE=mpich

FROM mpioperator/${MPI_TYPE}-builder:${BASE_LABEL} AS builder

COPY src/ /src/
RUN mkdir /build
RUN mpic++ /src/pi.cc -o /build/pi
RUN mpic++ /src/hello_world.c -o /build/hello_world

FROM mpioperator/${MPI_TYPE}:${BASE_LABEL}

COPY --from=builder /build/* /home/mpiuser/