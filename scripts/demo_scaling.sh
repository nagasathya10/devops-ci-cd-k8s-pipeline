#!/usr/bin/env bash
# ==============================================================================
# Script to demonstrate Kubernetes Scaling (Assignment Component 2 Step 4)
# ==============================================================================

DEPLOYMENT_NAME="todo-api-deployment"

echo "================================================================="
echo "Kubernetes Scaling Demonstration"
echo "Deployment: $DEPLOYMENT_NAME"
echo "================================================================="

echo -e "\nStep 1: Checking initial running pods (should be 3 replicas):"
kubectl get pods -l app=todo-api

echo -e "\nStep 2: Scaling up deployment to 5 replicas..."
kubectl scale deployment "$DEPLOYMENT_NAME" --replicas=5

echo -e "\nWaiting for new pods to reach Running status..."
kubectl rollout status deployment/"$DEPLOYMENT_NAME" --timeout=60s

echo -e "\nStep 3: Verification - 5 Pods currently running:"
kubectl get pods -l app=todo-api -o wide

echo -e "\nSleeping for 5 seconds before scaling down..."
sleep 5

echo -e "\nStep 4: Scaling back down to 3 replicas..."
kubectl scale deployment "$DEPLOYMENT_NAME" --replicas=3

echo -e "\nWaiting for scaling down to complete..."
kubectl rollout status deployment/"$DEPLOYMENT_NAME" --timeout=60s

echo -e "\nStep 5: Final state - 3 Replicas restored:"
kubectl get pods -l app=todo-api

echo -e "\n================================================================="
echo "Kubernetes scaling demonstration finished successfully!"
echo "================================================================="
