# EM-Team Changelog

All notable changes to EM-Team system will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2026-05-01

### Added
- **alignment-session** skill — Pre-coding human-AI alignment session (from Matt Pocock's grill-me/grill-with-docs)
- **architecture-zoom-out** skill — Higher-level code perspective for unfamiliar code areas (from Matt Pocock's zoom-out)
- **architecture-improvement** skill — Systematic module deepening with deletion test (from Matt Pocock's improve-codebase-architecture)
- **issue-generator** skill — Convert plans to structured vertical-slice GitHub issues (from Matt Pocock's to-issues)
- **prd-generator** skill — Convert ideas to structured PRD documents (from Matt Pocock's to-prd)
- **ux-audit** skill — Behavioral UX audit with 6 scored dimensions (from Gstack)
- **plan-tune** skill — Learn and tune output preferences over time (from Gstack)
- **NestJS patterns** section added to backend-patterns skill (from ECC)

### Changed
- Updated all command invocations to use `/em:skill:*` and `/em:agent-name` format
- Normalized docs across VI guide, usage guide, getting-started, and README

### Source Repos Reviewed
- Product-Manager-Skills v0.78
- Gstack v1.1.1.0
- GSD v1.40.0-rc.4
- ECC v2.0.0-rc.1
- agent-skills (stable)
- Skills/Matt Pocock (new repo, 44 skills)

---

## [2.1.0] - 2026-05-01

### Communication Styles System

Integrated `claude-comstyle` personality styles with EM-Team density modes into a unified two-axis communication system.

#### Added
- **style-switcher skill** (`skills/workflow/style-switcher/`) - Unified communication control with 13 personality styles and 3 density modes
- **Communication Styles Reference** (`references/compact-output.md`) - Comprehensive reference for all styles, modes, and combinations
- **Personality Styles (13):** Tactical, Raw, Reality Check, git log, Socratic, BLUF, Inverted, Dramatic, 80s Hacker, Dad Joke, Rubber Duck, Teacher, First Principles
- **Density Modes (3):** STANDARD, COMPACT, TERSE (auto-detection for CI/CD and rapid iteration)
- **Terminal CLI modifier** - Strip markdown for extra 20-30% token savings
- **Vietnamese menu** - Full menu with Vietnamese descriptions for all 16 options

#### Changed
- **Renamed 5 styles** from character-based to functional names: Military→Tactical, Caveman→Raw, Yoda→Inverted, Pirate→Dramatic, Feynman→Teacher
- **`protocols/writing-style.md`** - Renamed "Compact Output Modes" to "Communication Modes" with cross-references
- **`preambles/agent-preamble.md`** - Renamed "Compact Mode" to "Communication Modes" with personality/density axis documentation
- **`CLAUDE.md`** - Added style-switcher to workflow skills and code conventions

#### Architecture
- Personality (tone/voice) and density (verbosity/format) are independent axes
- Any personality combines with any density mode
- CRITICAL findings always get full context regardless of settings
- Auto-detection: CI=true→TERSE, rapid iteration→COMPACT

---

## [2.0.0] - 2026-05-01

### Major Upgrade: Synthesized Best Patterns from 6 Source Repos

This release brings the best patterns from everything-claude-code, get-shit-done, gstack, Product-Manager-Skills, superpowers, and agent-skills into EM-Skill.

### Foundation Infrastructure (New)
- **preambles/ethos.md** - Builder philosophy: Boil the Lake, Search Before Building, User Sovereignty, Iron Laws, ABC Coaching
- **preambles/skill-preamble.md** - Standard initialization protocol for all skills
- **preambles/agent-preamble.md** - Standard behavior rules for all agents
- **protocols/writing-style.md** - Communication standards: active voice, severity levels, report structure
- **templates/skill-template.md** - Master template with enriched frontmatter (14 fields) and 8 standard sections
- **templates/agent-template.md** - Master template with status protocol, role identity, coaching mandate
- **templates/workflow-template.md** - Master template with 6-phase lifecycle and verification gates
- **templates/context-artifacts/** - PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md templates (from GSD)

### Skills Upgraded (29 skills)
- All skills upgraded with enriched YAML frontmatter (14 fields: name, description, version, category, origin, tools, triggers, intent, scenarios, best_for, estimated_time, anti_patterns, related_skills)
- Added "Coaching Notes" section to all skills (ABC - Always Be Coaching from Product-Manager-Skills)
- Added "When NOT to Use" sections where missing
- Enhanced Anti-Patterns tables

### New Skills (4)
- **typescript-patterns** - Type system, async, React/Next.js TS, utility types, generics (1033 lines)
- **python-patterns** - Python 3.10+ types, async, FastAPI, SQLAlchemy 2.0, testing (1224 lines)
- **go-patterns** - Error handling, concurrency, interfaces, testing, HTTP patterns (812 lines)
- **rust-patterns** - Ownership, traits, async tokio, smart pointers, FFI (879 lines)

### Agents Upgraded (25 agents)
- All agents upgraded with **Status Protocol** (DONE/DONE_WITH_CONCERNS/NEEDS_CONTEXT/BLOCKED) from superpowers
- All agents upgraded with **Role Identity** (agent-specific role with behavioral principles) from superpowers
- All agents upgraded with **Coaching Mandate (ABC)** from Product-Manager-Skills
- All agents upgraded with **Enhanced Frontmatter** (type, version, capabilities, inputs, outputs, collaborates_with, completion_marker)

### New Agents (3)
- **design-reviewer** - Visual design review with 6-pillar UI audit and screenshot comparison (from gstack)
- **devex-reviewer** - Developer experience audit, TTHW measurement, DX scorecard (from gstack)
- **iron-law-enforcer** - Gate enforcement for Iron Law compliance (from superpowers)

### Workflows Upgraded (20 workflows)
- All workflows upgraded with **6-Phase Lifecycle** (DEFINE -> PLAN -> BUILD -> VERIFY -> REVIEW -> SHIP) from agent-skills
- All workflows upgraded with **Verification Gates** between each phase from GSD
- All workflows upgraded with **Enriched Frontmatter** (version, category, agents_used, skills_used, estimated_time)

### New Workflows (3)
- **ship-workflow** - Version bump, changelog, commit, push, create PR (from gstack)
- **canary-monitoring** - Post-deploy health monitoring with baseline comparison (from gstack)
- **six-phase-lifecycle** - Master lifecycle workflow that all others inherit (from agent-skills)

### Documentation
- Updated CLAUDE.md with ETHOS section, new components, updated counts
- Updated version to 2.0.0

### Patterns Adopted by Source

| Pattern | Source |
|---|---|
| Enriched frontmatter (14 fields) | ECC, Product-Manager-Skills |
| Status Protocol (4 states) | superpowers |
| Role Identity + Behavior Shaping | superpowers |
| Coaching Mandate (ABC) | Product-Manager-Skills |
| 6-Phase Lifecycle + Gates | agent-skills, GSD |
| ETHOS (Boil the Lake, etc.) | gstack |
| Writing Style Protocol | gstack |
| Context Engineering Artifacts | GSD |
| Template-Driven Generation | gstack |
| Preamble System | gstack |
| Two-Stage Review | superpowers |
| Language-Specific Patterns | ECC |

---

## [1.2.0] - 2026-04-19

### Added - Discovery & Market Intelligence

This release adds comprehensive discovery and market intelligence capabilities extracted from Product-Manager-Skills and gstack methodologies.

**Skills (5 new):**
- `jobs-to-be-done` - Jobs, Pains, Gains framework for customer motivation
- `lean-ux-canvas` - Jeff Gothelf's 8-box problem framing tool
- `opportunity-solution-tree` - Teresa Torres' OST framework (outcome→opportunities→solutions→experiments)
- `pol-probe` - 5 prototype flavors for lightweight validation
- `office-hours` - YC Office Hours style validation with 6 forcing questions

**Agents (3 new):**
- `market-intelligence` - Market analysis and competitive intelligence
- `learn` - Project learnings management (patterns, pitfalls, preferences, ADRs)
- `autoplan` - Multi-phase review pipeline coordinator (CEO, Design, Eng, DX reviews)

**Workflows (1 new, 2 updated):**
- `discovery-process` - Complete 6-stage discovery workflow (2-4 weeks)
- `new-feature` (v2.0.0) - Enhanced with optional Stage 1.5: Market Validation
- `market-driven-feature` - Complete market discovery workflow

### Changed

- Updated command display to show 67+ commands (was 65+)
- Updated skill count to 26 (was 25)
- Updated agent count to 24 (was 22)

### Features

**Product Validation:**
- YC Office Hours framework with 6 forcing questions
- GREEN/YELLOW/RED scoring (1-10 per question)
- GO/NO-GO recommendations based on overall score

**Discovery Automation:**
- 6-stage workflow: Frame → Research → Synthesize → Solutions → Decide
- Integrates JTBD, Lean UX Canvas, OST, PoL probes
- Quality gates at each stage
- 2-4 week timeline with clear deliverables

**Knowledge Management:**
- Capture patterns (reusable solutions that worked)
- Document pitfalls (mistakes and how to avoid them)
- Record preferences (team conventions and choices)
- Archive architecture decisions (ADRs)
- Prevent knowledge silos and accelerate onboarding

**Review Coordination:**
- Multi-phase reviews: CEO (30min), Design (45min), Engineering (45min), DX (30min)
- Auto-decision framework with weighted scoring
- GO/CONDITIONAL GO/PIVOT/NO-GO recommendations
- Reduces meeting overload while maintaining quality

**Market Intelligence:**
- Market sizing and competitive analysis
- Trend identification and opportunity detection
- Customer research and validation
- Business case development

### Integration

All new components fully integrate with existing EM-Team system:

**Skills Integration:**
- `jobs-to-be-done` → brainstorming, lean-ux-canvas, opportunity-solution-tree
- `lean-ux-canvas` → jobs-to-be-done, brainstorming, spec-driven-development
- `opportunity-solution-tree` → jobs-to-be-done, lean-ux-canvas, brainstorming
- `pol-probe` → lean-ux-canvas, opportunity-solution-tree, brainstorming
- `office-hours` → product-manager, market-intelligence, planner

**Agents Integration:**
- `market-intelligence` → product-manager, planner, executor
- `learn` → executor, code-reviewer, security-auditor, planner
- `autoplan` → product-manager, frontend-expert, architect, staff-engineer

**Workflows Integration:**
- `discovery-process` → new-feature, market-driven-feature
- `new-feature` (v2.0) → Optional Stage 1.5: Market Validation
- `market-driven-feature` → Complete market discovery workflow

### Documentation

- Added comprehensive verification report (VERIFICATION-REPORT.md)
- All files include YAML frontmatter with keywords
- All files include integration sections
- All files include output templates and verification checklists
- All files include concrete examples and best practices

### System Impact

- **Total files created**: 11 (8 new, 3 updated)
- **Total content**: ~188K bytes
- **New skills**: +2 (office-hours + discovery skills)
- **New agents**: +2 (learn, autoplan)
- **New workflows**: +1 (discovery-process)
- **Updated workflows**: 2 (new-feature v2.0, market-driven-feature)

### Usage Examples

**Validate Product Idea:**
```
/office-hours I have an idea for a AI-powered code reviewer
→ Runs 6 forcing questions
→ Scores each question (1-10)
→ Overall score: 7.2/10 → Medium validation
→ Recommendation: Address weak areas (validate with 20 customer interviews)
```

**Run Discovery Process:**
```
/em-discovery-process We need to improve our checkout conversion
→ Stage 1: Frame Problem (lean-ux-canvas + jobs-to-be-done)
→ Stage 2: Research Planning (5-10 customer interviews)
→ Stage 3: Conduct Research (interviews + analytics)
→ Stage 4: Synthesize Insights (affinity mapping)
→ Stage 5: Generate Solutions (opportunity-solution-tree)
→ Stage 6: Decide & Document (GO/PIVOT/KILL decision)
```

**Coordinate Reviews:**
```
/em-autoplan Coordinate reviews for our new authentication feature
→ Schedules 4 reviews: CEO, Design, Engineering, DX
→ Auto-decision framework scores each review
→ Overall score: 4.4/5 → GO
→ Executor proceeds with implementation
```

**Capture Learnings:**
```
/em-learn We just completed a major refactoring project
→ Captures patterns, pitfalls, preferences, ADRs
→ Organizes by type and tags by technology
→ Makes searchable for future projects
```

### Migration Notes

No breaking changes. All new features are additive and backward compatible.

### Testing

Recommended testing scenarios:
1. Full journey: office-hours → discovery → autoplan → planner → executor → learn
2. Weak validation path: office-hours score 5-7
3. Pivot scenarios: discovery-process with invalidated hypotheses
4. Conditional go: autoplan with 3.0-3.9 score

---

## [1.1.0] - Previous Release

### Added

- Initial EM-Team system with 25 skills, 22 agents, 18 workflows
- Core development lifecycle support
- Quality assurance and testing capabilities
- Team coordination workflows

---

## Format

### Added
- New features
- New capabilities
- New components (skills, agents, workflows)

### Changed
- Changes to existing functionality
- Updates to components
- Enhancements

### Deprecated
- Soon-to-be removed features
- Features being phased out

### Removed
- Removed features
- Deprecated features that are now removed

### Fixed
- Bug fixes
- Issue resolutions

### Security
- Security vulnerability fixes
- Security improvements

---

**For more details, see:**
- VERIFICATION-REPORT.md - Complete verification report
- Individual skill/agent/workflow files - Detailed documentation
- `.claude/commands/em-show.sh` - Command reference
