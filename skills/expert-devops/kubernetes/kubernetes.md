---
name: kubernetes
description: >
  Kubernetes cluster management including pods, deployments, services, ingress,
  ConfigMaps, Secrets, kubectl operations, resource limits, and rolling updates.
  Use when deploying to Kubernetes, writing manifests, or troubleshooting cluster workloads.
version: "1.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "kubernetes"
  - "k8s"
  - "kubectl"
  - "deployment"
  - "pod"
  - "service"
  - "ingress"
  - "configmap"
intent: >
  Provide practical Kubernetes patterns for deploying applications, managing workloads,
  configuring networking, and operating clusters with confidence.
scenarios:
  - "Deploying a stateless web application with rolling updates and health probes"
  - "Exposing a service via Ingress with TLS termination"
  - "Debugging a CrashLoopBackOff by inspecting pod events and logs"
best_for: "K8s manifests, deployments, services, ConfigMaps, health probes, kubectl operations, rolling updates"
estimated_time: "20-40 min"
anti_patterns:
  - "Running single-replica deployments without pod disruption budgets in production"
  - "Storing secrets in ConfigMaps or environment variables in manifests"
  - "Setting CPU/memory limits too low causing OOMKills or throttling"
  - "Using latest tag for container images in production"
related_skills: ["docker", "docker-compose", "terraform"]
---

# Kubernetes

## Overview

Kubernetes orchestrates containerized workloads across clusters. It handles deployment, scaling, networking, self-healing, and configuration management. This skill covers the core resource types and operational patterns needed to deploy and manage applications on Kubernetes.

## When to Use

- Deploying applications to a Kubernetes cluster (any provider)
- Writing Deployment, Service, Ingress, ConfigMap, and Secret manifests
- Configuring health probes, resource limits, and rolling update strategies
- Debugging pod failures, networking issues, or scheduling problems
- Setting up local development clusters (minikube, kind, k3d)

## When NOT to Use

- Simple single-container deployments (Docker or docker-compose suffice)
- Infrastructure provisioning (use Terraform)
- Configuration management on bare VMs (use Ansible)

## Process

### 1. Write Manifests

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
  labels:
    app: myapp
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: myregistry/myapp:1.0.0
          ports:
            - containerPort: 8080
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: myapp-secrets
                  key: database-url
            - name: LOG_LEVEL
              valueFrom:
                configMapKeyRef:
                  name: myapp-config
                  key: log-level
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 256Mi
          livenessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 15
          readinessProbe:
            httpGet:
              path: /ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
```

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
    - port: 80
      targetPort: 8080
  type: ClusterIP
```

```yaml
# ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: myapp
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - myapp.example.com
      secretName: myapp-tls
  rules:
    - host: myapp.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: myapp
                port:
                  number: 80
```

### 2. Configuration with ConfigMaps and Secrets

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  log-level: "info"
  feature-flags: |
    darkMode: true
    betaFeatures: false
```

```yaml
# secret.yaml (use external-secrets or sealed-secrets in production)
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
type: Opaque
stringData:
  database-url: "postgres://user:pass@db:5432/mydb"
```

### 3. Essential kubectl Commands

| Command | Purpose |
|---------|---------|
| `kubectl apply -f manifest.yaml` | Create or update resources |
| `kubectl get pods -w` | Watch pod status in real time |
| `kubectl describe pod <name>` | Inspect pod details and events |
| `kubectl logs <pod> -f` | Stream container logs |
| `kubectl logs <pod> --previous` | Logs from previous crashed container |
| `kubectl exec -it <pod> -- sh` | Shell into a running pod |
| `kubectl rollout status deploy/<name>` | Watch rollout progress |
| `kubectl rollout undo deploy/<name>` | Roll back to previous revision |
| `kubectl scale deploy/<name> --replicas=5` | Scale replicas |
| `kubectl get events --sort-by=.metadata.creationTimestamp` | View cluster events |

### 4. Local Development

```bash
# minikube
minikube start --cpus=4 --memory=8192
eval $(minikube docker-env)   # Use minikube's Docker daemon

# kind
kind create cluster --config kind-config.yaml

# k3d
k3d cluster create mycluster --agents 2
```

## Best Practices

### Resource Management
- Always set `requests` AND `limits` for CPU and memory
- Set requests to actual usage (measure with metrics-server), limits to 2-4x requests
- Use LimitRanges and ResourceQuotas at namespace level for governance

### Health Probes
- Configure `livenessProbe` (restart on failure) and `readinessProbe` (remove from service on failure)
- Set `initialDelaySeconds` to account for startup time
- Use startup probes for slow-starting applications

### Security
- Use Secrets (not ConfigMaps) for sensitive data; prefer external-secrets-operator in production
- Apply RBAC with least-privilege principles
- Use NetworkPolicies to restrict pod-to-pod traffic
- Run as non-root with `securityContext: runAsNonRoot: true`

### Reliability
- Use rolling update strategy with `maxUnavailable: 0` for zero-downtime deployments
- Create PodDisruptionBudgets for multi-replica deployments
- Pin image tags to specific versions, never use `:latest`

## Troubleshooting

| Symptom | Diagnostic Command | Common Cause |
|---------|-------------------|--------------|
| CrashLoopBackOff | `kubectl logs <pod> --previous` | App crash, missing config, OOM |
| ImagePullBackOff | `kubectl describe pod <name>` | Wrong image/tag, missing pull secret |
| Pending | `kubectl describe pod <name>` | Insufficient resources, no matching node |
| Service unreachable | `kubectl get endpoints <svc>` | Selector mismatch, pods not ready |
| OOMKilled | `kubectl describe pod <name>` | Memory limit too low |

## Coaching Notes

- **Labels vs annotations**: Labels are for identifying and selecting objects (used by Services, Deployments). Annotations are for metadata (used by tools like cert-manager, ingress controllers).
- **Requests vs limits**: Requests are what the scheduler guarantees. Limits are the ceiling. If a container exceeds its memory limit, it gets OOMKilled. If it exceeds CPU limits, it gets throttled (not killed).
- **Namespace strategy**: Use namespaces for environment isolation (dev/staging/prod) or team ownership, not for security boundaries (use NetworkPolicies for that).

## Verification

- [ ] All manifests apply without errors: `kubectl apply -f .`
- [ ] Pods reach Running status: `kubectl get pods`
- [ ] Health probes pass: `kubectl describe pod <name>` shows healthy
- [ ] Service endpoints match pod IPs: `kubectl get endpoints <svc>`
- [ ] Ingress routes traffic correctly: `curl https://myapp.example.com/healthz`
- [ ] No secrets in ConfigMaps or plain manifests
- [ ] Resource limits are defined for every container

## Related Skills

- **docker** - Building container images for Kubernetes
- **docker-compose** - Local multi-container development
- **terraform** - Provisioning Kubernetes clusters and cloud infrastructure
