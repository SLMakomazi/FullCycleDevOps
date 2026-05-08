# FullCycleDevOps - Minimal DevOps Stack

## 🚀 **Quick Start**

```bash
# Start the stack
docker-compose up -d

# Check services
docker-compose ps

# View logs
docker-compose logs -f
```

## 📋 **Services**

| Service | Port | Description |
|---------|-------|-------------|
| API | 8080 | Spring Boot Application |
| MongoDB | 27017 | Database |
| Prometheus | 9090 | Metrics Collection |
| Grafana | 3000 | Visualization |

## 🔗 **Access URLs**

- **API**: http://localhost:8080
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin123)
- **MongoDB**: mongodb://localhost:27017

## 📁 **Project Structure**

```
FullCycleDevOps/
├── api/                    # Spring Boot application
├── grafana/                 # Grafana dashboards
├── prometheus/              # Prometheus config
├── jenkins/                 # CI/CD pipeline
└── docker-compose.yml        # Stack definition
```

## 🏗️ **Architecture**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   API      │────▶│  MongoDB   │    │ Prometheus  │
│ :8080      │    │ :27017     │    │ :9090      │
└─────────────┘    └─────────────┘    └─────┬──────┘
                                          │
                                          ▼
                                   ┌─────────────┐
                                   │  Grafana    │
                                   │ :3000       │
                                   └─────────────┘
```

## 🔄 **CI/CD**

Jenkins builds and deploys:
- Automatic builds on Git push
- Semantic versioning: `v1.{BUILD_NUMBER}`
- Docker Hub integration

## 📊 **Monitoring**

- **Metrics**: Prometheus scrapes API `/actuator/prometheus`
- **Visualization**: Grafana dashboards auto-provisioned
- **Storage**: 200-hour retention

## 🎯 **Usage**

1. **Develop**: Push code to trigger Jenkins build
2. **Deploy**: `docker-compose up -d` starts all services
3. **Monitor**: Access Grafana for observability

Simple, clean DevOps stack ready for development! 🎉
