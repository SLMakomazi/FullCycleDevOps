# FullCycleDevOps - Minimal DevOps Stack

## Overview

This repository contains a full DevOps observability stack for a Spring Boot API using MongoDB, Prometheus, Grafana, Jenkins, and ArgoCD.

It is designed for both local Docker Compose development and Kubernetes/GitOps deployment.

---

## Repository layout

```
FullCycleDevOps/
├── api/                    # Spring Boot application source, Docker build, local API compose
├── argocd/                 # ArgoCD app and project manifests
├── docker-compose.yml      # Root local compose stack for API, MongoDB, Prometheus, Grafana
├── grafana/                # Grafana dashboards and provisioning
├── jenkins/                # Jenkins pipeline, compose, and setup docs
├── k8s/                    # Kubernetes manifests with base and local overlay
└── prometheus/             # Prometheus config and alerting
```

---

## Folder and file documentation

### Root files

- `docker-compose.yml`
  - Local development stack for:
    - `api` on host `8085`
    - `mongodb` on host `27017`
    - `prometheus` on host `9090`
    - `grafana` on host `3000`
  - Includes Docker networks `monitoring` and `database`.
  - Configures `host.docker.internal` for Prometheus scraping from the host.

### `api/`
Contains the Spring Boot service source, build config, and local API compose.

- `Dockerfile`: builds the API image from the packaged JAR.
- `.dockerignore`: ignore rules for Docker builds.
- `.env`: local environment values for MongoDB and optional OpenTelemetry. Update this with your own secrets.
- `docker-compose.yml`: alternate local compose definition for API and MongoDB.
- `pom.xml`: Maven project definition.

#### `api/src/main/java/com/fullcycle/devops/`
- `DevOpsObservabilityApplication.java` — application entry point.
- `config/DotenvConfig.java` — environment loading helper.
- `controller/ItemController.java` — REST API controller.
- `dto/ItemRequest.java` / `ItemResponse.java` — API payloads.
- `exception/` — centralized exception handling.
- `model/Item.java` — MongoDB document model.
- `repository/ItemRepository.java` — Spring Data repository.
- `service/ItemService.java` — business service logic.

#### `api/src/main/resources/`
- `application.yml` — profile-aware application config (default, Docker, Kubernetes).
- `logback-spring.xml` — structured logging configuration.

#### `api/src/test/java/`
- `ItemControllerTest.java` — sample controller unit test.

#### `api/target/`
- Generated Maven build artifacts and compiled classes.
- This folder is produced by `mvn package` and is not intended for manual editing.

### `argocd/`
- `application.yaml` — ArgoCD `Application` pointing to `k8s/local-wsl`.
- `project.yaml` — ArgoCD `Project` configuration.

### `k8s/`
Kubernetes manifests organized into a reusable base and an overlay for local WSL.

#### `k8s/base/`
- `deployment.yaml` — API deployment with probes, resources, and env injection.
- `service.yaml` — NodePort service exposing the API on NodePort `30086`.
- `prometheus-service.yaml` — Prometheus service manifest.
- `secrets.yaml` — Kubernetes Secret for MongoDB.
- `kustomization.yaml` — base Kustomize manifest.

#### `k8s/local-wsl/`
- `kustomization.yaml` — local overlay for WSL/K3s deployment.
- `deployment-patch.yaml` — patch that injects local config values and exposes endpoints.

#### `k8s/README.md`
- Additional Kubernetes deployment and ArgoCD guidance.

### `prometheus/`
- `prometheus.yml` — static scrape configuration.
- `alertmanager.yml` — Alertmanager configuration.
- `alert_rules.yml` — Prometheus alert rules.

### `grafana/`
- `dashboards/` — JSON dashboards for observability.
- `provisioning/dashboards/dashboards.yml` — dashboard provisioning config.
- `provisioning/datasources/prometheus.yml` — Grafana Prometheus datasource.

### `jenkins/`
- `Jenkinsfile` — CI/CD pipeline for build, test, Docker push, and manifest updates.
- `jenkins-compose.yml` — Jenkins local compose definition.
- `JENKINS_SETUP.md` — Jenkins installation and configuration guide.
- `GITHUB_WEBHOOK_SETUP.md` — webhook setup instructions.

---

## Port and service mapping

| Service | Host Port | Access URL | Notes |
|---|---|---|---|
| API (Docker Compose) | `8085` | `http://localhost:8085` | Local dev API endpoint |
| MongoDB | `27017` | `mongodb://localhost:27017` | Local DB |
| Prometheus | `9090` | `http://localhost:9090` | Monitoring UI |
| Grafana | `3000` | `http://localhost:3000` | Dashboard UI |
| ArgoCD | `30085` | `https://localhost:30085` | GitOps UI |
| API NodePort | `30086` | `http://localhost:30086` | Kubernetes API service |

---

## Setup guide for a fresh clone

### Prerequisites

Install these tools first:
- Git
- Docker and Docker Compose
- Java 17 and Maven
- kubectl
- Kubernetes runtime such as MicroK8s, k3s, or Minikube

### 1) Clone the repo

```bash
git clone https://github.com/SLMakomazi/FullCycleDevOps.git
cd FullCycleDevOps
```

### 2) Start the root Docker Compose development stack

```bash
docker compose up -d
```

This starts:
- Spring Boot API (`api`)
- MongoDB
- Prometheus
- Grafana

### 3) Verify local services

- API: `http://localhost:8085`
- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`

### 4) Build the API from source

```bash
cd api
mvn clean package
```

### 5) Optional Kubernetes deployment

Deploy the local overlay to your cluster:

```bash
kubectl apply -k k8s/local-wsl
```

Then check:

```bash
kubectl get pods -n devops-observability
kubectl get svc -n devops-observability
```

### 6) Optional ArgoCD setup

If ArgoCD is not installed:

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/
```

Forward ArgoCD locally:

```bash
kubectl port-forward svc/argocd-server -n argocd --address 0.0.0.0 30085:443
```

Access ArgoCD at:
- `https://localhost:30085`

### 7) Configure Grafana and Prometheus

Grafana is pre-provisioned to use Prometheus with:
- `grafana/provisioning/datasources/prometheus.yml`
- `grafana/provisioning/dashboards/dashboards.yml`

Prometheus scrapes the Kubernetes API via:
- `host.docker.internal:30086` when using the K8s NodePort service.

---

## Recommended workflow

1. Edit code in `api/src/`.
2. Run unit tests with `mvn test`.
3. Build Docker image via `docker build` or root compose.
4. Deploy locally with Docker Compose, or to Kubernetes with Kustomize.
5. Use Grafana and Prometheus to validate metrics.

---

## Important notes

- `api/target/` contains generated Maven outputs; rebuild rather than editing these files.
- `k8s/base/service.yaml` exposes the API on NodePort `30086`.
- `argocd-server` uses NodePort `30085` and should remain separate from the API port.
- Update `api/.env` with your own MongoDB credentials and OpenTelemetry endpoint.
- The repository contains multiple manifest paths; `argocd/application.yaml` is configured to use `k8s/local-wsl`.

---

## Troubleshooting

- If Prometheus target is down, verify the API NodePort and app readiness.
- If ArgoCD is unreachable, confirm the port-forward is active and the service is exposed on `30085`.
- If Jenkins fails, inspect `jenkins/Jenkinsfile` and validate Docker Hub / GitHub credentials.

---

## Additional documentation

For Kubernetes-specific instructions, see `k8s/README.md`.
For Jenkins setup, see `jenkins/JENKINS_SETUP.md` and `jenkins/GITHUB_WEBHOOK_SETUP.md`.
