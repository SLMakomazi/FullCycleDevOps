# Cloud-Native DevOps & Observability Platform

A comprehensive enterprise-grade platform demonstrating modern cloud-native DevOps practices, distributed tracing, GitOps workflows, and full-stack observability.

## 🏗️ Architecture Overview

This platform showcases enterprise-ready infrastructure with:

### Core Services
- **Spring Boot Microservice** - RESTful API with MongoDB integration and OpenTelemetry instrumentation
- **Container Orchestration** - Docker Compose and Kubernetes deployments with Helm charts
- **API Gateway** - Traefik for ingress control, load balancing, and security
- **Cluster Management** - Rancher for Kubernetes cluster management
- **CI/CD Pipeline** - Bamboo automation for build, test, and deployment
- **GitOps Platform** - ArgoCD for continuous deployment and GitOps workflows

### Observability Stack
- **Distributed Tracing** - OpenTelemetry + Grafana Tempo for end-to-end trace correlation
- **Centralized Logging** - Graylog + Filebeat + OpenSearch with structured JSON logs
- **Metrics & Monitoring** - Prometheus + Grafana with correlated dashboards
- **Infrastructure as Code** - Terraform modules for reproducible deployments
- **Database** - MongoDB with proper schema validation and backup strategies

### Production Features
- **Security** - Network policies, RBAC, secrets management, and TLS encryption
- **High Availability** - Pod disruption budgets, autoscaling, and health checks
- **Resource Management** - Resource quotas, limits, and optimization
- **Observability Correlation** - Unified view of logs, metrics, and traces

## 🚀 Quick Start

### Prerequisites

- **Docker 20.10+** and **Docker Compose v2.0+**
- **8GB+ RAM** and **2+ CPU cores**
- **20GB+** available disk space
- **Git** for version control

### One-Command Setup

```bash
# Clone the repository
git clone <repository-url>
cd FullCycleDevOps

# Run the automated setup script
chmod +x scripts/setup.sh
./scripts/setup.sh
```

The setup script will:
- ✅ Create all required directories and permissions
- ✅ Configure OpenSearch system settings
- ✅ Initialize environment configuration
- ✅ Start all services with health checks
- ✅ Display service URLs and next steps

## 📁 Project Structure

```
FullCycleDevOps/
├── api/                     # Spring Boot application
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/fullcycle/devops/
│   │   │   │   ├── controller/      # REST controllers
│   │   │   │   ├── service/        # Business logic
│   │   │   │   ├── repository/     # Data access
│   │   │   │   ├── model/          # Entity classes
│   │   │   │   ├── dto/            # Data transfer objects
│   │   │   │   └── exception/      # Error handling
│   │   │   └── resources/
│   │   │       ├── application.yml   # Spring configuration
│   │   │       └── logback-spring.xml # JSON logging config
│   ├── pom.xml               # Maven dependencies
│   └── Dockerfile            # Multi-stage build
├── bamboo/                  # Bamboo CI/CD configuration
│   ├── bamboo-spec.yml       # Pipeline as code
│   ├── setup-scripts/       # Deployment scripts
│   └── README.md           # Bamboo setup guide
├── rancher/                 # Rancher cluster management
│   ├── docker-compose.yml    # Rancher server setup
│   ├── workload-example.yaml # Sample workload
│   └── README.md           # Rancher setup guide
├── k8s/                     # Kubernetes manifests
│   ├── namespaces/          # Namespace definitions
│   ├── api/                 # Application deployments
│   ├── mongodb/             # Database configuration
│   ├── prometheus/          # Monitoring stack
│   └── grafana/            # Dashboard configuration
├── graylog/                 # Graylog configuration
├── filebeat/                # Log shipping configuration
├── prometheus/              # Prometheus configuration
├── grafana/                 # Grafana provisioning
├── scripts/                 # Helper scripts
│   ├── setup.sh            # Environment setup
│   ├── cleanup.sh          # Resource cleanup
│   └── test-api.sh        # API testing
├── docker-compose.yml        # Full stack orchestration
└── README.md               # This file
```

## 🔧 Service URLs

After setup, access services at:

