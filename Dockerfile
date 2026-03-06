ARG CUDA_VERSION=13.1.1
ARG UBUNTU_VERSION=22.04

FROM nvidia/cuda:$CUDA_VERSION-devel-ubuntu$UBUNTU_VERSION

# Define ARGs without default values
ARG USERNAME
ARG USER_UID
ARG USER_GID

# Enforce mandatory ARGs by failing the build if they are empty
RUN test -n "$USERNAME" || (echo "ERROR: USERNAME argument is required" && exit 1) \
 && test -n "$USER_UID" || (echo "ERROR: USER_UID argument is required" && exit 1) \
 && test -n "$USER_GID" || (echo "ERROR: USER_GID argument is required" && exit 1)

ENV DEBIAN_FRONTEND=noninteractive

# Install OpenSSH server, sudo, and development tools (openssl added for password generation)
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


# Apply SSH and PAM fixes for Docker and large UIDs
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd \
    && sed -i 's/^session\s*optional\s*pam_lastlog.so/#session optional pam_lastlog.so/g' /etc/pam.d/sshd \
    && echo "PrintLastLog no" >> /etc/ssh/sshd_config

# Delete default SSH host keys generated during apt-get install
# This forces the entrypoint script to generate unique keys per container
RUN rm -f /etc/ssh/ssh_host_*

# Configure the SSH daemon directory
RUN mkdir -p /var/run/sshd

# Create the user group and user with the required IDs
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -l -m -d /home/$USERNAME -s /bin/bash --uid $USER_UID --gid $USER_GID -G sudo $USERNAME

# Allow passwordless sudo for the user
RUN echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set USERNAME as an environment variable so the entrypoint script can access it at runtime
ENV USERNAME=$USERNAME

# Copy and set permissions for the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22/tcp

# Set the entrypoint to our script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Start the SSH daemon in the foreground (passed to entrypoint as "$@")
CMD ["/usr/sbin/sshd", "-D"]
