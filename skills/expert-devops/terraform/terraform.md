---
name: terraform
description: >
  Infrastructure as Code with Terraform including provider configuration, resource management,
  state handling, modules, and multi-cloud provisioning (AWS, Azure, GCP).
  Use when provisioning cloud infrastructure, writing Terraform configurations, or managing state.
version: "1.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "terraform"
  - "iac"
  - "infrastructure as code"
  - "hcl"
  - "terraform plan"
  - "terraform apply"
intent: >
  Enable teams to provision, version, and manage cloud infrastructure declaratively
  with Terraform, following best practices for state management, modularity, and safety.
scenarios:
  - "Provisioning a VPC with subnets, security groups, and compute instances on AWS"
  - "Refactoring monolithic Terraform configs into reusable modules for multi-environment deployment"
  - "Resolving state drift and safely importing existing cloud resources into Terraform management"
best_for: "Cloud provisioning, IaC, state management, modules, multi-cloud, infrastructure lifecycle"
estimated_time: "20-40 min"
anti_patterns:
  - "Storing state files locally in a team environment (causes conflicts and drift)"
  - "Hardcoding secrets in .tf files instead of using variables or vault integration"
  - "Running terraform apply without reviewing terraform plan output first"
  - "Not pinning provider and module versions, risking unexpected breaking changes"
related_skills: ["kubernetes", "ansible"]
---

# Terraform

## Overview

Terraform manages infrastructure as code using HashiCorp Configuration Language (HCL). It provisions, changes, and version-controls cloud resources across AWS, Azure, GCP, and dozens of other providers. Infrastructure is declared declaratively; Terraform determines the diff and applies the minimal set of changes.

## When to Use

- Provisioning cloud infrastructure (compute, networking, storage, databases)
- Managing infrastructure across multiple cloud providers from a single codebase
- Creating reproducible environments (dev, staging, production) from shared modules
- Importing existing resources into Terraform management

## When NOT to Use

- Application deployment within a cluster (use Kubernetes manifests or Helm)
- Configuration management on existing servers (use Ansible)
- Simple file templating without infrastructure (use scripts)

## Process

### 1. Configure Provider and Backend

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "myapp-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}
```

### 2. Define Variables and Outputs

```hcl
# variables.tf
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

# outputs.tf
output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}
```

### 3. Define Resources

```hcl
# main.tf
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
  }
}
```

### 4. Use Modules

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
```

### 5. Standard Workflow

```bash
terraform init              # Download providers and modules
terraform fmt               # Format HCL files
terraform validate          # Check syntax and internal consistency
terraform plan              # Preview changes (always review before apply)
terraform apply             # Apply changes (requires confirmation)
terraform state list        # List managed resources
terraform state show <res>  # Show resource details
```

## Best Practices

### State Management
- Use remote state (S3+DynamoDB, Azure Blob, GCS) for team collaboration
- Enable state locking to prevent concurrent modifications
- Never edit state files manually; use `terraform state` commands
- Use workspaces or directory-based layouts for environment isolation

### Code Organization
- Split configurations into files by purpose: `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`
- Extract reusable components into modules with clear inputs and outputs
- Use `terraform.tfvars` or `.auto.tfvars` for environment-specific values (gitignored)
- Pin all provider and module versions in `required_providers`

### Safety
- Always review `terraform plan` output before applying
- Run `terraform fmt` and `terraform validate` in CI before merge
- Use `prevent_destroy` lifecycle meta-argument for critical resources
- Store sensitive values in environment variables or vault, never in `.tf` files

## Troubleshooting

| Issue | Solution |
|-------|----------|
| State lock error | Check DynamoDB for stale locks; `terraform force-unlock <lock-id>` as last resort |
| Provider version conflict | Pin versions in `required_providers`; run `terraform init -upgrade` |
| Drift detected | Run `terraform plan` to see diff; use `terraform import` or `terraform apply` to reconcile |
| Destroy hanging | Check resource dependencies; use `-target` for selective destruction |
| Module source error | Verify `source` path or registry URL; run `terraform get -update` |

## Coaching Notes

- **Plan before apply**: `terraform plan` is your safety net. It shows exactly what will be created, changed, or destroyed. Never skip it. In CI, run plan on every PR.
- **State is sacred**: The state file maps your HCL to real cloud resources. Losing it means Terraform loses track of what it manages. Always use remote state with backup.
- **Modules for reuse**: If you write the same VPC/security group/compute pattern twice, extract it into a module. Modules are Terraform's unit of reuse and sharing.

## Verification

- [ ] `terraform fmt` passes with no changes
- [ ] `terraform validate` returns no errors
- [ ] `terraform plan` shows expected changes with no surprises
- [ ] Remote state backend is configured with locking enabled
- [ ] All providers and modules are version-pinned
- [ ] No secrets in `.tf` or `.tfvars` files committed to version control
- [ ] `terraform state list` matches expected resources

## Related Skills

- **kubernetes** - Container orchestration on provisioned infrastructure
- **ansible** - Configuration management after infrastructure provisioning
