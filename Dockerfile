ARG CUDA_VERSION=13.1.1
ARG UBUNTU_VERSION=22.04

FROM nvidia/cuda:$CUDA_VERSION-devel-ubuntu$UBUNTU_VERSION

ARG USERNAME=student

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    build-essential \
    gdb \
    git \
    vim \
    nano \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Delete default SSH host keys generated during apt-get install
# This forces the entrypoint script to generate unique keys per container
RUN rm -f /etc/ssh/ssh_host_*

# Configure the SSH daemon directory
RUN mkdir -p /var/run/sshd

ENV USER_UID=1000
ENV USER_GID=$USER_UID

# Create the user group and user with the required IDs
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -m -d /home/$USERNAME -s /bin/bash --uid $USER_UID --gid $USER_GID -G sudo $USERNAME

# Allow passwordless sudo for the user
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# Copy and set permissions for the entrypoint script
# Set USERNAME as an environment variable so the entrypoint script can access it at runtime
ENV USERNAME=$USERNAME
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22/tcp

# Set the entrypoint to our script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start the SSH daemon in the foreground (passed to entrypoint as "$@")
CMD ["/usr/sbin/sshd", "-D", "-e"]
