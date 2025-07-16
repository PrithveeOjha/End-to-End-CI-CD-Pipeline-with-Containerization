Containerized Flask App CI/CD with GitHub Actions & Minikube
This document provides a comprehensive, step-by-step guide to setting up an End-to-End Continuous Integration/Continuous Delivery (CI/CD) pipeline for a simple Python Flask web application. The pipeline leverages GitHub for version control, Docker for containerization, GitHub Actions for automation, and a local Minikube cluster for deployment. This documentation also includes a detailed log of troubleshooting steps encountered and their resolutions, making it a practical guide for beginners.

1. Introduction to CI/CD and Containerization
Before diving into the technical steps, let's briefly understand the core concepts:

CI/CD (Continuous Integration/Continuous Delivery): This is an automated approach to software development that focuses on frequently integrating code changes, automatically testing them, and reliably delivering them to a deployment environment. It helps teams release software faster and with higher quality.

Continuous Integration (CI): Developers frequently merge code changes into a central repository. Automated builds and tests are run to detect integration issues early.

Continuous Delivery (CD): After CI, code changes are automatically prepared for release to a production-like environment. This means the application is always in a deployable state.

Containerization (with Docker): This technology packages an application and all its dependencies (code, runtime, system tools, libraries, settings) into a single, isolated unit called a container.

Docker: The most popular platform for building, shipping, and running containers.

Docker Image: A lightweight, standalone, executable package of software that includes everything needed to run an application.

Docker Container: A runnable instance of a Docker image. Containers ensure consistency across different environments.

Minikube: A tool that runs a single-node Kubernetes cluster on your local machine. It's excellent for learning and developing with Kubernetes without needing a full-blown cloud cluster.

Kubernetes (K8s): An open-source system for automating deployment, scaling, and management of containerized applications.

2. Project Overview: "Hello World" Flask Application
Our project involves a simple "Hello World" web application built with Python and Flask. The goal is to automate the following process:

Code changes are pushed to GitHub.

GitHub Actions automatically builds a Docker image of the application.

The Docker image is pushed to Docker Hub.

The application is deployed to a local Minikube Kubernetes cluster.

3. Detailed Step-by-Step Implementation
Part 1: Local Development Environment Setup
Step 1.1: Set up Version Control (Git & GitHub)
Install Git: Download and install Git from https://git-scm.com/downloads.

Create a GitHub Account: Sign up for a free account at https://github.com/.

Create a New GitHub Repository:

Log in to GitHub.

Click the "+" sign (top right) -> "New repository."

Repository Name: my-flask-app

Choose "Public" or "Private."

Check "Add a README file" to initialize the repository.

Click "Create repository."

Clone the Repository Locally:

On your GitHub repo page, click "Code" -> copy the HTTPS URL.

Open your terminal/command prompt.

Navigate to your desired projects directory: cd C:\Users\YourUser\Documents\Projects (Windows example).

Clone the repository: git clone <copied_github_url> (e.g., git clone https://github.com/your-username/my-flask-app.git).

Change into the project directory: cd my-flask-app.

Step 1.2: Create a Simple Flask Web Application
Install Python: Download and install Python 3.10+ from https://www.python.org/downloads/. Ensure "Add Python to PATH" is checked during Windows installation.

Create a Virtual Environment: (Inside your my-flask-app directory)

python -m venv venv

.\venv\Scripts\activate (for Windows Command Prompt/PowerShell)

Troubleshooting Note: If you see "Chocolatey detected you are not running from an elevated command shell", open your terminal "Run as administrator".

Install Flask:

pip install Flask

Create app.py: Create a file named app.py in your my-flask-app directory with the following content:

from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello, World! This is version 1.0!"

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True, host='0.0.0.0', port=port)

Generate requirements.txt:

pip freeze > requirements.txt

Commit and Push Initial Code:

git add .

git commit -m "Initial Flask app"

git push origin main

Step 1.3: Create a Dockerfile
Create Dockerfile: In your my-flask-app directory, create a file named Dockerfile (no extension) with:

# Use a lightweight official Python runtime as a parent image
FROM python:3.10-slim-buster # Updated to 3.10 to match click dependency

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code into the container at /app
COPY . .

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable (optional, for demonstration)
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]

