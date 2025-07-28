#!/bin/bash

set -e  # Exit on error

echo "Updating system packages..."
sudo apt-get update -y

echo "Installing OpenJDK 21 (JRE and JDK headless)..."
sudo apt-get install openjdk-21-jre-headless -y
sudo apt-get install openjdk-21-jdk-headless -y



echo "Installing Docker..."
sudo apt-get install docker.io -y

echo "Installing Maven..."
sudo apt-get install maven -y

echo "Updating package list again..."
sudo apt-get update



echo "Creating Jenkins group (if it doesn't exist)..."
sudo groupadd -f jenkins

echo "Adding current user ($USER) to Jenkins and Docker groups..."
sudo usermod -aG jenkins  $USER
sudo usermod -aG docker $USER

echo "Refreshing group membership for Docker (will only affect new shells)..."
sudo newgrp docker <<EONG

echo "Changing permissions on Docker socket..."
sudo chmod 666 /var/run/docker.sock

echo "Running SonarQube container..."
sudo docker run -d --name=sonar-qube -p 9000:9000 mc1arke/sonarqube-with-community-branch-plugin

echo "Running nexus repo container"
sudo docker run -d --name=nexus -p 8081:8081 sonatype/nexus3:3.82.0-alpine

echo "Install Jenkins .."
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y jenkins
echo "Jenkins installation complete"

echo "Install Trivy"
sudo apt-get install wget -y apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get  install -y trivy
echo "Trivy installation complete"

echo "installing kubectl"
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
echo "kubectl installation complete"


EONG


echo "Setup completed. You may need to log out and back in for group changes to take effect."