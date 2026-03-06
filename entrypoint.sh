#!/bin/bash
# entrypoint.sh

# 1. Generate fresh SSH host keys (if they don't already exist)
ssh-keygen -A

# 2. Generate a random 12-character password
NEW_PASSWORD=$(openssl rand -base64 12)

# 3. Apply the password to the user (USERNAME is passed from Dockerfile ENV)
echo "$USERNAME:$NEW_PASSWORD" | chpasswd

# 4. Print the credentials to the container logs
echo "======================================================================"
echo "Container initialization complete."
echo "Username : $USERNAME"
echo "Password : $NEW_PASSWORD"
echo "======================================================================"
echo "Use 'docker logs <container_name>' to view this password again."

# 5. Execute the main command passed to the container (e.g., sshd -D)
exec "$@"
