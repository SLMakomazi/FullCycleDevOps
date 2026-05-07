# Rancher Setup and Configuration

## Overview

This directory contains Rancher configuration files and setup instructions for managing the DevOps & Observability platform.

## Local Cluster Bootstrap

### Prerequisites

- Docker 20.10+
- Docker Compose v2.0+
- At least 8GB RAM
- 2+ CPU cores

### Quick Start

1. **Start Rancher Server:**
   ```bash
   docker-compose up -d rancher
   ```

2. **Access Rancher UI:**
   - URL: https://localhost
   - Initial password: `rancher123`
   - Follow the setup wizard to configure your first admin user

3. **Create a Local Cluster:**
   - Navigate to "Clusters" in the Rancher UI
   - Click "Create" → "Custom"
   - Cluster Name: `devops-cluster`
   - Select "None" for cloud provider
   - Click "Create"

### Cluster Configuration

Once the cluster is created, you'll need to apply the Kubernetes manifests:

```bash
kubectl apply -f ../k8s/namespaces/
kubectl apply -f ../k8s/mongodb/
kubectl apply -f ../k8s/api/
kubectl apply -f ../k8s/prometheus/
kubectl apply -f ../k8s/grafana/
```

## Workload Deployment Examples

### Deploy the Spring Boot API

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: devops-api-workload
  namespace: devops-observability
  labels:
    workload.user.cattle.io/workloadselector: deployment-devops-observability-devops-api-workload
spec:
  replicas: 2
  selector:
    matchLabels:
      workload.user.cattle.io/workloadselector: deployment-devops-observability-devops-api-workload
  template:
    metadata:
      labels:
        workload.user.cattle.io/workloadselector: deployment-devops-observability-devops-api-workload
    spec:
      containers:
      - name: devops-api
        image: devops-observability-api:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "kubernetes"
        - name: MONGODB_URI
          value: "mongodb://app_user:app_password@mongodb-service:27017/devops_observability"
```

## Monitoring Integration

Rancher provides built-in monitoring capabilities that can be integrated with our Prometheus setup:

1. **Enable Cluster Monitoring:**
   - Navigate to "Tools" → "Monitoring"
   - Install the Rancher monitoring stack
   - Configure Prometheus to scrape our application metrics

2. **Alerting Configuration:**
   - Set up alert managers in Rancher
   - Configure notification channels (Slack, Email, etc.)
   - Import alert rules from our Prometheus configuration

## Best Practices

### Security

- Use RBAC to restrict access to cluster resources
- Enable network policies for pod communication
- Regularly update Rancher and Kubernetes versions
- Use secrets management for sensitive data

### Backup and Recovery

- Enable Rancher backups
- Configure etcd backups for the Kubernetes cluster
- Test disaster recovery procedures regularly

### Scaling

- Use Rancher's cluster management features for multi-cluster setups
- Implement proper resource quotas and limits
- Monitor cluster health and performance

## Troubleshooting

### Common Issues

1. **Cluster won't initialize:**
   - Check Docker daemon status
   - Verify port availability (80, 443)
   - Review Rancher server logs

2. **Workload deployment failures:**
   - Check resource availability
   - Verify image pull policies
   - Review pod logs

3. **Network connectivity issues:**
   - Check CNI plugin status
   - Verify service endpoints
   - Review network policies

### Logs and Debugging

```bash
# Rancher server logs
docker logs rancher

# Check cluster status
kubectl get nodes
kubectl get pods -n devops-observability

# Debug specific pod
kubectl describe pod <pod-name> -n devops-observability
kubectl logs <pod-name> -n devops-observability
```

## Next Steps

1. Configure automated backups
2. Set up multi-environment deployments
3. Implement GitOps with Rancher
4. Integrate with external CI/CD pipelines
5. Configure advanced monitoring and alerting
