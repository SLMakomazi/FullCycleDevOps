# Namespace Module Outputs

output "name" {
  description = "Name of the namespace"
  value       = kubernetes_namespace.this.metadata[0].name
}

output "id" {
  description = "ID of the namespace"
  value       = kubernetes_namespace.this.id
}

output "labels" {
  description = "Labels applied to the namespace"
  value       = kubernetes_namespace.this.metadata[0].labels
}

output "annotations" {
  description = "Annotations applied to the namespace"
  value       = kubernetes_namespace.this.metadata[0].annotations
}
