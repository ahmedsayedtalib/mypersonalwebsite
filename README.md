# 🌐 My Personal Website - CI/CD on GKE

This repository contains my **personal website** built with HTML, CSS, and JavaScript, and deployed using a full **CI/CD pipeline** powered by Jenkins, Docker, SonarQube, Terraform, ArgoCD, and Google Kubernetes Engine (GKE).

---

## 🚀 Project Overview

This project demonstrates a complete DevOps workflow — from source code to production — using the following stack:

- **Frontend:** 🖥️ HTML, CSS, JavaScript (Static Website)
- **Version Control:** 🔗 Git & GitHub
- **Static Code Analysis:** 🔍 SonarQube
- **Containerization:** 🐳 Docker
- **Continuous Integration:** ⚙️ Jenkins
- **Infrastructure as Code:** 🌱 Terraform
- **Continuous Deployment:** ⚙️ Jenkins
- **Cloud Platform:** ☁️ Google Cloud Platform (GCP)
- **Monitoring:** 📊 Prometheus & Grafana

---

## 🧩 Repository Structure

/mypersonalwebsite
/
├── Dockerfile # 🐳 Builds the website image
├── Jenkinsfile # ⚙️ CI/CD pipeline definition
├── index.js # 🖥️ JavaScript for the frontend
├── index.css # 🖌️ Website styles
├── k8s/
│ └── deployment.yaml # 🚀 Kubernetes deployment manifest
├── personal_website/
│ ├── metrics.yaml # 📊 Optional monitoring config
│ └── mypersonalwebsite/
│ └── index.html # 🖥️ Main HTML page
└── sonar-scanner.zip # 🔍 SonarQube scanner (if needed)


---
## ⚙️ CI/CD Pipeline Stages

1. Code Checkout 🔄

Jenkins pulls the source code from GitHub using the main branch.

2. Static Code Analysis 🔍

SonarQube analyzes the code for bugs, vulnerabilities, and code smells.

Only .html, .css, and .js files are analyzed.

3. Build and Dockerize 🐳

Docker image is built from the Dockerfile.

Image is tagged with the build number and pushed to Google Artifact Registry.

4. Update Kubernetes Manifest ✏️

Updates the image: field in k8s/depl.yaml to the new Docker image tag.

5. Terraform Init & Apply 🌱

Initializes Terraform and applies infrastructure changes.

Creates or updates GKE cluster and other required resources.

Backend bucket is assumed to already exist.

6. Login to GCP 🔐

Authenticates Jenkins to GCP using a service account JSON key.

Configures kubectl to communicate with the GKE cluster.

7. Deploy to GKE via Jenkins 🚢

Jenkins directly applies k8s/depl.yaml using kubectl.

Service manifests are applied from the same directory.

8. Verify Deployment ✅

Checks all pods, services, and deployments in the default namespace.

---

## 🔑 Credentials & Access

The Jenkins service account used for GCP operations has the following roles:

roles/artifactregistry.admin 🐳

roles/artifactregistry.createOnPushWriter 🐳

roles/container.admin 🚀

roles/storage.admin ☁️

These roles are sufficient for pushing images, managing clusters, and reading/writing to GCS.

These roles are sufficient for pushing images, managing clusters, and reading/writing to GCS.

---

## 🧠 Lessons Learned

SonarQube Setup: Required increasing memory(2GB min/4GB max) and setting sonar.web.host=0.0.0.0

Token Issues: Solved by creating a valid sonarqube token and configuring Jenkins credentials.

GKE & GCP IAM: Service account needed multiple roles for successful deploys.

Terraform Integration: Learned to automate GKE cluster creation and resource provisioning.

Direct Deployment via Jenkins: GitOps via ArgoCD is optional; Jenkins can now handle kubectl apply directly.

---

## 🧰 Tools Used
Tool	Symbol	Purpose
Jenkins	⚙️	CI/CD automation & CD via kubectl
SonarQube	🔍	Static code analysis
Docker	🐳	Containerization
Terraform	🌱	Infrastructure as Code
GKE	🚀	Kubernetes cluster & deployment
Google Cloud Platform (GCP)	☁️	Cloud hosting & storage
GitHub	🔗	Source control

---

## 🧾 Deployment (Manual)

To deploy manually:

```bash

kubectl apply -f k8s/deployment.yaml

👤  Author

Ahmed Sayed Talib Osman
DevOps & Cloud Admin
📍 Saudi Arabia 🇸🇦
📧 ahmedsayedtalib@outlook.com