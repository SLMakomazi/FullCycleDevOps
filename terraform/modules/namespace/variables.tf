# Namespace Module Variables

variable "name" {
  description = "Name of the namespace"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the namespace"
  type        = map(string)
  default     = {}
}

variable "annotations" {
  description = "Annotations to apply to the namespace"
  type        = map(string)
  default     = {}
}

variable "network_policy_enabled" {
  description = "Enable default network policies"
  type        = bool
  default     = true
}

variable "resource_quota_enabled" {
  description = "Enable resource quota"
  type        = bool
  default     = true
}

variable "limit_range_enabled" {
  description = "Enable limit range"
  type        = bool
  default     = true
}

variable "resource_quota" {
  description = "Resource quota limits"
  type        = map(string)
  default = {
    "requests.cpu"    = "2"
    "requests.memory" = "4Gi"
    "limits.cpu"      = "4"
    "limits.memory"   = "8Gi"
    "persistentvolumeclaims" = "10"
    "pods"            = "20"
    "services"        = "10"
    "secrets"         = "10"
    "configmaps"      = "10"
  }
}
