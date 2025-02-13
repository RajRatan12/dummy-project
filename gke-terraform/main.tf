terraform {
  required_version = ">= 0.12"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = "us-central1-a"
  initial_node_count = 1

  remove_default_node_pool = true

  network    = "default"
  subnetwork = "default"

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-nodes"
  cluster    = google_container_cluster.primary.name
  location   = google_container_cluster.primary.location

  node_config {
    machine_type    = "e2-micro"
    disk_size_gb    = 30
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
    # Set resource_labels explicitly as an empty map to avoid unexpected changes.
    resource_labels = {}
  }

  initial_node_count = 1

  lifecycle {
    ignore_changes = [
      # Ignore changes to these nested fields so that Terraform doesn't try to update them.
      node_config[0].kubelet_config,
      node_config[0].resource_labels,
    ]
  }
}

output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}
