# Agents Overview

Complete reference for all EM-Team agents (36 total).

## Core Agents (8 agents)
1. **planner** - Create detailed implementation plans
2. **executor** - Execute with atomic commits
3. **code-reviewer** - Code review with Standard (5-axis) and Deep (9-axis) modes
4. **debugger** - Systematic debugging
5. **test-engineer** - Test strategy & generation
6. **security-reviewer** - Security review with Audit (OWASP) and Review (OWASP+STRIDE) modes
7. **ui-auditor** - Visual QA
8. **verifier** - Post-execution verification

> **Note:** `code-reviewer` includes Deep mode (9-axis). `security-reviewer` includes Audit mode. Both supersede the deleted `senior-code-reviewer` and `security-auditor` agents.

## Optional Agents (4 agents)
9. **researcher** - Technical exploration
10. **codebase-mapper** - Architecture analysis and convention extraction
11. **integration-checker** - Cross-phase validation
12. **performance-auditor** - Benchmarking and optimization

## Specialized Agents (8 agents)
13. **team-lead** - Team review orchestrator (trigger: `em-agent:team-lead`)
14. **architect** - Architecture & technical design (trigger: `em-agent:architect`)
15. **frontend-expert** - React/Next.js, UI/UX, performance (trigger: `em-agent:frontend-expert`)
16. **backend-expert** - API design, performance, auth, error handling (trigger: `em-agent:backend-expert`)
17. **database-expert** - Schema, queries, fintech patterns (trigger: `em-agent:database-expert`)
18. **product-manager** - Requirements, GAP analysis, market fit (trigger: `em-agent:product-manager`)
19. **security-reviewer** - OWASP Top 10 + STRIDE, blocking authority, unified with audit mode (trigger: `em-agent:security-reviewer`)
20. **staff-engineer** - Root cause analysis, cross-service impact (trigger: `em-agent:staff-engineer`)

> **Boundary:** Use **Architect** for "should we build it this way?" (design decisions). Use **Staff Engineer** for "why is this broken?" (root cause, incidents).

## New Agents (v2.0+)
21. **market-intelligence** - Market analysis, competitive intelligence (trigger: `em-agent:market-intelligence`)
22. **learn** - Knowledge management and cross-session learning
23. **autoplan** - Multi-phase review pipeline orchestrator
24. **techlead-orchestrator** - Distributed team coordination
25. **design-reviewer** - Visual design review with 6-pillar UI audit (trigger: `em-agent:design-reviewer`)
26. **devex-reviewer** - Developer experience audit and TTHW measurement (trigger: `em-agent:devex-reviewer`)
27. **iron-law-enforcer** - Gate enforcement for Iron Law compliance (trigger: `em-agent:iron-law-enforcer`)

## Expert Agents (v3.0)
28. **react-expert** - React/Next.js, hooks, state management, SSR (trigger: `em-agent:react-expert`)
29. **vue-expert** - Vue 3, Composition API, Pinia, Vue Router (trigger: `em-agent:vue-expert`)
30. **nestjs-expert** - NestJS, TypeScript backend, GraphQL, microservices (trigger: `em-agent:nestjs-expert`)
31. **devops-expert** - Docker, Kubernetes, Terraform, CI/CD, cloud (trigger: `em-agent:devops-expert`)
32. **mobile-expert** - Flutter, React Native, Android, iOS (trigger: `em-agent:mobile-expert`)
33. **spring-expert** - Spring Boot, JPA, security, microservices (trigger: `em-agent:spring-expert`)
34. **rust-expert** - Rust systems, ownership, async tokio, FFI (trigger: `em-agent:rust-expert`)

## Test Automation Agents (v3.8.0+)
35. **playwright-setup** - Auto-detect stack, install browsers, generate config, scaffold POM, generate auth config (trigger: `em-agent:playwright-setup`)
36. **brownfield-test-engineer** - Spec-to-test for existing codebases; asks clarifying questions when spec unclear; FLOWS.json→AC→TC mapping; TC-code coverage 100% per layer (trigger: `em-agent:brownfield-test-engineer`)
37. **test-verifier** - Double-check test results: TC-coverage pre-check, retry loop max 3, targeted fix suggestions per attempt; PASS with confidence score / FAIL with manual steps (trigger: `em-agent:test-verifier`)

---

**Version:** 5.5.0
**Last Updated:** 2026-05-27

See [Usage Guide](../guides/usage-guide.md#using-agents) for details.
