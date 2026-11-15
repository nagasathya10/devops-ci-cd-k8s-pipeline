# ==============================================================================
# Multi-Stage Dockerfile for DevOps Task Management REST API
# (Deployment Enhancement: Multi-Stage Build for minimal attack surface & size)
# ==============================================================================

# ----------------- Stage 1: Build & Dependency Resolution ---------------------
FROM python:3.11-slim AS builder

WORKDIR /build

# Install build-essential if C extensions are required
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Install dependencies into an isolated directory
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ----------------- Stage 2: Final Minimal Runtime Image -----------------------
FROM python:3.11-slim AS runner

# Create a non-privileged user and group for security
RUN groupadd -g 10001 appgroup && \
    useradd -u 10001 -g appgroup -s /sbin/nologin -d /app appuser

WORKDIR /app

# Copy only the installed dependencies from the builder stage
COPY --from=builder /install /usr/local

# Copy application source code
COPY app/ /app/app/

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

# Default environment configuration (can be overridden by Kubernetes ConfigMap)
ENV PORT=5000 \
    HOST=0.0.0.0 \
    ENVIRONMENT=production \
    PYTHONUNBUFFERED=1

# Expose API application port
EXPOSE 5000

# Switch to non-root user
USER 10001:10001

# Docker Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Start production WSGI server (Gunicorn)
CMD ["gunicorn", "--workers", "2", "--bind", "0.0.0.0:5000", "app.app:app"]
