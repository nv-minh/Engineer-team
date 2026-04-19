# EM-Team Changelog

All notable changes to EM-Team system will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
