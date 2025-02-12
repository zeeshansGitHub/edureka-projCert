pipeline {
    agent any
    environment {
        TEST_SERVER = "172.31.82.79"
        PROD_SERVER = "172.31.83.204"
        REPO_URL = "https://github.com/zeeshansGitHub/edureka-projCert.git"
        IMAGE_NAME = "devopsedu/webapp"
        CONTAINER_NAME = "php-app"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: "${REPO_URL}"
            }
        }

        stage('Install Puppet Agent') {
            steps {
                script {
                    // Use SSH agent credentials for the TEST_SERVER
                    sshagent(credentials: ['jenkins_slave_key']) {
                        sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} sudo apt update
                        ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} sudo apt install -y puppet-agent
                        '''
                    }
                }
            }
        }

        stage('Install Docker with Ansible') {
            steps {
                script {
                    // Use SSH agent credentials for the TEST_SERVER
                    sshagent(credentials: ['jenkins_slave_key']) {
                        sh '''
                        ansible-playbook -i ${TEST_SERVER}, ansible/docker-setup.yml
                        '''
                    }
                }
            }
        }

        stage('Build & Deploy Container') {
            steps {
                script {
                    sshagent(credentials: ['jenkins_slave_key']) {
                        sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker pull ${IMAGE_NAME}"
                        ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
                        '''
                    }
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                input message: "Deploy to production?"
                script {
                    sshagent(credentials: ['jenkins_slave_key']) {
                        sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@${PROD_SERVER} "docker pull ${IMAGE_NAME}"
                        ssh -o StrictHostKeyChecking=no ubuntu@${PROD_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
                        '''
                    }
                }
            }
        }
    }

    // ✅ FIXED: Use post { failure { ... } } instead of when { failed() }
    post {
        failure {
            echo "Deployment failed, rolling back..."
            script {
                sshagent(credentials: ['jenkins_slave_key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@${TEST_SERVER} "docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"
                    '''
                }
            }
        }
    }
}
