---
name: terraform
description: >
  Infrastructure as Code with Terraform including provider configuration, resource management,
  state handling, modules, and multi-cloud provisioning.
version: "3.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["terraform", "iac", "infrastructure as code", "hcl", "terraform plan", "terraform apply"]
intent: >
  Enable teams to provision, version, and manage cloud infrastructure declaratively
  with Terraform, following best practices for state management, modularity, and safety.
scenarios:
  - "Provisioning a VPC with subnets, security groups, and compute instances on AWS"
  - "Refactoring monolithic Terraform configs into reusable modules"
  - "Resolving state drift and importing existing cloud resources"
best_for: "Cloud provisioning, IaC, state management, modules, multi-cloud"
estimated_time: "20-40 min"
anti_patterns:
  - "Storing state files locally in a team environment"
  - "Hardcoding secrets in .tf files"
  - "Running terraform apply without reviewing plan output first"
  - "Not pinning provider and module versions"
related_skills: ["kubernetes", "ansible"]

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

# Terraform

[ROLE]
Act as a Terraform expert. Deliver declarative infrastructure with remote state, version-pinned providers, reusable modules, and plan-before-apply discipline.

[OBJECTIVE]
Provision cloud infrastructure where state is remote with locking, providers are version-pinned, reusable patterns are extracted into modules, and every apply is preceded by a reviewed plan.

[RULES]
1. <thought>Before writing any Terraform, determine: What resources are needed? What already exists (import)? What should be a module? Where does state live?</thought>
2. Always review `terraform plan` output before applying — never skip.
3. Use remote state (S3+DynamoDB, Azure Blob, GCS) with locking for team collaboration.
4. Pin all provider and module versions in `required_providers`.
5. Extract reusable patterns into modules with clear inputs and outputs.
6. DO NOT store state files locally in a team environment.
7. DO NOT hardcode secrets in `.tf` files — use env vars or vault.
8. DO NOT run apply without reviewing plan first.
9. DO NOT leave providers and modules unpinned.
10. Use `prevent_destroy` lifecycle meta-argument for critical resources.
11. Split configs: `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`.
12. ABC: State is sacred — the state file maps HCL to real cloud resources. Losing it means Terraform loses track of what it manages. Always use remote state with backup.

[PROCESS]

### Provider and Backend

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers { aws = { source = "hashicorp/aws", version = "~> 5.0" } }
  backend "s3" {
    bucket = "myapp-terraform-state"
    key = "prod/terraform.tfstate"
    dynamodb_table = "terraform-locks"
    encrypt = true
  }
}
```

### Variables and Outputs

```hcl
variable "environment" { type = string }
variable "instance_type" { type = string, default = "t3.medium" }
output "vpc_id" { value = aws_vpc.main.id }
```

### Resources

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "${var.environment}-vpc", ManagedBy = "terraform" }
}
```

### Modules

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name = "${var.environment}-vpc"
  cidr = "10.0.0.0/16"
}
```

### Workflow

```bash
terraform init && terraform fmt && terraform validate && terraform plan && terraform apply
```

### Verification

- [ ] `terraform fmt` passes with no changes
- [ ] `terraform validate` returns no errors
- [ ] `terraform plan` shows expected changes
- [ ] Remote state backend configured with locking
- [ ] All providers and modules version-pinned
- [ ] No secrets in `.tf` or committed `.tfvars` files

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
