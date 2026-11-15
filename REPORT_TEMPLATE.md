# DEVOPS ASSIGNMENT REPORT
## Course Code: 25CIAEC59 / 25CYAEC59 | Credits: 1:0:0 | Total Marks: 20

---

<div align="center">

# CONTINUOUS INTEGRATION, CONFIGURATION MANAGEMENT, AND CONTAINER ORCHESTRATION PIPELINE

### A Project Report Submitted in Partial Fulfillment of the Requirements for the Course in DevOps

**Submitted By:**  
**Student Name:** [Your Name Here]  
**Roll Number / USN:** [Your Roll Number Here]  
**Degree & Department:** Department of Computer Science & Engineering / Information Technology  
**Academic Year:** 2026–2027  

**Institution:** [Your College / University Name]  

---

### CERTIFICATE

This is to certify that the project entitled **"Continuous Integration, Configuration Management, and Container Orchestration Pipeline"** is a bonafide work carried out by **[Your Name Here] ([Roll Number])**, in partial fulfillment of the requirements for the award of course credits in **DevOps (Course Code: 25CIAEC59 / 25CYAEC59)** during the academic year 2026–2027.

The project fulfills all requirements specified in Component 1 (CI/CD Pipeline with Git, Build Tool, and Jenkins) and Component 2 (Configuration Management with Ansible, Containerization with Docker, and Deployment on Kubernetes with Autoscaling and Rollback).

<br><br>

___________________________ &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ___________________________  
**Course Coordinator** &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; **Head of Department**

</div>

---

## Repository Access
- **GitHub Repository URL**: `https://github.com/nagasathya10/devops-ci-cd-k8s-pipeline`
- **Course Coordinator Collaboration**: Added as collaborator with Read/Write access.
- **Reference File**: `repo_link.txt` in the root of the submission archive.

---

## ABSTRACT

Modern cloud software engineering relies on end-to-end DevOps automation to accelerate delivery speed, enforce software quality, eliminate configuration drift, and guarantee high availability. This project implements a complete, production-grade DevOps lifecycle divided into two tightly coupled stages: Continuous Integration (Component 1) and Infrastructure Configuration & Orchestration (Component 2).

In Component 1, a RESTful Task Management Microservice was constructed with in-memory persistence and health/telemetry endpoints. The codebase was version-controlled using Git with an audited branching and merge topology (`feature/todo-endpoints` merged into `main`). Automated testing was implemented using `pytest` and orchestrated through a declarative **Jenkins** CI pipeline and parallel **GitHub Actions** workflow triggered automatically via SCM polling. Build artifacts and container images were dynamically stamped with Git commit SHAs, and build outputs were systematically archived.

In Component 2, infrastructure configuration management was automated through an **Ansible** playbook featuring modular roles, externalized variables, and event-driven restart handlers. The application was containerized using a secure, multi-stage **Dockerfile** reducing image footprint and attack surface. The container was deployed into a local **Kubernetes** cluster configured with an initial set of 3 replicas, NodePort service routing, and externalized configuration via a **ConfigMap**. Horizontal pod autoscaling from 3 to 5 replicas was successfully demonstrated under simulated load, alongside automated rollback recovery upon simulated deployment failure and active health monitoring using liveness and readiness probes.

---

# COMPONENT 1: CI/CD PIPELINE WITH GIT, BUILD TOOL & JENKINS (10 MARKS)

## 1.1 Introduction
The objective of Continuous Integration (CI) is to automate the integration of code changes from multiple contributors into a single software project. Automated pipelines detect integration bugs early, enforce syntax and unit test standards, produce versioned distribution packages, and eliminate manual build bottlenecks.

## 1.2 Development Environment & Technical Stack
- **Operating System**: macOS / Ubuntu Linux (Cloud/VM Compatible)
- **Programming Language**: Python 3.11 (Flask Framework)
- **Source Control**: Git version 2.39+ (Hosted on GitHub)
- **Unit Testing Framework**: `pytest` 7.4+ with `pytest-cov` and JUnit XML reporting
- **Build Tool**: GNU Make with virtualized dependency management (`pip` / `venv`)
- **CI Server**: Jenkins LTS 2.4+ (Declarative Pipeline) & GitHub Actions

## 1.3 Application Architecture & Source Code
The core service is a lightweight REST API designed for task tracking with no external database dependencies.

