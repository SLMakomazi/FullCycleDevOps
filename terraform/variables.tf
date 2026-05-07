# Terraform Variables
# Configuration variables for the DevOps & Observability Platform

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "devops-cluster"
}

variable "namespace" {
  description = "Kubernetes namespace for the platform"
  type        = string
  default     = "devops-observability"
}

variable "environment" {
  description = "Environment (development, staging, production)"
  type        = string
  default     = "development"
}

variable "region" {
  description = "AWS region (for future cloud deployment)"
  type        = string
  default     = "us-west-2"
}

variable "kubernetes_version" {
  description = "Kubernetes version for Kind cluster"
  type        = string
  default     = "v1.29.0"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "storage_size" {
  description = "Default storage size for PVCs"
  type        = string
  default     = "10Gi"
}

variable "replica_count" {
  description = "Default replica count for deployments"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    project     = "devops-observability"
    environment = "development"
    managed_by  = "terraform"
  }
}

# Application variables
variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "devops-observability-api:latest"
}

variable "app_port" {
  description = "Port for the application"
  type        = number
  default     = 8080
}

# Monitoring variables
variable "prometheus_version" {
  description = "Prometheus version"
  type        = string
  default     = "2.50.0"
}

variable "grafana_version" {
  description = "Grafana version"
  type        = string
  default     = "10.2.0"
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

# Database variables
variable "mongodb_version" {
  description = "MongoDB version"
  type        = string
  default     = "7.0.5"
}

variable "mongodb_storage_size" {
  description = "MongoDB storage size"
  type        = string
  default     = "20Gi"
}

# Ingress variables
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

# Observability variables
variable "tracing_enabled" {
  description = "Enable distributed tracing"
  type        = bool
  default     = true
}

variable "logging_enabled" {
  description = "Enable centralized logging"
  type        = bool
  default     = true
}

variable "metrics_enabled" {
  description = "Enable metrics collection"
  type        = bool
  default     = true
}

# Security variables
variable "rbac_enabled" {
  description = "Enable RBAC"
  type        = bool
  default     = true
}

variable "network_policies_enabled" {
  description = "Enable network policies"
  type        = bool
  default     = true
}

variable "pod_security_policy_enabled" {
  description = "Enable Pod Security Policy"
  type        = bool
  default     = false
}
