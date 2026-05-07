# Main Terraform Configuration
# Infrastructure as Code for DevOps & Observability Platform

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}

# Provider configuration
provider "kubernetes" {
  config_path = pathexpand("~/.kube/config")
  config_context = "kind-devops-cluster"
}

provider "helm" {
  kubernetes {
    config_path = pathexpand("~/.kube/config")
    config_context = "kind-devops-cluster"
  }
}

# Local variables
locals {
  cluster_name = "devops-cluster"
  namespace    = "devops-observability"
  
  tags = {
    project     = "devops-observability"
    environment = "development"
    managed_by  = "terraform"
  }
}

# Create Kind cluster (for local development)
resource "kind_cluster" "devops" {
  name           = local.cluster_name
  wait_for_ready = true
  
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    
    nodes {
      role  = "control-plane"
      image = "kindest/node:v1.29.0"
      
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
      extra_port_mappings {
        container_port = 3000
        host_port      = 3000
      }
      extra_port_mappings {
        container_port = 9000
        host_port      = 9000
      }
      extra_port_mappings {
        container_port = 9090
        host_port      = 9090
      }
      extra_port_mappings {
        container_port = 3200
        host_port      = 3200
      }
    }
    
    nodes {
      role  = "worker"
      image = "kindest/node:v1.29.0"
    }
  }
}

# Create namespace
module "namespace" {
  source = "./modules/namespace"
  
  name = local.namespace
  tags = local.tags
  
  depends_on = [kind_cluster.devops]
}

# Create monitoring stack
module "monitoring" {
  source = "./modules/monitoring"
  
  namespace = local.namespace
  tags      = local.tags
  
  depends_on = [module.namespace]
}

# Create observability stack
module "observability" {
  source = "./modules/observability"
  
  namespace = local.namespace
  tags      = local.tags
  
  depends_on = [module.namespace]
}

# Create application stack
module "application" {
  source = "./modules/application"
  
  namespace = local.namespace
  tags      = local.tags
  
  depends_on = [module.namespace]
}

# Create ingress
module "ingress" {
  source = "./modules/ingress"
  
  namespace = local.namespace
  tags      = local.tags
  
  depends_on = [module.monitoring, module.observability, module.application]
}

# Create secrets
module "secrets" {
  source = "./modules/secrets"
  
  namespace = local.namespace
  tags      = local.tags
  
  depends_on = [module.namespace]
}

# Create storage
module "storage" {
  source = "./modules/storage"
  
  namespace = local.namespace
  tags      = local.tags
  
  depends_on = [module.namespace]
}

# Outputs
output "cluster_name" {
  description = "Kind cluster name"
  value       = kind_cluster.devops.name
}

output "kubeconfig_path" {
  description = "Path to kubeconfig file"
  value       = kind_cluster.devops.kubeconfig_path
}

output "namespace" {
  description = "Kubernetes namespace"
  value       = local.namespace
}

output "service_urls" {
  description = "Service URLs"
  value = {
    api       = "http://api.localhost"
    grafana   = "http://grafana.localhost"
    prometheus = "http://prometheus.localhost"
    graylog   = "http://graylog.localhost"
    tempo     = "http://tempo.localhost"
    traefik   = "http://traefik.localhost"
  }
}
