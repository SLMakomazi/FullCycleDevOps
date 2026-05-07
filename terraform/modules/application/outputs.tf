# Application Module Outputs

output "deployment_name" {
  description = "Application deployment name"
  value       = kubernetes_deployment.app.metadata[0].name
}

output "service_name" {
  description = "Application service name"
  value       = kubernetes_service.app.metadata[0].name
}

output "service_url" {
  description = "Application service URL"
  value       = "${kubernetes_service.app.metadata[0].name}.${var.namespace}.svc:${var.app_port}"
}

output "hpa_name" {
  description = "HPA name"
  value       = var.hpa_enabled ? kubernetes_horizontal_pod_autoscaler.app[0].metadata[0].name : null
}
