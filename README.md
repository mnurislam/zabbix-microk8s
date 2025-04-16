# Zabbix on MicroK8s with Custom Alpine Image

This repository contains everything needed to build, package, and deploy Zabbix Server using a custom-built Docker image based on Alpine Linux, complete with frontend and MariaDB, all orchestrated via MicroK8s (lightweight Kubernetes).

---

## Features
- Multi-stage Docker build of Zabbix 6.0.39 from source
- Lightweight Alpine-based image (~91MB)
- Automated DB schema import via Kubernetes initContainer
- Fully self-contained deployment using Kubernetes YAML
- Compatible with MicroK8s or any K8s distribution

---

## Repository Structure

```
.
├── Dockerfile                        # Multi-stage build to compile Zabbix from source
├── init-zabbix-db.sh                # Schema import logic used by init container
├── zabbix.yaml                      # Full Kubernetes deployment (server, frontend, mariadb)
├── .dockerignore
├── README.md                        # This file
└── notes/
    └── deployment-notes.md          # Deep-dive: build issues and fixes (learning path)
```

---

## Usage

### 1. Build & Push Docker Image
```bash
docker build -t your_dockerhub_username/zabbix-alpine-custom:1.0.2 .
docker push your_dockerhub_username/zabbix-alpine-custom:1.0.2
```

Update the `image:` field in `zabbix.yaml` if needed.

---

### 2. Create Kubernetes Secret for DockerHub Access
```bash
microk8s kubectl create secret docker-registry regcred \
  --docker-username=your_dockerhub_username \
  --docker-password=your_dockerhub_password \
  --docker-email=your_email@example.com \
  --namespace=zabbix
```

---

### 3. Deploy to MicroK8s
```bash
microk8s kubectl apply -f zabbix.yaml
```

Wait for pods to become ready:
```bash
microk8s kubectl get pods -n zabbix
```

Access the Zabbix frontend at:
```
http://<your-node-ip>:30080
```

---

## Default Credentials
| Component     | Username | Password    |
|---------------|----------|-------------|
| MariaDB       | zabbix   | zabbixpass  |
| MariaDB Root  | root     | rootpass    |
| Zabbix Web UI | Admin    | zabbix      |

> **Note:** Adjust credentials as needed for production.

---

## Resources
- [Zabbix Documentation](https://www.zabbix.com/documentation/current/en/manual)
- [MicroK8s Documentation](https://microk8s.io/docs)

---

## Author
**khublai** — _Built from scratch to learn, automate, and optimize Zabbix on K8s._

Feel free to open issues or submit PRs if you'd like to contribute or extend this setup!

