# VPC
resource "google_compute_network" "vpc_network" {
  name                    = "personalwebsite-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "personalwebsite-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# GKE Cluster (Autopilot)
resource "google_container_cluster" "gke_cluster" {
  name             = "ahmedsayed-cluster"
  location         = var.region
  networking_mode  = "VPC_NATIVE"
  enable_autopilot = true


  ip_allocation_policy {}

  lifecycle {
    prevent_destroy = true
  }
}

# Artifact Registry
resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "personalwebsite-docker"
  description   = "Docker repository for personal website"
  format        = "DOCKER"
  lifecycle {
    prevent_destroy = true
  }
}

# GCS Bucket for Terraform State
resource "google_storage_bucket" "tf_state_bucket" {
  name     = "ahmedsayed-cluster"
  location = var.region

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
