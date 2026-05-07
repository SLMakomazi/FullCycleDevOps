# Storage Module Outputs

output "storage_class_name" {
  description = "Storage class name"
  value       = var.create_storage_class ? kubernetes_storage_class.custom[0].metadata[0].name : var.storage_class_name
}

output "mongodb_pvc_name" {
  description = "MongoDB PVC name"
  value       = var.mongodb_enabled ? kubernetes_persistent_volume_claim.mongodb[0].metadata[0].name : null
}

output "grafana_pvc_name" {
  description = "Grafana PVC name"
  value       = var.grafana_enabled ? kubernetes_persistent_volume_claim.grafana[0].metadata[0].name : null
}

output "prometheus_pvc_name" {
  description = "Prometheus PVC name"
  value       = var.prometheus_enabled ? kubernetes_persistent_volume_claim.prometheus[0].metadata[0].name : null
}

output "tempo_pvc_name" {
  description = "Tempo PVC name"
  value       = var.tempo_enabled ? kubernetes_persistent_volume_claim.tempo[0].metadata[0].name : null
}

output "traefik_pvc_name" {
  description = "Traefik PVC name"
  value       = var.traefik_enabled ? kubernetes_persistent_volume_claim.traefik[0].metadata[0].name : null
}
