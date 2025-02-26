pipeline {
    agent any
    environment {
        TEST_SERVER = "172.31.82.79"
        PROD_SERVER = "172.31.83.204"
        REPO_URL = "https://github.com/zeeshansGitHub/edureka-projCert.git"
        IMAGE_NAME = "devopsedu/webapp"
        CONTAINER_NAME = "php-app"
        SSH_CREDENTIALS = 'ssh_key'
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

         stage('Install Docker') {

            steps {

                sh '''

                    sudo apt-get update

                    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

                    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

                    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

                    sudo apt-get update

                    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

                '''

            }

        }



        stage('Build Docker Image') {
            steps {
                script {
                    echo "🔹 Building Docker image from Dockerfile..."
                }
                sh '''
                cd $WORKSPACE
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
                sudo apt install -y ansible puppet-agent || true
                '''
            }
        }

        stage('Install Puppet Agent on Test Server') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Installing Puppet Agent on ${TEST_SERVER}..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "sudo apt update && sudo apt install -y puppet-agent || true"
                    '''
                }
            }
        }

        stage('Install Docker with Ansible') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Running Ansible playbook to install Docker on ${TEST_SERVER}..."
                    ansible-playbook -i "${TEST_SERVER}," --user=ubuntu --private-key=~/.ssh/id_rsa ansible/docker-setup.yml
                    '''
                }
            }
        }

        stage('Verify Docker Installation') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Verifying Docker installation on ${TEST_SERVER}..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker --version || (echo '❌ Docker installation failed!' && exit 1)"
                    '''
                }
            }
        }

        stage('Deploy Container on Test Server') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Stopping old container if running..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME} || echo 'No existing container to stop'"

                    echo "🔹 Running new Docker container on ${TEST_SERVER}..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest"
                    '''
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                input message: "🚀 Deploy to production?"
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Stopping old container on Production..."
                    ssh -o StrictHostKeyChecking=no ubuntu@${PROD_SERVER} "docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME} || echo 'No existing container to stop'"

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
                echo "⚠️ Deployment failed, rolling back..."
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