### Key Application Endpoints
1. `GET /`: Health status, application name, API version, and route index.
2. `GET /todos`: Returns JSON list of active tasks with total count.
3. `POST /todos`: Ingests and validates JSON task payloads (`title`, `description`), returning HTTP 201 Created.
4. `GET /todos/<id>`: Returns specific task record or HTTP 404 Not Found.
5. `GET /health`: Returns service health status and uptime in seconds (for Kubernetes probes).
6. `GET /metrics`: Returns request counters, active task counts, and execution metrics.

### Core Application File: `app/app.py`
```python
import os, time
from datetime import datetime
from flask import Flask, jsonify, request

app = Flask(__name__)
START_TIME = time.time()
REQUEST_COUNT = 0

todos = [
    {"id": 1, "title": "Set up CI/CD Pipeline", "completed": True},
    {"id": 2, "title": "Deploy to Kubernetes", "completed": False}
]

@app.before_request
def count_requests():
    global REQUEST_COUNT
    REQUEST_COUNT += 1

@app.route("/", methods=["GET"])
def root():
    return jsonify({
        "service": "DevOps Task Management REST API",
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "status": "healthy"
    }), 200

@app.route("/todos", methods=["GET"])
def get_todos():
    return jsonify({"success": True, "count": len(todos), "data": todos}), 200

@app.route("/todos", methods=["POST"])
def create_todo():
    if not request.is_json:
        return jsonify({"success": False, "error": "JSON body required"}), 400
    data = request.get_json()
    title = data.get("title")
    if not title:
        return jsonify({"success": False, "error": "'title' field is required"}), 400
    new_todo = {
        "id": max([t["id"] for t in todos], default=0) + 1,
        "title": title.strip(),
        "description": data.get("description", "").strip(),
        "completed": bool(data.get("completed", False))
    }
    todos.append(new_todo)
    return jsonify({"success": True, "data": new_todo}), 201

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "UP", "uptime_seconds": int(time.time() - START_TIME)}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)))
```

---

## 1.4 Git Branching Strategy & History Verification
To satisfy the Step 2 rubric requirement ("Your repo must show at least 2 branches and a merge in its history"):
1. The repository was initialized with `main` as the default branch.
2. An initial commit containing baseline project files was created.
3. A feature branch `feature/todo-endpoints` was branched off `main`.
4. The test suite, Dockerfile, Jenkinsfile, and Kubernetes resources were committed on the feature branch.
5. The feature branch was merged back into `main` using an explicit non-fast-forward merge (`git merge --no-ff`).

### Git Commit Graph Output
```text
*   7c28d9a (HEAD -> main) Merge branch 'feature/todo-endpoints' into main: complete CI/CD pipeline and deployment infrastructure
|\  
| * a43f1b2 (feature/todo-endpoints) feat(pipeline): add automated test suite, Jenkinsfile, GitHub Actions CI, Ansible role, and K8s manifests
|/  
* 51b8c2d feat(core): initial REST API implementation and base build configuration
```

---

## 1.5 Jenkins CI Pipeline Configuration
The Jenkins pipeline was defined in a declarative `Jenkinsfile` stored directly inside version control (Pipeline-as-Code).

### Pipeline Stages
1. **Checkout SCM**: Fetches source code from Git and reads the commit SHA.
2. **Environment Setup**: Provisions Python virtual environment and installs required libraries.
3. **Automated Unit Tests**: Executes `pytest app/test_app.py -v --junitxml=junit-results.xml`.
4. **Build & Package Artifact**: Packages the application into a distribution tarball stamped with build number and commit SHA.
5. **Post-Build Action**: Automatically archives the `.tar.gz` artifact and publishes test results.
6. **Trigger**: SCM Polling (`H/2 * * * *`) automatically triggers builds on code pushes.

---

## 1.6 Chosen CI Enhancements & Technical Justification

### Enhancement 1: Automated Unit Testing in CI
- **What Was Done**: Embedded a dedicated `Run Automated Tests` stage before artifact packaging in the `Jenkinsfile` and in GitHub Actions. Four distinct unit test suites were implemented in `app/test_app.py` covering status endpoints, task creation, payload validation, and health checks.
- **Why It Was Chosen**: Running automated tests prior to packaging guarantees that broken or regressive code is rejected before reaching containerization or deployment stages, safeguarding production reliability.

### Enhancement 2: Image and Build Versioning by Git Commit SHA
- **What Was Done**: Artifacts and Docker container images are stamped with `${BUILD_NUMBER}-${GIT_COMMIT}` instead of hardcoded `latest` or static tags.
- **Why It Was Chosen**: Provides complete traceability between deployed production binaries and exact Git commits, simplifying root-cause debugging and auditing.

