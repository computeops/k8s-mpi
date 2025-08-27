FROM ubuntu:18.04

# Install OpenMPI and build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libopenmpi-dev \
        openmpi-bin openssh-client openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Install OpenSSH for MPI to communicate between containers
RUN mkdir -p /var/run/sshd

# Allow OpenSSH to talk to containers without asking for confirmation
# by disabling StrictHostKeyChecking.
# mpi-operator mounts the .ssh folder from a Secret. For that to work, we need
# to disable UserKnownHostsFile to avoid write permissions.
# Disabling StrictModes avoids directory and files read permission checks.
RUN sed -i 's/[ #]\(.*StrictHostKeyChecking \).*/ \1no/g' /etc/ssh/ssh_config && \
    echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config && \
    sed -i 's/#\(StrictModes \).*/\1no/g' /etc/ssh/sshd_config

# Copy and compile the MPI program
COPY src/mpi_hello_world.c /project/
WORKDIR /project
RUN mpicc -o mpi_hello_world mpi_hello_world.c
