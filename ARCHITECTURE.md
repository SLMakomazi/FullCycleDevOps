# Cloud-Native DevOps & Observability Platform Architecture

This document explains the purpose and benefits of every file and directory in the comprehensive cloud-native DevOps & Observability Platform.

## 📁 Directory Structure Overview

```
FullCycleDevOps/
├── api/                     # Spring Boot microservice with OpenTelemetry
├── bamboo/                  # Bamboo CI/CD pipeline configuration
├── rancher/                 # Rancher Kubernetes management
├── graylog/                 # Graylog centralized logging
├── filebeat/                # Log shipping configuration
├── prometheus/              # Metrics collection configuration
├── grafana/                 # Monitoring dashboards with tracing
├── k8s/                     # Kubernetes deployment manifests
├── otel/                    # OpenTelemetry Collector configuration
├── tempo/                   # Grafana Tempo distributed tracing
├── traefik/                 # Traefik API Gateway and ingress
├── terraform/               # Infrastructure as Code modules
├── argocd/                  # ArgoCD GitOps configuration
├── helm/                    # Helm charts for deployments
├── scripts/                 # Automation and utility scripts
├── docker-compose.yml        # Full stack orchestration with new services
└── README.md               # Main project documentation
```

---

## 🚀 API Directory (`api/`)

### Purpose
Contains the complete Spring Boot microservice with MongoDB integration, providing RESTful CRUD operations with full observability.

### Files and Their Benefits

#### `pom.xml`
**Purpose**: Maven project configuration and dependency management
**Benefits**: 
- Centralized dependency management
- Consistent build configuration
- Plugin management for testing and security scanning
- Version control of all dependencies

**Example**:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

#### `src/main/java/com/fullcycle/devops/DevOpsObservabilityApplication.java`
**Purpose**: Main Spring Boot application entry point
**Benefits**:
- Application bootstrap configuration
- Component scanning setup
- Embedded server startup

**Example**:
```java
@SpringBootApplication
public class DevOpsObservabilityApplication {
    public static void main(String[] args) {
        SpringApplication.run(DevOpsObservabilityApplication.class, args);
    }
}
```

#### `src/main/java/com/fullcycle/devops/model/Item.java`
**Purpose**: Entity class defining data structure
**Benefits**:
- MongoDB document mapping
- Data validation annotations
- Automatic timestamp management

**Example**:
```java
@Document(collection = "items")
public class Item {
    @Id
    private String id;
    
    @NotBlank(message = "Name is required")
    private String name;
}
```

#### `src/main/java/com/fullcycle/devops/dto/`
**Purpose**: Data Transfer Objects for API communication
**Benefits**:
- Separation of concerns
- Input validation
- Clean API contracts

**Example**:
```java
public class ItemRequest {
    @NotBlank
    @Size(min = 1, max = 100)
    private String name;
}
```

#### `src/main/java/com/fullcycle/devops/repository/ItemRepository.java`
**Purpose**: Data access layer using Spring Data MongoDB
**Benefits**:
- Automatic CRUD operations
- Query method generation
- Database abstraction

**Example**:
```java
@Repository
public interface ItemRepository extends MongoRepository<Item, String> {
    Optional<Item> findByName(String name);
}
```

#### `src/main/java/com/fullcycle/devops/service/ItemService.java`
**Purpose**: Business logic layer with error handling
**Benefits**:
- Separation of business logic
- Transaction management
- Comprehensive logging
- Custom error handling

**Example**:
```java
@Service
public class ItemService {
    public ItemResponse createItem(ItemRequest itemRequest) {
        log.info("Creating new item: {}", itemRequest.getName());
        // Business logic here
    }
}
```

#### `src/main/java/com/fullcycle/devops/controller/ItemController.java`
**Purpose**: REST API endpoints with metrics
**Benefits**:
- HTTP request handling
- Input validation
- Custom metrics collection
- Proper HTTP status codes

**Example**:
```java
@RestController
@RequestMapping("/api/items")
public class ItemController {
    @PostMapping
    public ResponseEntity<ItemResponse> createItem(@Valid @RequestBody ItemRequest itemRequest) {
        itemCreatedCounter.increment();
        return new ResponseEntity<>(itemService.createItem(itemRequest), HttpStatus.CREATED);
    }
}
```