Commit and Push Dockerfile:

git add Dockerfile

git commit -m "Add Dockerfile"

git push origin main

Step 1.4: Install Docker Desktop & Create Docker Hub Account
Install Docker Desktop: Download and install from https://www.docker.com/products/docker-desktop/. Ensure it's running.

Create Docker Hub Account: Sign up at https://hub.docker.com/.

Part 2: GitHub Actions CI/CD Pipeline Configuration
Step 2.1: Configure GitHub Actions Workflow (ci-cd.yml)
Create Workflow Directory: In your my-flask-app directory, create .github/workflows/.

Create ci-cd.yml: Inside .github/workflows/, create ci-cd.yml with the following content:

name: CI/CD Pipeline for Kubernetes (Conceptual Deployment)

on:
  push:
    branches:
      - main # Or 'master', depending on your default branch

env:
  DOCKER_USERNAME: your-dockerhub-username # <-- IMPORTANT: Replace with your actual Docker Hub username!
  IMAGE_NAME: my-flask-app

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.10' # Aligned with Dockerfile and requirements

    - name: Install Python dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt

    - name: Run Unit/Integration Tests (Placeholder)
      run: echo "Running tests..."

    - name: Log in to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }} # Uses Docker Hub Access Token

    - name: Build and push Docker image to Docker Hub
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ env.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
        # Also tag as 'latest' for convenience
        tags: |
          ${{ env.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
          ${{ env.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:latest

    # --- Kubernetes Deployment Steps (Conceptual for a remote cluster) ---
    # This section demonstrates how you would interact with a Kubernetes cluster
    # from GitHub Actions. For a *local Minikube*, these steps would run on your machine
    # *after* you manually pull the image from Docker Hub.
    - name: Set up Kubectl on the runner
      uses: azure/setup-kubectl@v3 # Corrected action
      with:
        version: 'v1.28.0' # Specify a stable version

    - name: Configure Kubeconfig for a remote cluster (Placeholder)
      run: |
        echo "This step would configure kubectl to connect to a remote Kubernetes cluster."
        echo "For a local Minikube, this is a manual step on your machine."
        # Example for a real cluster (requires KUBE_CONFIG_DATA secret):
        # mkdir -p ~/.kube
        # echo "${{ secrets.KUBE_CONFIG_DATA }}" | base64 -d > ~/.kube/config
        # chmod 600 ~/.kube/config

    - name: Apply Kubernetes manifests to the cluster (Placeholder)
      run: |
        echo "kubectl apply -f deployment.yaml"
        echo "kubectl apply -f service.yaml"
        echo "This would deploy the application to the configured Kubernetes cluster."
        # These commands would run if a remote cluster was configured:
        # kubectl apply -f deployment.yaml
        # kubectl apply -f service.yaml
        # kubectl rollout status deployment/${{ env.IMAGE_NAME }}-deployment

Set up GitHub Secrets:

Go to your GitHub repository -> Settings -> "Secrets and variables" -> "Actions".

Click "New repository secret".

DOCKER_USERNAME: Your Docker Hub username (e.g., prithv33).

DOCKER_PASSWORD: Your Docker Hub Access Token (generated from Docker Hub Account Settings -> Security -> New Access Token. Only copy the alphanumeric string, not dckr_pat_).

Troubleshooting Note: If "denied: requested access to the resource is denied" error persists, regenerate the token with "Read & Write" permissions and ensure no expiry, then update the secret. Double-check username case sensitivity.

Commit and Push Workflow:

git add .github/workflows/ci-cd.yml

git commit -m "Add GitHub Actions CI/CD workflow"

git push origin main

Part 3: Local Kubernetes (Minikube) Deployment
Step 3.1: Install Minikube and Kubectl
Install Hypervisor: Ensure Docker Desktop is installed and running (it includes a Docker driver for Minikube).

Install Minikube:

Open Command Prompt / PowerShell as Administrator.

choco install minikube (Windows with Chocolatey)

Install Kubectl:

Open Command Prompt / PowerShell as Administrator.

choco install kubernetes-cli (Windows with Chocolatey)

Troubleshooting Note: If you get "Chocolatey detected you are not running from an elevated command shell", ensure your terminal is opened "Run as administrator".

Step 3.2: Start Minikube and Configure Docker Environment
Start Minikube:

Open Command Prompt / PowerShell as Administrator.

minikube start --driver=docker

Troubleshooting Note: If "Error during connect: ... The system cannot find the file specified" occurs, ensure Docker Desktop is fully running and WSL 2 is enabled/integrated in Docker Desktop settings. Restart Docker Desktop and your terminal.

Troubleshooting Note: If "! Failing to connect to https://registry.k8s.io/" warning appears:

Initial Fix Attempt: Restart Docker Desktop and Minikube (minikube stop then minikube start).

DNS Configuration (Crucial): In Docker Desktop Settings -> Resources -> Network, change "DNS filtering behavior" from "Auto (recommended)" to "No filtering". Click "Apply & restart". Then minikube stop and minikube start again.

Last Resort (if still failing): minikube delete --all then minikube start --driver=docker. This provides a clean slate.

Configure Docker Environment for Minikube:

For PowerShell: minikube docker-env | Invoke-Expression

For Command Prompt (CMD): @FOR /f "tokens=*" %i IN ('minikube docker-env') DO @%i

This command ensures your local docker commands interact with the Docker daemon inside the Minikube VM.

Step 3.3: Create Kubernetes Deployment and Service YAML Files
Create deployment.yaml: In your my-flask-app directory, create deployment.yaml:

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-flask-app-deployment
  labels:
    app: my-flask-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-flask-app
  template:
    metadata:
      labels:
        app: my-flask-app
    spec:
      containers:
      - name: my-flask-app-container
        image: your-dockerhub-username/my-flask-app:latest # IMPORTANT: Replace with your Docker Hub username
        imagePullPolicy: Always # Ensure it pulls from registry if needed
        ports:
        - containerPort: 5000

Create service.yaml: In your my-flask-app directory, create service.yaml:

apiVersion: v1
kind: Service
metadata:
  name: my-flask-app-service
spec:
  selector:
    app: my-flask-app
  type: NodePort # Exposes the service on a port on each node (Minikube VM)
  ports:
  - protocol: TCP
    port: 80 # Service port
    targetPort: 5000 # Container port

Commit and Push YAMLs:

git add deployment.yaml service.yaml

git commit -m "Add Kubernetes deployment and service YAMLs"

git push origin main

Step 3.4: Deploy to Minikube
Ensure Minikube is running and docker-env is active.

Pull the Docker image locally to Minikube's daemon:

docker pull your-dockerhub-username/my-flask-app:latest

Troubleshooting Note: If "manifest not found" error occurs, verify your GitHub Actions workflow successfully pushed the image to Docker Hub. Check workflow logs and Docker Hub repository directly. Ensure docker login was successful on your local machine if the repo is private.

Apply Kubernetes Manifests:

kubectl apply -f deployment.yaml

Troubleshooting Note: If "error validating deployment.yaml: ... connect: connection refused" occurs, ensure Minikube is running and kubectl config use-context minikube has been run. Verify connectivity with kubectl cluster-info.

kubectl apply -f service.yaml

Step 3.5: Access Your Application
Get Service URL:

minikube service my-flask-app-service --url

Open the provided URL in your web browser. You should see "Hello, World! This is version 1.0!".

4. End-to-End Pipeline Test
To test the full CI/CD pipeline:

Modify app.py locally: Change the message to "Hello, World! This is version 2.0!".

Commit and Push to GitHub:

git add app.py

git commit -m "Update to v2.0"

git push origin main

Monitor GitHub Actions: Observe the workflow run in your GitHub repository's "Actions" tab. It will build and push the new image.

Manually Pull and Apply on Minikube: Since GitHub Actions cannot directly deploy to your local Minikube, you will perform these steps on your local machine:

docker pull your-dockerhub-username/my-flask-app:latest

kubectl apply -f deployment.yaml (This will trigger a rolling update in Kubernetes, pulling the new latest image).

Verify New Version: Refresh your browser at the minikube service URL. You should now see "Hello, World! This is version 2.0!".

5. Troubleshooting Log
This section summarizes the common errors encountered during this setup and their resolutions:

Error: Chocolatey detected you are not running from an elevated command shell

Resolution: Always open Command Prompt or PowerShell with "Run as administrator."

Error: ERROR: No matching distribution found for click==8.2.1 (during pip install in Docker build or GitHub Actions)

Resolution: This indicates a Python version mismatch. click==8.2.1 requires Python 3.10+.

Fix: Update FROM python:3.9-slim-buster to FROM python:3.10-slim-buster in your Dockerfile.

Fix: Update python-version: '3.9' to python-version: '3.10' in your .github/workflows/ci-cd.yml.

Error: denied: requested access to the resource is denied (during docker push in GitHub Actions)

Resolution: This is an authentication failure with Docker Hub.

Fix: Go to Docker Hub Account Settings -> Security -> Access Tokens. Generate a brand new Access Token with "Read & Write" permissions. Copy the alphanumeric string (without dckr_pat_).

Fix: Go to GitHub Repository Settings -> Secrets and variables -> Actions. Update the DOCKER_PASSWORD secret with the new token. Ensure DOCKER_USERNAME is also correct and case-sensitive.

Error: Unable to resolve action kubectl-action/setup@v2, action not found (in GitHub Actions)

Resolution: The action name was incorrect.

Fix: Change uses: kubectl-action/setup@v2 to uses: azure/setup-kubectl@v3 in your .github/workflows/ci-cd.yml.

Error: Error response from daemon: manifest for prithv33/my-flask-app:latest not found: manifest unknown (during docker pull on local machine)

Resolution: The image was not found in the Docker Hub registry.

Fix: Verify that the GitHub Actions workflow successfully pushed the image to Docker Hub (check workflow logs).

Fix: Ensure your docker pull command uses the correct image name, tag, and Docker Hub username.

Fix: If the Docker Hub repository is private, ensure you've performed docker login on your local machine using your Docker Hub username and Access Token.

Error: error validating "deployment.yaml": ... connect: connection refused (during kubectl apply)

Resolution: kubectl cannot connect to the Minikube cluster's API server.

Fix: Ensure Minikube is running (minikube start).

Fix: Ensure kubectl config use-context minikube has been run. Verify connectivity with kubectl cluster-info.

Warning: ! Failing to connect to https://registry.k8s.io/ from inside the minikube container (during minikube start)

Resolution: Minikube's internal Docker container has network connectivity issues, likely DNS related.

Fix: Restart Docker Desktop. Then minikube stop followed by minikube start --driver=docker.

Fix (Crucial): In Docker Desktop Settings -> Resources -> Network, change "DNS filtering behavior" from "Auto (recommended)" to "No filtering". Click "Apply & restart". Then minikube stop and minikube start again.

Fix (Last Resort): minikube delete --all then minikube start --driver=docker for a complete reset.

Error: Error: unknown flag: --dns-ip (during minikube start)

Resolution: These flags are deprecated in newer Minikube versions.

Fix: Remove --dns-ip and --dns-proxy=false from your minikube start command. Rely on Docker Desktop's DNS settings and other troubleshooting steps.

6. Conclusion and Further Exploration
You have successfully set up a CI/CD pipeline that automates the build and push of your Flask application's Docker image using GitHub Actions, and you can deploy it to a local Minikube Kubernetes cluster. This project provides a solid foundation for understanding modern software delivery practices.

Next Steps to Enhance Your Knowledge:

Automate Minikube Deployment: For a truly automated local CI/CD, you could explore tools like Tilt or Skaffold that monitor your local code changes and automatically rebuild/redeploy to Minikube.

Cloud Deployment: Transition your Kubernetes deployment from Minikube to a cloud-managed Kubernetes service like AWS EKS, Google Kubernetes Engine (GKE), or Azure Kubernetes Service (AKS). This would involve configuring cloud-specific GitHub Actions for authentication and deployment.

Advanced Kubernetes Concepts: Learn about Ingress controllers, Helm charts, Horizontal Pod Autoscaling, Persistent Volumes, and more.

Add More Tests: Implement unit, integration, and end-to-end tests for your Flask application and integrate them into your CI pipeline before the Docker image build.

Monitoring and Logging: Set up monitoring (e.g., Prometheus, Grafana) and centralized logging (e.g., ELK stack) for your deployed application.

Security Best Practices: Deepen your understanding of container security, image scanning, and Kubernetes security policies.
