# Workflows Overview

Complete catalog of EM-Team workflows (27 top-level workflows + sub-workflows).

## Workflow Selection Guide

| Starting Point | Workflow |
|---|---|
| Blank directory + idea | **greenfield-app** |
| Existing codebase + feature | new-feature |
| Existing codebase + market opportunity | market-driven-feature |
| Technical bootstrapping only | project-setup |

## Primary Workflows (7 workflows)
1. **new-feature** - From idea to production (with optional market validation)
2. **greenfield-app** - From blank directory to shipped application (NEW v3.1.0)
3. **bug-fix** - Investigate and fix bugs
4. **qa-bug-hunter** - QA testing with human-gated GitHub issue creation (NEW v4.1.0)
5. **refactoring** - Improve code quality
6. **security-audit** - Security assessment
7. **brownfield-investigation** - Context-aware bug investigation for brownfield projects (CONTEXT LOAD → REPRODUCE → ROOT CAUSE → EVIDENCE → HUMAN GATE → CONTEXT UPDATE) *(NEW v5.0.0)*

## Support Workflows (6 workflows)
7. **project-setup** - Initialize new projects
8. **documentation** - Generate and update docs
9. **deployment** - Deploy and monitor
10. **retro** - Learn and improve
11. **ship-workflow** - Version bump, changelog, PR creation
12. **canary-monitoring** - Post-deploy health monitoring

## Master Workflow
13. **six-phase-lifecycle** - DEFINE → PLAN → BUILD → VERIFY → REVIEW → SHIP (all workflows inherit this)

## Team Workflows (8 workflows)
14. **team-review** - Full team review orchestrated by Team Lead
15. **architecture-review** - Architecture review with Architect & Staff Engineer
16. **design-review** - UI/UX design review with Frontend Expert & Product Manager
17. **code-review-9axis** - Deep 9-axis code review with Code Reviewer (Deep mode) & Security
18. **database-review** - Database schema & query review with Database Expert & Architect
19. **product-review** - Product/spec review with Product Manager & Architect
20. **security-review-advanced** - Advanced security (OWASP + STRIDE) with Security & Staff
21. **incident-response** - Production incident handling with Staff Engineer & Security

## Distributed Workflows (2 workflows)
22. **distributed-investigation** - Parallel bug investigation across full stack
23. **distributed-development** - Parallel feature development with multiple agents

## Product Workflows (2 workflows)
24. **discovery-process** - Complete 6-stage discovery workflow (2-4 weeks)
25. **market-driven-feature** - Market-driven feature development

## Outsourcing Workflows (1 workflow)
26. **japanese-outsourcing** - End-to-end Japanese outsourcing workflow with 基本設計, 詳細設計, 受け入れテスト, formal gates

## Incident Sub-Workflows (`workflows/incident/`)
- **initial-triage** - First response and impact assessment
- **cross-service-impact** - Multi-service incident investigation
- **root-cause-analysis** - Systematic root cause identification
- **resolution-verification** - Verify fix and prevent regression
- **postmortem-prevention** - Postmortem and prevention measures
- **security-investigation** - Security-focused incident investigation

## Security Sub-Workflows (`workflows/security/`)
- **deep-investigation** - Deep security vulnerability investigation
- **owasp-assessment** - OWASP Top 10 assessment
- **stride-threat-modeling** - STRIDE threat modeling

---

**Version:** 5.5.0
**Last Updated:** 2026-05-27

See [Usage Guide](../guides/usage-guide.md#using-workflows) for details.