#### `src/main/java/com/fullcycle/devops/config/OpenTelemetryConfig.java`
**Purpose**: OpenTelemetry instrumentation configuration
**Benefits**:
- Automatic trace generation
- Metrics export configuration
- Log correlation setup
- Performance monitoring

**Example**:
```java
@Configuration
public class OpenTelemetryConfig {
    @Bean
    public OpenTelemetry openTelemetry() {
        return OpenTelemetrySdk.builder()
            .setTracerProvider(tracerProvider())
            .setMeterProvider(meterProvider())
            .setLoggerProvider(loggerProvider())
            .build();
    }
}
```

#### `src/main/resources/application.yml` (Updated)
**Purpose**: Spring Boot configuration with OpenTelemetry
**Benefits**:
- OpenTelemetry configuration
- Environment-specific settings
- Metrics endpoint configuration
- Trace correlation setup

**Example**:
```yaml
spring:
  data:
    mongodb:
      uri: ${MONGODB_URI:mongodb://localhost:27017/devops_observability}

management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus

otel:
  exporter:
    otlp:
      endpoint: ${OTEL_EXPORTER_OTLP_ENDPOINT:http://otel-collector:4317}
  service:
    name: ${OTEL_SERVICE_NAME:devops-observability-api}
    version: ${OTEL_SERVICE_VERSION:1.0.0}
```

#### `src/main/java/com/fullcycle/devops/exception/`
**Purpose**: Global error handling and custom exceptions
**Benefits**:
- Consistent error responses
- Centralized exception handling
- Proper HTTP status codes
- Structured error format

