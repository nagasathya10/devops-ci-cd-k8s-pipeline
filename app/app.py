import os
import time
from datetime import datetime
from flask import Flask, jsonify, request

app = Flask(__name__)

# Start time for calculating uptime
START_TIME = time.time()
REQUEST_COUNT = 0

# In-memory storage for tasks/todos
todos = [
    {
        "id": 1,
        "title": "Set up CI/CD Pipeline",
        "description": "Configure Jenkins and GitHub Actions for automated build and test",
        "completed": True,
        "created_at": "2026-11-13T10:00:00Z"
    },
    {
        "id": 2,
        "title": "Deploy to Kubernetes",
        "description": "Deploy containerized app on Kubernetes with 3 replicas and scaling",
        "completed": False,
        "created_at": "2026-11-13T11:00:00Z"
    }
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
        "environment": os.getenv("ENVIRONMENT", "production"),
        "status": "healthy",
        "endpoints": {
            "root": "GET /",
            "list_todos": "GET /todos",
            "create_todo": "POST /todos",
            "get_todo_by_id": "GET /todos/<id>",
            "health_check": "GET /health",
            "service_metrics": "GET /metrics"
        }
    }), 200

@app.route("/todos", methods=["GET"])
def get_todos():
    return jsonify({
        "success": True,
        "count": len(todos),
        "data": todos
    }), 200

@app.route("/todos/<int:todo_id>", methods=["GET"])
def get_todo(todo_id):
    todo = next((item for item in todos if item["id"] == todo_id), None)
    if todo is None:
        return jsonify({
            "success": False,
            "error": f"Todo with id {todo_id} not found"
        }), 404
    return jsonify({
        "success": True,
        "data": todo
    }), 200

@app.route("/todos", methods=["POST"])
def create_todo():
    if not request.is_json:
        return jsonify({
            "success": False,
            "error": "Request body must be valid JSON"
        }), 400

    payload = request.get_json()
    title = payload.get("title")
    if not title or not isinstance(title, str) or not title.strip():
        return jsonify({
            "success": False,
            "error": "'title' field is required and must be a non-empty string"
        }), 400

    new_id = max([t["id"] for t in todos], default=0) + 1
    new_todo = {
        "id": new_id,
        "title": title.strip(),
        "description": payload.get("description", "").strip(),
        "completed": bool(payload.get("completed", False)),
        "created_at": datetime.utcnow().isoformat() + "Z"
    }
    todos.append(new_todo)
    return jsonify({
        "success": True,
        "message": "Todo created successfully",
        "data": new_todo
    }), 201

@app.route("/health", methods=["GET"])
def health():
    uptime_seconds = int(time.time() - START_TIME)
    return jsonify({
        "status": "UP",
        "uptime_seconds": uptime_seconds,
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "active_tasks": len(todos)
    }), 200

@app.route("/metrics", methods=["GET"])
def metrics():
    uptime_seconds = int(time.time() - START_TIME)
    return jsonify({
        "total_requests": REQUEST_COUNT,
        "uptime_seconds": uptime_seconds,
        "todo_count": len(todos),
        "completed_todos": len([t for t in todos if t["completed"]]),
        "pending_todos": len([t for t in todos if not t["completed"]])
    }), 200

if __name__ == "__main__":
    port = int(os.getenv("PORT", 5000))
    host = os.getenv("HOST", "0.0.0.0")
    print(f"Starting DevOps Todo API on {host}:{port}...")
    app.run(host=host, port=port, debug=False)
