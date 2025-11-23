provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_ip_range
  network       = google_compute_network.vpc.id
  region        = var.region
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_container_cluster" "ahmedsayed-cluster" {
  name     = var.gke_cluster_name
  location = var.gke_location
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.subnet.id
  enable_autopilot = true
  lifecycle {
    prevent_destroy = true
  }
}

# resource "google_storage_bucket" "bucket" {
#   name     = var.tf_bucket_name
#   location = var.region

#   lifecycle {
#     prevent_destroy = true
#   }
# }
