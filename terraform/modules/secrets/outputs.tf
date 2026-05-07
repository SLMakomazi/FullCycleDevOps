# Secrets Module Outputs

output "mongodb_secret_name" {
  description = "MongoDB secret name"
  value       = kubernetes_secret.mongodb.metadata[0].name
}

output "mongodb_password" {
  description = "MongoDB password"
  value       = random_password.mongodb.result
  sensitive   = true
}

output "grafana_secret_name" {
  description = "Grafana secret name"
  value       = kubernetes_secret.grafana.metadata[0].name
}

output "grafana_admin_password" {
  description = "Grafana admin password"
  value       = random_password.grafana.result
  sensitive   = true
}

output "graylog_secret_name" {
  description = "Graylog secret name"
  value       = kubernetes_secret.graylog.metadata[0].name
}

output "graylog_root_password" {
  description = "Graylog root password"
  value       = random_password.graylog.result
  sensitive   = true
}
