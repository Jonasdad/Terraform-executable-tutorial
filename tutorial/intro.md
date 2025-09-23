# IaC Network Monitoring: Snort + Terraform
This tutorial aims to provide the user with basic knowledge of how to install and configure Terraform, Docker and Snort to work in sync for quick and easy deployment of network monitoring. Terraform will be used to deploy and manage two separate Docker containers, one running Snort and one running a simple HTTP server for alert monitoring.

On a high level, the tutorial will include:
- The creation of the Docker images
- The network configuration of the containers
- The Terraform configuration files to deploy and manage the containers
- Generating traffic to trigger Snort alerts and viewing them through the HTTP server

## Table of Contents
1. Background
2. Install Docker
3. Create your own Snort Docker container (Optional)
4. Create your own HTTP Server Docker container (Optional)
5. Install Terraform
6. Setting up Terraform to work with Docker
7. Deploy and manage your containers through Terraform


Please press start to proceed to the next section.