import pytest
from app.app import app

@pytest.fixture
def client():
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client

def test_root_endpoint(client):
    """Test the root '/' endpoint returns metadata and 200 status."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
    assert "endpoints" in data

def test_get_todos(client):
    """Test GET /todos returns a list of tasks."""
    response = client.get("/todos")
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True
    assert isinstance(data["data"], list)
    assert len(data["data"]) >= 2

def test_create_todo_success(client):
    """Test POST /todos creates a new task and returns 201."""
    new_task = {
        "title": "Configure Ansible Playbook",
        "description": "Write role and handlers for server provisioning",
        "completed": False
    }
    response = client.post("/todos", json=new_task)
    assert response.status_code == 201
    data = response.get_json()
    assert data["success"] is True
    assert data["data"]["title"] == "Configure Ansible Playbook"
    assert "id" in data["data"]

def test_create_todo_missing_title(client):
    """Test POST /todos fails with 400 when title is missing."""
    invalid_task = {
        "description": "Missing title test"
    }
    response = client.post("/todos", json=invalid_task)
    assert response.status_code == 400
    data = response.get_json()
    assert data["success"] is False
    assert "'title' field is required" in data["error"]

def test_get_todo_by_id_success(client):
    """Test GET /todos/<id> returns the task details."""
    response = client.get("/todos/1")
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True
    assert data["data"]["id"] == 1

def test_get_todo_by_id_not_found(client):
    """Test GET /todos/<id> returns 404 for non-existent ID."""
    response = client.get("/todos/9999")
    assert response.status_code == 404
    data = response.get_json()
    assert data["success"] is False

def test_health_check_endpoint(client):
    """Test GET /health returns UP status for Kubernetes probes."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "UP"
    assert "uptime_seconds" in data

def test_metrics_endpoint(client):
    """Test GET /metrics returns service operational statistics."""
    response = client.get("/metrics")
    assert response.status_code == 200
    data = response.get_json()
    assert "total_requests" in data
    assert "todo_count" in data
