ARG BASE_LABEL=v0.6.0

FROM mpioperator/mpich-builder:${BASE_LABEL} AS builder

COPY src/ /src/
RUN mkdir /build
RUN mpic++ /src/pi.cc -o /build/pi
RUN mpic++ /src/hello_world.c -o /build/hello_world

FROM mpioperator/mpich:${BASE_LABEL}

COPY --from=builder /build/* /home/mpiuser/
