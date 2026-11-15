# DevOps CI/CD Build & Automation Makefile
SHELL := /bin/bash
PYTHON := python3
PIP := pip3
VENV := .venv
APP_DIR := app
BUILD_DIR := dist
APP_NAME := devops-todo-api
VERSION := $(shell git rev-parse --short HEAD 2>/dev/null || echo "1.0.0")

.PHONY: all help venv install test build package clean run docker-build docker-run

all: test package

help:
	@echo "Available targets:"
	@echo "  venv         - Create Python virtual environment"
	@echo "  install      - Install application and test dependencies"
	@echo "  test         - Run automated unit tests with pytest and coverage"
	@echo "  build        - Compile bytecode and validate syntax"
	@echo "  package      - Bundle application into distributable tarball with version tag"
	@echo "  run          - Run application locally on port 5000"
	@echo "  docker-build - Build Docker container image"
	@echo "  docker-run   - Run container locally"
	@echo "  clean        - Remove build artifacts, pycache, and test reports"

venv:
	$(PYTHON) -m venv $(VENV)

install:
	$(PIP) install -r requirements.txt

test:
	$(PYTHON) -m pytest $(APP_DIR)/test_app.py -v --junitxml=junit-results.xml

build:
	$(PYTHON) -m py_compile $(APP_DIR)/app.py $(APP_DIR)/test_app.py

package: test build
	@mkdir -p $(BUILD_DIR)
	@tar --exclude='__pycache__' --exclude='*.pyc' -czvf $(BUILD_DIR)/$(APP_NAME)-$(VERSION).tar.gz $(APP_DIR) requirements.txt Dockerfile
	@echo "Artifact successfully packaged: $(BUILD_DIR)/$(APP_NAME)-$(VERSION).tar.gz"

run:
	PORT=5000 $(PYTHON) $(APP_DIR)/app.py

docker-build:
	docker build -t $(APP_NAME):$(VERSION) -t $(APP_NAME):latest .

docker-run:
	docker run -p 5000:5000 --rm $(APP_NAME):latest

clean:
	rm -rf $(BUILD_DIR) .pytest_cache junit-results.xml __pycache__ $(APP_DIR)/__pycache__ .coverage
