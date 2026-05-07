# Ingress Module
# Deploys Traefik ingress controller and routing rules

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

# Traefik Helm release
resource "helm_release" "traefik" {
  count = var.traefik_enabled ? 1 : 0
  
  name       = "traefik"
  namespace  = var.namespace
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = var.traefik_chart_version
  
  timeout = 300
  
  values = [
    yamlencode({
      deployment = {
        replicas = var.traefik_replicas
      }
      
      service = {
        type = "LoadBalancer"
        ports = {
          web = {
            port = 80
            targetPort = 80
          }
          websecure = {
            port = 443
            targetPort = 443
          }
          metrics = {
            port = 8082
            targetPort = 8082
          }
        }
      }
      
      ports = {
        web = {
          redirectTo = "websecure"
        }
        websecure = {
          tls = {
            enabled = var.tls_enabled
            certResolver = var.cert_resolver
          }
        }
      }
      
      ingressRoute = {
        dashboard = {
          enabled = var.dashboard_enabled
          matchRule = "Host(`traefik.${var.ingress_domain}`)"
          entryPoints = ["websecure"]
          middlewares = ["traefik-auth"]
        }
      }
      
      providers = {
        kubernetesCRD = {
          enabled = true
          allowCrossNamespace = true
          allowExternalNameServices = true
        }
        kubernetesIngress = {
          enabled = true
          allowCrossNamespace = true
          allowExternalNameServices = true
        }
      }
      
      pilot = {
        enabled = false
      }
      
      experimental = {
        plugins = {
          enabled = true
        }
      }
      
      metrics = {
        prometheus = {
          enabled = true
          addEntryPointsLabels = true
          addServicesLabels = true
        }
      }
      
      tracing = {
        jaeger = {
          enabled = var.tracing_enabled
          samplingServerURL = "http://tempo-service.${var.namespace}.svc:14268/api/sampling"
          localAgentHostPort = "tempo-service.${var.namespace}.svc:6831"
          samplingType = "const"
          samplingParam = 1.0
        }
      }
      
      accessLog = {
        enabled = true
        format = "json"
        fields = {
          defaultMode = "keep"
          names = {
            ClientUsername = "drop"
            RequestHost = "keep"
            RequestMethod = "keep"
            RequestPath = "keep"
            RequestProtocol = "keep"
            RequestScheme = "keep"
            RequestRemoteAddr = "keep"
            RequestUserAgent = "keep"
            RequestContentSize = "keep"
            ResponseStatusCode = "keep"
            ResponseContentSize = "keep"
            Duration = "keep"
            StartUTC = "keep"
            Timestamp = "keep"
          }
        }
      }
      
      log = {
        level = "INFO"
        format = "json"
      }
      
      globalArguments = [
        "--global.checknewversion=true",
        "--global.sendanonymoususage=false"
      ]
      
      additionalArguments = concat([
        "--certificatesresolvers.letsencrypt.acme.email=${var.acme_email}",
        "--certificatesresolvers.letsencrypt.acme.storage=/etc/traefik/acme/acme.json",
        "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
      ], var.additional_arguments)
      
      resources = {
        requests = {
          cpu = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu = "500m"
          memory = "512Mi"
        }
      }
      
      persistence = {
        enabled = true
        size = var.traefik_storage_size
        storageClass = var.storage_class
      }
    })
  ]
  
  depends_on = [var.namespace_dependency]
}

# Traefik middleware for authentication
resource "kubernetes_manifest" "traefik_auth_middleware" {
  count = var.dashboard_enabled ? 1 : 0
  
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "traefik-auth"
      namespace = var.namespace
    }
    spec = {
      basicAuth = {
        users = [
          "admin:$apr1$6a9t8j3p$J5X3F9gQ2k8w7x4r1y2z3"
        ]
      }
    }
  }
}

# Security headers middleware
resource "kubernetes_manifest" "security_headers_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "security-headers"
      namespace = var.namespace
    }
    spec = {
      headers = {
        customRequestHeaders = {
          X-Forwarded-Proto = "https"
        }
        customResponseHeaders = {
          X-Content-Type-Options = "nosniff"
          X-Frame-Options = "DENY"
          X-XSS-Protection = "1; mode=block"
          Referrer-Policy = "strict-origin-when-cross-origin"
          Strict-Transport-Security = "max-age=31536000; includeSubDomains"
        }
      }
    }
  }
}

# Rate limiting middleware
resource "kubernetes_manifest" "rate_limit_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "rate-limit"
      namespace = var.namespace
    }
    spec = {
      rateLimit = {
        average = 100
        period = "1m"
        burst = 200
      }
    }
  }
}

# CORS middleware
resource "kubernetes_manifest" "cors_middleware" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "cors"
      namespace = var.namespace
    }
    spec = {
      headers = {
        accessControlAllowCredentials = true
        accessControlAllowHeaders = ["*"]
        accessControlAllowMethods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
        accessControlAllowOriginList = ["*"]
        accessControlMaxAge = 86400
      }
    }
  }
}

# IngressRoute for API
resource "kubernetes_manifest" "api_ingress_route" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "api-ingress"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`api.${var.ingress_domain}`)"
          kind = "Rule"
          services = [
            {
              name = "devops-api-service"
              port = 8080
            }
          ]
          middlewares = ["security-headers@kubernetescrd", "cors@kubernetescrd", "rate-limit@kubernetescrd"]
        }
      ]
      tls = {
        certResolver = "letsencrypt"
      }
    }
  }
}

# IngressRoute for Grafana
resource "kubernetes_manifest" "grafana_ingress_route" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "grafana-ingress"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`grafana.${var.ingress_domain}`)"
          kind = "Rule"
          services = [
            {
              name = "prometheus-grafana"
              port = 80
            }
          ]
          middlewares = ["security-headers@kubernetescrd", "traefik-auth@kubernetescrd"]
        }
      ]
      tls = {
        certResolver = "letsencrypt"
      }
    }
  }
}

# IngressRoute for Prometheus
resource "kubernetes_manifest" "prometheus_ingress_route" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "prometheus-ingress"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`prometheus.${var.ingress_domain}`)"
          kind = "Rule"
          services = [
            {
              name = "prometheus-operated"
              port = 9090
            }
          ]
          middlewares = ["security-headers@kubernetescrd", "traefik-auth@kubernetescrd"]
        }
      ]
      tls = {
        certResolver = "letsencrypt"
      }
    }
  }
}

# IngressRoute for Tempo
resource "kubernetes_manifest" "tempo_ingress_route" {
  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"
    metadata = {
      name      = "tempo-ingress"
      namespace = var.namespace
    }
    spec = {
      entryPoints = ["websecure"]
      routes = [
        {
          match = "Host(`tempo.${var.ingress_domain}`)"
          kind = "Rule"
          services = [
            {
              name = "tempo"
              port = 3200
            }
          ]
          middlewares = ["security-headers@kubernetescrd"]
        }
      ]
      tls = {
        certResolver = "letsencrypt"
      }
    }
  }
}