### Core Application Services
| Service | URL | Credentials |
|---------|-----|-------------|
| **Spring Boot API** | http://localhost:8080 | - |
| **API Health** | http://localhost:8080/actuator/health | - |
| **API Metrics** | http://localhost:8080/actuator/prometheus | - |
| **MongoDB** | mongodb://localhost:27017 | admin/admin123 |

### Observability Services
| Service | URL | Credentials |
|---------|-----|-------------|
| **Prometheus** | http://localhost:9090 | - |
| **Grafana** | http://localhost:3000 | admin/admin123 |
| **Tempo (Tracing)** | http://localhost:3200 | - |
| **OpenTelemetry Collector** | http://localhost:8888 | - |
| **Graylog** | http://localhost:9000 | admin/admin |
| **OpenSearch** | http://localhost:9200 | - |

### DevOps & Infrastructure Services
| Service | URL | Credentials |
|---------|-----|-------------|
| **Traefik Dashboard** | http://localhost:8080 | admin/admin123 |
| **ArgoCD** | http://localhost:8086 | admin/admin123 |
| **Bamboo** | http://localhost:8085 | - |
| **Rancher** | https://localhost | rancher123 |

### Ingress Routes (via Traefik)
| Service | URL | Description |
|---------|-----|-------------|
| **API** | http://api.localhost | Main application API |
| **Grafana** | http://grafana.localhost | Monitoring dashboards |
| **Prometheus** | http://prometheus.localhost | Metrics collection |
| **Tempo** | http://tempo.localhost | Distributed tracing |
| **Graylog** | http://graylog.localhost | Log management |
| **Traefik** | http://traefik.localhost | API Gateway dashboard |

## 📊 API Documentation

### Endpoints

The Spring Boot API provides full CRUD operations for `Item` resources:

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/items` | Retrieve all items |
| `GET` | `/api/items/{id}` | Retrieve item by ID |
| `POST` | `/api/items` | Create new item |
| `PUT` | `/api/items/{id}` | Update existing item |
| `DELETE` | `/api/items/{id}` | Delete item |

### Item Schema

```json
{
  "id": "string",
  "name": "string (1-100 chars, required)",
  "description": "string (max 500 chars)",
  "createdAt": "datetime",
  "updatedAt": "datetime"
}
```

### Example Usage

```bash
# Create a new item
curl -X POST http://localhost:8080/api/items \
  -H "Content-Type: application/json" \
  -d '{"name":"Sample Item","description":"Test item"}'

# Get all items
curl http://localhost:8080/api/items

# Get specific item
curl http://localhost:8080/api/items/{id}

# Update item
curl -X PUT http://localhost:8080/api/items/{id} \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Item","description":"Updated description"}'

# Delete item
curl -X DELETE http://localhost:8080/api/items/{id}
```

## 🔍 Monitoring & Observability

### Distributed Tracing (OpenTelemetry + Tempo)

The platform provides end-to-end distributed tracing with correlation:

- **OpenTelemetry Instrumentation** - Automatic trace generation in the Spring Boot API
- **Trace Correlation** - Correlates traces across all services
- **Performance Analysis** - Identify bottlenecks and latency issues
- **Service Dependencies** - Visualize service interactions

### Prometheus Metrics

The application exposes custom metrics at `/actuator/prometheus`:

- `items_created_total` - Total items created
- `items_updated_total` - Total items updated  
- `items_deleted_total` - Total items deleted
- `http_server_requests_seconds_*` - HTTP request metrics
- `jvm_memory_*` - JVM memory usage
- `process_cpu_usage` - CPU utilization
- **OpenTelemetry Metrics** - Custom business metrics with trace correlation

### Grafana Dashboards

Pre-configured dashboards include:

- **Correlated Observability Dashboard** - Unified view of logs, metrics, and traces
- **Spring Boot Application Dashboard** - Application performance metrics
- **JVM Monitoring** - Memory, GC, and thread metrics
- **HTTP Request Analysis** - Request rates, latency, and error rates
- **Kubernetes Cluster Health** - Cluster resource monitoring
- **Distributed Tracing Dashboard** - End-to-end trace analysis

### Graylog Logging

Structured JSON logs are automatically collected and indexed:

- **Service Logs** - Application logs with trace IDs and correlation
- **Access Logs** - HTTP request/response logs with performance data
- **Error Logs** - Exception and error tracking with stack traces
- **Performance Logs** - Slow query and performance metrics
- **Trace Logs** - Distributed trace information for correlation

### Log-Metrics-Trace Correlation

The platform provides unified observability with correlation:

- **Trace ID Injection** - Automatic trace ID injection into logs and metrics
- **Grafana Tempo Integration** - Jump from metrics to traces and logs
- **Graylog Trace Search** - Search logs by trace ID
- **Prometheus Trace Metrics** - Trace-based performance metrics

## ☸️ Kubernetes Deployment

### Quick Deploy

```bash
# Deploy to Kubernetes
kubectl apply -f k8s/namespaces/
kubectl apply -f k8s/mongodb/
kubectl apply -f k8s/api/
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/
kubectl apply -f k8s/otel/
kubectl apply -f k8s/tempo/
kubectl apply -f k8s/traefik/
kubectl apply -f k8s/argocd/

