pipeline {
    agent any

    environment {
        GITHUB_CRED       = 'github'
        SONAR_URL         = 'http://192.168.103.2:32000'
        SONAR_CRED        = 'sonarqube-cred'
        DOCKER_REPO       = 'ahmedsayedtalib'
        DOCKER_CRED       = 'docker-cred'
        IMAGE_NAME        = 'mypersonalwebsite'
        PROJECT_ID        = 'first-cascade-473914-c1'
        REGION            = 'us-central1'
        ZONE              = 'us-central1-a'
        TF_BUCKET         = "ahmedsayed-cluster"
        TF_STATE_PREFIX   = "terraform/state"
        TERRAFORM_DIR     = "${WORKSPACE}/terraform"
        GCP_CRED          = "gcp-cred"
        K8S_DIR           = "${WORKSPACE}/k8s"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "🔄 Checking out source code from GitHub"
                git branch: 'main', credentialsId: "${GITHUB_CRED}", url: 'https://github.com/ahmedsayedtalib/mypersonalwebsite.git'
            }
            post {
                success { echo "✅ Checkout successful" }
                failure { echo "❌ Checkout failed" }
            }
        }

        stage('Static Code Analysis') {
            steps {
                echo "🔍 Running SonarQube analysis"
                withSonarQubeEnv('sonarqube') { 
                    withCredentials([string(credentialsId: "${SONAR_CRED}", variable: "SONAR_TOKEN")]) {
                        script {
                            def scannerHome = tool 'sonar-scanner'
                            sh """
                                ${scannerHome}/bin/sonar-scanner \
                                    -Dsonar.projectKey=mypersonalwebsite \
                                    -Dsonar.sources=. \
                                    -Dsonar.inclusions="**/*.html,**/*.css,**/*.js" \
                                    -Dsonar.host.url=${SONAR_URL} \
                                    -Dsonar.token=${SONAR_TOKEN}
                            """
                        }
                    }
                }
            }
            post {
                success { echo "✅ SonarQube analysis successful" }
                failure { echo "❌ SonarQube analysis failed" }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def IMAGE_TAG = "${env.BUILD_NUMBER}"
                    echo "🐳 Building Docker image: ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
                withCredentials([usernamePassword(credentialsId:"${DOCKER_CRED}", usernameVariable:"USER", passwordVariable:"PASSWORD")]) {
                    sh """
                        docker login -u ${USER} -p ${PASSWORD}
                        docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} .
                        docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
            post {
                success { echo "✅ Docker image built and pushed" }
                failure { echo "❌ Docker build/push failed" }
            }
        }

        stage('Update Manifest Image Tag') {
            steps {
                echo "✏️ Updating Kubernetes manifest with new image tag"
                script {
                    def IMAGE_TAG = "${env.BUILD_NUMBER}"
                    sh """
                        sed -i "s|image:.*${IMAGE_NAME}.*|image: ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}|g" ${K8S_DIR}/depl.yaml
                    """
                }
            }
            post {
                success { echo "✅ Manifest updated with new image" }
                failure { echo "❌ Failed to update manifest" }
            }
        }

        stage('Login to GCP') {
            steps {
                echo "🔐 Logging into GCP and configuring credentials"
                withCredentials([file(credentialsId:"${GCP_CRED}", variable:"GCP_KEY")]) {
                    script {
                        env.GOOGLE_APPLICATION_CREDENTIALS = "${GCP_KEY}"
                        sh """
                            gcloud auth activate-service-account --key-file=$GCP_KEY
                            gcloud container clusters get-credentials ahmedsayed-cluster --zone ${ZONE} --project ${PROJECT_ID}
                            kubectl config current-context
                        """
                    }
                }
            }
            post {
                success { echo "✅ GCP login successful" }
                failure { echo "❌ GCP login failed" }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                echo "🚀 Initializing and applying Terraform"
                dir("${TERRAFORM_DIR}") {
                    sh """
                        terraform init -backend-config="bucket=${TF_BUCKET}" -backend-config="prefix=${TF_STATE_PREFIX}"
                        terraform plan -out=tfplan
                        terraform apply -auto-approve tfplan
                    """
                }
            }
            post {
                success { echo "✅ Terraform applied successfully" }
                failure { echo "❌ Terraform failed" }
            }
        }

        stage('Deploy to GKE') {
            steps {
                echo "🚢 Deploying application to GKE via kubectl"
                sh """
                    kubectl apply -f ${K8S_DIR}/depl.yaml
                    kubectl apply -f ${K8S_DIR}/service.yaml
                """
            }
            post {
                success { echo "✅ Application deployed to GKE" }
                failure { echo "❌ Deployment to GKE failed" }
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "✅ Verifying deployment"
                sh """
                    kubectl get all -n default
                    kubectl get svc -n default
                """
            }
            post {
                success { echo "✅ Deployment verification passed" }
                failure { echo "❌ Deployment verification failed" }
            }
        }

    }

    post {
        success { echo "🎉 Pipeline completed successfully!" }
        failure { echo "💥 Pipeline failed. Check logs for errors." }
        always {
            echo "🧹 Cleaning up Docker images and temporary resources"
            sh "docker system prune -f"
        }
    }
}
