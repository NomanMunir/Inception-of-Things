#!/bin/bash

# K3s Server Setup Script
# This script installs and configures K3s in server (controller) mode

set -e

SERVER_IP="$1"

echo "=== Starting K3s Server Setup ==="
echo "Server IP: $SERVER_IP"

# Update system packages
echo "Updating system packages..."
apt-get update -y

# Disable Firewall (if applicable)
systemctl stop ufw || true
systemctl disable ufw --now || true




echo "Installing required packages..."
apt-get install -y curl

# Install K3s in server mode
echo "Installing K3s server..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 644" sh -

# Wait for K3s to be ready
echo "Waiting for K3s to be ready..."
sleep 10

# Verify K3s is running
systemctl status k3s --no-pager

# Setup kubeconfig for vagrant user
# echo "Setting up kubeconfig for vagrant user..."
# mkdir -p /home/vagrant/.kube
# cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
# chown vagrant:vagrant /home/vagrant/.kube/config
# chmod 600 /home/vagrant/.kube/config

# Copy node token for worker nodes
echo "Copying node token for worker nodes..."
cp /var/lib/rancher/k3s/server/node-token /vagrant/

# Install kubectl for root user (already included in k3s)
echo "Setting up kubectl alias..."
echo 'alias k="kubectl"' >> /home/vagrant/.bashrc

# Verify installation
echo "Verifying K3s installation..."
k3s kubectl get nodes

echo "=== K3s Server Setup Complete ==="
echo "Node token saved to /vagrant/node-token"
echo "You can access the cluster using: vagrant ssh ${HOSTNAME}"
