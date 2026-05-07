# Monitoring Module
# Deploys Prometheus, Grafana, and related monitoring components

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

# Prometheus Helm release
resource "helm_release" "prometheus" {
  count = var.prometheus_enabled ? 1 : 0
  
  name       = "prometheus"
  namespace  = var.namespace
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.prometheus_chart_version
  
  timeout = 600
  
  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = var.prometheus_retention
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.prometheus_storage_size
                  }
                }
              }
            }
          }
          resources = {
            requests = {
              cpu    = "500m"
              memory = "1Gi"
            }
            limits = {
              cpu    = "1000m"
              memory = "2Gi"
            }
          }
        }
      }
      
      grafana = {
        adminPassword = var.grafana_admin_password
        persistence = {
          enabled = true
          size    = var.grafana_storage_size
          storageClass = var.storage_class
        }
        resources = {
          requests = {
            cpu    = "250m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
        sidecar = {
          datasources = {
            enabled = true
          }
          dashboards = {
            enabled = true
            provider = {
              foldersFromFilesStructure = true
            }
          }
        }
        ingress = {
          enabled = var.ingress_enabled
          hosts = [
            {
              host = "grafana.${var.ingress_domain}"
              paths = ["/"]
            }
          ]
          tls = var.ingress_tls_enabled ? [
            {
              hosts = ["grafana.${var.ingress_domain}"]
            }
          ] : []
        }
      }
      
      alertmanager = {
        enabled = var.alertmanager_enabled
        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = var.storage_class
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.alertmanager_storage_size
                  }
                }
              }
            }
          }
        }
      }
      
      nodeExporter = {
        enabled = var.node_exporter_enabled
      }
      
      kubeStateMetrics = {
        enabled = var.kube_state_metrics_enabled
      }
    })
  ]
  
  depends_on = [var.namespace_dependency]
}

# Custom Prometheus rules
resource "kubernetes_config_map" "prometheus_rules" {
  count = var.prometheus_enabled && length(var.custom_rules) > 0 ? 1 : 0
  
  metadata {
    name      = "prometheus-custom-rules"
    namespace = var.namespace
    labels = {
      app.kubernetes.io/name = "prometheus"
    }
  }
  
  data = {
    "custom-rules.yml" = yamlencode({
      groups = var.custom_rules
    })
  }
}

# Grafana dashboard ConfigMaps
resource "kubernetes_config_map" "grafana_dashboards" {
  for_each = var.grafana_enabled ? var.grafana_dashboards : {}
  
  metadata {
    name      = "grafana-dashboard-${each.key}"
    namespace = var.namespace
    labels = {
      grafana_dashboard = "1"
      app.kubernetes.io/name = "grafana"
    }
  }
  
  data = {
    "${each.key}.json" = each.value
  }
}

# Grafana datasource ConfigMap
resource "kubernetes_config_map" "grafana_datasources" {
  count = var.grafana_enabled ? 1 : 0
  
  metadata {
    name      = "grafana-datasources"
    namespace = var.namespace
    labels = {
      app.kubernetes.io/name = "grafana"
    }
  }
  
  data = {
    "datasources.yml" = yamlencode([
      {
        name = "Prometheus"
        type = "prometheus"
        access = "proxy"
        url = "http://prometheus-operated.${var.namespace}.svc:9090"
        isDefault = true
        editable = false
      },
      {
        name = "Tempo"
        type = "tempo"
        access = "proxy"
        url = "http://tempo-service.${var.namespace}.svc:3200"
        editable = false
      }
    ])
  }
}

# Service Monitor for custom applications
resource "kubernetes_manifest" "service_monitor" {
  for_each = var.service_monitors
  
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = each.key
      namespace = var.namespace
      labels = {
        app.kubernetes.io/name = each.key
      }
    }
    spec = each.value
  }
}
