#!/bin/bash
sudo apt-get update
sudo apt-get install -y curl apt-transport-https ca-certificates gnupg ufw
sudo ufw disable

#Sometimes the google key retrieval can fail, make sure there are no duplicates
sudo rm -f /usr/share/keyrings/cloud.google.gpg

# Install kubectl through google-cli
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update
sudo apt-get install -y google-cloud-cli
sudo apt-get update
sudo apt-get install -y kubectl

#Install k3s in agent mode (need multiple try, can randomly fail)
for i in {1..3}; do
  if curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="12345" INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111 --flannel-iface=eth1" sh -s; then
	break
  else
    if [ $i -eq 3 ]; then
	echo "Failed to install k3s after 3 attempts"
	exit 1
    fi
    sleep 10
  fi
done

sleep 15
