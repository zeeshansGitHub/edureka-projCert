pipeline {
    agent any
    environment {
        TEST_SERVER = "test-server-ip"
        PROD_SERVER = "prod-server-ip"
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
                sh '''
                ssh ubuntu@${TEST_SERVER} sudo apt update
                ssh ubuntu@${TEST_SERVER} sudo apt install -y puppet-agent
                '''
            }
        }

        stage('Install Docker with Ansible') {
            steps {
                sh '''
                ansible-playbook -i ${TEST_SERVER}, ansible/docker-setup.yml
                '''
            }
        }

        stage('Build & Deploy Container') {
            steps {
                script {
                    try {
                        sh '''
                        ssh ubuntu@${TEST_SERVER} "docker pull ${IMAGE_NAME}"
                        ssh ubuntu@${TEST_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
                        '''
                    } catch (Exception e) {
                        error "Deployment failed, triggering rollback."
                    }
                }
            }
        }

        stage('Rollback on Failure') {
            when {
                failed()
            }
            steps {
                sh '''
                ssh ubuntu@${TEST_SERVER} "docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"
                '''
            }
        }

        stage('Deploy to Production') {
            steps {
                input message: "Deploy to production?"
                sh '''
                ssh ubuntu@${PROD_SERVER} "docker pull ${IMAGE_NAME}"
                ssh ubuntu@${PROD_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
                '''
            }
        }
    }
}
