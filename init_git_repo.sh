#!/usr/bin/env bash
# ==============================================================================
# Script to initialize Git repository with required 2 branches & merge commit
# Fulfills Assignment Component 1 Step 2: Git Setup & Branch Merge History
# ==============================================================================

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

echo "================================================================="
echo "Initializing Git Repository with Required Branching & Merge History"
echo "================================================================="

# Configure local git user if not globally set
if ! git config user.name > /dev/null 2>&1; then
    git config user.name "DevOps Student"
    git config user.email "student@university.edu"
    echo "Configured local Git identity."
fi

# Initialize repository with default branch 'main'
if [ ! -d ".git" ]; then
    git init -b main
    echo "Git repository initialized on branch 'main'."
else
    echo "Git repository already initialized."
fi

# Step 1: Initial commit on main branch
git checkout -B main
git add .gitignore requirements.txt Makefile app/app.py
git commit -m "feat(core): initial REST API implementation and base build configuration" || echo "Initial commit exists"

# Step 2: Create feature branch for endpoints and CI/CD enhancements
echo -e "\nCreating feature branch: feature/todo-endpoints..."
git checkout -B feature/todo-endpoints

# Add test suite, CI workflows, Ansible, and Kubernetes manifests
git add app/test_app.py app/__init__.py Jenkinsfile .github/ Dockerfile .dockerignore ansible/ k8s/ scripts/ repo_link.txt
git commit -m "feat(pipeline): add automated test suite, Jenkinsfile, GitHub Actions CI, Ansible role, and K8s manifests" || echo "Feature commit exists"

# Step 3: Merge feature branch back into main with an explicit merge commit
echo -e "\nSwitching back to main branch..."
git checkout main

echo "Merging feature/todo-endpoints into main with non-fast-forward merge..."
git merge --no-ff feature/todo-endpoints -m "Merge branch 'feature/todo-endpoints' into main: complete CI/CD pipeline and deployment infrastructure"

echo -e "\n================================================================="
echo "Git History Verification (Satisfies Component 1 Step 2):"
echo "================================================================="
git log --graph --oneline --decorate --all -n 10

echo -e "\nRepository branches:"
git branch -a

echo -e "\n================================================================="
echo "To push this repository to GitHub:"
echo "1. Create an empty repository named 'devops-ci-cd-k8s-pipeline' on github.com"
echo "2. Run:"
echo "   git remote add origin https://github.com/nagasathya10/devops-ci-cd-k8s-pipeline.git"
echo "   git push -u origin main"
echo "   git push -u origin feature/todo-endpoints"
echo "================================================================="
