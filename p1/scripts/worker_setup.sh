#!/bin/bash

# K3s Worker Setup Script
# This script installs and configures K3s in agent (worker) mode

set -e

SERVER_IP="$1"
WORKER_IP="$2"

echo "=== Starting K3s Worker Setup ==="
echo "Server IP: $SERVER_IP"
echo "Worker IP: $WORKER_IP"

# Update system packages
echo "Updating system packages..."
apt-get update -y

# Wait for server to be ready and token to be available
echo "Waiting for server node token..."
while [ ! -f /vagrant/node-token ]; do
    echo "  Token not found, waiting 5 seconds..."
    sleep 5
done

echo "Node token found, proceeding with installation..."

# Wait for server API to be ready before joining
echo "Testing server API connectivity..."
while ! curl -k -s https://$SERVER_IP:6443/ping >/dev/null 2>&1; do
    echo "  Server API not ready at https://$SERVER_IP:6443, waiting 10 seconds..."
    sleep 10
done

echo "Server API is responding! Proceeding with K3s installation..."

# Read the node token
NODE_TOKEN=$(cat /vagrant/node-token)

# Install K3s in agent mode
echo "Installing K3s agent..."

# Install with inline environment variables (more reliable)
curl -sfL https://get.k3s.io | K3S_URL="http://$SERVER_IP:6443" K3S_TOKEN="$NODE_TOKEN" INSTALL_K3S_EXEC="--node-ip $WORKER_IP" sh -

# Wait for K3s agent to be ready
echo "Waiting for K3s agent to be ready..."
sleep 15

# Verify K3s agent is running
echo "Checking K3s agent status..."
if systemctl is-active --quiet k3s-agent; then
    echo "✅ K3s agent is running successfully!"
    systemctl status k3s-agent --no-pager
else
    echo "❌ K3s agent failed to start. Checking logs..."
    systemctl status k3s-agent --no-pager
    echo "Recent logs:"
    journalctl -u k3s-agent --no-pager -n 20
fi

# Setup kubectl alias for convenience
echo "Setting up kubectl alias..."
echo 'alias k="kubectl"' >> /home/vagrant/.bashrc

echo "=== K3s Worker Setup Complete ==="
echo "Worker node joined the cluster successfully!"
