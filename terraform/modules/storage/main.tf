# Storage Module
# Creates persistent volumes and storage classes

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
}

# Custom storage class
resource "kubernetes_storage_class" "custom" {
  count = var.create_storage_class ? 1 : 0
  
  metadata {
    name = var.storage_class_name
    labels = merge(var.labels, {
      app = "platform"
      component = "storage"
    })
  }
  
  storage_provisioner = var.storage_provisioner
  parameters = var.storage_class_parameters
  allow_volume_expansion = var.allow_volume_expansion
  volume_binding_mode = var.volume_binding_mode
  reclaim_policy = var.reclaim_policy
}

# MongoDB PVC
resource "kubernetes_persistent_volume_claim" "mongodb" {
  count = var.mongodb_enabled ? 1 : 0
  
  metadata {
    name      = "mongodb-pvc"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "mongodb"
      component = "database"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.mongodb_storage_size
      }
    }
  }
}

# Grafana PVC
resource "kubernetes_persistent_volume_claim" "grafana" {
  count = var.grafana_enabled ? 1 : 0
  
  metadata {
    name      = "grafana-pvc"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "grafana"
      component = "monitoring"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.grafana_storage_size
      }
    }
  }
}

# Prometheus PVC
resource "kubernetes_persistent_volume_claim" "prometheus" {
  count = var.prometheus_enabled ? 1 : 0
  
  metadata {
    name      = "prometheus-pvc"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "prometheus"
      component = "monitoring"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.prometheus_storage_size
      }
    }
  }
}

# Tempo PVC
resource "kubernetes_persistent_volume_claim" "tempo" {
  count = var.tempo_enabled ? 1 : 0
  
  metadata {
    name      = "tempo-pvc"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "tempo"
      component = "observability"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.tempo_storage_size
      }
    }
  }
}

# Traefik PVC
resource "kubernetes_persistent_volume_claim" "traefik" {
  count = var.traefik_enabled ? 1 : 0
  
  metadata {
    name      = "traefik-pvc"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "traefik"
      component = "ingress"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.traefik_storage_size
      }
    }
  }
}

# Graylog PVC
resource "kubernetes_persistent_volume_claim" "graylog" {
  count = var.graylog_enabled ? 1 : 0
  
  metadata {
    name      = "graylog-pvc"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "graylog"
      component = "logging"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.graylog_storage_size
      }
    }
  }
}

# OpenSearch PVC
resource "kubernetes_persistent_volume_claim" "opensearch" {
  count = var.opensearch_enabled ? 1 : 0
  
  metadata {
    name      = "opensearch-pvc"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "opensearch"
      component = "logging"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.opensearch_storage_size
      }
    }
  }
}

# Application logs PVC
resource "kubernetes_persistent_volume_claim" "app_logs" {
  count = var.app_logs_enabled ? 1 : 0
  
  metadata {
    name      = "app-logs-pvc"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "application"
      component = "logging"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = var.app_logs_storage_size
      }
    }
  }
}

# Shared storage PVC
resource "kubernetes_persistent_volume_claim" "shared" {
  count = var.shared_storage_enabled ? 1 : 0
  
  metadata {
    name      = "shared-pvc"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "platform"
      component = "storage"
    })
  }
  
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = var.shared_storage_class
    resources {
      requests = {
        storage = var.shared_storage_size
      }
    }
  }
}
