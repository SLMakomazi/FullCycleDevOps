# Secrets Module
# Creates Kubernetes secrets for the platform

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

# Random password for MongoDB
resource "random_password" "mongodb" {
  length  = 32
  special = true
}

# MongoDB secret
resource "kubernetes_secret" "mongodb" {
  metadata {
    name      = "mongodb-secret"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "mongodb"
      component = "database"
    })
  }
  
  type = "Opaque"
  
  data = {
    username = var.mongodb_username
    password = random_password.mongodb.result
    database = var.mongodb_database
  }
}

# Random password for Grafana
resource "random_password" "grafana" {
  length  = 32
  special = false
}

# Grafana secret
resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana-secret"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "grafana"
      component = "monitoring"
    })
  }
  
  type = "Opaque"
  
  data = {
    admin-user = var.grafana_admin_user
    admin-password = random_password.grafana.result
  }
}

# Random password for Graylog
resource "random_password" "graylog" {
  length  = 32
  special = false
}

# Graylog root password SHA2
resource "random_password" "graylog_root" {
  length  = 32
  special = false
}

# Graylog secret
resource "kubernetes_secret" "graylog" {
  metadata {
    name      = "graylog-secret"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "graylog"
      component = "logging"
    })
  }
  
  type = "Opaque"
  
  data = {
    root-password = random_password.graylog.result
    root-password-sha2 = sha256(random_password.graylog_root.result)
    password-secret = random_password.graylog_root.result
  }
}

# OpenSearch secret
resource "kubernetes_secret" "opensearch" {
  metadata {
    name      = "opensearch-secret"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "opensearch"
      component = "logging"
    })
  }
  
  type = "Opaque"
  
  data = {
    username = var.opensearch_username
    password = var.opensearch_password
  }
}

# OpenTelemetry Collector secret
resource "kubernetes_secret" "otel_collector" {
  metadata {
    name      = "otel-collector-secret"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "otel-collector"
      component = "observability"
    })
  }
  
  type = "Opaque"
  
  data = {
    otel-token = var.otel_token
  }
}

# TLS certificate secret
resource "kubernetes_secret" "tls" {
  count = var.tls_enabled ? 1 : 0
  
  metadata {
    name      = "tls-secret"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "platform"
      component = "security"
    })
  }
  
  type = "kubernetes.io/tls"
  
  data = {
    tls.crt = var.tls_cert
    tls.key = var.tls_key
  }
}

# Docker registry secret
resource "kubernetes_secret" "docker_registry" {
  count = var.docker_registry_enabled ? 1 : 0
  
  metadata {
    name      = "docker-registry-secret"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "platform"
      component = "security"
    })
  }
  
  type = "kubernetes.io/dockerconfigjson"
  
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.docker_registry_url) = {
          username = var.docker_registry_username
          password = var.docker_registry_password
          auth = base64encode("${var.docker_registry_username}:${var.docker_registry_password}")
        }
      }
    })
  }
}

# Custom application secrets
resource "kubernetes_secret" "app" {
  for_each = var.app_secrets
  
  metadata {
    name      = "app-secret-${each.key}"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = "application"
      component = "security"
    })
  }
  
  type = "Opaque"
  
  data = each.value
}
