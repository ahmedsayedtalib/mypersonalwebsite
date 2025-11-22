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
        GCP_PROJECT_ID    = "first-cascade-473914-c1"
        GKE_REGION        = "us-central1"
        K8S_DIR           = "${WORKSPACE}/k8s"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
                echo '✅ Code checked out'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('sonarqube') {
                        withCredentials([string(credentialsId: SONAR_CRED, variable: 'SONAR_TOKEN')]) {
                            sh """
                            ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=mypersonalwebsite \
                                -Dsonar.sources=. \
                                -Dsonar.inclusions=**/*.js,**/*.css,**/*.html \
                                -Dsonar.host.url=${SONAR_URL} \
                                -Dsonar.login=${SONAR_TOKEN}
                            """
                        }
                    }
                    echo '✅ SonarQube completed'
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    env.IMAGE_TAG = "${BUILD_NUMBER}"
                    withCredentials([usernamePassword(credentialsId: DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker build -t ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG} .
                        docker push ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}
                        """
                    }
                    echo "✅ Docker image ${IMAGE_NAME}:${IMAGE_TAG} pushed"
                }
            }
        }

        stage('Update Kubernetes Manifest') {
            steps {
                sh "sed -i 's|image:.*|image: ${DOCKER_REPO}/${IMAGE_NAME}:${IMAGE_TAG}|g' ${K8S_DIR}/*.yaml"
                echo '✅ Manifest updated'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                script {
                    dir(TERRAFORM_DIR) {
                        withCredentials([file(credentialsId:GCP_CRED, variable: 'GCP_KEY')]) {
                            withEnv(["GOOGLE_APPLICATION_CREDENTIALS=$GCP_KEY"]) {
                                sh """
                                gcloud auth activate-service-account --key-file=${GCP_KEY}
                                gcloud config set project ${PROJECT_ID}
                                terraform init -backend-config="bucket=${TF_BUCKET}" -backend-config="prefix=${TF_STATE_PREFIX}"
                                terraform apply -auto-approve
                                gcloud container clusters get-credentials ${TF_BUCKET} --region=${GKE_REGION} --project=${GCP_PROJECT_ID}
                                """
                            }
                        }
                    }
                    echo '✅ Terraform applied successfully'
                }
            }
        }
        stage('Deploy to GKE') {
            steps {
                dir(K8S_DIR) {
                    sh "kubectl apply -f ."
                }
                echo '✅ Kubernetes deployment applied'
            }
        }

        stage('Smoke Test') {
            steps {
                script {
                    echo '🔍 Running smoke test...'
                    def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://<your-app-url>", returnStdout: true).trim()
                    if (response != '200') {
                        error "Smoke test failed! Expected HTTP 200 but got ${response}"
                    }
                    echo '✅ Smoke test passed'
                }
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up Docker images and resources'
            sh 'docker system prune -f'
        }
        success {
            echo '🎉 Pipeline completed successfully'
        }
        failure {
            echo '💥 Pipeline failed. Check logs for errors'
        }
    }
}
