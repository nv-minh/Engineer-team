---
name: kubernetes
description: >
  Kubernetes cluster management including pods, deployments, services, ingress,
  ConfigMaps, Secrets, kubectl operations, resource limits, and rolling updates.
version: "3.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["kubernetes", "k8s", "kubectl", "deployment", "pod", "service", "ingress", "configmap"]
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

input_schema:
  type: object
  required: [task_description]
  properties:
    task_description:
      type: string
      description: "What to implement, review, or investigate"
    context:
      type: object
      description: "Project context — existing code, tech stack, constraints"
    mode:
      type: string
      enum: [implement, review, investigate, advise]
      default: implement
      description: "Execution mode"

output_schema:
  type: object
  required: [status, implementation]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    implementation:
      type: object
      description: "Implementation details, code, or analysis results"
    patterns_applied:
      type: array
      items: { type: string }
      description: "Patterns and best practices used"
    recommendations:
      type: array
      items:
        type: object
        properties:
          priority: { type: string, enum: [high, medium, low] }
          action: { type: string }
          reasoning: { type: string }

error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    attempted_action: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
---

# Kubernetes

[ROLE]
Act as a Kubernetes expert. Deliver production-ready manifests with health probes, resource limits, rolling update strategies, and proper secret management.

[OBJECTIVE]
Deploy applications to Kubernetes with proper resource requests/limits, liveness/readiness probes, rolling update strategies, and Ingress configuration.

[RULES]
1. <thought>Before writing any manifest, determine: What probes does this need? What are realistic CPU/memory requests? What secrets does it need? What rolling update strategy is appropriate?</thought>
2. Always set `requests` AND `limits` for CPU and memory on every container.
3. Configure `livenessProbe` and `readinessProbe` for every deployment.
4. Use rolling update strategy with `maxUnavailable: 0` for zero-downtime deployments.
5. Use Secrets (not ConfigMaps) for sensitive data — prefer external-secrets-operator.
6. Pin image tags to specific versions — never use `:latest`.
7. DO NOT store secrets in ConfigMaps or plain manifests.
8. DO NOT set resource limits too low — this causes OOMKills and throttling.
9. DO NOT use `:latest` tag for container images in production.
10. Use NetworkPolicies to restrict pod-to-pod traffic.
11. Run as non-root with `securityContext: runAsNonRoot: true`.
12. ABC: Requests are what the scheduler guarantees. Limits are the ceiling. If a container exceeds memory limits, it gets OOMKilled. If it exceeds CPU limits, it gets throttled (not killed).

[PROCESS]

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata: { name: myapp }
spec:
  replicas: 3
  strategy: { type: RollingUpdate, rollingUpdate: { maxSurge: 1, maxUnavailable: 0 } }
  selector: { matchLabels: { app: myapp } }
  template:
    metadata: { labels: { app: myapp } }
    spec:
      containers:
        - name: myapp
          image: myregistry/myapp:1.0.0
          ports: [{ containerPort: 8080 }]
          resources:
            requests: { cpu: 100m, memory: 128Mi }
            limits: { cpu: 500m, memory: 256Mi }
          livenessProbe: { httpGet: { path: /healthz, port: 8080 }, initialDelaySeconds: 10 }
          readinessProbe: { httpGet: { path: /ready, port: 8080 }, initialDelaySeconds: 5 }
```

### Service and Ingress

```yaml
apiVersion: v1
kind: Service
metadata: { name: myapp }
spec: { selector: { app: myapp }, ports: [{ port: 80, targetPort: 8080 }], type: ClusterIP }
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: { name: myapp, annotations: { cert-manager.io/cluster-issuer: letsencrypt-prod } }
spec:
  tls: [{ hosts: [myapp.example.com], secretName: myapp-tls }]
  rules: [{ host: myapp.example.com, http: { paths: [{ path: /, pathType: Prefix, backend: { service: { name: myapp, port: { number: 80 } } } }] } }]
```

### Essential kubectl Commands

| Command | Purpose |
|---------|---------|
| `kubectl apply -f manifest.yaml` | Create or update resources |
| `kubectl get pods -w` | Watch pod status |
| `kubectl describe pod <name>` | Inspect pod details and events |
| `kubectl logs <pod> -f` | Stream logs |
| `kubectl logs <pod> --previous` | Logs from crashed container |
| `kubectl rollout undo deploy/<name>` | Roll back |

### Troubleshooting

| Symptom | Diagnostic | Common Cause |
|---------|-----------|-------------|
| CrashLoopBackOff | `kubectl logs --previous` | App crash, missing config, OOM |
| ImagePullBackOff | `kubectl describe pod` | Wrong image/tag, missing pull secret |
| Pending | `kubectl describe pod` | Insufficient resources |

### Verification

- [ ] All manifests apply without errors
- [ ] Pods reach Running status with healthy probes
- [ ] Resource limits defined for every container
- [ ] No secrets in ConfigMaps or plain manifests
- [ ] Ingress routes traffic correctly

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
