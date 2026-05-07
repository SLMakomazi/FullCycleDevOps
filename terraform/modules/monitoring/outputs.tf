# Monitoring Module Outputs

output "prometheus_service_name" {
  description = "Prometheus service name"
  value       = var.prometheus_enabled ? helm_release.prometheus[0].name : null
}

output "grafana_service_name" {
  description = "Grafana service name"
  value       = var.grafana_enabled ? helm_release.prometheus[0].name : null
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = var.ingress_enabled ? "http://prometheus.${var.ingress_domain}" : null
}

output "grafana_url" {
  description = "Grafana URL"
  value       = var.ingress_enabled ? "http://grafana.${var.ingress_domain}" : null
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = var.grafana_admin_password
  sensitive   = true
}
