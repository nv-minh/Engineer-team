# Naming Convention Protocol

**Canonical naming rules for `.claude/skills/` entry points that route to agents, skills, and workflows.**

---

## File Naming Rules

| Entity Type | Filename Pattern | `name:` Format | Routes To | Example |
|---|---|---|---|---|
| Agent shorthand | `em-{agent-name}.md` | `em:{agent-name}` | `agents/{agent-name}.md` | `em-backend-expert.md` → `em:backend-expert` |
| Agent alias | `em-{short}.md` | `em:{short}` | Same agent as shorthand | `em-backend.md` → `em:backend` (routes to backend-expert) |
| Skill wrapper | `em-skill-{skill-name}.md` | `em:skill:{skill-name}` | `skills/{category}/{skill-name}/{skill-name}.md` | `em-skill-react.md` → `em:skill:react` |
| Workflow | `em-{workflow-name}.md` | `em:{workflow-name}` | `workflows/{workflow-name}.md` | `em-bug-fix.md` → `em:bug-fix` |
| Command | `em-{command-name}.md` | `em:{command-name}` | `.claude/commands/{command-name}.md` | `em-checkpoint.md` → `em:checkpoint` |

---

## Rules

1. **One canonical file per entity.** No `-skill` suffix duplicates. If `em-backend-expert.md` exists, do not create `em-backend-expert-skill.md`.

2. **Friendly aliases are allowed, max 1 per agent.** Example: `em-backend.md` (alias) → `em-backend-expert.md` (canonical). The alias must state which agent it routes to in its description.

3. **Deprecated files must have `DEPRECATED` in the description field.** Example: `description: "DEPRECATED — Use em:code-reviewer with Deep mode instead"`. This makes deprecation visible in skill listings.

4. **The `name:` field uses colons as separators.** Agent/workflow names use `em:{name}`. Skill wrappers use `em:skill:{name}`. Never use hyphens in the `name:` field prefix — `em:backend-expert` is correct, `em-backend-expert` is wrong.

5. **Filename uses hyphens as separators.** All filenames are lowercase with hyphens: `em-backend-expert.md`, not `em_backend_expert.md`.

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
3. Optionally create ONE friendly alias if the canonical name is long (e.g., `em:db` → `em:database-expert`)
4. Never create more than 2 entry points per entity (1 canonical + 1 optional alias)