# Apply production improvements
kubectl apply -f k8s/network-policies.yaml
kubectl apply -f k8s/pod-disruption-budgets.yaml
kubectl apply -f k8s/resource-quotas.yaml
kubectl apply -f k8s/horizontal-pod-autoscalers.yaml

# Check deployment status
kubectl get pods -n devops-observability
kubectl get services -n devops-observability
kubectl get hpa -n devops-observability
```

### Kubernetes Architecture

- **Namespace Isolation** - All services in `devops-observability` namespace
- **Resource Limits** - CPU and memory constraints for all pods
- **Health Checks** - Liveness and readiness probes
- **Persistent Storage** - PVCs for data persistence
- **Service Discovery** - Internal service communication
- **Ingress Configuration** - Traefik for external access routing
- **Network Policies** - Security boundaries between services
- **Autoscaling** - HPA for automatic scaling based on metrics
- **Pod Disruption Budgets** - High availability during maintenance

## 🔄 GitOps Workflow (ArgoCD)

### ArgoCD Setup

```bash
# Install ArgoCD
kubectl apply -f argocd/argocd-install.yaml

# Configure applications
kubectl apply -f argocd/applications/
kubectl apply -f argocd/applicationsets/
kubectl apply -f argocd/projects/

# Access ArgoCD UI
kubectl port-forward svc/argocd-server 8080:8080 -n argocd
```

### GitOps Features

- **Automated Synchronization** - Git-to-cluster automatic deployment
- **ApplicationSets** - Dynamic application generation
- **Multi-Environment Support** - Dev, staging, and production
- **Rollback Capability** - Automatic rollback on failure
- **Progressive Delivery** - Canary and blue-green deployments

## 🏗️ Infrastructure as Code (Terraform)

### Terraform Deployment

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply

# Destroy infrastructure
terraform destroy
```

### Terraform Modules

- **Namespace Module** - Kubernetes namespace creation with policies
- **Monitoring Module** - Prometheus and Grafana deployment
- **Observability Module** - Tempo and OpenTelemetry Collector
- **Application Module** - Spring Boot application with autoscaling
- **Ingress Module** - Traefik configuration and routing
- **Secrets Module** - Secure credential management
- **Storage Module** - Persistent volume provisioning

## 📦 Helm Charts

### Helm Deployment

```bash
# Deploy with Helm
helm install devops-api ./helm/application
helm install monitoring ./helm/monitoring
helm install observability ./helm/observability
helm install traefik ./helm/traefik

# Upgrade with Helm
helm upgrade devops-api ./helm/application --values values-prod.yaml

# Uninstall
helm uninstall devops-api
```

### Helm Features

- **Reusable Charts** - Environment-specific deployments
- **Value Overrides** - Configuration per environment
- **Dependency Management** - Service dependencies
- **Rollback Support** - Version-controlled deployments

## 🔄 CI/CD Pipeline

### Bamboo Integration

The Bamboo pipeline provides:

