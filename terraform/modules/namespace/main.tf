# Namespace Module
# Creates Kubernetes namespace with labels and annotations

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
}

# Create namespace
resource "kubernetes_namespace" "this" {
  metadata {
    name = var.name
    
    labels = merge(var.labels, {
      "kubernetes.io/metadata.name" = var.name
    })
    
    annotations = merge(var.annotations, {
      "terraform.io/managed-by" = "terraform"
    })
  }
}

# Network policies for namespace
resource "kubernetes_network_policy" "default_deny" {
  count = var.network_policy_enabled ? 1 : 0
  
  metadata {
    name      = "default-deny-all"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

# Resource quota for namespace
resource "kubernetes_resource_quota" "this" {
  count = var.resource_quota_enabled ? 1 : 0
  
  metadata {
    name      = "${var.name}-quota"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  
  spec {
    hard = var.resource_quota
  }
}

# Limit range for namespace
resource "kubernetes_limit_range" "this" {
  count = var.limit_range_enabled ? 1 : 0
  
  metadata {
    name      = "${var.name}-limits"
    namespace = kubernetes_namespace.this.metadata[0].name
  }
  
  spec {
    limit {
      type = "Container"
      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
      default_limit = {
        cpu    = "500m"
        memory = "512Mi"
      }
    }
  }
}
