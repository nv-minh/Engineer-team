# Stage 0: SETUP (Git & Spec Bootstrap)

Shared sub-workflow used by `new-feature.md` and `bug-fix.md`.

**Parameters** (set by the calling workflow):

| Parameter | new-feature | bug-fix |
|---|---|---|
| `{doc_type}` | spec | bug |
| `{doc_prefix}` | FEAT | BUG |
| `{slug_type}` | feature | bug |
| `{default_branch_pattern}` | feat/{slug} \| fix/{slug} \| refactor/{slug} | fix/{slug} |
| `{doc_template_body}` | feature spec skeleton | bug doc skeleton |
| `{artifact_name}` | spec_document_skeleton | bug_document_skeleton |
| `{next_action}` | brainstorm | investigate |

---

<thought>
Observe: Workflow initiated. No branch created, no {doc_type} document in project spec folder, no pull from main yet.
Analyze: Must bootstrap the workspace — detect spec folder, read branch naming rules, create {doc_type} doc, pull latest from main, checkout branch. Gate requires: spec folder detected, rules checked, branch name confirmed by user, {doc_type} doc created, on correct branch with latest main.
Plan: Detect spec folder → check branch naming rules → confirm branch name with user → create {doc_type} doc → git pull origin main → git checkout -b {branch-name}.
</thought>

<action>
type: setup_git_and_spec
tasks:
  1. detect_spec_folder:
     - check {cwd}/spec/ → use "spec/"
     - check {cwd}/specs/ → use "specs/"
     - else → create "spec/" in {cwd}
  2. detect_branch_naming_rules:
     - read {cwd}/.claude/rules/branch-naming.md (if exists)
     - read {cwd}/spec/README.md (grep for branch patterns)
     - grep {cwd}/spec/*.md for existing branch patterns (feat/, fix/, CR-)
     - if none found → use defaults: {default_branch_pattern}
     - display found rules to user
  3. determine_branch_name:
     - apply detected rules to {slug_type} slug
     - confirm with user before creating
  4. create_{doc_type}_document:
     - write {spec_folder}/{doc_prefix}-{slug}.md using {doc_template_body}
     - Note: if project uses CR-based naming, use CR-{NNN}-{slug}.md format instead
  5. git_operations:
     - git fetch origin
     - detect default branch (main or master)
     - git checkout {default_branch}
     - git pull origin {default_branch}
     - git checkout -b {branch-name}
</action>

<observation>
result: spec folder ready, branch naming rules displayed, {doc_type} doc created, branch checked out with latest main
state_change: workspace bootstrapped, ready to start {slug_type} work
gate_status: PASS | FAIL
</observation>

**Gate 0 — SETUP Complete:**
- [ ] spec folder detected or created
- [ ] branch naming rules found and displayed to user
- [ ] branch name confirmed by user
- [ ] {doc_type} document created in project spec folder
- [ ] pulled latest from default branch (main/master)
- [ ] checked out to new branch

PASS → Stage 1 | FAIL → fix git/spec issues before proceeding

**State Snapshot:**
```yaml
workflow_state:
  current_phase: DEFINE
  stage_completed: setup
  artifacts:
    - {artifact_name}
    - branch_name
  next_action: "{next_action}"
```
