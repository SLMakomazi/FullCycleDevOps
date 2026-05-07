#!/bin/bash

# Full-Stack DevOps & Observability Platform Setup Script
# This script automates the complete environment setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="devops-observability"
DOCKER_COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"

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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Check available memory
    TOTAL_MEM=$(free -m | awk 'NR==2{print $2}' 2>/dev/null || echo "0")
    if [ "$TOTAL_MEM" -lt 8192 ]; then
        log_warn "System has less than 8GB RAM. Performance may be affected."
    fi
    
    # Check available disk space
    AVAILABLE_SPACE=$(df -BG . | awk 'NR==2{print $4}' | sed 's/G//')
    if [ "$AVAILABLE_SPACE" -lt 20 ]; then
        log_warn "Less than 20GB disk space available. Some services may fail."
    fi
    
    log_info "Prerequisites check completed"
}

# Function to create required directories
create_directories() {
    log_step "Creating required directories..."
    
    # Create log directories
    mkdir -p api/logs
    mkdir -p logs/filebeat
    mkdir -p logs/graylog
    mkdir -p logs/prometheus
    mkdir -p logs/grafana
    
    # Create data directories for volumes
    mkdir -p data/mongodb
    mkdir -p data/opensearch
    mkdir -p data/graylog
    mkdir -p data/prometheus
    mkdir -p data/grafana
    mkdir -p data/bamboo
    mkdir -p data/rancher
    
    # Set proper permissions
    chmod 755 api/logs
    chmod 755 logs/filebeat
    chmod 755 logs/graylog
    chmod 755 logs/prometheus
    chmod 755 logs/grafana
    
    log_info "Directories created successfully"
}

# Function to set up OpenSearch permissions
setup_opensearch_permissions() {
    log_step "Setting up OpenSearch permissions..."
    
    # Set OpenSearch data directory permissions
    if [ -d "data/opensearch" ]; then
        sudo chown -R 1000:1000 data/opensearch 2>/dev/null || {
            log_warn "Could not set OpenSearch permissions. You may need to run: sudo chown -R 1000:1000 data/opensearch"
        }
    fi
    
    # Set vm.max_map_count for OpenSearch
    if [ "$(sysctl -n vm.max_map_count)" -lt 262144 ]; then
        log_warn "Setting vm.max_map_count for OpenSearch..."
        sudo sysctl -w vm.max_map_count=262144 2>/dev/null || {
            log_warn "Could not set vm.max_map_count. Please run: sudo sysctl -w vm.max_map_count=262144"
        }
        
        # Make it persistent
        echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf 2>/dev/null || {
            log_warn "Could not make vm.max_map_count persistent. Please add to /etc/sysctl.conf manually."
        }
    fi
    
    log_info "OpenSearch permissions configured"
}

# Function to create environment file
create_env_file() {
    log_step "Creating environment configuration..."
    
    if [ ! -f "$ENV_FILE" ]; then
        cat > "$ENV_FILE" << EOF
# DevOps & Observability Platform Environment Configuration

# Application Configuration
SPRING_PROFILES_ACTIVE=docker
MONGODB_URI=mongodb://mongodb:27017/devops_observability
MONGODB_DATABASE=devops_observability

# MongoDB Configuration
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=admin123

# Graylog Configuration
GRAYLOG_PASSWORD_SECRET=somepasswordpepper
GRAYLOG_ROOT_PASSWORD_SHA2=8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918
GRAYLOG_HTTP_EXTERNAL_URI=http://localhost:9000/

# OpenSearch Configuration
OPENSEARCH_INITIAL_ADMIN_PASSWORD=StrongPassword123!

# Grafana Configuration
GF_SECURITY_ADMIN_PASSWORD=admin123
GF_USERS_ALLOW_SIGN_UP=false

# Bamboo Configuration
CATTLE_BOOTSTRAP_PASSWORD=rancher123

# Docker Registry (if using private registry)
DOCKER_REGISTRY=your-registry.com
DOCKER_USERNAME=your-username
DOCKER_PASSWORD=your-password
EOF
        log_info "Environment file created: $ENV_FILE"
    else
        log_info "Environment file already exists: $ENV_FILE"
    fi
}

# Function to create MongoDB initialization script
create_mongo_init() {
    log_step "Creating MongoDB initialization script..."
    
    mkdir -p scripts
    cat > scripts/mongo-init.js << 'EOF'
// MongoDB initialization script
db = db.getSiblingDB('devops_observability');

// Create application user
db.createUser({
  user: 'app_user',
  pwd: 'app_password',
  roles: [
    {
      role: 'readWrite',
      db: 'devops_observability'
    }
  ]
});

// Create initial collection with validation
db.createCollection('items', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['name', 'createdAt'],
      properties: {
        name: {
          bsonType: 'string',
          minLength: 1,
          maxLength: 100
        },
        description: {
          bsonType: 'string',
          maxLength: 500
        },
        createdAt: {
          bsonType: 'date'
        },
        updatedAt: {
          bsonType: 'date'
        }
      }
    }
  }
});

