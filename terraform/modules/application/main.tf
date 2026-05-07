# Application Module
# Deploys the Spring Boot application and related components

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13.0"
    }
  }
}

# Application deployment
resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
    labels = merge(var.labels, {
      app = var.app_name
      component = "application"
    })
  }
  
  spec {
    replicas = var.replica_count
    
    selector {
      match_labels = {
        app = var.app_name
      }
    }
    
    template {
      metadata {
        labels = merge(var.labels, {
          app = var.app_name
          component = "application"
        })
        annotations = merge(var.annotations, {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port" = tostring(var.app_port)
          "prometheus.io/path" = "/actuator/prometheus"
        })
      }
      
      spec {
        service_account_name = var.service_account_name
        
        containers {
          name  = var.app_name
          image = var.app_image
          
          ports {
            name           = "http"
            container_port = var.app_port
            protocol       = "TCP"
          }
          
          env = concat([
            {
              name  = "SPRING_PROFILES_ACTIVE"
              value = var.spring_profile
            },
            {
              name  = "MONGODB_URI"
              value = "mongodb://${var.mongodb_service}:27017/${var.mongodb_database}"
            },
            {
              name  = "OTEL_EXPORTER_OTLP_ENDPOINT"
              value = "http://otel-collector.${var.namespace}.svc:4317"
            },
            {
              name  = "OTEL_SERVICE_NAME"
              value = var.app_name
            },
            {
              name  = "OTEL_SERVICE_VERSION"
              value = var.app_version
            }
          ], var.extra_env_vars)
          
          resources {
            limits = var.resource_limits
            requests = var.resource_requests
          }
          
          liveness_probe {
            http_get {
              path = "/actuator/health/liveness"
              port = "http"
            }
            initial_delay_seconds = var.liveness_probe_initial_delay
            period_seconds        = var.liveness_probe_period
            timeout_seconds       = var.liveness_probe_timeout
            failure_threshold     = var.liveness_probe_failure_threshold
          }
          
          readiness_probe {
            http_get {
              path = "/actuator/health/readiness"
              port = "http"
            }
            initial_delay_seconds = var.readiness_probe_initial_delay
            period_seconds        = var.readiness_probe_period
            timeout_seconds       = var.readiness_probe_timeout
            failure_threshold     = var.readiness_probe_failure_threshold
          }
          
          volume_mounts = concat([
            {
              name = "logs"
              mount_path = "/var/log/app"
            }
          ], var.extra_volume_mounts)
          
          security_context = {
            allow_privilege_escalation = false
            read_only_root_filesystem   = true
            run_as_non_root           = true
            run_as_user              = 1000
            run_as_group             = 1000
            capabilities = {
              drop = ["ALL"]
            }
          }
        }
        
        volumes = concat([
          {
            name = "logs"
            persistent_volume_claim = {
              claim_name = kubernetes_persistent_volume_claim.logs[0].metadata[0].name
            }
          }
        ], var.extra_volumes)
        
        node_selector = var.node_selector
        affinity = var.affinity
        tolerations = var.tolerations
      }
    }
  }
}

# Application service
resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.app_name}-service"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = var.app_name
      component = "application"
    })
    annotations = merge(var.annotations, {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port" = tostring(var.app_port)
      "prometheus.io/path" = "/actuator/prometheus"
    })
  }
  
  spec {
    selector = {
      app = var.app_name
    }
    
    ports {
      name        = "http"
      port        = var.app_port
      target_port = var.app_port
      protocol    = "TCP"
    }
    
    type = var.service_type
  }
}

# Logs PVC
resource "kubernetes_persistent_volume_claim" "logs" {
  count = var.logs_pvc_enabled ? 1 : 0
  
  metadata {
    name      = "${var.app_name}-logs"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = var.app_name
      component = "application"
    })
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = var.storage_class
    resources {
      requests = {
        storage = var.logs_storage_size
      }
    }
  }
}

# ServiceAccount
resource "kubernetes_service_account" "app" {
  count = var.create_service_account ? 1 : 0
  
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    labels = merge(var.labels, {
      app = var.app_name
      component = "application"
    })
  }
}

# Horizontal Pod Autoscaler
resource "kubernetes_horizontal_pod_autoscaler" "app" {
  count = var.hpa_enabled ? 1 : 0
  
  metadata {
    name      = "${var.app_name}-hpa"
    namespace = var.namespace
    labels = merge(var.labels, {
      app = var.app_name
      component = "application"
    })
  }
  
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }
    
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
    
    metrics {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type               = "Utilization"
          average_utilization = var.target_cpu_utilization
        }
      }
    }
    
    metrics {
      type = "Resource"
      resource {
        name = "memory"
        target {
          type               = "Utilization"
          average_utilization = var.target_memory_utilization
        }
      }
    }
  }
}

# ServiceMonitor for Prometheus
resource "kubernetes_manifest" "service_monitor" {
  count = var.service_monitor_enabled ? 1 : 0
  
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "${var.app_name}-monitor"
      namespace = var.namespace
      labels = merge(var.labels, {
        app = var.app_name
        component = "application"
      })
    }
    spec = {
      selector = {
        matchLabels = {
          app = var.app_name
        }
      }
      endpoints = [
        {
          port = "http"
          path = "/actuator/prometheus"
          interval = "30s"
          scrapeTimeout = "10s"
        }
      ]
    }
  }
}
