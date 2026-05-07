# Ingress Module Outputs

output "traefik_service_name" {
  description = "Traefik service name"
  value       = var.traefik_enabled ? helm_release.traefik[0].name : null
}

output "traefik_load_balancer_ip" {
  description = "Traefik LoadBalancer IP"
  value       = var.traefik_enabled ? helm_release.traefik[0].status[0].load_balancer[0].ingress[0].ip : null
}

output "dashboard_url" {
  description = "Traefik dashboard URL"
  value       = var.dashboard_enabled ? "https://traefik.${var.ingress_domain}" : null
}

output "api_url" {
  description = "API URL"
  value       = "https://api.${var.ingress_domain}"
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://grafana.${var.ingress_domain}"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "https://prometheus.${var.ingress_domain}"
}

output "tempo_url" {
  description = "Tempo URL"
  value       = "https://tempo.${var.ingress_domain}"
}
