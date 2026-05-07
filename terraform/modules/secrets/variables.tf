# Secrets Module Variables

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "labels" {
  description = "Labels to apply to secrets"
  type        = map(string)
  default     = {}
}

variable "mongodb_username" {
  description = "MongoDB username"
  type        = string
  default     = "admin"
}

variable "mongodb_database" {
  description = "MongoDB database name"
  type        = string
  default     = "devops_observability"
}

variable "grafana_admin_user" {
  description = "Grafana admin username"
  type        = string
  default     = "admin"
}

variable "opensearch_username" {
  description = "OpenSearch username"
  type        = string
  default     = "admin"
}

variable "opensearch_password" {
  description = "OpenSearch password"
  type        = string
  default     = "StrongPassword123!"
  sensitive   = true
}

variable "otel_token" {
  description = "OpenTelemetry authentication token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tls_enabled" {
  description = "Enable TLS certificate"
  type        = bool
  default     = false
}

variable "tls_cert" {
  description = "TLS certificate"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tls_key" {
  description = "TLS private key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "docker_registry_enabled" {
  description = "Enable Docker registry secret"
  type        = bool
  default     = false
}

variable "docker_registry_url" {
  description = "Docker registry URL"
  type        = string
  default     = ""
}

variable "docker_registry_username" {
  description = "Docker registry username"
  type        = string
  default     = ""
}

variable "docker_registry_password" {
  description = "Docker registry password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "app_secrets" {
  description = "Custom application secrets"
  type        = map(map(string))
  default     = {}
}
