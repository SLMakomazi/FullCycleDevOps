# Observability Module Outputs

output "tempo_service_name" {
  description = "Tempo service name"
  value       = var.tempo_enabled ? helm_release.tempo[0].name : null
}

output "otel_collector_service_name" {
  description = "OpenTelemetry Collector service name"
  value       = var.otel_collector_enabled ? helm_release.otel_collector[0].name : null
}

output "tempo_url" {
  description = "Tempo URL"
  value       = var.ingress_enabled ? "http://tempo.${var.ingress_domain}" : null
}

output "otel_collector_endpoint" {
  description = "OpenTelemetry Collector endpoint"
  value       = var.otel_collector_enabled ? "otel-collector.${var.namespace}.svc:4317" : null
}
