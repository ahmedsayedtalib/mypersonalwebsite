variable "project_id" {
  description = "GCP project ID"
  type        = string
  default = "first-cascade-473914-c1"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
  default     = "ahmedsayed-vpc"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "ahmedsayed-subnet"
}

variable "subnet_ip_range" {
  description = "IP range for the subnet"
  type        = string
  default     = "10.10.0.0/16"
}

variable "gke_cluster_name" {
  description = "GKE Autopilot cluster name"
  type        = string
  default     = "ahmedsayed-cluster"
}

variable "gke_location" {
  description = "Region or zone for GKE cluster"
  type        = string
  default     = "us-central1"
}

variable "tf_bucket_name" {
  description = "Cloud Storage bucket for Terraform state or storage"
  type        = string
  default     = "ahmedsayed-cluster"
}