**Example**:
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(ResourceNotFoundException ex) {
        return new ResponseEntity<>(new ErrorResponse(HttpStatus.NOT_FOUND.value(), ex.getMessage()), HttpStatus.NOT_FOUND);
    }
}
```

#### `src/main/resources/application.yml`
**Purpose**: Spring Boot configuration with profiles
**Benefits**:
- Environment-specific configuration
- Database connection settings
- Metrics endpoint configuration
- Profile-based deployment

**Example**:
```yaml
spring:
  data:
    mongodb:
      uri: ${MONGODB_URI:mongodb://localhost:27017/devops_observability}

management:
  endpoints:
    web:
      exposure:
        include: health,metrics,prometheus
```

#### `src/main/resources/logback-spring.xml`
**Purpose**: Structured JSON logging configuration
**Benefits**:
- JSON formatted logs for parsing
- Log rotation policies
- Profile-specific logging
- Container-friendly output

**Example**:
```xml
<encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
    <providers>
        <timestamp/>
        <logLevel/>
        <message/>
        <mdc/>
    </providers>
</encoder>
```

#### `Dockerfile`
**Purpose**: Multi-stage container build configuration
**Benefits**:
- Optimized image size
- Security (non-root user)
- Health checks
- Production-ready configuration

**Example**:
```dockerfile
# Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
RUN addgroup -g 1001 appgroup && adduser -u 1001 -G appgroup -s /bin/sh -D appuser
COPY --from=build /app/target/*.jar application.jar
USER appuser
EXPOSE 8080
```

---

## � OpenTelemetry Directory (`otel/`)

### Purpose
OpenTelemetry Collector configuration for distributed tracing, metrics, and logs collection.

### Files and Their Benefits

#### `otel-collector-config.yaml`
**Purpose**: Main OpenTelemetry Collector configuration
**Benefits**:
- Unified telemetry collection
- Trace, metrics, and log processing
- Multiple export destinations
- Performance optimization

**Example**:
```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:
    timeout: 1s
    send_batch_size: 1024

exporters:
  otlp:
    endpoint: tempo:4317
  prometheus:
    endpoint: "0.0.0.0:8889"
```

#### `Dockerfile`
**Purpose**: Container build configuration for OpenTelemetry Collector
**Benefits**:
- Optimized container image
- Security hardening
- Health checks
- Production-ready configuration

#### `k8s/` directory
**Purpose**: Kubernetes manifests for OpenTelemetry Collector deployment
**Benefits**:
- Production deployment
- Service discovery
- Resource management
- Health monitoring

**Files**:
- `otel-collector-deployment.yaml` - Deployment configuration
- `otel-collector-service.yaml` - Service exposure
- `otel-collector-configmap.yaml` - Configuration management

---

## 🎯 Tempo Directory (`tempo/`)

### Purpose
Grafana Tempo distributed tracing backend configuration.

### Files and Their Benefits

#### `tempo.yaml`
**Purpose**: Main Tempo server configuration
**Benefits**:
- Distributed trace storage
- High-performance query engine
- Scalable architecture
- Integration with OpenTelemetry

**Example**:
```yaml
server:
  http_listen_port: 3200
  grpc_listen_port: 9095

distributor:
  receivers:
    otlp:
      protocols:
        grpc:
          endpoint: 0.0.0.0:4317
        http:
          endpoint: 0.0.0.0:4318
```

#### `overrides.yaml`
**Purpose**: Tenant-specific configuration overrides
**Benefits**:
- Multi-tenant support
- Custom retention policies
- Performance tuning
- Resource management

#### `docker-compose.yml`
**Purpose**: Local development configuration
**Benefits**:
- Easy local setup
- Development dependencies
- Volume persistence
- Network configuration

#### `k8s/` directory
**Purpose**: Kubernetes manifests for Tempo deployment
**Benefits**:
- Production deployment
- Persistent storage
- Service exposure
- Configuration management

**Files**:
- `tempo-deployment.yaml` - Deployment with resource limits
- `tempo-service.yaml` - Service configuration
- `tempo-configmap.yaml` - Configuration management
- `tempo-pvc.yaml` - Persistent volume claims

---

## 🌐 Traefik Directory (`traefik/`)

### Purpose
Traefik API Gateway and ingress controller configuration.

### Files and Their Benefits

#### `traefik.yml`
**Purpose**: Main Traefik static configuration
**Benefits**:
- API gateway setup
- Security configuration
- Metrics integration
- Tracing integration

**Example**:
```yaml
api:
  dashboard: true
  insecure: true

entryPoints:
  web:
    address: ":80"
  websecure:
    address: ":443"

providers:
  kubernetesCRD:
    allowCrossNamespace: true
  kubernetesIngress:
    allowCrossNamespace: true
```

#### `dynamic-config.yml`
**Purpose**: Dynamic routing and middleware configuration
**Benefits**:
- Load balancing
- Security headers
- Rate limiting
- Circuit breaking

**Example**:
```yaml
http:
  middlewares:
    security-headers:
      headers:
        customResponseHeaders:
          X-Content-Type-Options: "nosniff"
          X-Frame-Options: "DENY"
    rate-limit:
      rateLimit:
        average: 100
        period: 1m
```

#### `docker-compose.yml`
**Purpose**: Local Traefik deployment
**Benefits**:
- Development environment
- Dashboard access
- Metrics collection
- Health monitoring

#### `k8s/` directory
**Purpose**: Kubernetes manifests for Traefik deployment
**Benefits**:
- Production deployment
- RBAC configuration
- Service exposure
- Configuration management

**Files**:
- `traefik-deployment.yaml` - Deployment with security context
- `traefik-service.yaml` - LoadBalancer service
- `traefik-configmap.yaml` - Configuration management
- `traefik-rbac.yaml` - Role-based access control

---

## 🏗️ Terraform Directory (`terraform/`)

### Purpose
Infrastructure as Code modules for reproducible deployments.

### Files and Their Benefits

#### `main.tf`
**Purpose**: Main Terraform configuration
**Benefits**:
- Infrastructure definition
- Module orchestration
- Provider configuration
- Output management

**Example**:
```terraform
module "namespace" {
  source = "./modules/namespace"
  name = local.namespace
  tags = local.tags
}

module "monitoring" {
  source = "./modules/monitoring"
  namespace = local.namespace
  tags = local.tags
}
```

#### `variables.tf`
**Purpose**: Input variables configuration
**Benefits**:
- Parameterization
- Environment-specific values
- Default values
- Type safety

#### `modules/` directory
**Purpose**: Reusable infrastructure modules
**Benefits**:
- Modular architecture
- Reusability
- Consistency
- Maintainability

**Modules**:
- `namespace/` - Kubernetes namespace with policies
- `monitoring/` - Prometheus and Grafana deployment
- `observability/` - Tempo and OpenTelemetry Collector
- `application/` - Spring Boot application with autoscaling
- `ingress/` - Traefik configuration and routing
- `secrets/` - Secure credential management
- `storage/` - Persistent volume provisioning

---

## 🔄 ArgoCD Directory (`argocd/`)

### Purpose
GitOps workflow configuration for continuous deployment.

### Files and Their Benefits

#### `argocd-install.yaml`
**Purpose**: ArgoCD installation manifest
**Benefits**:
- Automated deployment
- Git synchronization
- Application management
- Multi-environment support

**Example**:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd
  namespace: argocd
spec:
  server:
    grpc:
      web: true
    insecure: true
```

#### `applications/` directory
**Purpose**: Application deployment configurations
**Benefits**:
- Application definitions
- Deployment strategies
- Sync policies
- Health monitoring

**Files**:
- `devops-observability-app.yaml` - Main application deployment
- `monitoring-stack.yaml` - Monitoring stack deployment
- `observability-stack.yaml` - Observability stack deployment

#### `applicationsets/` directory
**Purpose**: Dynamic application generation
**Benefits**:
- Automated application creation
- Multi-environment support
- Git-based discovery
- Template-based generation

**Files**:
- `git-generator.yaml` - Git repository-based generation
- `environment-based-appset.yaml` - Environment-specific applications

#### `projects/` directory
**Purpose**: ArgoCD project configurations
**Benefits**:
- Resource isolation
- Access control
- Sync policies
- Namespace management

**Files**:
- `devops-observability-project.yaml` - Main project configuration

#### `k8s/` directory
**Purpose**: Kubernetes manifests for ArgoCD
**Benefits**:
- Namespace creation
- Configuration management
- Service accounts
- RBAC setup

**Files**:
- `argocd-namespace.yaml` - Namespace definition
- `argocd-cm.yaml` - ConfigMap configuration

---

## 📦 Helm Directory (`helm/`)

### Purpose
Helm charts for reusable application deployments.

### Files and Their Benefits

#### `application/` directory
**Purpose**: Spring Boot application Helm chart
**Benefits**:
- Reusable deployment
- Configuration management
- Environment-specific values
- Dependency management

**Files**:
- `Chart.yaml` - Chart metadata and dependencies
- `values.yaml` - Default configuration values
- `templates/deployment.yaml` - Application deployment
- `templates/service.yaml` - Service exposure
- `templates/hpa.yaml` - Horizontal Pod Autoscaler
- `templates/servicemonitor.yaml` - Prometheus monitoring

#### `monitoring/` directory
**Purpose**: Monitoring stack Helm chart
**Benefits**:
- Prometheus deployment
- Grafana configuration
- Alert management
- Dashboard provisioning

#### `observability/` directory
**Purpose**: Observability stack Helm chart
**Benefits**:
- Tempo deployment
- OpenTelemetry Collector
- Trace correlation
- Metrics integration

#### `traefik/` directory
**Purpose**: Traefik ingress controller Helm chart
**Benefits**:
- API gateway deployment
- Ingress configuration
- Security setup
- Dashboard access

---

## � Bamboo Directory (`bamboo/`)

### Purpose
CI/CD pipeline configuration for automated build, test, and deployment processes.

### Files and Their Benefits

#### `bamboo-spec.yml`
**Purpose**: Complete pipeline definition as code
**Benefits**:
- Version-controlled pipeline configuration
- Automated testing and security scanning
- Multi-environment deployment
- Quality gates and notifications

**Example**:
```yaml
stages:
  - Build:
      manual: false
  - Test:
      - Build
  - Deploy:
      - Test

jobs:
  - Build:
      tasks:
        - checkout:
            repository: devops-observability
        - script:
            - mvn clean package -B
```

#### `setup-scripts/deploy.sh`
**Purpose**: Kubernetes deployment automation
**Benefits**:
- Idempotent deployment process
- Health check validation
- Rollback capability
- Environment-specific configuration

**Example**:
```bash
deploy_application() {
    kubectl apply -f k8s/api/ --validate=false
    kubectl rollout status deployment/devops-api -n ${NAMESPACE} --timeout=300s
    kubectl wait --for=condition=ready pod -l app=devops-api -n ${NAMESPACE} --timeout=300s
}
```

#### `README.md`
**Purpose**: Bamboo setup and configuration guide
**Benefits**:
- Step-by-step setup instructions
- Variable configuration guide
- Troubleshooting information
- Best practices documentation

---

## 🐄 Rancher Directory (`rancher/`)

### Purpose
Kubernetes cluster management and workload deployment configuration.

### Files and Their Benefits

#### `docker-compose.yml`
**Purpose**: Rancher server container configuration
**Benefits**:
- Simplified Rancher deployment
- Persistent data storage
- Network isolation
- Automated restart policies

**Example**:
```yaml
services:
  rancher:
    image: rancher/rancher:v2.8.0
    ports:
      - "80:80"
      - "443:443"
    environment:
      - CATTLE_BOOTSTRAP_PASSWORD=rancher123
```

#### `workload-example.yaml`
**Purpose**: Sample Kubernetes workload configuration
**Benefits**:
- HPA configuration for auto-scaling
- Resource limits and requests
- Health check configuration
- Rolling update strategy

**Example**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: devops-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: devops-api-rancher
  minReplicas: 2
  maxReplicas: 10
```

---

## 📊 Graylog Directory (`graylog/`)

### Purpose
Centralized log management and analysis platform configuration.

### Files and Their Benefits

#### `graylog.conf`
**Purpose**: Main Graylog server configuration
**Benefits**:
- OpenSearch integration settings
- Performance optimization
- Security configuration
- Input and output configuration

**Example**:
```properties
elasticsearch_hosts = http://opensearch:9200
mongodb_uri = mongodb://mongodb:27017/graylog
http_enable_cors = true
message_journal_max_size = 5gb
```

#### `log4j2.xml`
**Purpose**: Graylog's own logging configuration
**Benefits**:
- Structured logging for Graylog itself
- Log rotation policies
- Component-specific log levels
- Error isolation

**Example**:
```xml
<RollingFile name="RollingFile" fileName="/var/log/graylog/server.log">
    <PatternLayout pattern="%d{yyyy-MM-dd'T'HH:mm:ss.SSSZ} [%t] %-5level %logger{36} - %msg%n"/>
    <Policies>
        <TimeBasedTriggeringPolicy interval="1" modulate="true"/>
        <SizeBasedTriggeringPolicy size="100MB"/>
    </Policies>
</RollingFile>
```

---

## 📤 Filebeat Directory (`filebeat/`)

### Purpose
Log shipping agent configuration for forwarding logs to Graylog.

### Files and Their Benefits

#### `filebeat.yml`
**Purpose**: Filebeat configuration for log collection
**Benefits**:
- Automatic log discovery
- JSON parsing and enrichment
- Multi-line log handling
- Container metadata extraction

**Example**:
```yaml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/app/*.log
  fields:
    service: devops-api
  json.keys_under_root: true

output.graylog:
  hosts: ["graylog:12201"]
  compression_level: 3
```

---

## 📈 Prometheus Directory (`prometheus/`)

### Purpose
Metrics collection and alerting configuration.

### Files and Their Benefits

#### `prometheus.yml`
**Purpose**: Prometheus server configuration
**Benefits**:
- Service discovery configuration
- Custom metrics collection
- Alert rule definitions
- Performance optimization

**Example**:
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'devops-api'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['api:8080']
```

---

## 📊 Grafana Directory (`grafana/`)

### Purpose
Monitoring dashboards and visualization configuration.

### Files and Their Benefits

#### `provisioning/datasources/prometheus.yml`
**Purpose**: Automatic datasource configuration
**Benefits**:
- Zero-configuration setup
- Consistent datasource management
- Version-controlled configuration
- Multi-datasource support

**Example**:
```yaml
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
```

#### `provisioning/dashboards/dashboards.yml`
**Purpose**: Automatic dashboard loading
**Benefits**:
- Pre-configured dashboards
- Consistent monitoring setup
- Automated dashboard updates
- Team collaboration

**Example**:
```yaml
providers:
  - name: 'default'
    orgId: 1
    type: file
    disableDeletion: false
    options:
      path: /var/lib/grafana/dashboards
```

#### `dashboards/spring-boot-dashboard.json`
**Purpose**: Pre-built Spring Boot monitoring dashboard
**Benefits**:
- Immediate visibility
- Best practice metrics
- Performance monitoring
- Error tracking

---

## ☸️ Kubernetes Directory (`k8s/`)

### Purpose
Kubernetes deployment manifests for all platform components with production-ready configurations.

### Files and Their Benefits

#### `namespaces/devops-namespace.yaml`
**Purpose**: Namespace isolation for all services
**Benefits**:
- Resource isolation
- Security boundaries
- Environment separation
- Access control

**Example**:
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: devops-observability
  labels:
    environment: production
```

#### `network-policies.yaml`
**Purpose**: Network security policies for production
**Benefits**:
- Service-to-service communication control
- Zero-trust network security
- Traffic filtering
- Attack surface reduction

**Example**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-network-policy
spec:
  podSelector:
    matchLabels:
      app: devops-api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: devops-observability
```

#### `pod-disruption-budgets.yaml`
**Purpose**: High availability during maintenance
**Benefits**:
- Service availability guarantees
- Rolling update safety
- Maintenance window protection
- Production stability

**Example**:
```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: api-pdb
spec:
  minAvailable: 1
  selector:
    matchLabels:
      app: devops-api
```

#### `resource-quotas.yaml`
**Purpose**: Resource management and cost control
**Benefits**:
- Resource exhaustion prevention
- Cost optimization
- Fair resource allocation
- Multi-tenant isolation

**Example**:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: devops-observability-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
```

#### `horizontal-pod-autoscalers.yaml`
**Purpose**: Automatic scaling based on metrics
**Benefits**:
- Dynamic resource allocation
- Cost optimization
- Performance optimization
- Load-based scaling

**Example**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: devops-api
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

#### `api/api-deployment.yaml`
**Purpose**: Spring Boot application deployment
**Benefits**:
- Container orchestration
- Health checks
- Resource limits
- Rolling updates

**Example**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: devops-api
  template:
    spec:
      containers:
      - name: devops-api
        image: devops-observability-api:latest
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
```

#### `mongodb/mongodb-deployment.yaml`
**Purpose**: Database deployment with persistence
**Benefits**:
- Data persistence
- Backup capability
- Security configuration
- High availability

**Example**:
```yaml
spec:
  containers:
  - name: mongodb
    env:
    - name: MONGO_INITDB_ROOT_USERNAME
      valueFrom:
        secretKeyRef:
          name: mongodb-secret
          key: username
```

---

## 🛠️ Scripts Directory (`scripts/`)

### Purpose
Automation scripts for environment management and testing.

### Files and Their Benefits

#### `setup.sh`
**Purpose**: Complete environment bootstrap script
**Benefits**:
- One-command setup
- Dependency checking
- Configuration generation
- Service orchestration

**Example**:
```bash
check_prerequisites() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
}

start_services() {
    docker-compose up -d
    wait_for_services
}
```

#### `test-api.sh`
**Purpose**: Automated API testing suite
**Benefits**:
- Comprehensive testing
- Performance validation
- Error detection
- Regression testing

**Example**:
```bash
test_crud_operations() {
    item_id=$(create_item)
    get_item_by_id "$item_id"
    update_item "$item_id"
    delete_item "$item_id"
}
```

#### `cleanup.sh`
**Purpose**: Complete environment cleanup
**Benefits**:
- Resource cleanup
- Space reclamation
- Configuration reset
- Safe removal

---

## 🐳 Root Level Files

### `docker-compose.yml`
**Purpose**: Full-stack service orchestration
**Benefits**:
- Complete environment setup
- Service dependency management
- Network isolation
- Persistent data storage

**Example**:
```yaml
version: '3.8'
services:
  api:
    build: ./api
    depends_on:
      - mongodb
    networks:
      - database
      - monitoring

networks:
  database:
    driver: bridge
  monitoring:
    driver: bridge
```

### `README.md`
**Purpose**: Main project documentation
**Benefits**:
- Complete setup guide
- Architecture overview
- Troubleshooting information
- Best practices documentation

---

## 🎯 Integration Benefits

### How Files Work Together

1. **Development Flow**:
   ```
   Code → Build → Test → Package → Deploy
   ```
   - `pom.xml` defines build process with OpenTelemetry dependencies
   - `bamboo-spec.yml` automates CI/CD with security scanning
   - `Dockerfile` creates container image with security hardening
   - `OpenTelemetryConfig.java` adds distributed tracing instrumentation

2. **Distributed Tracing Flow**:
   ```
   Application → OpenTelemetry → Collector → Tempo → Grafana
   ```
   - `OpenTelemetryConfig.java` generates traces
   - `otel/otel-collector-config.yaml` processes telemetry data
   - `tempo/tempo.yaml` stores distributed traces
   - Grafana dashboards visualize trace data

3. **API Gateway Flow**:
   ```
   External Request → Traefik → Service → Response
   ```
   - `traefik/traefik.yml` configures API gateway
   - `traefik/dynamic-config.yml` defines routing rules
   - Network policies secure service communication
   - TLS termination and security headers

4. **GitOps Flow**:
   ```
   Git Push → ArgoCD → Kubernetes → Application Update
   ```
   - `argocd/applications/` define deployment configurations
   - `argocd/applicationsets/` enable dynamic deployments
   - `argocd/projects/` provide resource isolation
   - Automated synchronization with rollback capability

5. **Infrastructure as Code Flow**:
   ```
   Terraform Code → Plan → Apply → Resources
   ```
   - `terraform/main.tf` orchestrates all modules
   - `terraform/modules/` provide reusable components
   - `terraform/variables.tf` enable environment-specific values
   - Reproducible infrastructure across environments

6. **Helm Deployment Flow**:
   ```
   Helm Chart → Values → Templates → Kubernetes Resources
   ```
   - `helm/application/` provides reusable application deployment
   - `helm/monitoring/` deploys observability stack
   - `helm/traefik/` configures ingress controller
   - Environment-specific values for multi-environment support

7. **Enhanced Observability Flow**:
   ```
   Application → OpenTelemetry → Collector → Multiple Sinks
   ```
   - Traces: Application → OpenTelemetry → Tempo → Grafana
   - Metrics: Application → OpenTelemetry → Prometheus → Grafana
   - Logs: Application → OpenTelemetry → Graylog → Grafana
   - Correlated view across all three pillars

8. **Production Deployment Flow**:
   ```
   Docker Compose → Kubernetes → Production Features
   ```
   - `docker-compose.yml` local development with all services
   - `k8s/` manifests with production improvements
   - Network policies, PDBs, HPAs, and resource quotas
   - High availability and security configurations

### Key Architectural Benefits

1. **Cloud-Native Architecture**: Full Kubernetes-native deployment with modern patterns
2. **Distributed Observability**: End-to-end tracing with correlation across logs, metrics, and traces
3. **GitOps Workflows**: Automated, version-controlled deployments with ArgoCD
4. **Infrastructure as Code**: Reproducible infrastructure with Terraform modules
5. **API Gateway**: Centralized ingress with security, rate limiting, and load balancing
6. **Production Ready**: Network policies, autoscaling, resource management, and high availability
7. **Modularity**: Each component can be developed and deployed independently
8. **Scalability**: Horizontal autoscaling based on metrics and load
9. **Security**: Zero-trust network policies, RBAC, and secrets management
10. **Maintainability**: Configuration as code, comprehensive documentation, and automated testing

### Cloud-Native Integration Examples

1. **End-to-End Request Flow**:
   ```
   User Request → Traefik → API Service → MongoDB → OpenTelemetry → Tempo → Grafana
   ```

2. **GitOps Deployment Flow**:
   ```
   Git Push → ArgoCD → Helm/Terraform → Kubernetes → Monitoring → Alerting
   ```

3. **Observability Correlation**:
   ```
   Trace ID → Application Logs → Collector → Tempo → Grafana → Root Cause Analysis
   ```

4. **Production Scaling Flow**:
   ```
   Load Increase → HPA → More Pods → Network Policies → Service Discovery → Load Balancing
   ```

This comprehensive cloud-native architecture provides an enterprise-grade foundation for modern applications with complete observability, security, and automation capabilities. The integration of OpenTelemetry, Traefik, ArgoCD, Terraform, and Helm creates a production-ready platform that scales, monitors, and secures itself automatically.
