#!/bin/bash
# Update the package list and install dependencies
sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Kubernetes tools (kubectl, kubeadm, kubelet)
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl

# Disable swap (required for Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Install Prometheus Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz
cd node_exporter-1.3.1.linux-amd64/
sudo cp node_exporter /usr/local/bin/

# Create systemd service for Node Exporter
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Start and enable Node Exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# Install Grafana Agent (for scraping and sending metrics/logs)
wget https://github.com/grafana/agent/releases/download/v0.22.1/agent-linux-amd64.zip
unzip agent-linux-amd64.zip
sudo cp agent-linux-amd64 /usr/local/bin/grafana-agent

# Create a systemd service for Grafana Agent
sudo tee /etc/systemd/system/grafana-agent.service > /dev/null <<EOF
[Unit]
Description=Grafana Agent
After=network.target

[Service]
User=nobody
ExecStart=/usr/local/bin/grafana-agent -config.file=/etc/grafana-agent.yaml

[Install]
WantedBy=default.target
EOF

# Start and enable Grafana Agent
sudo systemctl daemon-reload
sudo systemctl start grafana-agent
sudo systemctl enable grafana-agent

# Install Falco (Runtime Security Tool)
curl -s https://s3.amazonaws.com/download.draios.com/stable/install-falco | sudo bash

# Add Falco as a systemd service
sudo systemctl start falco
sudo systemctl enable falco

# Install Splunk Universal Forwarder
wget -O splunkforwarder-8.2.2-linux-2.6-amd64.deb 'https://www.splunk.com/path-to-forwarder-package'
sudo dpkg -i splunkforwarder-8.2.2-linux-2.6-amd64.deb

# Start the Splunk Universal Forwarder and accept the license
sudo /opt/splunkforwarder/bin/splunk start --accept-license

# Configure Splunk Forwarder to send logs to the Splunk Indexer
var_splunk_server_ip="192.168.1.10"  # Replace with the actual IP address of the Splunk Indexer
sudo /opt/splunkforwarder/bin/splunk add forward-server $var_splunk_server_ip:9997 -auth admin:changeme

# Add a monitoring input (e.g., system logs)
sudo /opt/splunkforwarder/bin/splunk add monitor /var/log/syslog

# Restart Splunk Forwarder to apply changes
sudo /opt/splunkforwarder/bin/splunk restart

# Output installation log
echo "Docker, Kubernetes tools, Node Exporter, Grafana Agent, Falco, and Splunk Universal Forwarder installed successfully!" | tee /root/install_log.txt