---
name: architecture-review
description: Architecture review with Architect and Staff Engineer agents
version: "2.0.0"
category: "team"
origin: "agent-skills"
agents_used:
  - architect
  - staff-engineer
skills_used:
  - code-review
  - documentation
  - performance-optimization
  - writing-plans
estimated_time: "2-4 hours (standard) / 1-2 days (comprehensive)"
---

# Architecture Review Workflow

## Overview

The Architecture Review workflow provides deep technical assessment of architectural designs, patterns, and decisions. It combines the Architect agent's expertise in design patterns with the Staff Engineer's deep technical investigation capabilities.

## When to Use

- New system architecture design
- Major architectural refactoring
- Microservices decomposition
- Architecture Decision Record (ADR) review
- Scalability assessment
- Integration design

## Lifecycle

```
DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE
```

### Stage-to-Lifecycle Mapping

| Workflow Stage | Lifecycle Phase | Description |
|---|---|---|
| Architecture Analysis (Stage 1) | DEFINE + PLAN | Architect identifies patterns, assesses principles, reviews design |
| Deep Technical Review (Stage 2) | BUILD + VERIFY | Staff Engineer analyzes cross-service impact, dependencies, risks |
| Consolidated Assessment (Stage 3) | REVIEW + SHIP | Merge findings, prioritize recommendations, create roadmap |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Architectural pattern identified
- [ ] Principles assessed
- [ ] Design reviewed
- [ ] Scalability evaluated
- [ ] Scorecard completed
PASS → proceed to PLAN | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Architecture review findings documented
- [ ] Pattern assessment complete
- [ ] Scalability concerns identified
- [ ] Integration points mapped
PASS → proceed to BUILD | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Cross-service impact analyzed
- [ ] Dependencies mapped
- [ ] Performance implications assessed
- [ ] Risks identified
PASS → proceed to VERIFY | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Findings merged
- [ ] Risks prioritized
- [ ] Recommendations actionable
- [ ] Roadmap defined
PASS → proceed to REVIEW | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Consolidated report complete
- [ ] Decision made (APPROVED/CONDITIONAL/REJECTED)
- [ ] Recommendations categorized (immediate/short-term/long-term)
- [ ] Scorecard finalized
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

### Stage 1: Architecture Analysis (Architect)

**Agent:** `duck:architect`

**Actions:**
- Identify architectural pattern (Layered, Hexagonal, Microservices, Event-Driven)
- Assess architectural principles (high cohesion, low coupling, separation of concerns)
- Review technical design
- Evaluate scalability and maintainability
- Review ADRs (if applicable)

**Input:**
- Architecture diagrams
- Technical design documents
- ADRs
- System requirements

**Output:** Architecture Review Report

**Quality Gate:**
- [ ] Architectural pattern identified
- [ ] Principles assessed
- [ ] Design reviewed
- [ ] Scalability evaluated
- [ ] Scorecard completed

---

### Stage 2: Deep Technical Review (Staff Engineer)

**Agent:** `duck:staff`

**Actions:**
- Cross-service impact analysis
- Dependency analysis
- Performance implications
- Integration complexity assessment
- Risk identification

**Input:**
- Architecture review from Architect
- System context
- Performance requirements

**Output:** Staff Engineering Technical Report

**Quality Gate:**
- [ ] Cross-service impact analyzed
- [ ] Dependencies mapped
- [ ] Performance implications assessed
- [ ] Risks identified

---

### Stage 3: Consolidated Architecture Assessment

**Agents:** `duck:architect` + `duck:staff`

**Actions:**
- Merge architecture and technical findings
- Identify architectural risks
- Prioritize recommendations
- Create actionable roadmap

**Output:** Consolidated Architecture Review Report

**Quality Gate:**
- [ ] Findings merged
- [ ] Risks prioritized
- [ ] Recommendations actionable
- [ ] Roadmap defined

---

## Handoff Contracts

### To Architect
```yaml
provides:
  - architecture_diagrams
  - technical_design
  - requirements
  - constraints

expects:
  - architecture_review
  - pattern_assessment
  - scalability_analysis
  - design_recommendations
```

### Architect → Staff Engineer
```yaml
provides:
  - architecture_review
  - pattern_identification
  - scalability_concerns
  - integration_points

expects:
  - cross_service_impact
  - dependency_analysis
  - performance_implications
  - technical_risks
```

