# Storage Module Variables

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "labels" {
  description = "Labels to apply to storage resources"
  type        = map(string)
  default     = {}
}

variable "create_storage_class" {
  description = "Create custom storage class"
  type        = bool
  default     = false
}

variable "storage_class_name" {
  description = "Storage class name"
  type        = string
  default     = "standard"
}

variable "storage_provisioner" {
  description = "Storage provisioner"
  type        = string
  default     = "kubernetes.io/no-provisioner"
}

variable "storage_class_parameters" {
  description = "Storage class parameters"
  type        = map(string)
  default     = {}
}

variable "allow_volume_expansion" {
  description = "Allow volume expansion"
  type        = bool
  default     = true
}

variable "volume_binding_mode" {
  description = "Volume binding mode"
  type        = string
  default     = "WaitForFirstConsumer"
}

variable "reclaim_policy" {
  description = "Reclaim policy"
  type        = string
  default     = "Delete"
}

variable "mongodb_enabled" {
  description = "Enable MongoDB PVC"
  type        = bool
  default     = true
}

variable "mongodb_storage_size" {
  description = "MongoDB storage size"
  type        = string
  default     = "20Gi"
}

variable "grafana_enabled" {
  description = "Enable Grafana PVC"
  type        = bool
  default     = true
}

variable "grafana_storage_size" {
  description = "Grafana storage size"
  type        = string
  default     = "5Gi"
}

variable "prometheus_enabled" {
  description = "Enable Prometheus PVC"
  type        = bool
  default     = true
}

variable "prometheus_storage_size" {
  description = "Prometheus storage size"
  type        = string
  default     = "20Gi"
}

variable "tempo_enabled" {
  description = "Enable Tempo PVC"
  type        = bool
  default     = true
}

variable "tempo_storage_size" {
  description = "Tempo storage size"
  type        = string
  default     = "10Gi"
}

variable "traefik_enabled" {
  description = "Enable Traefik PVC"
  type        = bool
  default     = true
}

variable "traefik_storage_size" {
  description = "Traefik storage size"
  type        = string
  default     = "1Gi"
}

variable "graylog_enabled" {
  description = "Enable Graylog PVC"
  type        = bool
  default     = true
}

variable "graylog_storage_size" {
  description = "Graylog storage size"
  type        = string
  default     = "10Gi"
}

variable "opensearch_enabled" {
  description = "Enable OpenSearch PVC"
  type        = bool
  default     = true
}

variable "opensearch_storage_size" {
  description = "OpenSearch storage size"
  type        = string
  default     = "20Gi"
}

variable "app_logs_enabled" {
  description = "Enable application logs PVC"
  type        = bool
  default     = true
}

variable "app_logs_storage_size" {
  description = "Application logs storage size"
  type        = string
  default     = "5Gi"
}

variable "shared_storage_enabled" {
  description = "Enable shared storage PVC"
  type        = bool
  default     = false
}

variable "shared_storage_class" {
  description = "Shared storage class"
  type        = string
  default     = "standard"
}

variable "shared_storage_size" {
  description = "Shared storage size"
  type        = string
  default     = "10Gi"
}
