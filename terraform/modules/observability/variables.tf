# Observability Module Variables

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "namespace_dependency" {
  description = "Namespace dependency"
  type        = any
  default     = null
}

variable "tempo_enabled" {
  description = "Enable Tempo deployment"
  type        = bool
  default     = true
}

variable "otel_collector_enabled" {
  description = "Enable OpenTelemetry Collector deployment"
  type        = bool
  default     = true
}

variable "tempo_chart_version" {
  description = "Tempo Helm chart version"
  type        = string
  default     = "1.8.1"
}

variable "otel_collector_chart_version" {
  description = "OpenTelemetry Collector Helm chart version"
  type        = string
  default     = "0.80.0"
}

variable "tempo_version" {
  description = "Tempo version"
  type        = string
  default     = "2.4.1"
}

variable "otel_collector_version" {
  description = "OpenTelemetry Collector version"
  type        = string
  default     = "0.93.0"
}

variable "tempo_retention" {
  description = "Tempo trace retention period"
  type        = string
  default     = "24h"
}

variable "tempo_storage_size" {
  description = "Tempo storage size"
  type        = string
  default     = "10Gi"
}

variable "otel_collector_replicas" {
  description = "OpenTelemetry Collector replica count"
  type        = number
  default     = 2
}

variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = "standard"
}

variable "ingress_enabled" {
  description = "Enable ingress for services"
  type        = bool
  default     = true
}

variable "ingress_domain" {
  description = "Domain for ingress"
  type        = string
  default     = "localhost"
}

variable "ingress_tls_enabled" {
  description = "Enable TLS for ingress"
  type        = bool
  default     = false
}