### Staff Engineer → Consolidation
```yaml
provides:
  - technical_findings
  - impact_analysis
  - risk_assessment
  - recommendations

expects:
  - consolidation
  - prioritzation
  - roadmap
```

---

## Architecture Pattern Assessment

### LAYERED ARCHITECTURE
```yaml
characteristics:
  - presentation_layer: UI, API controllers
  - business_logic_layer: Services, domain logic
  - data_access_layer: Repositories, DAOs
  - database_layer: Database, external services

  data_flow: unidirectional (top to bottom)
  dependencies: upper_layers depend_on lower_layers

  pros:
    - easy_to_understand
    - separation_of_concerns
    - testable

  cons:
    - can_become_rigid
    - hidden_latencies
    - logic_can_leak

  when_to_use:
    - traditional_crud_applications
    - small_to_medium_teams
    - straightforward_requirements
```

### HEXAGONAL ARCHITECTURE
```yaml
characteristics:
  - domain: Core business logic (no dependencies)
  - ports: Interfaces defined by domain
  - adapters: Implementations for ports

  types:
    - driving_adapters: UI, API, tests (drive domain)
    - driven_adapters: Database, APIs, messaging (driven by domain)

  data_flow: bidirectional through ports
  dependencies: all dependencies point inward

  pros:
    - domain is_independent
    - easy to swap_adapters
    - highly_testable
    - technology_agnostic

  cons:
    - more_complex initially
    - requires_discipline
    - overkill_for_simple_apps

  when_to_use:
    - complex_business_domains
    - technology_uncertainty
    - long_term_maintainability_needed
```

### MICROSERVICES ARCHITECTURE
```yaml
characteristics:
  - independent_services: loosely coupled
  - own_database: each service owns its data
  - api_gateway: single entry point
  - service_mesh: inter-service communication

  pros:
    - independent_deployment
    - technology_diversity
    - fault_isolation
    - team_autonomy

  cons:
    - distributed_complexity
    - data_consistency challenges
    - operational_overhead
    - network_latency

  when_to_use:
    - multiple_teams
    - high_scaling_requirements
    - diverse_technology_needs
    - fault_isolation_critical
```

### EVENT-DRIVEN ARCHITECTURE
```yaml
characteristics:
  - event_producers: emit events
  - event_broker: kafka, rabbitmq, etc.
  - event_consumers: process events

  patterns:
    - event_sourcing: store events as source of truth
    - cqrs: command_query_responsibility_separation
    - saga: distributed_transactions

  pros:
    - loose_coupling
    - async_processing
    - real_time_updates
    - scalability

  cons:
    - complexity
    - eventual_consistency
    - debugging_difficulty
    - message_ordering

  when_to_use:
    - async_processing_needed
    - real_time_updates_required
    - high_scalability_needed
    - multiple_producers_consumers
```

---

## Architecture Review Checklist

### Principles
- [ ] High cohesion: Related functionality grouped together
- [ ] Low coupling: Minimal dependencies between components
- [ ] Separation of concerns: Different concerns handled separately
- [ ] Single responsibility: Each component has one reason to change

### Design
- [ ] Components identified and responsibilities assigned
- [ ] Interfaces defined and clear
- [ ] Relationships mapped
- [ ] Data flow documented

### Cross-cutting
- [ ] Authentication addressed
- [ ] Authorization addressed
- [ ] Logging planned
- [ ] Monitoring planned
- [ ] Caching strategy defined

### Scalability
- [ ] Horizontal scaling possible (stateless design)
- [ ] Vertical scaling feasible (resource efficiency)
- [ ] Data partitioning strategy (sharding/federation)
- [ ] Caching strategy appropriate

### Integration
- [ ] API design follows RESTful principles
- [ ] Data exchange format standardized
- [ ] Resilience patterns (circuit breaker, retry logic)
- [ ] Timeout handling defined

---

## Output Template

