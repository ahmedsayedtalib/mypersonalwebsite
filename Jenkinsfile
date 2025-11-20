pipeline {
    agent any

    environment {
        GITHUB_CRED       = 'github-cred'
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
        stage('Declarative: Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Checkout Code') {
            steps {
                echo '🔄 Checking out source code from GitHub'
                git branch: 'main', url: 'https://github.com/ahmedsayedtalib/mypersonalwebsite.git', credentialsId: 'github-cred'
                echo '✅ Checkout successful'
            }
        }

       stage("SonarQube Static Code Analysis") {
            steps {
                script {
                    echo "Running SonarQube analysis..."

                    // Path to Jenkins-installed SonarScanner tool
                    def scannerHome = tool 'sonar-scanner'

                    // Inject SonarQube environment variables
                    withSonarQubeEnv('sonarqube') {
                        withCredentials([string(credentialsId: SONAR_CRED, variable: "SONAR_TOKEN")]) {
                            sh """
                                ${scannerHome}/bin/sonar-scanner \
                                  -Dsonar.projectKey=mypersonalwebsite \
                                  -Dsonar.sources=. \
                                  -Dsonar.inclusions=**/*.html,**/*.css,**/*.js \
                                  -Dsonar.host.url=${SONAR_URL} \
                                  -Dsonar.login=${SONAR_TOKEN}
                            """
                        }
                    }
                }
        } 
            echo '✅ SonarQube analysis successful'
    }

        stage('Set Dynamic Environment Variables') {
            steps {
                script {
                    // Assign BUILD_NUMBER dynamically to IMAGE_TAG
                    env.IMAGE_TAG = "${BUILD_NUMBER}"
                    echo "IMAGE_TAG set to ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "🐳 Building Docker image: ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}"
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_CRED}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} .
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
                        """
                    }
                }
                echo '✅ Docker build and push successful'
            }
        }

        stage('Update Manifest Image Tag') {
            steps {
                echo 'Updating Kubernetes manifest image tags...'
                sh "sed -i 's|image:.*|image: ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}|g' ${K8S_DIR}/*.yaml"
                echo '✅ Manifest updated'
            }
        }

        stage('Login to GCP') {
            steps {
                echo 'Logging into GCP...'
                withCredentials([file(credentialsId: "${GCP_CRED}", variable: 'GCP_KEY')]) {
                    sh "gcloud auth activate-service-account --key-file=${GCP_KEY}"
                    sh "gcloud config set project ${PROJECT_ID}"
                }
                echo '✅ GCP login successful'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh """
                    terraform init -backend-config="bucket=${TF_BUCKET}" -backend-config="prefix=${TF_STATE_PREFIX}"
                    terraform apply -auto-approve
                    """
                }
                echo '✅ Terraform applied successfully'
            }
        }

        stage('Deploy to GKE') {
            steps {
                dir("${K8S_DIR}") {
                    sh "kubectl apply -f ."
                }
                echo '✅ Deployed to GKE'
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl get pods -o wide"
                echo '✅ Deployment verified'
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up Docker images and temporary resources'
            sh 'docker system prune -f'
        }

        success {
            echo '🎉 Pipeline completed successfully!'
        }

        failure {
            echo '💥 Pipeline failed. Check logs for errors.'
        }
    }
}
