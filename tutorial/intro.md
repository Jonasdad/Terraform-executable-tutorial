# IaC Network Monitoring: Snort + HTTP Server + Terraform
This tutorial aims to provide the user with basic knowledge of how to install and configure Terraform, Docker and Snort to work in sync for quick and easy deployment of network monitoring. Terraform will be used to deploy and manage two separate Docker containers, one running Snort and one running a simple HTTP server for alert monitoring.

On a high level, the tutorial will include:
- The creation of the Docker images
- The network configuration of the containers
- The Terraform configuration files to deploy and manage the containers
- Generating traffic to trigger Snort alerts and viewing them through the HTTP server

## Why This Matters for DevOps
This tutorial demonstrates core DevOps principles with Infrastructure as Code. I highlights automated deployment and teardown of environments, allowing for rapid iteration and testing. If anything goes wrong, you can simply edit the configuration files and redeploy. This approach minimizes human error and ensures consistency across different environments. It also showcases a real world use case for Terraform, which is a widely used tool in the industry.

## Intended Learning Outcomes
By the end of this tutorial, you should be able to:
- Understand the basics of Infrastructure as Code (IaC) and its benefits.
- Install and configure Docker and Terraform on your machine.
- Create and manage Docker containers using Terraform.
- Configure a simple network monitoring setup using Snort and an HTTP server.
- Understand how to trigger and view Snort alerts through the HTTP server.

## Table of Contents
1. Background
2. Install Docker
3. Create your own Snort Docker container (Optional)
4. Create your own HTTP Server Docker container (Optional)
5. Install Terraform
6. Setting up Terraform to work with Docker
7. Deploy and manage your containers through Terraform
8. Conclusion


Please press start to proceed to the next section.