1. **Build Stage** - Compile and unit tests
2. **Test Stage** - Integration and performance tests
3. **Security Stage** - Vulnerability scanning and SAST
4. **Package Stage** - Docker image build and publish
5. **Deploy Stage** - Kubernetes deployment with rollback

### Pipeline Features

- **Automated Testing** - Unit, integration, and performance tests
- **Security Scanning** - OWASP dependency check and container scanning
- **Quality Gates** - Code coverage and quality metrics
- **Multi-Environment** - Dev, staging, and production deployments
- **Rollback Capability** - Automatic rollback on deployment failure

## 🛠️ Development Guide

### Local Development

```bash
# Start only application and database
docker-compose up -d mongodb api

# Run application locally
cd api
mvn spring-boot:run

# Run tests
mvn test

# Build application
mvn clean package
```

### Environment Variables

Key environment variables:

```bash
# Application
SPRING_PROFILES_ACTIVE=docker
MONGODB_URI=mongodb://localhost:27017/devops_observability

# Security
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=admin123

# Monitoring
GF_SECURITY_ADMIN_PASSWORD=admin123
GRAYLOG_ROOT_PASSWORD_SHA2=<hash>
```

### Testing

```bash
# Run API test suite
./scripts/test-api.sh

# Run with custom API URL
API_BASE_URL=http://api:8080 ./scripts/test-api.sh

# Run performance tests
cd api
mvn gatling:test
```

## 🔧 Configuration

### Docker Compose

The main `docker-compose.yml` orchestrates:

- **Networks** - Isolated communication channels
- **Volumes** - Persistent data storage
- **Health Checks** - Service availability monitoring
- **Restart Policies** - Automatic recovery
- **Resource Limits** - Memory and CPU constraints

### Prometheus Configuration

Located in `prometheus/prometheus.yml`:

- **Scrape Interval** - 15 seconds
- **Custom Metrics** - Application-specific metrics
- **Alert Rules** - Automated alerting conditions
- **Service Discovery** - Dynamic target detection

### Grafana Provisioning

Automatic configuration via:

- **Datasources** - Prometheus and Graylog integration
- **Dashboards** - Pre-loaded monitoring dashboards
- **Alerting** - Notification channel setup

## 🚨 Troubleshooting

### Common Issues

#### Services Won't Start
```bash
# Check system resources
free -h
df -h

# Check Docker daemon
docker ps
docker logs <container-name>

# Check port conflicts
netstat -tulpn | grep :8080
```

#### OpenSearch Fails
```bash
# Check vm.max_map_count
sysctl vm.max_map_count

# Set required value
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

#### API Health Checks Fail
```bash
# Check application logs
docker logs devops-api

# Test health endpoint directly
curl http://localhost:8080/actuator/health

# Check database connectivity
docker exec mongodb mongosh --eval "db.adminCommand('ping')"
```

### Logs and Debugging

```bash
# View all service logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f api
docker-compose logs -f mongodb

# Check Kubernetes pod logs
kubectl logs -f <pod-name> -n devops-observability

# Debug pod issues
kubectl describe pod <pod-name> -n devops-observability
```

### Cleanup and Reset

```bash
# Stop all services
docker-compose down -v

# Complete cleanup
./scripts/cleanup.sh

# Reset Kubernetes
kubectl delete namespace devops-observability
```

## 📈 Performance Considerations

### Resource Optimization

- **JVM Tuning** - G1GC with container-aware settings
- **Connection Pooling** - Database connection optimization
- **Caching** - Application-level caching strategies
- **Load Balancing** - Multiple API replicas

### Scaling

```bash
# Scale API replicas
docker-compose up -d --scale api=3

# Kubernetes HPA
kubectl apply -f k8s/api/api-hpa.yaml

