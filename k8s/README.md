# Kubernetes Deployment with Kustomize

## 📁 **Directory Structure**

```
k8s/
├── deployment.yaml          # Base deployment manifest
├── service.yaml            # Service definition
├── secrets.yaml           # Sensitive configuration
├── kustomization.yaml     # Base kustomization
├── local-wsl/           # WSL 2 specific overlay
│   ├── kustomization.yaml # Local WSL overrides
│   └── deployment-patch.yaml # Local patches
└── README.md             # Documentation

argocd/                    # ArgoCD configurations (moved to root)
├── application.yaml       # ArgoCD app definition
└── project.yaml         # ArgoCD project
```

## 🚀 **Deployment Commands**

### **1. Local Development (WSL 2)**
```bash
# Make script executable
chmod +x deploy-to-k3s.sh

# Deploy to local k3s
./deploy-to-k3s.sh
```

### **2. Manual Kustomize Commands**
```bash
# Build manifests
kubectl kustomize k8s/local-wsl

# Apply to cluster
kubectl apply -k k8s/local-wsl

# Check status
kubectl get pods -n devops-observability
```

### **3. Port Forwarding**
```bash
# Forward API to localhost
kubectl port-forward service/fullcycle-api-service 8080:8080 -n devops-observability

# Access API
curl http://localhost:8080/actuator/health
```

## 🔧 **Configuration**

### **Environment Variables**
- `SPRING_PROFILES_ACTIVE=kubernetes`
- `MONGODB_URI` (from secret)
- `MONGODB_DATABASE=devops_observability`
- `JAVA_OPTS="-Xmx512m -Xms256m"`

### **Secrets**
MongoDB credentials stored in `fullcycle-secrets`:
```yaml
mongodb-uri: bW9uZ29kYjovL2FkbWluOmFkbWluMTIzQG1vbmdvZGI6MjcwMTcvZGV2b3BzX29ic2VydmFiaWxpdHk/YXV0aFNvdXJjZT1hZG1pbg==
```
(Base64 decoded: `mongodb://admin:admin123@mongodb:27017/devops_observability?authSource=admin`)

### **Resources**
- **Requests**: 256Mi memory, 250m CPU
- **Limits**: 512Mi memory, 500m CPU
- **Local WSL**: Reduced to 128Mi/256Mi for development

## 🔄 **ArgoCD Integration**

### **Setup ArgoCD**
```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Apply project and app (now in root argocd/ folder)
kubectl apply -f argocd/
```

### **ArgoCD Configuration**
- **Project**: `fullcycle-project`
- **Application**: `fullcycle-api`
- **Source**: GitHub repo `k8s/local-wsl` path
- **Destination**: `devops-observability` namespace
- **Sync Policy**: Automated with self-healing

## 📊 **Monitoring**

### **Health Checks**
- **Liveness**: `/actuator/health` (60s delay, 30s interval)
- **Readiness**: `/actuator/health` (30s delay, 10s interval)

### **Endpoints**
- **Metrics**: `/actuator/prometheus`
- **Health**: `/actuator/health`
- **Info**: `/actuator/info`

## 🛠 **Troubleshooting**

### **Common Issues**
1. **Image not found**: Run `./deploy-to-k3s.sh` to build and import
2. **Pod pending**: Check `kubectl describe pod` for resource issues
3. **Connection refused**: Verify MongoDB is running and accessible

### **Debug Commands**
```bash
# Check pod logs
kubectl logs -n devops-observability -l app=fullcycle-api

# Describe pod
kubectl describe pod -n devops-observability -l app=fullcycle-api

# Check events
kubectl get events -n devops-observability --sort-by='.lastTimestamp'
```