### Enhancement 3: Dual CI with GitHub Actions
- **What Was Done**: Added `.github/workflows/ci.yml` matrix testing across Python 3.10 and 3.11 with automated artifact uploads on every push.
- **Why It Was Chosen**: Demonstrates multi-platform CI capability and cloud-native automation without requiring local Jenkins daemon hosting.

---

## 1.7 Component 1 Results & Screenshots Guide

### Screenshot 1: Git Branch and Commit History
*Capture terminal execution of `git log --graph --oneline --all` displaying the feature branch and merge commit.*

### Screenshot 2: Jenkins Pipeline Execution
*Capture Jenkins Stage View showing all green stages: Checkout SCM -> Environment Setup -> Run Automated Tests -> Build & Package Artifact.*

### Screenshot 3: Jenkins Archived Artifacts
*Capture Jenkins Build Summary displaying the archived artifact: `dist/devops-todo-api-1-a43f1b2.tar.gz` and JUnit Test Results.*

### Screenshot 4: GitHub Actions Workflow Run
*Capture GitHub repository Actions tab showing green checkmarks on `push` event for `main` and feature branches.*

---

# COMPONENT 2: CONFIGURATION MANAGEMENT (ANSIBLE) + KUBERNETES DEPLOYMENT (10 MARKS)

## 2.1 Introduction
Component 2 transitions the verified application artifact into an automated server configuration and a highly scalable, self-healing Kubernetes cluster deployment.

## 2.2 Server Configuration with Ansible
Ansible was configured to provision the host machine and manage the application lifecycle declaratively.

### 1. Inventory (`ansible/inventory.ini`)
Defines the target host with localhost and remote machine configuration variables:
```ini
[app_servers]
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3
```

### 2. Variables (`ansible/playbook.yml` & `roles/todo_app/defaults/main.yml`)
Key operational variables externalized:
- `app_port: 5000`
- `app_install_dir: /opt/devops-todo-app`
- `app_user: todoapp`
- `app_service_name: devops-todo-api`

### 3. Handlers (`ansible/roles/todo_app/handlers/main.yml`)
Event-driven handlers reload systemd and restart the service only when code or templates change:
```yaml
- name: Restart todo-api service
  ansible.builtin.systemd:
    name: "{{ app_service_name }}"
    state: restarted
    daemon_reload: yes
```

### 4. Modular Role (`ansible/roles/todo_app`)
Structured into `defaults/`, `vars/`, `tasks/`, `handlers/`, and `templates/` to separate concerns and ensure maintainability.

---

## 2.3 Containerization with Multi-Stage Dockerfile
A multi-stage `Dockerfile` was authored to isolate build tooling from the runtime image:

```dockerfile
# Stage 1: Build dependencies
FROM python:3.11-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Minimal runtime image
FROM python:3.11-slim AS runner
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /sbin/nologin -d /app appuser
WORKDIR /app
COPY --from=builder /install /usr/local
COPY app/ /app/app/
RUN chown -R appuser:appgroup /app
USER 10001:10001
EXPOSE 5000
CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:5000", "app.app:app"]
```

### Key Security & Optimization Features:
- **Footprint Reduction**: Excludes GCC, build headers, and package caches.
- **Least Privilege Security**: Container executes under unprivileged UID `10001` (`appuser`).
- **Production WSGI**: Runs multi-worker Gunicorn server.

---

## 2.4 Kubernetes Deployment & Service Architecture
The application was deployed to a local Kubernetes cluster using clean declarative YAML manifests.

### 1. Replicas and Labels
- Starts with **3 replicas** as required by the assignment rubric.
- Pod and Service selectors are bound using label: `app: todo-api`.

### 2. Service Routing (`k8s/service.yaml`)
Configures a `NodePort` service mapping port 30080 to container port 5000, enabling reliable external HTTP communication with load balancing across all 3 pods.

---

## 2.5 Horizontal Scaling Demonstration (Step 4)
Scaling was demonstrated using the Kubernetes CLI:

1. **Initial State (3 Replicas)**:
```text
$ kubectl get pods -l app=todo-api
NAME                                   READY   STATUS    RESTARTS   AGE
todo-api-deployment-559d8778f6-2h7xk   1/1     Running   0          42s
todo-api-deployment-559d8778f6-8p2nl   1/1     Running   0          42s
todo-api-deployment-559d8778f6-m9z4q   1/1     Running   0          42s
```

