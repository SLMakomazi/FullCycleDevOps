#!/bin/bash

# Cleanup Script for DevOps & Observability Platform
# This script cleans up all resources created by setup.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Function to stop and remove containers
cleanup_containers() {
    log_step "Stopping and removing containers..."
    
    if [ -f "docker-compose.yml" ]; then
        docker-compose down -v --remove-orphans
        log_info "Containers stopped and removed"
    else
        log_warn "docker-compose.yml not found"
    fi
}

# Function to remove Docker images
cleanup_images() {
    log_step "Removing Docker images..."
    
    # Remove project-specific images
    docker images | grep devops-observability | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true
    
    # Remove dangling images
    docker image prune -f
    
    log_info "Docker images cleaned up"
}

# Function to remove volumes
cleanup_volumes() {
    log_step "Removing Docker volumes..."
    
    # Remove project volumes
    docker volume ls | grep devops | awk '{print $2}' | xargs -r docker volume rm 2>/dev/null || true
    
    log_info "Docker volumes cleaned up"
}

# Function to remove local directories
cleanup_directories() {
    log_step "Removing local directories..."
    
    # Remove data directories
    if [ -d "data" ]; then
        rm -rf data/
        log_info "Data directories removed"
    fi
    
    # Remove log directories
    if [ -d "logs" ]; then
        rm -rf logs/
        log_info "Log directories removed"
    fi
    
    # Remove environment file
    if [ -f ".env" ]; then
        rm -f .env
        log_info "Environment file removed"
    fi
}

# Function to reset OpenSearch settings
reset_opensearch_settings() {
    log_step "Resetting OpenSearch system settings..."
    
    # Remove vm.max_map_count setting
    if grep -q "vm.max_map_count=262144" /etc/sysctl.conf 2>/dev/null; then
        sudo sed -i '/vm.max_map_count=262144/d' /etc/sysctl.conf
        log_info "OpenSearch system settings reset"
    fi
}

# Function to show cleanup summary
show_summary() {
    log_step "Cleanup Summary:"
    echo ""
    echo "✓ Containers stopped and removed"
    echo "✓ Docker images cleaned up"
    echo "✓ Docker volumes removed"
    echo "✓ Local directories deleted"
    echo "✓ System settings reset"
    echo ""
    log_info "Cleanup completed successfully!"
}

# Function to confirm cleanup
confirm_cleanup() {
    echo -e "${YELLOW}This will remove ALL data, containers, and configurations.${NC}"
    echo -e "${YELLOW}Are you sure you want to continue? (y/N)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log_info "Cleanup cancelled by user"
        exit 0
    fi
}

# Main execution
main() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}DevOps & Observability Platform Cleanup${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    confirm_cleanup
    cleanup_containers
    cleanup_images
    cleanup_volumes
    cleanup_directories
    reset_opensearch_settings
    show_summary
    
    echo -e "${BLUE}================================================${NC}"
}

# Handle script interruption
trap 'log_error "Cleanup interrupted"; exit 1' INT TERM

# Run main function
main "$@"
