# Application Module Variables

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "devops-api"
}

variable "app_image" {
  description = "Application Docker image"
  type        = string
  default     = "devops-observability-api:latest"
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 8080
}

variable "replica_count" {
  description = "Number of replicas"
  type        = number
  default     = 2
}

variable "spring_profile" {
  description = "Spring profile"
  type        = string
  default     = "kubernetes"
}

variable "mongodb_service" {
  description = "MongoDB service name"
  type        = string
  default     = "mongodb-service"
}

variable "mongodb_database" {
  description = "MongoDB database name"
  type        = string
  default     = "devops_observability"
}

variable "service_type" {
  description = "Service type"
  type        = string
  default     = "ClusterIP"
}

variable "create_service_account" {
  description = "Create service account"
  type        = bool
  default     = true
}

variable "service_account_name" {
  description = "Service account name"
  type        = string
  default     = "devops-api"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to resources"
  type        = map(string)
  default     = {}
}

variable "resource_requests" {
  description = "Resource requests"
  type        = map(string)
  default = {
    cpu    = "250m"
    memory = "256Mi"
  }
}

variable "resource_limits" {
  description = "Resource limits"
  type        = map(string)
  default = {
    cpu    = "500m"
    memory = "512Mi"
  }
}

variable "extra_env_vars" {
  description = "Extra environment variables"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "extra_volume_mounts" {
  description = "Extra volume mounts"
  type = list(object({
    name       = string
    mount_path = string
  }))
  default = []
}

variable "extra_volumes" {
  description = "Extra volumes"
  type = list(object({
    name = string
    persistent_volume_claim = optional(object({
      claim_name = string
    }))
    config_map = optional(object({
      name = string
    }))
    secret = optional(object({
      secret_name = string
    }))
  }))
  default = []
}

variable "storage_class" {
  description = "Storage class"
  type        = string
  default     = "standard"
}

variable "logs_pvc_enabled" {
  description = "Enable logs PVC"
  type        = bool
  default     = true
}

variable "logs_storage_size" {
  description = "Logs storage size"
  type        = string
  default     = "5Gi"
}

variable "hpa_enabled" {
  description = "Enable Horizontal Pod Autoscaler"
  type        = bool
  default     = true
}

variable "min_replicas" {
  description = "Minimum replicas for HPA"
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Maximum replicas for HPA"
  type        = number
  default     = 10
}

variable "target_cpu_utilization" {
  description = "Target CPU utilization for HPA"
  type        = number
  default     = 70
}

variable "target_memory_utilization" {
  description = "Target memory utilization for HPA"
  type        = number
  default     = 80
}

variable "liveness_probe_initial_delay" {
  description = "Liveness probe initial delay"
  type        = number
  default     = 30
}

variable "liveness_probe_period" {
  description = "Liveness probe period"
  type        = number
  default     = 10
}

variable "liveness_probe_timeout" {
  description = "Liveness probe timeout"
  type        = number
  default     = 5
}

variable "liveness_probe_failure_threshold" {
  description = "Liveness probe failure threshold"
  type        = number
  default     = 3
}

variable "readiness_probe_initial_delay" {
  description = "Readiness probe initial delay"
  type        = number
  default     = 10
}

variable "readiness_probe_period" {
  description = "Readiness probe period"
  type        = number
  default     = 5
}

variable "readiness_probe_timeout" {
  description = "Readiness probe timeout"
  type        = number
  default     = 3
}

variable "readiness_probe_failure_threshold" {
  description = "Readiness probe failure threshold"
  type        = number
  default     = 3
}

variable "service_monitor_enabled" {
  description = "Enable ServiceMonitor"
  type        = bool
  default     = true
}

variable "node_selector" {
  description = "Node selector"
  type        = map(string)
  default     = {}
}

variable "affinity" {
  description = "Affinity rules"
  type        = any
  default     = null
}

variable "tolerations" {
  description = "Tolerations"
  type        = list(any)
  default     = []
}
