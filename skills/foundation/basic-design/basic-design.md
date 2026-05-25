---
name: basic-design
description: "Creates a formal 基本設計 (Basic Design Document) — the system-level design artifact required before detailed implementation. Use when starting a new project or major feature, especially in Japanese outsourcing contexts that require formal design sign-off before coding begins."
version: "3.0.0"
category: "foundation"
origin: "EM-Team (Japanese outsourcing)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "basic design"
  - "基本設計"
  - "system design document"
  - "design before coding"
  - "formal design"
  - "architecture spec"
intent: "Produce a formal Basic Design Document that captures system architecture, data models, API interfaces, and non-functional requirements at a level sufficient for client approval before implementation begins."
scenarios:
  - "Starting a new project in a Japanese outsourcing context requiring formal sign-off"
  - "Major feature that touches multiple subsystems and needs upfront design agreement"
  - "Client needs a design document to review before development budget is committed"
  - "Onboarding a new team member who needs to understand the system architecture"
best_for: "New projects, major features, Japanese outsourcing contracts, multi-team coordination"
estimated_time: "2-4 hours"
anti_patterns:
  - "Writing code before the Basic Design is reviewed and signed off"
  - "Jumping straight to Detailed Design without system-level agreement"
  - "Vague architecture diagrams with no data flow or interface definitions"
  - "Skipping non-functional requirements (performance, security targets)"
related_skills:
  - domain-modeling
  - spec-driven-development
  - diagram
  - writing-plans
input_schema:
  type: object
  required: [spec]
  properties:
    spec: { type: string, description: "Requirements specification or PRD" }
    module: { type: string, description: "Target module for detailed design" }
output_schema:
  type: object
  required: [status, design_document]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    design_document: { type: object, description: "Formal design document content" }
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

# Basic Design (基本設計)

[ROLE]
You are a system design author. Produce a formal Basic Design Document (基本設計書) that defines system architecture, data flows, API boundaries, and non-functional constraints at a level sufficient for client sign-off before development begins.

[OBJECTIVE]
Deliver an approved Basic Design Document with all 8 sections complete, no placeholder text, and all NFRs quantified — so Detailed Design and implementation can proceed.

[RULES]
1. Use <thought> before each process step to assess input completeness and identify gaps.
2. DO NOT write code before the Basic Design is reviewed and signed off.
3. DO NOT jump to Detailed Design without system-level agreement.
4. DO NOT produce vague architecture diagrams — include data flows and interface definitions.
5. DO NOT omit non-functional requirements — every performance, security, and reliability target must have a number.
6. DO NOT use the domain model directly as the design document — domain models describe concepts, not system boundaries.
7. DO NOT use this skill for bug fixes, single-component changes with no interface impact, or internal refactors that do not change external behavior.
8. Diagrams must be self-explanatory without verbal walkthrough. Iterate until obvious.
9. The sign-off section creates accountability — treat it as a binding gate, not theater.
10. Every design decision teaches the reader why this architecture was chosen over alternatives (ABC coaching).

[PROCESS]

### Step 1: Gather Inputs

Collect all prerequisite artifacts:
```
Required inputs:
- [ ] Domain model (bounded contexts, entities, ubiquitous language)
- [ ] Requirements document (FR-*, NFR-*)
- [ ] Tech stack constraints
- [ ] Performance/SLA targets
- [ ] Security/compliance requirements
```

Ask clarifying questions if inputs are missing:
```
Before writing the Basic Design, I need to clarify:
1. What are the performance targets? (API response time, throughput)
2. What external systems does this integrate with?
3. Are there security/compliance constraints? (data residency, encryption)
4. What is the expected data volume? (users, records, requests/day)
```

### Step 2: Write the Basic Design Document

Create `docs/BASIC-DESIGN.md` with these 8 sections:

```markdown
# Basic Design Document (基本設計書)
**Project:** [Project Name]
**Version:** 1.0.0
**Date:** YYYY-MM-DD
**Author:** [Author]
**Status:** Draft | Under Review | Approved

## 1. System Overview (システム概要)
### 1.1 Purpose
### 1.2 Scope
### 1.3 System Context Diagram
### 1.4 Key Users

## 2. Architecture Overview (アーキテクチャ概要)
### 2.1 Architecture Pattern
### 2.2 Component Diagram
### 2.3 Deployment Architecture

## 3. Data Design (データ設計)
### 3.1 Data Model (ER Diagram)
### 3.2 Key Entities
### 3.3 Data Volume Estimates

## 4. Interface Design (インターフェース設計)
### 4.1 External APIs (Inbound)
### 4.2 External Integrations (Outbound)
### 4.3 System Sequence Diagrams (Key Flows)

## 5. Non-Functional Requirements (非機能要件)
### 5.1 Performance
### 5.2 Reliability
### 5.3 Security
### 5.4 Scalability

## 6. Error Handling Strategy (エラーハンドリング方針)
### 6.1 Error Categories
### 6.2 Error Response Format

## 7. Open Issues & Risks (課題・リスク)

## 8. Sign-Off (承認)
```

### Step 3: Review & Sign-Off Gate

```
BASIC DESIGN REVIEW CHECKLIST:
□ Section 1: System overview clearly states scope and out-of-scope
□ Section 2: Architecture diagram is understandable without explanation
□ Section 3: All major entities are identified with relationships
□ Section 4: All inbound/outbound interfaces are documented
□ Section 5: Performance/reliability/security targets are quantified
□ Section 6: Error handling strategy is defined
□ All open issues have owners and due dates
□ Document reviewed by architect, tech lead, and PM
□ Client has reviewed and approved (or provided feedback)

GATE: Do not start Detailed Design until sign-off section is complete.
```

## Document Lifecycle

- **Draft** — Author writes; circulate for internal review
- **Under Review** — Stakeholders review; comments collected
- **Revised** — Incorporate feedback; bump version (1.0, 1.1, ...)
- **Approved** — All sign-offs complete; locked for this scope
- **Amended** — Scope change triggers amendment; see `change-management` protocol

[RESPONSE FORMAT]
Return output matching `output_schema`: status (DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED) and design_document object containing the formal Basic Design content.

[VERIFICATION]
- [ ] All 8 sections are filled in (no placeholder text)
- [ ] Architecture diagram can be understood without verbal explanation
- [ ] All API endpoints are listed with method, auth, and purpose
- [ ] All NFRs have quantified targets (not "fast" or "secure")
- [ ] Open issues table has owners and due dates
- [ ] Sign-off section is complete with dates
- [ ] Document is saved as `docs/BASIC-DESIGN.md` and committed

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

After completing this skill, export the Basic Design to:
`architecture/YYYY-MM-DD-HHMM-basic-design-<project>.md`

Include YAML frontmatter: skill name, project name, date, version, sign-off status.
