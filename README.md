# TP CI/CD — Go Microservice with ArgoCD Image Updater

A simple Go HTTP microservice with a full CI/CD pipeline using GitHub Actions and ArgoCD Image Updater (Approach 3).

## Prerequisites

- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)
- [argocd CLI](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

## Setup

### 1. Start minikube

```bash
minikube start
```

### 2. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=available --timeout=120s deployment/argocd-server -n argocd

# Get the initial admin password
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

### 3. Install ArgoCD Image Updater

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
```

### 4. Set up ghcr.io pull secret

Replace `GITHUB_USERNAME` and `GITHUB_TOKEN` with your actual values:

```bash
kubectl create namespace tp-cicd

kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=GITHUB_USERNAME \
  --docker-password=GITHUB_TOKEN \
  --namespace=tp-cicd

# Also create it in argocd namespace for Image Updater
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=GITHUB_USERNAME \
  --docker-password=GITHUB_TOKEN \
  --namespace=argocd
```

### 5. Replace placeholder and apply ArgoCD Application

Edit `argocd/application.yaml` and replace all occurrences of `GITHUB_USERNAME` with your actual GitHub username. Also update `helm/values.yaml` accordingly.

```bash
kubectl apply -f argocd/application.yaml
```

### 6. Access ArgoCD UI (optional)

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open https://localhost:8080 in your browser
# Login: admin / <password from step 2>
```

## How it works

1. Push code to `main` → GitHub Actions runs lint, security scan, and Helm validation.
2. On success, the pipeline bumps the semver tag, builds the Docker image, and pushes it to `ghcr.io`.
3. ArgoCD Image Updater detects the new semver tag and updates `helm/values.yaml` via a Git commit.
4. ArgoCD detects the Git change and syncs the Kubernetes deployment automatically.

## Local development

```bash
go run main.go
curl http://localhost:8080/
curl http://localhost:8080/healthz
```