# Monitor resource usage
kubectl top pods -n devops-observability
```

## 🌐 API Gateway (Traefik)

### Traefik Features

- **Load Balancing** - Automatic load distribution across pods
- **TLS Termination** - SSL/TLS certificate management
- **Rate Limiting** - Request rate limiting and throttling
- **CORS Support** - Cross-origin resource sharing
- **Circuit Breaker** - Fault tolerance and resilience
- **Security Headers** - HTTP security headers injection
- **Dynamic Configuration** - Hot-reload configuration updates

### Ingress Routes

The platform provides secure ingress routes:

- **API** - `http://api.localhost` - Main application API
- **Grafana** - `http://grafana.localhost` - Monitoring dashboards
- **Prometheus** - `http://prometheus.localhost` - Metrics collection
- **Tempo** - `http://tempo.localhost` - Distributed tracing
- **Graylog** - `http://graylog.localhost` - Log management

## 🔒 Security Best Practices

### Container Security

- **Non-root Users** - All containers run as non-root
- **Minimal Images** - Alpine-based runtime images
- **Security Scanning** - Automated vulnerability detection
- **Secrets Management** - Kubernetes secrets for sensitive data
- **Pod Security Policies** - Security context constraints

### Network Security

- **Network Policies** - Pod-to-pod communication control
- **TLS Encryption** - HTTPS for all external communication
- **Authentication** - RBAC for cluster access
- **Audit Logging** - Comprehensive access logging
- **Service Mesh Security** - mTLS for service communication

### Production Security Features

- **Resource Quotas** - Prevent resource exhaustion
- **Pod Disruption Budgets** - High availability during maintenance
- **Horizontal Autoscaling** - Automatic scaling based on metrics
- **Health Checks** - Liveness and readiness probes
- **Graceful Shutdown** - Proper termination handling

## 🚀 Future Improvements

### Cloud-Native Enhancements

1. **Service Mesh** - Istio integration for advanced traffic management
2. **Chaos Engineering** - Fault injection and resilience testing
3. **Event-Driven Scaling** - KEDA for event-driven autoscaling
4. **Multi-Cluster GitOps** - Cross-cluster federation with ArgoCD
5. **Advanced Tracing** - Distributed tracing with Jaeger
6. **Security Hardening** - OPA policies and admission controllers
7. **Performance Optimization** - Caching strategies and CDN integration
8. **Machine Learning** - AIOps for predictive monitoring

### Enterprise Features

1. **Multi-Cloud Support** - AWS EKS, Azure AKS, Google GKE
2. **Compliance** - SOC 2, GDPR, HIPAA compliance features
3. **Disaster Recovery** - Backup and recovery strategies
4. **Cost Optimization** - Resource optimization and cost monitoring
5. **Team Collaboration** - Role-based access and team workflows
6. **API Management** - API versioning and documentation
7. **Service Catalog** - Self-service infrastructure provisioning

## 📚 Additional Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Detailed file-by-file architecture guide
- **[Terraform Documentation](terraform/README.md)** - Infrastructure as code guide
- **[Helm Charts](helm/README.md)** - Helm chart documentation
- **[ArgoCD Guide](argocd/README.md)** - GitOps workflow documentation
- **[OpenTelemetry Guide](otel/README.md)** - Distributed tracing setup
- **[Traefik Configuration](traefik/README.md)** - API gateway configuration

## 🎯 Getting Started Guide

### 1. Local Development

```bash
# Start all services locally
docker-compose up -d

# Test the API
./scripts/test-api.sh

# View logs
docker-compose logs -f api
```

### 2. Kubernetes Development

```bash
# Deploy to Kubernetes
kubectl apply -f k8s/

# Check status
kubectl get pods -n devops-observability

# Test with kubectl
kubectl port-forward svc/devops-api-service 8080:8080 -n devops-observability
```

### 3. GitOps Deployment

```bash
# Configure GitOps
kubectl apply -f argocd/

# Sync applications
argocd app sync devops-observability

# Monitor deployment
argocd app get devops-observability
```

### 4. Infrastructure as Code

```bash
# Deploy with Terraform
cd terraform
terraform apply

# Update with GitOps
git push origin main
argocd app sync devops-observability
```

---

**Built with ❤️ for modern cloud-native DevOps and observability practices**

### Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For questions and support:

- **Documentation** - Check this README and component-specific READMEs
- **Issues** - Open GitHub issues for bugs and feature requests
- **Discussions** - Use GitHub Discussions for general questions

---

**Built with ❤️ for modern DevOps and observability practices**