#!/usr/bin/env bash
# ==============================================================================
# Script to demonstrate Kubernetes Rollout & Rollback (Deployment Enhancement)
# ==============================================================================

DEPLOYMENT_NAME="todo-api-deployment"

echo "================================================================="
echo "Kubernetes Deployment Rollback Demonstration"
echo "Deployment: $DEPLOYMENT_NAME"
echo "================================================================="

echo -e "\nStep 1: Check initial rollout history:"
kubectl rollout history deployment/"$DEPLOYMENT_NAME"

echo -e "\nStep 2: Simulating an intentional bad/broken deployment image update..."
kubectl set image deployment/"$DEPLOYMENT_NAME" todo-api=devops-todo-api:broken-tag-does-not-exist --record || true

echo -e "\nStep 3: Checking pod status (Pods should show ImagePullBackOff / ErrImagePull):"
sleep 4
kubectl get pods -l app=todo-api

echo -e "\nStep 4: Executing Rollback command (kubectl rollout undo)..."
kubectl rollout undo deployment/"$DEPLOYMENT_NAME"

echo -e "\nWaiting for rollback to complete healthy state..."
kubectl rollout status deployment/"$DEPLOYMENT_NAME" --timeout=60s

echo -e "\nStep 5: Rollback verified! Pods are back to healthy running state:"
kubectl get pods -l app=todo-api

echo -e "\nStep 6: Updated Rollout History:"
kubectl rollout history deployment/"$DEPLOYMENT_NAME"

echo -e "\n================================================================="
echo "Kubernetes rollback demonstration completed successfully!"
echo "================================================================="
