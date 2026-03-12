#!/bin/bash

if [ ! -f /.isolate-env-inited ]; then
  # Generate fresh SSH host keys (if they don't already exist)
  ssh-keygen -A

  # Force ownership of the mounted volume to the internal user
  chown -R "$USERNAME:$USERNAME" /home/"$USERNAME"

  # Generate a random 12-character password
  NEW_PASSWORD=$(openssl rand -base64 12)

  # Apply the password to the user (USERNAME is passed from Dockerfile ENV)
  echo "$USERNAME:$NEW_PASSWORD" | chpasswd

  # Print the credentials to the container logs
  echo "======================================================================"
  echo "Container initialization complete."
  echo "Username : $USERNAME"
  echo "Password : $NEW_PASSWORD"
  echo "======================================================================"
  echo "Use 'docker logs <container_name>' to view this password again."

  touch /.isolate-env-inited
fi

# Execute the main command passed to the container (e.g., sshd -D)
exec "$@"
