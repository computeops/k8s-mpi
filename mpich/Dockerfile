FROM ubuntu:18.04

# Install MPICH and build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libmpich-dev \
        mpich \
        openssh-client \
        openssh-server && \
    rm -rf /var/lib/apt/lists/*

# Create MPI user
RUN useradd -m -s /bin/bash -u 1000 mpiuser

# Install OpenSSH for MPI to communicate between containers
RUN mkdir -p /var/run/sshd

# Allow OpenSSH to talk to containers without asking for confirmation
RUN sed -i 's/[ #]\(.*StrictHostKeyChecking \).*/ \1no/g' /etc/ssh/ssh_config && \
    echo "    UserKnownHostsFile /dev/null" >> /etc/ssh/ssh_config && \
    sed -i 's/#\(StrictModes \).*/\1no/g' /etc/ssh/sshd_config

# Copy and compile the MPI program
COPY src/pi.cc /project/
RUN cd /project && mpic++ -o pi pi.cc
RUN chown -R mpiuser:mpiuser /project

# Switch to MPI user
USER mpiuser
WORKDIR /project