---
name: ansible
description: >
  Ansible automation including playbooks, roles, inventory management, idempotent tasks,
  modules, and secrets management with Vault.
  Use when automating server configuration, deploying applications, or managing infrastructure at scale.
version: "1.0.0"
category: "expert-devops"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "ansible"
  - "playbook"
  - "ansible-playbook"
  - "ansible vault"
  - "configuration management"
  - "ansible role"
intent: >
  Enable teams to automate IT infrastructure configuration and deployment
  with idempotent, readable Ansible playbooks organized into reusable roles.
scenarios:
  - "Writing a playbook that installs and configures Nginx with a virtual host template"
  - "Organizing a growing set of tasks into roles with handlers, templates, and defaults"
  - "Encrypting sensitive variables with Ansible Vault for safe storage in version control"
best_for: "Server configuration, application deployment, idempotent automation, infrastructure management"
estimated_time: "20-40 min"
anti_patterns:
  - "Writing monolithic playbooks instead of organizing into roles"
  - "Using shell/command tasks when idempotent modules exist"
  - "Storing unencrypted secrets in group_vars or host_vars"
  - "Running playbooks without checking syntax first (ansible-playbook --syntax-check)"
related_skills: ["terraform", "kubernetes"]
---

# Ansible

## Overview

Ansible automates configuration management, application deployment, and infrastructure orchestration through human-readable YAML playbooks. It is agentless (requires only SSH and Python on target hosts), idempotent by design, and organizes automation into reusable roles with clear variable hierarchies.

## When to Use

- Configuring servers after Terraform provisioning (the config management layer)
- Deploying applications to bare-metal or VM hosts
- Automating repeated operational tasks (user management, package updates, service restarts)
- Managing configuration drift across fleets of servers

## When NOT to Use

- Provisioning cloud infrastructure (use Terraform)
- Orchestrating containers at scale (use Kubernetes)
- Running one-off commands (use SSH directly or cloud CLI tools)

## Process

### 1. Define Inventory

```ini
# inventory/production.ini
[webservers]
web1.example.com ansible_user=deploy
web2.example.com ansible_user=deploy

[dbservers]
db1.example.com ansible_user=deploy

[production:children]
webservers
dbservers

[production:vars]
ansible_python_interpreter=/usr/bin/python3
```

Or in YAML:

```yaml
# inventory/production.yaml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
    dbservers:
      hosts:
        db1.example.com:
    production:
      children:
        webservers:
        dbservers:
```

### 2. Write Playbooks

```yaml
# site.yml
---
- name: Deploy web application
  hosts: webservers
  become: true
  vars:
    app_port: 8080
    app_version: "1.2.0"

  tasks:
    - name: Install required packages
      ansible.builtin.package:
        name:
          - nginx
          - python3
          - python3-pip
        state: present
      tags: [packages]

    - name: Deploy nginx configuration
      ansible.builtin.template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: "0644"
      notify: restart nginx
      tags: [config]

    - name: Ensure nginx is running and enabled
      ansible.builtin.service:
        name: nginx
        state: started
        enabled: true
      tags: [service]

    - name: Deploy application
      ansible.builtin.unarchive:
        src: "files/app-{{ app_version }}.tar.gz"
        dest: /opt/myapp/
        owner: appuser
        group: appgroup
      notify: restart app
      tags: [deploy]

  handlers:
    - name: restart nginx
      ansible.builtin.service:
        name: nginx
        state: restarted

    - name: restart app
      ansible.builtin.service:
        name: myapp
        state: restarted
```

### 3. Organize with Roles

```bash
# Scaffold a role
ansible-galaxy init roles/myapp

# Role structure
roles/myapp/
  defaults/main.yml     # Default variables (lowest priority)
  vars/main.yml         # Role variables (higher priority)
  tasks/main.yml        # Main task list
  handlers/main.yml     # Handlers
  templates/            # Jinja2 templates
  files/                # Static files
  meta/main.yml         # Role metadata and dependencies
```

```yaml
# Use the role in a playbook
- name: Apply myapp role
  hosts: webservers
  become: true
  roles:
    - role: myapp
      vars:
        app_port: 8080
```

### 4. Secrets with Ansible Vault

```bash
# Encrypt a variables file
ansible-vault encrypt group_vars/production/vault.yml

# Edit encrypted file in place
ansible-vault edit group_vars/production/vault.yml

# Run playbook with vault password
ansible-playbook -i inventory/production site.yml --ask-vault-pass
```

### 5. Essential Commands

| Command | Purpose |
|---------|---------|
| `ansible-playbook site.yml` | Run a playbook |
| `ansible-playbook --syntax-check site.yml` | Validate syntax |
| `ansible-playbook --check site.yml` | Dry run (check mode) |
| `ansible-playbook --diff site.yml` | Show file changes |
| `ansible -m ping all` | Test connectivity |
| `ansible-vault encrypt file.yml` | Encrypt file |
| `ansible-galaxy init role_name` | Scaffold a role |
| `ansible-inventory --list` | Show inventory in JSON |

## Best Practices

### Idempotency
- Prefer modules over `shell`/`command`: `package`, `template`, `service`, `copy`, `user`
- Always specify `state` parameter (`present`, `started`, etc.)
- Use `creates` or `removes` guards when shell/command tasks are unavoidable

### Organization
- Use roles for anything beyond a few tasks; avoid monolithic playbooks
- Leverage `group_vars/` and `host_vars/` for variable hierarchy
- Use tags for selective execution: `ansible-playbook site.yml --tags config`
- Separate environment inventories: `inventory/dev/`, `inventory/staging/`, `inventory/prod/`

### Error Handling
- Use `block/rescue/always` for structured error handling
- Set `ignore_errors: true` only when failure is acceptable and documented
- Register task results and use `when:` conditionals for flow control

### Security
- Encrypt all secrets with `ansible-vault`
- Use FQCN (Fully Qualified Collection Names): `ansible.builtin.package` not just `package`
- Limit `become` usage to tasks that need elevated privileges

## Coaching Notes

- **Handlers only fire once**: Even if notified by multiple tasks, a handler runs once at the end of the play. This is by design and prevents repeated restarts.
- **Variable precedence matters**: Ansible has 22 levels of variable precedence. In practice: `defaults < inventory vars < playbook vars < extra-vars (CLI)`. When in doubt, use `ansible -m debug -a "var=variable_name"` to check the resolved value.
- **Check mode is your friend**: `--check` runs the playbook without making changes. Combine with `--diff` to see what would change. Always use this before running against production.

## Verification

- [ ] `ansible-playbook --syntax-check` passes for all playbooks
- [ ] `ansible -m ping all` reaches all inventory hosts
- [ ] Playbooks are idempotent (running twice produces no changes)
- [ ] Roles follow standard directory structure
- [ ] Secrets are encrypted with `ansible-vault`
- [ ] Tags are defined for selective execution
- [ ] `--check --diff` shows expected changes before production apply

## Related Skills

- **terraform** - Infrastructure provisioning before Ansible configuration
- **kubernetes** - Container orchestration (complementary to Ansible)
