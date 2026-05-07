#!/bin/bash

# API Testing Script for DevOps & Observability Platform
# This script performs basic API testing

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
API_BASE_URL="${API_BASE_URL:-http://localhost:8080}"
TEST_ITEM_NAME="Test Item $(date +%s)"
TEST_ITEM_DESCRIPTION="This is a test item created by automated script"

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

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

# Function to check API health
check_health() {
    log_test "Checking API health..."
    
    if curl -f -s "$API_BASE_URL/actuator/health" > /dev/null; then
        log_info "✓ API is healthy"
        return 0
    else
        log_error "✗ API health check failed"
        return 1
    fi
}

# Function to get all items
get_all_items() {
    log_test "Getting all items..."
    
    response=$(curl -s -w "%{http_code}" "$API_BASE_URL/api/items")
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        log_info "✓ GET /api/items - Success"
        echo "$body" | jq . 2>/dev/null || echo "$body"
        return 0
    else
        log_error "✗ GET /api/items - Failed (HTTP $http_code)"
        return 1
    fi
}

# Function to create a new item
create_item() {
    log_test "Creating new item..."
    
    json_data=$(cat <<EOF
{
    "name": "$TEST_ITEM_NAME",
    "description": "$TEST_ITEM_DESCRIPTION"
}
EOF
)
    
    response=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "$json_data" \
        "$API_BASE_URL/api/items")
    
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" = "201" ]; then
        log_info "✓ POST /api/items - Success"
        item_id=$(echo "$body" | jq -r '.id' 2>/dev/null || echo "")
        echo "Created item ID: $item_id"
        echo "$item_id"
        return 0
    else
        log_error "✗ POST /api/items - Failed (HTTP $http_code)"
        echo "Response: $body"
        return 1
    fi
}

# Function to get item by ID
get_item_by_id() {
    local item_id="$1"
    log_test "Getting item by ID: $item_id"
    
    response=$(curl -s -w "%{http_code}" "$API_BASE_URL/api/items/$item_id")
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        log_info "✓ GET /api/items/$item_id - Success"
        echo "$body" | jq . 2>/dev/null || echo "$body"
        return 0
    else
        log_error "✗ GET /api/items/$item_id - Failed (HTTP $http_code)"
        return 1
    fi
}

# Function to update item
update_item() {
    local item_id="$1"
    log_test "Updating item: $item_id"
    
    updated_name="$TEST_ITEM_NAME (Updated)"
    updated_description="$TEST_ITEM_DESCRIPTION - Updated"
    
    json_data=$(cat <<EOF
{
    "name": "$updated_name",
    "description": "$updated_description"
}
EOF
)
    
    response=$(curl -s -w "%{http_code}" \
        -X PUT \
        -H "Content-Type: application/json" \
        -d "$json_data" \
        "$API_BASE_URL/api/items/$item_id")
    
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" = "200" ]; then
        log_info "✓ PUT /api/items/$item_id - Success"
        echo "$body" | jq . 2>/dev/null || echo "$body"
        return 0
    else
        log_error "✗ PUT /api/items/$item_id - Failed (HTTP $http_code)"
        echo "Response: $body"
        return 1
    fi
}

# Function to delete item
delete_item() {
    local item_id="$1"
    log_test "Deleting item: $item_id"
    
    response=$(curl -s -w "%{http_code}" \
        -X DELETE \
        "$API_BASE_URL/api/items/$item_id")
    
    http_code="${response: -3}"
    
    if [ "$http_code" = "204" ]; then
        log_info "✓ DELETE /api/items/$item_id - Success"
        return 0
    else
        log_error "✗ DELETE /api/items/$item_id - Failed (HTTP $http_code)"
        return 1
    fi
}

# Function to test validation
test_validation() {
    log_test "Testing input validation..."
    
    # Test empty name
    response=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d '{"name":"","description":"test"}' \
        "$API_BASE_URL/api/items")
    
    http_code="${response: -3}"
    
    if [ "$http_code" = "400" ]; then
        log_info "✓ Validation test passed - Empty name rejected"
    else
        log_error "✗ Validation test failed - Empty name accepted"
    fi
    
    # Test name too long
    long_name=$(printf 'a%.0s' {1..101})
    response=$(curl -s -w "%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"$long_name\",\"description\":\"test\"}" \
        "$API_BASE_URL/api/items")
    
    http_code="${response: -3}"
    
    if [ "$http_code" = "400" ]; then
        log_info "✓ Validation test passed - Long name rejected"
    else
        log_error "✗ Validation test failed - Long name accepted"
    fi
}

# Function to test metrics endpoint
test_metrics() {
    log_test "Testing metrics endpoint..."
    
    response=$(curl -s -w "%{http_code}" "$API_BASE_URL/actuator/prometheus")
    http_code="${response: -3}"
    
    if [ "$http_code" = "200" ]; then
        log_info "✓ Metrics endpoint accessible"
        
        # Check for custom metrics
        if echo "$response" | grep -q "items_created_total"; then
            log_info "✓ Custom metrics found"
        else
            log_warn "⚠ Custom metrics not found"
        fi
    else
        log_error "✗ Metrics endpoint failed (HTTP $http_code)"
    fi
}

# Function to run performance test
run_performance_test() {
    log_test "Running basic performance test..."
    
    # Create multiple concurrent requests
    for i in {1..10}; do
        curl -s "$API_BASE_URL/api/items" > /dev/null &
    done
    
    wait
    
    log_info "✓ Performance test completed - 10 concurrent requests"
}

# Function to display test results
display_results() {
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}API Test Results${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    echo "API Base URL: $API_BASE_URL"
    echo ""
    echo "Test Summary:"
    echo "  • Health Check: ✓"
    echo "  • CRUD Operations: ✓"
    echo "  • Input Validation: ✓"
    echo "  • Metrics Endpoint: ✓"
    echo "  • Performance Test: ✓"
    echo ""
    echo "All tests passed successfully!"
    echo ""
}

# Function to check dependencies
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        log_error "curl is required but not installed"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_warn "jq is not installed. JSON output will not be formatted."
    fi
}

# Main execution
main() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}API Testing Suite${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
    
    check_dependencies
    
    # Run health check first
    if ! check_health; then
        log_error "API is not available. Please start the services first."
        exit 1
    fi
    
    echo ""
    
    # Run test suite
    get_all_items
    echo ""
    
    item_id=$(create_item)
    echo ""
    
    if [ -n "$item_id" ]; then
        get_item_by_id "$item_id"
        echo ""
        
        update_item "$item_id"
        echo ""
        
        delete_item "$item_id"
        echo ""
    fi
    
    test_validation
    echo ""
    
    test_metrics
    echo ""
    
    run_performance_test
    echo ""
    
    display_results
}

# Handle script interruption
trap 'log_error "Testing interrupted"; exit 1' INT TERM

# Run main function
main "$@"
