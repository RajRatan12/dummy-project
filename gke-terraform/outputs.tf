output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}
