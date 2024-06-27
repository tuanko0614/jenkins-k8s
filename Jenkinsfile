pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        ARGOCD_SERVER = '192.168.83.10:31654'
        ARGOCD_APP_NAME = 'your-argocd-app-name' // Thay thế bằng tên ứng dụng ArgoCD của bạn
        ARGOCD_CREDENTIALS = credentials('argocd') // Sử dụng ID thông tin đăng nhập bạn đã tạo
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/tuanko0614/jenkins-k8s.git'
            }
        }

        stage('Build') {
            steps {
                script {
                    bat 'docker build -t tuandt0614/local-jenkins:latest .'
                }
            }
        }

        stage('Login') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'password', usernameVariable: 'usr')]) {
                    script {
                        // Tạo file tạm để lưu mật khẩu
                        writeFile file: 'docker_password.txt', text: "${password}"
                        // Đăng nhập vào Docker Hub
                        bat 'docker login -u %usr% --password-stdin < docker_password.txt'
                        // Xóa file tạm sau khi đăng nhập
                        bat 'del docker_password.txt'
                    }
                }
            }
        }

        stage('Push') {
            steps {
                bat 'docker push tuandt0614/local-jenkins:latest'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    bat 'kubectl apply -f k8s\\deployment.yaml'
                }
            }
        }

        stage('Sync with ArgoCD') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'argocd', passwordVariable: 'ARGOCD_PASSWORD', usernameVariable: 'ARGOCD_USERNAME')]) {
                        bat """
                        curl -s -X POST https://$ARGOCD_SERVER/api/v1/session -d '{"username": "$ARGOCD_USERNAME", "password": "$ARGOCD_PASSWORD"}' -H 'Content-Type: application/json' -o token.json --insecure
                        set /p ARGOCD_TOKEN=<token.json
                        curl -s -X POST https://$ARGOCD_SERVER/api/v1/applications/$ARGOCD_APP_NAME/sync -H "Authorization: Bearer %ARGOCD_TOKEN%" -H 'Content-Type: application/json' --insecure
                        del token.json
                        """
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
