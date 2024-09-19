#!/bin/bash

# Prompt for necessary information
read -p "Enter your username on the remote server: " USERNAME
read -p "Enter the server hostname (e.g., ia-class.cs.georgetown.edu): " SERVER
read -p "Enter a name for your SSH key (e.g., id_ed25519_ia-class): " KEY_NAME
read -p "Enter a short name for the SSH host (e.g., ia-class): " HOST_ALIAS

# Ensure ~/.ssh exists with correct permissions
if [ ! -d "$HOME/.ssh" ]; then
    mkdir "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    echo "Created ~/.ssh directory and set permissions."
else
    chmod 700 "$HOME/.ssh"
    echo "Ensured ~/.ssh directory has correct permissions."
fi

cd "$HOME/.ssh"

# Generate the SSH key
ssh-keygen -t ed25519 -f "$HOME/.ssh/$KEY_NAME"

# Set permissions on the key files
chmod 600 "$HOME/.ssh/$KEY_NAME"*
echo "Set permissions on the SSH key files."

# Copy the public key to the server
ssh-copy-id -i "$HOME/.ssh/${KEY_NAME}.pub" "$USERNAME@$SERVER"

# Create or update the SSH config file
SSH_CONFIG="$HOME/.ssh/config"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

# Check if the host alias already exists in the config
if grep -q "Host $HOST_ALIAS" "$SSH_CONFIG"; then
    echo "Host alias $HOST_ALIAS already exists in your SSH config."
else
    # Append the new host configuration
    echo -e "\nHost $HOST_ALIAS" >> "$SSH_CONFIG"
    echo "    HostName $SERVER" >> "$SSH_CONFIG"
    echo "    User $USERNAME" >> "$SSH_CONFIG"
    echo "    IdentityFile ~/.ssh/$KEY_NAME" >> "$SSH_CONFIG"
    echo "Added $HOST_ALIAS to your SSH config."
fi

echo "Setup complete! You can now SSH into the server using: ssh $HOST_ALIAS"