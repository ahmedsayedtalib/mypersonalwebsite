# 🌐 My Personal Website - DevOps CI/CD Pipeline

This repository contains a **personal website** built with HTML, CSS, and JavaScript, deployed using a full **DevOps CI/CD workflow** on **Google Cloud (GKE)** with **Jenkins, Docker, Terraform, and Kubernetes**.

---

## 🚀 Project Overview

This project demonstrates a complete DevOps workflow from code commit to deployment. Key components:

 **Jenkins**: CI/CD orchestration  
- **SonarQube**: Static code analysis for JS, CSS, and HTML  
- **Docker**: Builds, tags, and pushes container images automatically  
- **Terraform**: Provisions GCP infrastructure including GKE  
- **Kubernetes (GKE)**: Deploys containerized app  
- **Smoke Test**: Validates deployment health (HTTP 200 check)

---

## 📂 Project Structure

mypersonalwebsite/
├─ Dockerfile # Docker image definition with auto-tagging
├─ Jenkinsfile # CI/CD pipeline
├─ k8s/
│ └─ *.yaml # Kubernetes deployment/service manifests
├─ terraform/
│ ├─ main.tf # Main Terraform configuration
│ ├─ variables.tf # Terraform variables
│ ├─ outputs.tf # Terraform outputs
├─ personal_website/ # HTML, CSS, JS files
├─ README.md # Project documentation


> Sensitive files (e.g., GCP service account JSON) are **excluded** using `.gitignore`.

---

## 🔑 GCP Permissions Required for the service account:

To run this pipeline successfully, the service account must have the following roles:

- Artifact Registry Administrator  
- Artifact Registry Create-on-Push Repository Administrator  
- Compute Admin  
- Compute Network Admin  
- Kubernetes Engine Cluster Admin  
- Kubernetes Engine Viewer  
- Service Account User  
- Storage Admin  

---

## ⚡ Pipeline Overview

The **Jenkins pipeline** automates:

1. **Checkout Code**: Pulls the latest code from GitHub.  
2. **SonarQube Analysis**: Runs static code analysis on JS, CSS, and HTML.  
   - Requires Java memory settings: minimum `1GB`, maximum `3GB`.  
3. **Build & Push Docker Image**:  
   - Auto-tags images with Jenkins `${BUILD_NUMBER}`  
   - Pushes to DockerHub using credentials  
4. **Update Kubernetes Manifest**: Updates manifests with new Docker image tag.  
5. **Terraform Init & Apply**:  
   - Initializes and applies infrastructure  
   - Protects critical resources using `prevent_destroy` blocks to avoid accidental deletion during pipeline runs  
6. **Deploy to GKE**: Applies manifests to Kubernetes cluster.  
7. **Smoke Test**: Validates deployment using HTTP response.

**Post Actions**:

- Cleans up unused Docker images with `docker system prune -f`  
- Displays success or failure messages

---

## 🔧 How to Run Locally

1. **Build Docker Image**:

```bash
docker build -t mypersonalwebsite .


Run Locally:
docker run -p 8080:80 mypersonalwebsite

Access the Website:
http://localhost:8080


## 📦 Deployment

Terraform provisions infrastructure (GKE cluster, backend bucket):
terraform init
terraform apply -auto-approve

Kubernetes Deployment:
kubectl apply -f k8s/depl.yaml

## 📝 Lessons Learned

SonarQube: Needed to modify the `SONAR_JAVA_OPTS` environment variable (set `-Xms1g -Xmx3g`) to allocate sufficient memory for Elasticsearch to run without errors. 

Terraform: Adding prevent_destroy = true to critical resources prevents accidental deletion during pipeline runs.

Docker: Using auto-tagging (BUILD_NUMBER) ensures consistent deployment and avoids overwriting existing images.

GCP IAM: Proper roles are critical for provisioning GKE and managing container images.

CI/CD: Running full end-to-end pipeline revealed subtle timing issues in resource creation and deployment order.
