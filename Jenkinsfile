pipeline {
    agent any

    environment {
        GITHUB_CRED       = 'github'
        SONAR_URL         = 'http://192.168.103.2:32000'
        SONAR_CRED        = 'sonarqube'
        DOCKER_CRED       = 'docker-cred'
        PROJECT_ID        = 'first-cascade-473914-c1'
        REGION            = 'us-central1'
        ZONE              = 'us-central1-a'
        IMAGE_NAME        = "personalwebsite"
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
                success { echo "✅ Checkout successful!" }
                failure { echo "❌ Checkout failed!" }
                always { echo "⚠️ Checkout stage finished" }
            }
        }

        stage('Static Code Analysis') {
            steps {
                echo "🔍 Running SonarQube analysis"
                withSonarQubeEnv('sonarqube') {
                    withCredentials([string(credentialsId: "${SONAR_CRED}", variable: "SONAR_TOKEN")]) {
                        sh """
                            sonar-scanner/bin/sonar-scanner \
                                -Dsonar.projectKey=mypersonalwebsite \
                                -Dsonar.sources=. \
                                -Dsonar.inclusions="**/*.html,**/*.css,**/*.js" \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
            post {
                success { echo "✅ SonarQube analysis passed!" }
                failure { echo "❌ SonarQube analysis failed!" }
                always { echo "⚠️ SonarQube stage finished" }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    IMAGE_TAG = "${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    echo "🐳 Building Docker image: ${IMAGE_TAG}"
                }
                withDockerRegistry([credentialsId: "${DOCKER_CRED}", url: ""]) {
                    sh """
                        docker build -t ${IMAGE_TAG} .
                        docker push ${IMAGE_TAG}
                    """
                }
            }
            post {
                success { echo "✅ Docker image built and pushed: ${IMAGE_TAG}" }
                failure { echo "❌ Docker build or push failed!" }
                always { echo "⚠️ Docker stage finished" }
            }
        }

        stage('Update Manifest Image Tag') {
            steps {
                echo "✏️ Updating Kubernetes manifest with new image tag"
                script {
                    sh """
                        sed -i "s|image:.*${IMAGE_NAME}.*|image: ${IMAGE_TAG}|g" ${K8S_DIR}/deployment.yaml
                    """
                }
            }
            post {
                success { echo "✅ Kubernetes manifest updated" }
                failure { echo "❌ Updating manifest failed" }
                always { echo "⚠️ Manifest update stage finished" }
            }
        }

        stage('Prepare Terraform Backend') {
            steps {
                echo "🛠 Preparing Terraform backend bucket"
                script {
                    sh """
                        gsutil ls -b gs://${TF_BUCKET} || gsutil mb -l ${REGION} gs://${TF_BUCKET}
                        gsutil versioning set on gs://${TF_BUCKET}
                    """
                }
            }
            post {
                success { echo "✅ Terraform backend prepared" }
                failure { echo "❌ Terraform backend preparation failed" }
                always { echo "⚠️ Terraform backend stage finished" }
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
                success { echo "✅ Terraform applied successfully!" }
                failure { echo "❌ Terraform apply failed!" }
                always { echo "⚠️ Terraform stage finished" }
            }
        }

        stage('Login to GCP') {
            steps {
                echo "🔐 Logging into GCP and configuring kubectl"
                withCredentials([file(credentialsId:"${GCP_CRED}", variable:"GCP_KEY")]) {
                    sh """
                        gcloud auth activate-service-account --key-file=$GCP_KEY
                        gcloud container clusters get-credentials ahmedsayed-cluster --zone ${ZONE} --project ${PROJECT_ID}
                    """
                }
            }
            post {
                success { echo "✅ GCP login successful!" }
                failure { echo "❌ GCP login failed!" }
                always { echo "⚠️ GCP login stage finished" }
            }
        }

        stage('Deploy to GKE via ArgoCD') {
            steps {
                echo "🚢 Deploying application via ArgoCD"
                sh """
                    argocd app sync personalwebsite
                    argocd app wait personalwebsite --health --timeout 300
                """
            }
            post {
                success { echo "✅ ArgoCD deployment successful!" }
                failure { echo "❌ ArgoCD deployment failed!" }
                always { echo "⚠️ ArgoCD stage finished" }
            }
        }

        stage('Install Monitoring (Prometheus & Grafana)') {
            steps {
                echo "📊 Installing Prometheus and Grafana"
                sh """
                    kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/raw/main/bundle.yaml
                    kubectl apply -f https://raw.githubusercontent.com/grafana/helm-charts/main/charts/grafana/templates/deployment.yaml
                """
            }
            post {
                success { echo "✅ Prometheus & Grafana installed successfully!" }
                failure { echo "❌ Monitoring installation failed!" }
                always { echo "⚠️ Monitoring stage finished" }
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
                success { echo "✅ Deployment verification passed!" }
                failure { echo "❌ Deployment verification failed!" }
                always { echo "⚠️ Verification stage finished" }
            }
        }
    }

    post {
        success {
            echo "🎉 Pipeline completed successfully!"
        }
        failure {
            echo "💥 Pipeline failed. Check logs for errors."
        }
        always {
            echo "🧹 Cleaning up Docker images and temporary resources"
            sh "docker system prune -f"
        }
    }
}
