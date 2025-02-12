pipeline {
    agent any
    environment {
        TEST_SERVER = "172.31.82.79"
        PROD_SERVER = "172.31.83.204"
        REPO_URL = "https://github.com/zeeshansGitHub/edureka-projCert.git"
        IMAGE_NAME = "devopsedu/webapp"
        CONTAINER_NAME = "php-app"
        SSH_CREDENTIALS = 'ssh_key'  // Name of the SSH key stored in Jenkins Credentials
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
                    ssh ubuntu@${TEST_SERVER} sudo apt update
                    ssh ubuntu@${TEST_SERVER} sudo apt install -y puppet-agent
                    '''
                }
            }
        }

        stage('Install Docker with Ansible') {
            steps {
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
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
                        ssh ubuntu@${TEST_SERVER} "docker pull ${IMAGE_NAME}"
                        ssh ubuntu@${TEST_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
                        '''
                    }
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                input message: "Deploy to production?"
                sshagent(credentials: [SSH_CREDENTIALS]) {
                    sh '''
                    ssh ubuntu@${PROD_SERVER} "docker pull ${IMAGE_NAME}"
                    ssh ubuntu@${PROD_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
                    '''
                }
            }
        }
    }

    post {
        failure {
            echo "Deployment failed, rolling back..."
            sshagent(credentials: [SSH_CREDENTIALS]) {
                sh '''
                ssh ubuntu@${TEST_SERVER} "docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"
                '''
            }
        }
    }
}