```markdown
# Architecture Review Report: [Project/Feature]

**Review Date:** [Date]
**Reviewers:** Architect Agent + Staff Engineer Agent
**Project/Feature:** [Name]

---

## Executive Summary

**Overall Architecture Quality:** [Score]/10
**Architecture Pattern:** [Detected Pattern]
**Scalability Rating:** [High/Medium/Low]
**Maintainability Rating:** [High/Medium/Low]
**Status:** [✅ SOUND | ⚠️ NEEDS IMPROVEMENT | ❌ PROBLEMATIC]

---

## Architecture Pattern Analysis

### Detected Pattern(s)
- [Pattern 1]
- [Pattern 2]

### Pattern Assessment
**Current Pattern:** [HEXAGONAL/LAYERED/MICROSERVICES/etc.]

**Fit for Purpose:**
- [✅/⚠️/❌] Appropriate for domain
- [✅/⚠️/❌] Scales as needed
- [✅/⚠️/❌] Team can maintain
- [✅/⚠️/❌] Operationally feasible

**Recommendations:**
[If pattern doesn't fit, recommend alternatives]

---

## Architecture Principles Review

### High Cohesion
**Status:** [✅/⚠️/❌]
**Findings:**
[Detailed assessment]

### Low Coupling
**Status:** [✅/⚠️/❌]
**Findings:**
[Detailed assessment]

### Separation of Concerns
**Status:** [✅/⚠️/❌]
**Findings:**
[Detailed assessment]

---

## Technical Design Assessment

### Component Design
[Assessment of component structure]

### Data Flow
[Assessment of data flow]

### Integration Points
[Assessment of integrations]

### Error Handling
[Assessment of error handling strategy]

---

## Cross-Service Impact Analysis

### Direct Impact
| Service | Impact Level | Affected Components | Users Affected |
|---------|-------------|-------------------|----------------|
| [Service] | [High/Med/Low] | [Components] | [Users] |

### Indirect Impact
| Service | Impact Level | Affected Components | Users Affected |
|---------|-------------|-------------------|----------------|
| [Service] | [High/Med/Low] | [Components] | [Users] |

### Dependency Analysis
| Dependency | Type | Health | Risk | Mitigation |
|------------|------|--------|------|------------|
| [Dependency] | [Type] | [Health] | [Risk] | [Mitigation] |

---

## Scalability Analysis

### Current Scalability
**Horizontal Scaling:** [Possible/Not Possible]
**Vertical Scaling:** [Possible/Not Possible]
**Data Partitioning:** [Implemented/Not Implemented]

### Bottlenecks Identified
1. [Bottleneck 1]
2. [Bottleneck 2]

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]

---

## Findings

### Critical Issues (Must Fix)
| Issue | Impact | Fix |
|-------|--------|-----|
| [Issue] | [Impact] | [Fix] |

### High Issues (Should Fix)
| Issue | Impact | Fix |
|-------|--------|-----|
| [Issue] | [Impact] | [Fix] |

### Medium Issues (Nice to Have)
| Issue | Impact | Fix |
|-------|--------|-----|
| [Issue] | [Impact] | [Fix] |

---

## Architecture Scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Maintainability | [1-10] | [Notes] |
| Scalability | [1-10] | [Notes] |
| Reliability | [1-10] | [Notes] |
| Performance | [1-10] | [Notes] |
| Security | [1-10] | [Notes] |
| **Overall** | **[1-10]** | [Notes] |

---

## Recommendations

### Immediate (Before Merge/Deploy)
1. [Recommendation 1]
2. [Recommendation 2]

### Short Term (Next Sprint)
1. [Recommendation 1]
2. [Recommendation 2]

### Long Term (Technical Roadmap)
1. [Recommendation 1]
2. [Recommendation 2]

---

## Decision

**Status:** [✅ APPROVED | ⚠️ CONDITIONAL | ❌ REJECTED]

**Rationale:**
[Reasoning for decision]

**Conditions (if CONDITIONAL):**
- [Condition 1]
- [Condition 2]

**Blocking Issues (if REJECTED):**
- [Issue 1]
- [Issue 2]

---

**Report Generated:** [Timestamp]
**Reviewed by:** Architect Agent + Staff Engineer Agent
```

---

## Success Criteria

- [ ] Architectural pattern identified and assessed
- [ ] Architecture principles evaluated
- [ ] Technical design reviewed
- [ ] Cross-service impact analyzed
- [ ] Dependencies mapped
- [ ] Scalability assessed
- [ ] Integration points reviewed
- [ ] Findings documented with severity
- [ ] Recommendations provided
- [ ] Scorecard completed

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Primary Agents:** duck:architect, duck:staff
