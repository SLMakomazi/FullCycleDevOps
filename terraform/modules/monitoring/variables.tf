# Monitoring Module Variables

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "namespace_dependency" {
  description = "Namespace dependency"
  type        = any
  default     = null
}

variable "prometheus_enabled" {
  description = "Enable Prometheus deployment"
  type        = bool
  default     = true
}

variable "grafana_enabled" {
  description = "Enable Grafana deployment"
  type        = bool
  default     = true
}

variable "alertmanager_enabled" {
  description = "Enable AlertManager deployment"
  type        = bool
  default     = true
}

variable "node_exporter_enabled" {
  description = "Enable Node Exporter"
  type        = bool
  default     = true
}

variable "kube_state_metrics_enabled" {
  description = "Enable kube-state-metrics"
  type        = bool
  default     = true
}

variable "prometheus_chart_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "55.5.0"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "15d"
}

variable "prometheus_storage_size" {
  description = "Prometheus storage size"
  type        = string
  default     = "20Gi"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123"
  sensitive   = true
}

variable "grafana_storage_size" {
  description = "Grafana storage size"
  type        = string
  default     = "5Gi"
}

variable "alertmanager_storage_size" {
  description = "AlertManager storage size"
  type        = string
  default     = "5Gi"
}

variable "storage_class" {
  description = "Storage class for persistent volumes"
  type        = string
  default     = "standard"
}

variable "ingress_enabled" {
  description = "Enable Grafana ingress"
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

variable "custom_rules" {
  description = "Custom Prometheus recording and alerting rules"
  type = list(object({
    name        = string
    interval    = optional(string, "30s")
    rules = list(object({
      alert       = optional(string)
      expr        = string
      for         = optional(string)
      labels      = optional(map(string), {})
      annotations = optional(map(string), {})
      record      = optional(string)
    }))
  }))
  default = []
}

variable "grafana_dashboards" {
  description = "Grafana dashboards"
  type        = map(string)
  default     = {}
}

variable "service_monitors" {
  description = "Service monitors for Prometheus"
  type = map(object({
    selector = object({
      matchLabels = map(string)
    })
    namespaceSelector = optional(object({
      any = optional(bool, true)
      matchNames = optional(list(string), [])
    }), {})
    endpoints = list(object({
      port = string
      path = optional(string, "/metrics")
      interval = optional(string, "30s")
      scrapeTimeout = optional(string, "10s")
      honorLabels = optional(bool, false)
    }))
  }))
  default = {}
}
