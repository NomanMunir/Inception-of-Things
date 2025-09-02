#!/bin/bash

# Common SSH Setup Script
# This script configures SSH for passwordless access

set -e

echo "=== Configuring SSH for passwordless access ==="

# Disable password authentication
echo "Disabling password authentication..."
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Ensure PubkeyAuthentication is enabled
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config

# Restart SSH service
echo "Restarting SSH service..."
systemctl restart sshd

echo "SSH configuration completed successfully!"
