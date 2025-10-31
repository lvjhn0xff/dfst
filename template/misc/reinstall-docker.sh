#!/usr/bin/env bash
# Full Docker uninstall + reinstall script
# Works on Ubuntu/Debian-based systems
# Run as root or with sudo

set -euo pipefail

echo ">>> Removing all containers, images, volumes, and networks..."
# Remove containers
sudo docker ps -aq | xargs -r sudo docker rm -f
# Remove images
sudo docker images -aq | xargs -r sudo docker rmi -f
# Remove volumes
sudo docker volume ls -q | xargs -r sudo docker volume rm -f
# Remove networks (skip default ones)
sudo docker network ls -q | grep -vE "bridge|host|none" | xargs -r sudo docker network rm || true

echo ">>> Stopping Docker services..."
sudo systemctl stop docker docker.socket || true

echo ">>> Uninstalling Docker packages..."
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose
sudo apt-get autoremove -y --purge
sudo apt-get clean

echo ">>> Removing leftover Docker data directories..."
sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker ~/.docker

echo ">>> Reinstalling Docker from official repository..."

# Optional: remove old repo info first
sudo rm -f /etc/apt/sources.list.d/docker.list /usr/share/keyrings/docker-archive-keyring.gpg

# Install prerequisites
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker’s official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo ">>> Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo ">>> Docker reinstall complete."
echo ">>> Version check:"
docker --version
docker compose version
