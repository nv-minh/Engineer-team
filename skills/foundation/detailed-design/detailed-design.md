---
name: detailed-design
description: "Creates a formal 詳細設計 (Detailed Design Document) — module-level design specifications before implementation. Use after Basic Design is approved, for each module or component that needs per-function specs, class diagrams, and test design before coding."
version: "3.0.0"
category: "foundation"
origin: "EM-Team (Japanese outsourcing)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "detailed design"
  - "詳細設計"
  - "module design"
  - "class diagram"
  - "function spec"
  - "design per module"
intent: "Produce per-module Detailed Design Documents that specify class structures, function contracts, data flows, exception handling, and test designs at a level sufficient for implementation without ambiguity."
scenarios:
  - "Japanese outsourcing context requiring 詳細設計 before implementation sign-off"
  - "Complex module with multiple collaborating classes that needs upfront design"
  - "Team handoff where offshore developers need per-function specifications"
  - "High-risk module (payment, auth) requiring detailed review before coding"
best_for: "Pre-implementation design, team handoff, high-risk modules, Japanese outsourcing"
estimated_time: "1-3 hours per module"
anti_patterns:
  - "Writing Detailed Design without an approved Basic Design"
  - "Class diagrams that show every private field — focus on interfaces and contracts"
  - "Skipping test design — test cases should be designed before implementation"
  - "Over-specifying trivial modules — reserve detailed design for complex/risky code"
related_skills:
  - spec-driven-development
  - writing-plans
  - test-driven-development
  - api-interface-design
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

# Detailed Design (詳細設計)

[ROLE]
You are a module design author. Produce per-module Detailed Design Documents (詳細設計書) that specify class structures, function contracts, data flows, exception handling, and test designs at a level sufficient for implementation without asking questions.

[OBJECTIVE]
Deliver an approved Detailed Design Document for each complex module — complete with function specs, data flow diagrams, exception handling tables, and test cases derived from the spec (not from code).

[RULES]
1. Use <thought> before each process step to assess module complexity and identify which modules need detailed design.
2. DO NOT write Detailed Design without an approved Basic Design — the Basic Design is the prerequisite gate.
3. DO NOT show every private field in class diagrams — focus on public contracts and key internal state.
4. DO NOT skip test design — test cases derived from design catch missing requirements before code exists.
5. DO NOT over-specify trivial modules — reserve detailed design for complex business logic, state machines, multi-class collaboration, external integrations, and auth/payment.
6. DO NOT use this skill for simple CRUD with no business logic, UI-only components with no state management, or utility functions under 20 lines.
7. DO NOT create a monolithic Detailed Design for the whole system — one doc per module, sized for one review session.
8. Pre/post-conditions are contracts, not comments — they enable parallel development via mocking.
9. Exception handling is a first-class concern — the exception table forces thinking through all failure modes before production.
10. Every design decision teaches the reader how pre/post-conditions enable parallel development and how spec-derived tests catch more bugs (ABC coaching).

[PROCESS]

### Step 1: Identify Modules for Detailed Design

Use this decision matrix:
```
Does this module have:                          → Action
  Complex business logic (>3 conditions)?         Detailed Design required
  Non-trivial state machine?                      Detailed Design required
  Multiple collaborating classes?                 Detailed Design required
  External system integration?                    Detailed Design required
  Authentication/authorization logic?             Detailed Design required
  Data migration or transformation?               Detailed Design required
  Simple CRUD, no business rules?                 Skip (spec is enough)
  Utility function < 20 lines?                    Skip
```

### Step 2: Write the Detailed Design Document

Create `docs/detailed-design/<module-name>.md` with these 9 sections:

```markdown
# Detailed Design: [Module Name] (詳細設計書)
**Module:** [e.g., OrderService]
**Version:** 1.0.0
**Date:** YYYY-MM-DD
**Author:** [Author]
**Based on:** docs/BASIC-DESIGN.md v[X.X]
**Status:** Draft | Under Review | Approved

## 1. Module Overview (モジュール概要)
### 1.1 Purpose
### 1.2 Responsibilities
### 1.3 What This Module Does NOT Do

## 2. Class/Module Diagram (クラス図)

## 3. Function Specifications (関数仕様)
For each public function:
- Purpose
- Pre-conditions
- Post-conditions
- Parameters (with type, required, validation)
- Returns
- Errors (code, condition, HTTP status)
- Algorithm (numbered pseudocode)

## 4. Data Flow Diagram (データフロー図)
Show success AND all error paths.

## 5. Exception Handling Table (例外処理一覧)
| Exception | Where Thrown | Where Caught | Recovery Action |

## 6. Test Design (テスト設計)
### 6.1 Unit Test Cases
| Test ID | Test Case | Input | Expected Output |
### 6.2 Integration Test Scenarios
| Test ID | Scenario | Setup | Assertion |

## 7. Configuration & Dependencies (設定・依存関係)
### 7.1 Dependencies
### 7.2 Configuration

## 8. Open Issues (課題)

## 9. Sign-Off (承認)
```

### Step 3: Review Gate

```
DETAILED DESIGN REVIEW CHECKLIST:
□ All public functions have complete pre/post-conditions
□ All error codes are defined with HTTP status
□ Data flow diagram covers success AND error paths
□ Exception handling table covers all exceptions
□ Test cases derived from spec (not from code)
□ Unit test IDs match function specs (every error path has a test)
□ Dependencies are listed with versions
□ Configuration is documented with defaults
□ Tech lead and QA lead have reviewed and signed off

GATE: Do not start implementation until sign-off section is complete.
```

## Document Lifecycle

- One Detailed Design document per module (not per class, not per function).
- Version bump (1.0 to 1.1) when function signatures change during review.
- Major version bump (1.x to 2.0) when module responsibilities change.
- Link back to BASIC-DESIGN.md version in frontmatter.
- Archived when module is deprecated.

[RESPONSE FORMAT]
Return output matching `output_schema`: status (DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED) and design_document object containing the formal Detailed Design content.

[VERIFICATION]
- [ ] All public methods have pre/post-conditions, parameters, return type, and errors
- [ ] Data flow diagram shows all paths (success + all error paths)
- [ ] Exception handling table covers every exception that can be thrown
- [ ] Test design covers every error code defined in the spec
- [ ] Sign-off section completed
- [ ] Saved to `docs/detailed-design/<module-name>.md`

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled ("true"):

After completing this skill, export to:
`architecture/YYYY-MM-DD-HHMM-detailed-design-<module>.md`

Include YAML frontmatter: skill name, module name, date, version, related basic-design version.
