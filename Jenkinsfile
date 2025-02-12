pipeline {
    agent any
    environment {
        TEST_SERVER = "172.31.82.79"
        PROD_SERVER = "172.31.83.204"
        REPO_URL = "https://github.com/zeeshansGitHub/edureka-projCert.git"
        IMAGE_NAME = "devopsedu/webapp"
        CONTAINER_NAME = "php-app"
        SSH_CREDENTIALS = 'ssh_key'  // Ensure this is correctly stored in Jenkins credentials
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: "${REPO_URL}"
            }
        }

        stage('Install Puppet Agent') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Installing Puppet Agent on ${TEST_SERVER}..."
                    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${TEST_SERVER} "sudo apt update && sudo apt install -y puppet-agent"
                    '''
                }
            }
        }

        stage('Install Docker with Ansible') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Running Ansible playbook to install Docker on ${TEST_SERVER}..."
                    ansible-playbook -i ${TEST_SERVER}, ansible/docker-setup.yml
                    '''
                }
            }
        }

        stage('Build & Deploy Container') {
            steps {
                script {
                    sshagent(credentials: [SSH_CREDENTIALS]) {
                        sh '''
                        echo "🔹 Pulling Docker image on ${TEST_SERVER}..."
                        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${TEST_SERVER} "docker pull ${IMAGE_NAME}"

                        echo "🔹 Running Docker container on ${TEST_SERVER}..."
                        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${TEST_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
                        '''
                    }
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                input message: "🚀 Deploy to production?"
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    echo "🔹 Deploying to Production Server (${PROD_SERVER})..."
                    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${PROD_SERVER} "docker pull ${IMAGE_NAME}"
                    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${PROD_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
                    '''
                }
            }
        }
    }

    post {
        failure {
            echo "⚠️ Deployment failed, rolling back..."
            sshagent(credentials: [SSH_CREDENTIALS]) {
                sh '''
                echo "🔹 Stopping and removing container on ${TEST_SERVER}..."
                ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@${TEST_SERVER} "docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"
                '''
            }
        }
    }
}
