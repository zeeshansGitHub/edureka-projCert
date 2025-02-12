pipeline {
    agent any
    environment {
        TEST_SERVER = "44.211.134.42"
        PROD_SERVER = "18.212.183.175"
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
                    sh '''
                    ssh ubuntu@${TEST_SERVER} "docker pull ${IMAGE_NAME}"
                    ssh ubuntu@${TEST_SERVER} "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${IMAGE_NAME}"
                    '''
                }
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

    // ✅ FIXED: Use post { failure { ... } } instead of when { failed() }
    post {
        failure {
            echo "Deployment failed, rolling back..."
            sh '''
            ssh ubuntu@${TEST_SERVER} "docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}"
            '''
        }
    }
}
