#!/bin/bash

# Deployment Script for Bamboo CI/CD
# This script handles the deployment of the application to Kubernetes

set -e

# Configuration
APP_NAME="${APP_NAME:-devops-observability-api}"
NAMESPACE="${NAMESPACE:-devops-observability}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
REGISTRY="${REGISTRY:-your-registry.com}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        exit 1
    fi
    
    log_info "kubectl is available and connected to cluster"
}

# Function to check if namespace exists
check_namespace() {
    if ! kubectl get namespace ${NAMESPACE} &> /dev/null; then
        log_warn "Namespace ${NAMESPACE} does not exist, creating it..."
        kubectl create namespace ${NAMESPACE}
        log_info "Namespace ${NAMESPACE} created"
    else
        log_info "Namespace ${NAMESPACE} exists"
    fi
}

# Function to deploy application
deploy_application() {
    log_info "Deploying application ${APP_NAME} with tag ${IMAGE_TAG}"
    
    # Update image tag in deployment
    sed -i.bak "s|image: devops-observability-api:latest|image: ${REGISTRY}/${APP_NAME}:${IMAGE_TAG}|g" k8s/api/api-deployment.yaml
    
    # Apply configurations
    log_info "Applying namespace configuration..."
    kubectl apply -f k8s/namespaces/ --validate=false
    
    log_info "Applying MongoDB configuration..."
    kubectl apply -f k8s/mongodb/ --validate=false
    
    log_info "Applying API configuration..."
    kubectl apply -f k8s/api/ --validate=false
    
    log_info "Applying Prometheus configuration..."
    kubectl apply -f k8s/prometheus/ --validate=false
    
    log_info "Applying Grafana configuration..."
    kubectl apply -f k8s/grafana/ --validate=false
    
    # Restore original deployment file
    mv k8s/api/api-deployment.yaml.bak k8s/api/api-deployment.yaml
}

# Function to wait for deployment
wait_for_deployment() {
    log_info "Waiting for deployments to be ready..."
    
    # Wait for API deployment
    kubectl rollout status deployment/devops-api -n ${NAMESPACE} --timeout=300s
    
    # Wait for MongoDB deployment
    kubectl rollout status deployment/mongodb -n ${NAMESPACE} --timeout=300s
    
    # Wait for Prometheus deployment
    kubectl rollout status deployment/prometheus -n ${NAMESPACE} --timeout=300s
    
    # Wait for Grafana deployment
    kubectl rollout status deployment/grafana -n ${NAMESPACE} --timeout=300s
    
    log_info "All deployments are ready"
}

# Function to run smoke tests
run_smoke_tests() {
    log_info "Running smoke tests..."
    
    # Wait for pods to be ready
    kubectl wait --for=condition=ready pod -l app=devops-api -n ${NAMESPACE} --timeout=300s
    
    # Get API endpoint
    API_URL=$(kubectl get svc devops-api-service -n ${NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    
    if [ -z "$API_URL" ]; then
        # If no LoadBalancer, try port-forwarding for testing
        log_warn "No external IP found, using port-forwarding for tests"
        kubectl port-forward svc/devops-api-service 8080:8080 -n ${NAMESPACE} &
        PORT_FORWARD_PID=$!
        sleep 10
        API_URL="localhost:8080"
    fi
    
    # Run health check
    if curl -f http://$API_URL/actuator/health; then
        log_info "Smoke tests passed"
    else
        log_error "Smoke tests failed"
        exit 1
    fi
    
    # Clean up port-forwarding if used
    if [ ! -z "$PORT_FORWARD_PID" ]; then
        kill $PORT_FORWARD_PID 2>/dev/null || true
    fi
}

# Function to display deployment status
show_status() {
    log_info "Deployment Status:"
    echo "Namespace: ${NAMESPACE}"
    echo "Application: ${APP_NAME}"
    echo "Image: ${REGISTRY}/${APP_NAME}:${IMAGE_TAG}"
    echo ""
    
    log_info "Pods in namespace ${NAMESPACE}:"
    kubectl get pods -n ${NAMESPACE}
    
    echo ""
    log_info "Services in namespace ${NAMESPACE}:"
    kubectl get services -n ${NAMESPACE}
}

# Main execution
main() {
    log_info "Starting deployment process..."
    
    check_kubectl
    check_namespace
    deploy_application
    wait_for_deployment
    run_smoke_tests
    show_status
    
    log_info "Deployment completed successfully!"
}

# Handle script interruption
trap 'log_error "Deployment interrupted"; exit 1' INT TERM

# Run main function
main "$@"
