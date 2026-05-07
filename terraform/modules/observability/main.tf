# Observability Module
# Deploys OpenTelemetry Collector, Tempo, and related observability components

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

# Tempo Helm release
resource "helm_release" "tempo" {
  count = var.tempo_enabled ? 1 : 0
  
  name       = "tempo"
  namespace  = var.namespace
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  version    = var.tempo_chart_version
  
  timeout = 300
  
  values = [
    yamlencode({
      tempo = {
        enabled = true
        retention = var.tempo_retention
        
        storage = {
          trace = {
            backend = "local"
            local = {
              path = "/var/tempo/traces"
            }
            wal = {
              path = "/var/tempo/wal"
            }
          }
        }
        
        ingester = {
          trace_idle_period = "10s"
          max_block_bytes = 1048576
          max_block_duration = "5m"
        }
        
        compactor = {
          compaction = {
            compaction_window = "1h"
            max_block_bytes = 100000000
            block_retention = "24h"
          }
        }
        
        metrics_generator = {
          registry = {
            external_labels = {
              source = "tempo"
              cluster = "devops-cluster"
            }
          }
          storage = {
            path = "/var/tempo/generator/wal"
            remote_write = [
              {
                url = "http://prometheus-operated.${var.namespace}.svc:9090/api/v1/write"
                send_exemplars = true
              }
            ]
          }
        }
        
        server = {
          http_listen_port = 3200
          grpc_listen_port = 9095
          log_level = "info"
        }
        
        distributor = {
          receivers = {
            otlp = {
              protocols = {
                grpc = {
                  endpoint = "0.0.0.0:4317"
                }
                http = {
                  endpoint = "0.0.0.0:4318"
                }
              }
            }
          }
        }
        
        query_frontend = {
          search = {
            external_backend = "elasticsearch"
            elasticsearch = {
              addresses = ["http://opensearch-service.${var.namespace}.svc:9200"]
              index_prefix = "tempo-"
              index_template_pattern = "tempo-{%Y.%m.%d}"
              max_doc_count = 1000
              use_ilm = true
              ilm_policy = "tempo-ilm-policy"
            }
          }
        }
      }
      
      persistence = {
        enabled = true
        size = var.tempo_storage_size
        storageClass = var.storage_class
      }
      
      service = {
        type = "ClusterIP"
        ports = {
          http = 3200
          grpc = 9095
          otlp = 4317
        }
      }
      
      ingress = {
        enabled = var.ingress_enabled
        className = "traefik"
        hosts = [
          {
            host = "tempo.${var.ingress_domain}"
            paths = [
              {
                path = "/"
                pathType = "Prefix"
              }
            ]
          }
        ]
        tls = var.ingress_tls_enabled ? [
          {
            hosts = ["tempo.${var.ingress_domain}"]
          }
        ] : []
      }
    })
  ]
  
  depends_on = [var.namespace_dependency]
}

