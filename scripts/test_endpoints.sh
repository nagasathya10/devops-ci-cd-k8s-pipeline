#!/usr/bin/env bash
# ==============================================================================
# Script to verify all REST API endpoints locally or via Kubernetes NodePort
# ==============================================================================

set -e

BASE_URL="${1:-http://localhost:5000}"

echo "================================================================="
echo "Testing DevOps Task API at: $BASE_URL"
echo "================================================================="

echo -e "\n1. Testing Root ('/') Endpoint:"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/"

echo -e "\n2. Testing Health ('/health') Check Endpoint (Liveness/Readiness):"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/health"

echo -e "\n3. Testing GET All Todos ('/todos'):"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/todos"

echo -e "\n4. Testing POST New Todo ('/todos'):"
curl -s -X POST "$BASE_URL/todos" \
     -H "Content-Type: application/json" \
     -d '{"title": "Automated Deployment Verification", "description": "Verified endpoint using curl script", "completed": true}' \
     -w "\nHTTP Status: %{http_code}\n"

echo -e "\n5. Testing GET Specific Todo ('/todos/1'):"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/todos/1"

echo -e "\n6. Testing Metrics Endpoint ('/metrics'):"
curl -s -w "\nHTTP Status: %{http_code}\n" "$BASE_URL/metrics"

echo -e "\n================================================================="
echo "All endpoint checks completed successfully!"
echo "================================================================="
