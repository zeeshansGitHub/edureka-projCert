# Jenkins Pipeline for PHP WebApp Deployment

## Overview
This Jenkins pipeline automates the deployment of a PHP web application using Docker, Ansible, and Puppet. The pipeline is set up on a Master VM and deploys the application to a Slave/Test Server and a Production Server.

## Architecture
- **Master VM**: Runs Jenkins, Ansible, Git, and manages deployments.
- **Test Server (Slave Node)**: Serves as a Jenkins agent where the application is first deployed.
- **Production Server**: Final deployment destination for the PHP application.

## Prerequisites
1. **Master VM Setup:**
   - Install Jenkins and required plugins:
     ```sh
     sudo apt update && sudo apt install -y jenkins
     ```
   - Install required dependencies:
     ```sh
     sudo apt install -y docker.io ansible puppet-agent git
     ```
   - Configure Jenkins SSH access to Test and Production servers.
   
2. **Test Server (Slave Node) Setup:**
   - Install OpenSSH, Python, Git:
     ```sh
     sudo apt update && sudo apt install -y openssh-server python3 git
     ```
   - Ensure the server is reachable from Jenkins Master.

3. **Production Server Setup:**
   - Ensure SSH access and Docker are installed.

4. **Jenkins Plugins Installed:**
   - Build Pipeline Plugin
   - Post-build Task Plugin

## Pipeline Execution
The Jenkins pipeline consists of multiple stages:

### 1. **Checkout Code**
- Clones the PHP web application repository from GitHub.

### 2. **Build Docker Image**
- Builds a Docker image using the `Dockerfile` in the repository.

### 3. **Install Required Packages**
- Installs Ansible and Puppet Agent on the Master VM.

### 4. **Install Puppet Agent on Test Server**
- Connects to the Test Server and installs the Puppet Agent.

### 5. **Install Docker with Ansible**
- Runs an Ansible playbook to install Docker on the Test Server.

### 6. **Verify Docker Installation**
- Checks if Docker is installed on the Test Server.

### 7. **Deploy Container on Test Server**
- Stops any existing container.
- Deploys a new container with the latest PHP application.

### 8. **Deploy to Production**
- Stops and removes any existing container.
- Pulls the latest Docker image.
- Runs the new container on the Production Server.

### 9. **Failure Handling**
- If deployment fails, it stops and removes the container from the Test Server.

## How to Run
1. Add the pipeline to Jenkins.
2. Configure Jenkins credentials for SSH access to Test and Production servers.
3. Trigger the pipeline from Jenkins.
4. Monitor logs and ensure the application is deployed successfully.

## Validation
- Verify the container is running using:
  ```sh
  docker ps -a
  ```
- Open a browser and check the application is accessible at `http://<server-ip>`.

## GitHub Repository
Ensure the following files are present in your repository:
- PHP application code
- `Dockerfile`
- Ansible playbook (`ansible/docker-setup.yml`)
- Puppet manifest (if needed)

