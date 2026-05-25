# Error Handling Protocol

**Standardized error types, severity levels, and recovery strategies for all workflows and skills.**

All workflows MUST include an `## Error Handling` section. This protocol defines the shared taxonomy so error types are consistent across the system.

---

## Universal Error Types

Every workflow must handle these errors. Include them in every `## Error Handling` section.

| Error Type | Severity | Trigger | Recovery | Counts as Retry? |
|---|---|---|---|---|
| `CONTEXT_OVERFLOW` | CRITICAL | Context window >80% consumed | `/compact`, prune prior stage outputs, or start new session | No |
| `BUILD_DEADLOCK` | HIGH | Circular dependency or build/test loop >3 consecutive failures | Invoke `systematic-debugging` skill with failure context | Yes |
| `TEST_ENV_FAILURE` | MEDIUM | Test infrastructure down, flaky environment, Docker/CI issue | Reset environment, retry stage | No |
| `SPEC_CONFLICT` | HIGH | Contradictory requirements discovered during build/verify | Return to DEFINE stage, resolve with stakeholder | Yes |

**Retry policy:** `max_retries_per_stage: 2` — after 2 retries of the same error type, escalate to human.

---

## Domain-Specific Error Types

Use these in workflows where they apply. Each error type belongs to a category.

### Security

| Error Type | Trigger | Recovery | Applicable Workflows |
|---|---|---|---|
| `SCAN_INCOMPLETE` | Security scanner fails or times out before completing | Re-run with narrower scope, or switch scanner | security-audit, security-review-advanced |
| `FIX_INTRODUCES_VULNERABILITY` | Security fix creates a new vulnerability | Revert fix, re-analyze attack surface | security-audit, security-review-advanced |

### QA & Testing

| Error Type | Trigger | Recovery | Applicable Workflows |
|---|---|---|---|
| `TARGET_UNREACHABLE` | Test target URL/service is down or unreachable | Verify deployment status, retry after service recovery | qa-bug-hunter, browser-testing |
| `EVIDENCE_CAPTURE_FAILURE` | Screenshot/video/trace capture fails | Check Playwright config, retry with `--headed` for debugging | qa-bug-hunter |
| `GITHUB_AUTH_FAILURE` | GitHub API token expired or insufficient permissions | Re-authenticate, check token scopes | qa-bug-hunter, ship-workflow |

### Refactoring

| Error Type | Trigger | Recovery | Applicable Workflows |
|---|---|---|---|
| `REGRESSION_INTRODUCED` | Existing tests fail after refactor | Revert last change, diff against passing state | refactoring |
| `BEHAVIOR_CHANGE_DETECTED` | Output differs from pre-refactor baseline | Confirm whether change is intentional with stakeholder | refactoring |

### Bug Fix

| Error Type | Trigger | Recovery | Applicable Workflows |
|---|---|---|---|
| `IRREPRODUCIBLE_BUG` | Bug cannot be reproduced after 3 attempts | Gather more context (logs, env diff), try different reproduction strategy | bug-fix |

### Greenfield & Setup

| Error Type | Trigger | Recovery | Applicable Workflows |
|---|---|---|---|
| `SCAFFOLD_FAILURE` | Project scaffold/generator fails | Check Node/Python version, clear cache, retry with verbose output | greenfield-app, project-setup |

### Deployment

| Error Type | Trigger | Recovery | Applicable Workflows |
|---|---|---|---|
| `DEPLOY_FAILURE` | Deployment to target environment fails | Check deployment logs, verify config, rollback if needed | deployment, canary-monitoring |
| `ROLLBACK_FAILURE` | Rollback to previous version fails | Manual intervention required, escalate immediately | deployment |
| `HEALTH_CHECK_FAILED` | Post-deploy health check returns unhealthy | Check application logs, verify dependencies, rollback if critical | deployment, canary-monitoring |

### Incident Response

| Error Type | Trigger | Recovery | Applicable Workflows |
|---|---|---|---|
| `ESCALATION_REQUIRED` | Incident severity exceeds current responder authority | Escalate to next-level oncall, document handoff | incident-response |
| `ROOT_CAUSE_UNCONFIRMED` | Root cause hypothesis lacks sufficient evidence | Gather more data (traces, logs, metrics), expand investigation scope | incident-response |

### Team Review

| Error Type | Trigger | Recovery | Applicable Workflows |
|---|---|---|---|
| `AGENT_TIMEOUT` | Review agent exceeds time limit (15min single, 30min distributed) | Collect partial output, reassign or retry with narrower scope | team-review, architecture-review, code-review-9axis, database-review, design-review, product-review, security-review-advanced |

### Versioning

| Error Type | Trigger | Recovery | Applicable Workflows |
|---|---|---|---|
| `VERSION_CONFLICT` | Version bump conflicts with existing tag or unreleased changes | Resolve conflict, re-run version bump with correct base | ship-workflow |

---

## Naming Convention

| Context | Convention | Example |
|---|---|---|
| Workflow error tables | `SCREAMING_SNAKE_CASE` | `BUILD_DEADLOCK`, `SPEC_CONFLICT` |
| Skill `error_schema` enums | `snake_case` | `missing_input`, `tool_failure` |

**Rationale:** Workflows use SCREAMING_SNAKE_CASE because error types appear in markdown tables as literal status codes that agents recognize and report. Skills use snake_case because error types appear in YAML `error_schema` enum values following JSON Schema convention.

---

## Skill Error Schema (Canonical)

All skills use this standard `error_schema` in YAML frontmatter:

```yaml
error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type:
      type: string
      enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error]
    message: { type: string }
    attempted_action: { type: string }
    suggestion: { type: string }
    retry_possible: { type: boolean }
```

| Skill Error Type | When to Use |
|---|---|
| `missing_input` | Required input field not provided |
| `ambiguous_scope` | Input is too vague to act on |
| `blocked` | External dependency prevents execution |
| `tool_failure` | Tool call failed (MCP, Bash, etc.) |
| `validation_error` | Input fails schema or business validation |

---

## Default Error Handling Template

Copy this block into any workflow that lacks an `## Error Handling` section:

```markdown
## Error Handling

| Error Type | Trigger | Recovery | Retry? |
|---|---|---|---|
| `CONTEXT_OVERFLOW` | Context window >80% | `/compact`, prune prior stages | No |
| `BUILD_DEADLOCK` | Build/test loop >3 failures | Invoke systematic-debugging | Yes |
| `TEST_ENV_FAILURE` | Infra/env issue, not code bug | Reset environment, retry | No |
| `SPEC_CONFLICT` | Contradictory requirements found | Return to DEFINE stage | Yes |

`max_retries_per_stage: 2` — after 2 retries, escalate to human.
```

Add domain-specific errors from the tables above as needed for the workflow's purpose.

---

## Integration

- **Workflows:** Reference this protocol in `## Error Handling` sections
- **Skills:** Use the canonical `error_schema` enum in YAML frontmatter
- **validate-hermes.sh:** Section 8 checks that all workflows have `## Error Handling`
- **review-gates.md:** Gate failure protocol complements this — gates handle phase-level failures, this protocol handles within-stage errors
