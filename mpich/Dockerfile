ARG BASE_LABEL=v0.6.0

FROM mpioperator/mpich-builder:${BASE_LABEL} AS builder

COPY src/pi.cc /src/pi.cc
RUN mpic++ /src/pi.cc -o /pi

FROM mpioperator/mpich:${BASE_LABEL}

COPY --from=builder /pi /home/mpiuser/pi
