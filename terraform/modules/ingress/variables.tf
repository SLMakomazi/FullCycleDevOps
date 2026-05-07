# Ingress Module Variables

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "namespace_dependency" {
  description = "Namespace dependency"
  type        = any
  default     = null
}

variable "traefik_enabled" {
  description = "Enable Traefik deployment"
  type        = bool
  default     = true
}

variable "traefik_chart_version" {
  description = "Traefik Helm chart version"
  type        = string
  default     = "25.0.0"
}

variable "traefik_replicas" {
  description = "Traefik replica count"
  type        = number
  default     = 2
}

variable "ingress_domain" {
  description = "Domain for ingress"
  type        = string
  default     = "localhost"
}

variable "tls_enabled" {
  description = "Enable TLS"
  type        = bool
  default     = false
}

variable "cert_resolver" {
  description = "Certificate resolver name"
  type        = string
  default     = "letsencrypt"
}

variable "acme_email" {
  description = "ACME email for Let's Encrypt"
  type        = string
  default     = "admin@devops-observability.local"
}

variable "dashboard_enabled" {
  description = "Enable Traefik dashboard"
  type        = bool
  default     = true
}

variable "tracing_enabled" {
  description = "Enable tracing"
  type        = bool
  default     = true
}

variable "storage_class" {
  description = "Storage class"
  type        = string
  default     = "standard"
}

variable "traefik_storage_size" {
  description = "Traefik storage size"
  type        = string
  default     = "1Gi"
}

variable "additional_arguments" {
  description = "Additional Traefik arguments"
  type        = list(string)
  default     = []
}
