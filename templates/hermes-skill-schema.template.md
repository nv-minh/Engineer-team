# Hermes Skill JSON Schema Template

> Reference template for adding `input_schema`, `output_schema`, `error_schema` to skill YAML frontmatter.
> All skills MUST include these schemas for Hermes protocol compliance.

---

## Schema Format

Add these keys to existing YAML frontmatter (do NOT replace existing keys like `name`, `description`, `triggers`, etc.).

### Generic Template

```yaml
---
name: skill-name
description: "..."
version: "3.0.0"
category: "..."
origin: "..."
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "..."
# ... existing keys unchanged ...

# === HERMES SCHEMAS (add below existing keys) ===

input_schema:
  type: object
  required: [task_description]
  properties:
    task_description:
      type: string
      description: "What the skill should accomplish"
    context:
      type: object
      description: "Project context"
      properties:
        project_root:
          type: string
          description: "Absolute path to project root"
        tech_stack:
          type: array
          items: { type: string }
          description: "Technologies in use (e.g., React, Node.js, PostgreSQL)"
        existing_patterns:
          type: array
          items: { type: string }
          description: "Established patterns to follow"
    options:
      type: object
      description: "Skill-specific options"
      properties:
        mode:
          type: string
          enum: [quick, standard, deep]
          default: standard
          description: "Execution depth"
        output_format:
          type: string
          enum: [markdown, json, yaml]
          default: markdown
          description: "Preferred output format"

output_schema:
  type: object
  required: [status, result]
  properties:
    status:
      type: string
      enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED]
      description: "Execution outcome"
    result:
      type: object
      description: "Skill-specific output — define properties per skill"
    artifacts:
      type: array
      items:
        type: object
        properties:
          name: { type: string }
          path: { type: string }
          type: { type: string, enum: [spec, plan, review, test, code, doc] }
      description: "Generated artifacts with paths"
    metadata:
      type: object
      properties:
        duration_estimate: { type: string }
        files_affected: { type: array, items: { type: string } }
        confidence: { type: string, enum: [high, medium, low] }

error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type:
      type: string
      enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error]
      description: "Error classification"
    message:
      type: string
      description: "Human-readable error description"
    attempted_action:
      type: string
      description: "What was attempted before failure"
    suggestion:
      type: string
      description: "How to resolve the error"
    retry_possible:
      type: boolean
      description: "Whether the agent should retry with adjusted params"
---
```

## Body Structure

After frontmatter, use Hermes blocks instead of prose sections:

```markdown
[ROLE]
One-line role definition. What this skill does, stated imperatively.

[OBJECTIVE]
The end goal. What the skill produces and why it matters.

[RULES]
1. Numbered imperative rules.
2. Include <thought> instruction.
3. Include anti-patterns as "DO NOT" rules.
4. Include "When NOT to Use" as a rule.

[PROCESS]
Step 1: [Action] — [What to do]
Step 2: [Action] — [What to do]
...

[RESPONSE FORMAT]
Reference output_schema. Include example output structure if complex.
```

## Examples by Skill Type

### Foundation Skill (e.g., spec-driven-development)

```yaml
input_schema:
  type: object
  required: [feature_description]
  properties:
    feature_description:
      type: string
      description: "What feature or project to specify"
    existing_context:
      type: array
      items: { type: string }
      description: "Paths to existing specs, PRDs, or requirements"

output_schema:
  type: object
  required: [status, spec]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    spec:
      type: object
      properties:
        objective: { type: string }
        requirements: { type: array, items: { type: string } }
        success_criteria: { type: array, items: { type: string } }
        boundaries: { type: object, properties: { in_scope: { type: array }, out_of_scope: { type: array } } }
```

### Quality Skill (e.g., code-review)

```yaml
input_schema:
  type: object
  required: [target]
  properties:
    target:
      type: string
      description: "PR URL, file path, or diff to review"
    depth:
      type: string
      enum: [standard, deep]
      default: standard

output_schema:
  type: object
  required: [status, assessment, findings]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    assessment: { type: string, enum: [APPROVE, REQUEST_CHANGES, COMMENT] }
    findings:
      type: array
      items:
        type: object
        required: [severity, issue, location, fix]
        properties:
          severity: { type: string, enum: [CRITICAL, HIGH, MEDIUM, LOW] }
          issue: { type: string }
          location: { type: string, description: "file:line" }
          fix: { type: string }
```

### Expert Skill (e.g., react, go-patterns)

Expert skills are primarily reference material. Use the generic schema:

```yaml
input_schema:
  type: object
  required: [task_description]
  properties:
    task_description: { type: string }
    context: { type: object }

output_schema:
  type: object
  required: [status, implementation]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    implementation: { type: object }
    patterns_applied: { type: array, items: { type: string } }
```