# OpenTelemetry Collector Helm release
resource "helm_release" "otel_collector" {
  count = var.otel_collector_enabled ? 1 : 0
  
  name       = "otel-collector"
  namespace  = var.namespace
  repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
  chart      = "opentelemetry-collector"
  version    = var.otel_collector_chart_version
  
  timeout = 300
  
  values = [
    yamlencode({
      mode = "deployment"
      replicas = var.otel_collector_replicas
      
      image = {
        repository = "otel/opentelemetry-collector-contrib"
        tag = var.otel_collector_version
      }
      
      config = yamlencode({
        extensions = {
          health_check = {
            endpoint = "0.0.0.0:13133"
          }
          zpages = {
            endpoint = "0.0.0.0:55679"
          }
          memory_ballast = {
            size_mib = 512
          }
        }
        
        receivers = {
          otlp = {
            protocols = {
              grpc = {
                endpoint = "0.0.0.0:4317"
              }
              http = {
                endpoint = "0.0.0.0:4318"
              }
            }
          }
          
          prometheus = {
            config = {
              scrape_configs = [
                {
                  job_name = "otel-collector"
                  static_configs = [
                    {
                      targets = ["localhost:8888"]
                    }
                  ]
                },
                {
                  job_name = "devops-api"
                  static_configs = [
                    {
                      targets = ["devops-api-service.${var.namespace}.svc:8080"]
                    }
                  ]
                  metrics_path = "/actuator/prometheus"
                  scrape_interval = "15s"
                }
              ]
            }
          }
          
          filelog = {
            include = [
              "/var/log/app/*.log",
              "/var/log/containers/*.log"
            ]
            start_at = "beginning"
            include_file_name = false
            include_file_path = true
            operators = [
              {
                type = "router"
                routes = [
                  {
                    output = "parse_json"
                    expr = "body matches \"^\\\\{.*\\\\}$\""
                  }
                ]
              },
              {
                type = "json_parser"
                output = "extract_metadata"
                timestamp = {
                  parse_from = "attributes.timestamp"
                  layout = "%Y-%m-%dT%H:%M:%S.%fZ"
                }
              }
            ]
          }
        }
        
        processors = {
          batch = {
            timeout = "1s"
            send_batch_size = 1024
            send_batch_max_size = 2048
          }
          
          memory_limiter = {
            check_interval = "1s"
            limit_mib = 1024
            spike_limit_mib = 512
          }
          
          resource = {
            attributes = [
              {
                key = "environment"
                value = "kubernetes"
                action = "upsert"
              },
              {
                key = "cluster"
                value = "devops-cluster"
                action = "upsert"
              }
            ]
          }
          
          resourcedetection = {
            detectors = ["env", "k8snode"]
            timeout = "10s"
            override = false
          }
          
          attributes = {
            actions = [
              {
                key = "service.name"
                action = "upsert"
                value = "devops-observability-api"
              },
              {
                key = "service.version"
                action = "upsert"
                value = "1.0.0"
              },
              {
                key = "telemetry.sdk.name"
                action = "delete"
              },
              {
                key = "telemetry.sdk.language"
                action = "delete"
              },
              {
                key = "telemetry.sdk.version"
                action = "delete"
              }
            ]
          }
        }
        
        exporters = {
          otlp = {
            endpoint = "tempo-service.${var.namespace}.svc:4317"
            tls = {
              insecure = true
            }
          }
          
          prometheus = {
            endpoint = "0.0.0.0:8889"
            namespace = "otel"
            const_labels = {
              environment = "kubernetes"
            }
          }
          
          loki = {
            endpoint = "http://graylog-service.${var.namespace}.svc:3100/loki/api/v1/push"
            labels = {
              job = "otel-collector"
              environment = "kubernetes"
            }
          }
          
          logging = {
            loglevel = "info"
          }
        }
        
        service = {
          extensions = ["health_check", "zpages", "memory_ballast"]
          pipelines = {
            traces = {
              receivers = ["otlp"]
              processors = ["memory_limiter", "batch", "resource", "attributes"]
              exporters = ["otlp", "logging"]
            }
            
            metrics = {
              receivers = ["otlp", "prometheus"]
              processors = ["memory_limiter", "batch", "resource", "attributes"]
              exporters = ["prometheus", "logging"]
            }
            
            logs = {
              receivers = ["otlp", "filelog"]
              processors = ["memory_limiter", "batch", "resource", "attributes"]
              exporters = ["loki", "logging"]
            }
          }
        }
      })
      
      resources = {
        limits = {
          cpu = "500m"
          memory = "512Mi"
        }
        requests = {
          cpu = "100m"
          memory = "256Mi"
        }
      }
      
      service = {
        ports = [
          {
            name = "otlp"
            port = 4317
            targetPort = 4317
          },
          {
            name = "otlp-http"
            port = 4318
            targetPort = 4318
          },
          {
            name = "prometheus"
            port = 8889
            targetPort = 8889
          },
          {
            name = "health"
            port = 13133
            targetPort = 13133
          }
        ]
      }
    })
  ]
  
  depends_on = [var.namespace_dependency]
}