print('MongoDB initialization completed');
EOF
    log_info "MongoDB initialization script created"
}

# Function to start services
start_services() {
    log_step "Starting services with Docker Compose..."
    
    # Pull latest images
    log_info "Pulling Docker images..."
    docker-compose pull
    
    # Start services
    log_info "Starting services..."
    docker-compose up -d
    
    log_info "Services started. Waiting for health checks..."
}

# Function to wait for services to be ready
wait_for_services() {
    log_step "Waiting for services to be ready..."
    
    # Wait for MongoDB
    log_info "Waiting for MongoDB..."
    timeout 60 bash -c 'until docker exec mongodb mongosh --eval "db.adminCommand(\"ping\")" > /dev/null 2>&1; do sleep 2; done'
    
    # Wait for OpenSearch
    log_info "Waiting for OpenSearch..."
    timeout 120 bash -c 'until curl -f http://localhost:9200/_cluster/health > /dev/null 2>&1; do sleep 5; done'
    
    # Wait for Graylog
    log_info "Waiting for Graylog..."
    timeout 120 bash -c 'until curl -f http://localhost:9000/api/ > /dev/null 2>&1; do sleep 5; done'
    
    # Wait for API
    log_info "Waiting for API..."
    timeout 180 bash -c 'until curl -f http://localhost:8080/actuator/health > /dev/null 2>&1; do sleep 5; done'
    
    # Wait for Prometheus
    log_info "Waiting for Prometheus..."
    timeout 60 bash -c 'until curl -f http://localhost:9090/-/healthy > /dev/null 2>&1; do sleep 3; done'
    
    # Wait for Grafana
    log_info "Waiting for Grafana..."
    timeout 60 bash -c 'until curl -f http://localhost:3000/api/health > /dev/null 2>&1; do sleep 3; done'
    
    log_info "All services are ready!"
}

# Function to display service URLs
display_service_urls() {
    log_step "Service URLs:"
    echo ""
    echo -e "${GREEN}Application Services:${NC}"
    echo "  • Spring Boot API:       http://localhost:8080"
    echo "  • API Health Check:      http://localhost:8080/actuator/health"
    echo "  • API Metrics:           http://localhost:8080/actuator/prometheus"
    echo ""
    echo -e "${GREEN}Monitoring Services:${NC}"
    echo "  • Prometheus:            http://localhost:9090"
    echo "  • Grafana:              http://localhost:3000 (admin/admin123)"
    echo ""
    echo -e "${GREEN}Logging Services:${NC}"
    echo "  • Graylog:              http://localhost:9000 (admin/admin)"
    echo "  • OpenSearch:           http://localhost:9200"
    echo ""
    echo -e "${GREEN}DevOps Services:${NC}"
    echo "  • Bamboo:               http://localhost:8085"
    echo "  • Rancher:              https://localhost (rancher123)"
    echo ""
    echo -e "${GREEN}Database:${NC}"
    echo "  • MongoDB:              mongodb://localhost:27017"
    echo ""
}

# Function to show next steps
show_next_steps() {
    log_step "Next Steps:"
    echo ""
    echo "1. ${YELLOW}Test the API:${NC}"
    echo "   curl http://localhost:8080/api/items"
    echo ""
    echo "2. ${YELLOW}Create sample data:${NC}"
    echo "   curl -X POST http://localhost:8080/api/items \\"
    echo "     -H 'Content-Type: application/json' \\"
    echo "     -d '{\"name\":\"Sample Item\",\"description\":\"Test item\"}'"
    echo ""
    echo "3. ${YELLOW}View metrics in Prometheus:${NC}"
    echo "   Open http://localhost:9090 and search for 'http_server_requests'"
    echo ""
    echo "4. ${YELLOW}View dashboards in Grafana:${NC}"
    echo "   Open http://localhost:3000 (admin/admin123)"
    echo ""
    echo "5. ${YELLOW}View logs in Graylog:${NC}"
    echo "   Open http://localhost:9000 (admin/admin)"
    echo ""
    echo "6. ${YELLOW}Deploy to Kubernetes:${NC}"
    echo "   kubectl apply -f k8s/"
    echo ""
    echo "7. ${YELLOW}Stop services:${NC}"
    echo "   docker-compose down"
    echo ""
}

# Function to cleanup on exit
cleanup() {
    if [ $? -ne 0 ]; then
        log_error "Setup failed. Check the error messages above."
        echo ""
        echo "To cleanup partially created resources, run:"
        echo "  docker-compose down -v"
        echo "  sudo rm -rf data/ logs/"
    fi
}

# Set trap for cleanup
trap cleanup EXIT

# Main execution
main() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}DevOps & Observability Platform Setup${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    check_prerequisites
    create_directories
    setup_opensearch_permissions
    create_env_file
    create_mongo_init
    start_services
    wait_for_services
    display_service_urls
    show_next_steps
    
    echo ""
    log_info "Setup completed successfully!"
    echo -e "${BLUE}================================================${NC}"
}

# Handle script interruption
trap 'log_error "Setup interrupted"; exit 1' INT TERM

# Run main function
main "$@"
