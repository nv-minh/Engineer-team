# Naming Convention Protocol

**Canonical naming rules for `.claude/skills/` entry points that route to agents, skills, and workflows.**

---

## File Naming Rules

| Entity Type | Filename Pattern | `name:` Format | Routes To | Example |
|---|---|---|---|---|
| Agent (canonical) | `em-agent-{name}.md` | `em-agent:{name}` | `agents/{name}.md` | `em-agent-planner.md` → `em-agent:planner` |
| Agent alias | `em-agent-{short}.md` | `em-agent:{short}` | Same agent, longer name | `em-agent-backend.md` → `em-agent:backend` (routes to backend-expert) |
| Workflow (canonical) | `em-wf-{name}.md` | `em-wf:{name}` | `workflows/{name}.md` | `em-wf-new-feature.md` → `em-wf:new-feature` |
| Workflow alias | `em-wf-{short}.md` | `em-wf:{short}` | Same workflow, longer name | `em-wf-refactor.md` → `em-wf:refactor` (routes to refactoring) |
| Skill wrapper | `em-skill-{name}.md` | `em-skill:{name}` | `skills/{category}/{name}/{name}.md` | `em-skill-react.md` → `em-skill:react` |
| Standalone command | `em-agent-{name}.md` | `em-agent:{name}` | Self-contained (no external file) | `em-agent-checkpoint.md` → `em-agent:checkpoint` |

---

## Rules

1. **Type prefix is mandatory.** Every entry point must use `em-agent:`, `em-wf:`, or `em-skill:` — never bare `em:`.

2. **Filename uses hyphens.** `em-agent-backend-expert.md`, not `em_agent_backend_expert.md`.

3. **`name:` field format.** `name: em-agent:backend-expert` — hyphen between `em` and type, colon between type and name.

4. **One canonical + max one alias per entity.** No more than 2 entry points for the same underlying file.

5. **Deprecated files must state it.** `description: "DEPRECATED — Use em-agent:code-reviewer instead"`. This makes deprecation visible in skill listings.

---

## Invocation Examples

```bash
# Agent
Use the em-agent:planner skill to create a plan
/em-agent:planner Create implementation plan for JWT authentication

# Workflow
Use the em-wf:new-feature workflow to implement user auth
/em-wf:new-feature Implement shopping cart feature

# Skill
Use the em-skill:brainstorming skill to explore ideas
/em-skill:brainstorming Feature ideas for notification system
```

---

## Identifying Duplicates

A file is redundant if:
- Its `name:` field matches another file's `name:` field (case-insensitive)
- It routes to the same agent/skill/workflow as another file
- It adds no unique content beyond what the canonical file provides

When found, delete the redundant file and keep the canonical one (shorter filename wins).

---

## Adding New Entry Points

When adding a new agent, skill, or workflow:

1. Create the source file in the appropriate directory (`agents/`, `skills/`, `workflows/`)
2. Create ONE canonical entry point in `.claude/skills/` following the naming pattern above
3. Optionally create ONE friendly alias if the canonical name is long (e.g., `em-agent:db` → `em-agent:database-expert`)
4. Never create more than 2 entry points per entity (1 canonical + 1 optional alias)
