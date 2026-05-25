---
name: ansible
description: >
  Ansible automation including playbooks, roles, inventory management, idempotent tasks,
  modules, and secrets management with Vault.
version: "3.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["ansible", "playbook", "ansible-playbook", "ansible vault", "configuration management", "ansible role"]
intent: >
  Enable teams to automate IT infrastructure configuration and deployment
  with idempotent, readable Ansible playbooks organized into reusable roles.
scenarios:
  - "Writing a playbook that installs and configures Nginx with a virtual host template"
  - "Organizing tasks into roles with handlers, templates, and defaults"
  - "Encrypting sensitive variables with Ansible Vault"
best_for: "Server configuration, application deployment, idempotent automation"
estimated_time: "20-40 min"
anti_patterns:
  - "Writing monolithic playbooks instead of organizing into roles"
  - "Using shell/command tasks when idempotent modules exist"
  - "Storing unencrypted secrets in group_vars or host_vars"
  - "Running playbooks without checking syntax first"
related_skills: ["terraform", "kubernetes"]

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

# Ansible

[ROLE]
Act as an Ansible expert. Deliver idempotent playbooks organized into reusable roles with encrypted secrets and proper variable hierarchies.

[OBJECTIVE]
Automate server configuration with playbooks that are idempotent (running twice produces no changes), organized into roles, and store secrets encrypted with Ansible Vault.

[RULES]
1. <thought>Before writing any task, determine: Is there an idempotent module for this (package, template, service)? Should this be a role? Are there secrets to encrypt?</thought>
2. Prefer modules over `shell`/`command` — `package`, `template`, `service`, `copy`, `user`.
3. Always specify `state` parameter (`present`, `started`, etc.).
4. Organize into roles for anything beyond a few tasks.
5. Encrypt all secrets with `ansible-vault`.
6. Use FQCN — `ansible.builtin.package` not just `package`.
7. DO NOT write monolithic playbooks — use roles.
8. DO NOT use shell/command when idempotent modules exist.
9. DO NOT store unencrypted secrets in vars files.
10. Use `--check --diff` before running against production.
11. Use tags for selective execution.
12. ABC: Handlers only fire once — even if notified by multiple tasks. This prevents repeated restarts by design.

[PROCESS]

### Playbook

```yaml
- name: Deploy web application
  hosts: webservers
  become: true
  tasks:
    - name: Install packages
      ansible.builtin.package:
        name: [nginx, python3]
        state: present
      tags: [packages]
    - name: Deploy config
      ansible.builtin.template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: restart nginx
      tags: [config]
  handlers:
    - name: restart nginx
      ansible.builtin.service: { name: nginx, state: restarted }
```

### Role Structure

```
roles/myapp/
  defaults/main.yml     # Default variables
  tasks/main.yml        # Main task list
  handlers/main.yml     # Handlers
  templates/            # Jinja2 templates
  files/                # Static files
```

### Vault

```bash
ansible-vault encrypt group_vars/production/vault.yml
ansible-playbook -i inventory/production site.yml --ask-vault-pass
```

### Essential Commands

| Command | Purpose |
|---------|---------|
| `ansible-playbook --syntax-check site.yml` | Validate syntax |
| `ansible-playbook --check --diff site.yml` | Dry run with diff |
| `ansible -m ping all` | Test connectivity |

### Verification

- [ ] `ansible-playbook --syntax-check` passes
- [ ] Playbooks are idempotent (running twice = no changes)
- [ ] Roles follow standard directory structure
- [ ] Secrets encrypted with ansible-vault
- [ ] Tags defined for selective execution

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