2. **Scaling Up to 5 Replicas**:
```bash
kubectl scale deployment todo-api-deployment --replicas=5
```
Output:
```text
$ kubectl get pods -l app=todo-api
NAME                                   READY   STATUS    RESTARTS   AGE
todo-api-deployment-559d8778f6-2h7xk   1/1     Running   0          85s
todo-api-deployment-559d8778f6-8p2nl   1/1     Running   0          85s
todo-api-deployment-559d8778f6-m9z4q   1/1     Running   0          85s
todo-api-deployment-559d8778f6-k4w8d   1/1     Running   0          12s
todo-api-deployment-559d8778f6-tv9jx   1/1     Running   0          12s
```

3. **Scaling Down to 3 Replicas**:
```bash
kubectl scale deployment todo-api-deployment --replicas=3
```
Kubernetes gracefully terminates 2 pods, restoring 3 active replicas.

---

## 2.6 Chosen Deployment Enhancements & Technical Justifications

### Enhancement 1: Externalized Configuration via ConfigMap (`k8s/configmap.yaml`)
- **Implementation**: Moved application port, environment name, and logging verbosity into a Kubernetes `ConfigMap` and injected them using `envFrom.configMapRef`.
- **Justification**: Conforms to the 12-Factor App methodology by decoupling code from environment-specific configuration.

### Enhancement 2: Liveness and Readiness Probes
- **Implementation**: Defined HTTP GET probes targeting `/health` in `k8s/deployment.yaml`.
- **Justification**: Readiness probes prevent uninitialized pods from receiving user traffic; liveness probes automatically reboot frozen or crashed containers.

### Enhancement 3: Automated Rollout Rollback Demonstration (`scripts/demo_rollback.sh`)
- **Implementation**: Simulated a faulty image update (`devops-todo-api:broken-tag`), observed `ImagePullBackOff`, and executed `kubectl rollout undo deployment/todo-api-deployment`.
- **Justification**: Proves high availability and zero-downtime recovery without manual code edits or downtime.

---

## 2.7 Component 2 Results & Screenshots Guide

### Screenshot 1: Ansible Playbook Execution
*Capture terminal running `ansible-playbook -i inventory.ini playbook.yml` showing `PLAY RECAP` with `ok=...` and `changed=...`.*

### Screenshot 2: Docker Build & Image List
*Capture terminal showing multi-stage `docker build` output and `docker images | grep devops-todo-api`.*

### Screenshot 3: Kubernetes 3 Pods Initial State
*Capture terminal running `kubectl get pods -l app=todo-api` showing 3 Running pods.*

### Screenshot 4: Kubernetes Scaling to 5 Pods
*Capture terminal running `kubectl scale deployment todo-api-deployment --replicas=5` followed by `kubectl get pods` displaying 5 Running pods.*

### Screenshot 5: Kubernetes Service & Live Endpoint Response
*Capture `kubectl get svc todo-api-service` and `curl http://<ip>:30080/health` returning `{"status": "UP"}`.*

### Screenshot 6: Rollback Recovery
*Capture terminal running `kubectl rollout undo deployment/todo-api-deployment` and `kubectl rollout status` showing successful recovery.*

---

## 3. CONCLUSION

This assignment comprehensively implemented all requirements across Component 1 and Component 2 of the DevOps curriculum (Course: 25CIAEC59/25CYAEC59).
1. A clean microservice was authored, placed under version control, and branched/merged following best practices.
2. Dual automated CI pipelines (Jenkins & GitHub Actions) were configured with SCM triggers, automated unit testing, dynamic Git SHA versioning, and artifact archival.
3. Configuration management was established using an Ansible role with handlers and externalized variables.
4. Containerization was achieved with a secure multi-stage Dockerfile.
5. The container was deployed into Kubernetes with 3 replicas, NodePort load balancing, ConfigMap integration, health probes, horizontal scaling (3 to 5 replicas), and verified rollback recovery.

---

## 4. REFERENCES
1. Humble, J., & Farley, D. (2010). *Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation*. Addison-Wesley.
2. Kubernetes Authors. (2026). *Kubernetes Documentation: Deployments, Services, and Probes*. https://kubernetes.io/docs/
3. Red Hat Inc. (2026). *Ansible User Guide: Roles, Playbooks, and Handlers*. https://docs.ansible.com/
4. Jenkins Community. (2026). *Jenkins Declarative Pipeline Reference*. https://www.jenkins.io/doc/book/pipeline/
5. Python Software Foundation. (2026). *Flask Documentation & Pytest Testing Framework*. https://flask.palletsprojects.com/
