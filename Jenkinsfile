pipeline {
    agent any
    environment {
        TEST_SERVER = "172.31.82.79"
        PROD_SERVER = "172.31.83.204"
        REPO_URL = "https://github.com/zeeshansGitHub/edureka-projCert.git"
        IMAGE_NAME = "devopsedu/webapp"  // Custom name, but not pushed to Docker Hub
        CONTAINER_NAME = "php-app"
        SSH_CREDENTIALS = 'ssh_key'  // Ensure this is correctly stored in Jenkins credentials
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo "🔹 Checking out code from repository..."
                }
                git branch: 'main', url: "${REPO_URL}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🔹 Building Docker image from Dockerfile..."
                }
                sh '''
                docker build -t ${IMAGE_NAME}:latest .
                '''
            }
        }

        stage('Install Required Packages') {
            steps {
                script {
                    echo "🔹 Installing Ansible and Puppet Agent on Jenkins agent..."
                }
                sh '''
                sudo apt update
                sudo apt install -y ansible puppet-agent
                '''
            }
        }

        stage('Install Puppet Agent on Test Server') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Installing Puppet Agent on ${TEST_SERVER}..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "sudo apt update && sudo apt install -y puppet-agent"
                    '''
                }
            }
        }

        stage('Install Docker with Ansible') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Running Ansible playbook to install Docker on ${TEST_SERVER}..."
                    ansible-playbook -i ${TEST_SERVER}, --user=ubuntu --private-key=~/.ssh/id_rsa ansible/docker-setup.yml
                    '''
                }
            }
        }

        stage('Verify Docker Installation') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Verifying Docker installation on ${TEST_SERVER}..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker --version || echo '❌ Docker installation failed!'"
                    '''
                }
            }
        }

        stage('Deploy Container on Test Server') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Stopping old container if running..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker stop ${CONTAINER_NAME} || true && docker rm ${CONTAINER_NAME} || true"

                    echo "🔹 Running new Docker container on ${TEST_SERVER}..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest"
                    '''
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                input message: "Deploy to production?"
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Stopping old container on Production..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${PROD_SERVER} "docker stop ${CONTAINER_NAME} || true && docker rm ${CONTAINER_NAME} || true"

                    echo "🔹 Running new Docker container on ${PROD_SERVER}..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${PROD_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest"
                    '''
                }
            }
        }
    }

    post {
        failure {
            script {
                echo "Deployment failed, rolling back..."
            }
            sshagent(credentials: [SSH_CREDENTIALS]) {
                sh '''
                echo "🔹 Stopping and removing container on ${TEST_SERVER}..."
                ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"
                '''
            }
        }
    }
}
