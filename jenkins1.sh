#!/bin/bash
set -e

echo "Updating system packages..."
sudo apt-get update -y

echo "Installing required base packages..."
sudo apt-get install -y \
  openjdk-21-jre-headless \
  openjdk-21-jdk-headless \
  docker.io \
  maven \
  wget \
  curl \
  gnupg \
  lsb-release \
  ca-certificates \
  apt-transport-https

echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Adding current user ($USER) to docker group..."
sudo usermod -aG docker $USER 
echo "Refreshing group membership for Docker (will only affect new shells)..."
sudo newgrp docker <<EONG

echo "Changing permissions on Docker socket..."
sudo chmod 666 /var/run/docker.sock
# -----------------------------
# SonarQube
# -----------------------------
echo "Running SonarQube container..."
sudo docker run -d --name sonar-qube -p 9000:9000 \
  mc1arke/sonarqube-with-community-branch-plugin

# -----------------------------
# Nexus
# -----------------------------
echo "Running Nexus container..."
sudo docker run -d --name nexus -p 8081:8081 \
  sonatype/nexus3:3.82.0-alpine

# -----------------------------
# Jenkins
# -----------------------------
echo "Installing Jenkins..."
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | \
  sudo tee /etc/apt/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins installation complete"

# -----------------------------
# Trivy
# -----------------------------
echo "Installing Trivy..."
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | sudo gpg --dearmor -o /etc/apt/keyrings/trivy.gpg

echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb jammy main" \
  | sudo tee /etc/apt/sources.list.d/trivy.list > /dev/null

sudo apt-get update
sudo apt-get install trivy -y

echo "Trivy installation complete"

# -----------------------------
# kubectl
# -----------------------------
echo "Installing kubectl..."

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y kubectl

echo "kubectl installation complete"

# -----------------------------
# Helm
# -----------------------------
echo "Installing Helm..."

curl https://baltocdn.com/helm/signing.asc | \
  sudo gpg --dearmor -o /etc/apt/keyrings/helm.gpg

echo "deb [signed-by=/etc/apt/keyrings/helm.gpg] \
https://baltocdn.com/helm/stable/debian/ all main" | \
sudo tee /etc/apt/sources.list.d/helm-stable-debian.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y helm

echo "Helm installation complete"

echo "Setup completed successfully!"
EONG
echo "⚠️ Please log out and log back in for Docker group changes to take effect."
