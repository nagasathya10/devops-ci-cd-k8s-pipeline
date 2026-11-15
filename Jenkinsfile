pipeline {
    agent any

    triggers {
        // Poll SCM every 2 minutes for changes (satisfies requirement for automated build trigger)
        pollSCM('H/2 * * * *')
    }

    environment {
        APP_NAME = 'devops-todo-api'
        // Dynamic build versioning using Jenkins build number and Git commit SHA (CI Enhancement)
        BUILD_VERSION = "${env.BUILD_NUMBER}-${GIT_COMMIT ? GIT_COMMIT.take(7) : 'manual'}"
        PORT = '5000'
    }

    options {
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        ansiColor('xterm')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo "Fetching source code from Git repository..."
                checkout scm
                echo "Branch: ${env.GIT_BRANCH ?: 'main'}"
                echo "Commit SHA: ${env.GIT_COMMIT ?: 'HEAD'}"
            }
        }

        stage('Environment Setup') {
            steps {
                echo "Setting up Python virtual environment and dependencies..."
                sh '''
                    python3 -m venv .venv
                    . .venv/bin/activate
                    pip install --upgrade pip
                    pip install -r requirements.txt
                '''
            }
        }

        stage('Run Automated Tests') {
            // CI Enhancement: Automated test stage running pytest before build stage
            steps {
                echo "Running unit tests with pytest and generating JUnit report..."
                sh '''
                    . .venv/bin/activate
                    python3 -m pytest app/test_app.py -v --junitxml=junit-results.xml
                '''
            }
        }

        stage('Build & Package Artifact') {
            steps {
                echo "Compiling and packaging application artifact version: ${BUILD_VERSION}..."
                sh """
                    mkdir -p dist
                    tar --exclude='__pycache__' -czvf dist/${APP_NAME}-${BUILD_VERSION}.tar.gz app requirements.txt Dockerfile
                    echo "Build successful: dist/${APP_NAME}-${BUILD_VERSION}.tar.gz"
                """
            }
        }

        stage('Container Image Build & Tag') {
            // Additional CI Enhancement: Versioned Docker image tagging
            steps {
                echo "Building Docker container image tagged with version ${BUILD_VERSION}..."
                sh """
                    if command -v docker &> /dev/null; then
                        docker build -t ${APP_NAME}:${BUILD_VERSION} -t ${APP_NAME}:latest .
                        echo "Docker image built: ${APP_NAME}:${BUILD_VERSION}"
                    else
                        echo "Docker daemon not running on agent host; skipping container packaging."
                    fi
                """
            }
        }
    }

    post {
        always {
            // Publish JUnit Test Results
            junit testResults: 'junit-results.xml', allowEmptyResults: true
        }
        success {
            echo "CI Pipeline executed successfully!"
            // Post-build action: Archive the build artifact
            archiveArtifacts artifacts: 'dist/*.tar.gz', fingerprint: true, allowEmptyArchive: false
        }
        failure {
            echo "CI Pipeline failed! Inspect logs above to identify errors."
        }
        cleanup {
            cleanWs deleteDirs: true, notFailBuild: true
        }
    }
}
