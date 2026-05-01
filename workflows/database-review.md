---
name: database-review
description: Database schema & query review with Database Expert and Architect agents
version: "2.0.0"
category: "team"
origin: "agent-skills"
agents_used:
  - "duck:database"
  - "duck:architect"
skills_used:
  - "backend-patterns"
  - "code-review"
  - "performance-optimization"
  - "database-migrations"
estimated_time: "2-4 hours"
---

# Database Review Workflow

## Overview

The Database Review workflow provides comprehensive assessment of database schema, queries, migrations, and data architecture. It combines the Database Expert's deep knowledge of database patterns with the Architect's system-wide perspective.

## When to Use

- New database schema design
- Database migration planning
- Query performance optimization
- Data architecture review
- Fintech ledger & audit trail design
- Database scaling strategy

## Lifecycle

DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE

### Phase Mapping

| Lifecycle Phase | Workflow Stage |
|-----------------|----------------|
| DEFINE | Identify schema, queries, and migration scope |
| PLAN | Database Schema & Query Review (Stage 1) |
| BUILD | Implement schema changes and query optimizations |
| VERIFY | Data Architecture Review (Stage 2) |
| REVIEW | Consolidated Database Assessment (Stage 3) |
| SHIP | Migration plan approved and deployed |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] Schema definition (DDL) provided
- [ ] Query lists compiled
- [ ] Migration scripts identified
- [ ] Performance requirements defined
PASS → proceed | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Schema design reviewed (normalization, naming, types)
- [ ] Query performance assessed
- [ ] Indexing strategy evaluated
- [ ] Migration plan reviewed
- [ ] Data integrity verified
PASS → proceed | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Schema changes implemented
- [ ] Query optimizations applied
- [ ] Indexes created
PASS → proceed | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] Data architecture assessed in system context
- [ ] Integration points reviewed
- [ ] Data flow evaluated
- [ ] Scalability assessed
PASS → proceed | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Findings merged and prioritized
- [ ] Bottlenecks identified
- [ ] Recommendations actionable
- [ ] Migration plan validated
- [ ] Scorecard completed
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

### Stage 1: Database Schema & Query Review (Database Expert)

**Agent:** `duck:database`

**Actions:**
- Review schema design (normalization, naming, types)
- Analyze query performance
- Assess indexing strategy
- Review migration plan
- Evaluate data integrity
- Review fintech patterns (if applicable)

**Input:**
- Schema definition (DDL)
- Query lists
- Migration scripts
- Performance requirements

**Output:** Database Expert Review Report

**Quality Gate:**
- [ ] Schema design reviewed
- [ ] Query performance assessed
- [ ] Indexing strategy evaluated
- [ ] Migration plan reviewed
- [ ] Data integrity verified

---

### Stage 2: Data Architecture Review (Architect)

**Agent:** `duck:architect`

**Actions:**
- Assess data architecture in system context
- Review integration points
- Evaluate data flow
- Assess scalability of data layer
- Review data consistency strategy

**Input:**
- Database review findings
- System architecture
- Integration requirements

**Output:** Data Architecture Assessment

**Quality Gate:**
- [ ] Data architecture assessed
- [ ] Integration points reviewed
- [ ] Data flow evaluated
- [ ] Scalability assessed

---

### Stage 3: Consolidated Database Assessment

**Agents:** `duck:database` + `duck:architect`

**Actions:**
- Merge database and architecture findings
- Identify data-related bottlenecks
- Prioritize optimizations
- Create actionable recommendations

**Output:** Consolidated Database Review Report

**Quality Gate:**
- [ ] Findings merged
- [ ] Bottlenecks identified
- [ ] Recommendations prioritized
- [ ] Migration plan validated

---

## Handoff Contracts

### To Database Expert
```yaml
provides:
  - schema_definition
  - query_lists
  - migration_scripts
  - performance_requirements
  - data_models

expects:
  - schema_review
  - query_optimization
  - migration_review
  - scaling_recommendations
  - fintech_patterns_review (if applicable)
```

### Database Expert → Architect
```yaml
provides:
  - schema_assessment
  - query_performance_analysis
  - indexing_recommendations
  - data_integrity_review

expects:
  - data_architecture_review
  - integration_assessment
  - scalability_analysis
  - data_flow_evaluation
```

---

## Database Review Framework

### Schema Design Review
```yaml
normalization:
  1nf:
    - eliminate_repeating_groups
    - each_column_atomic
    - no_repeating_groups

  2nf:
    - eliminate_partial_dependencies
    - all_non_key_columns dependent_on_entire_key

  3nf:
    - eliminate_transitive_dependencies
    - no_transitive_dependencies

  bcnf:
    - boyce_codd_normal_form
    - every_determinant is_candidate_key

design_checks:
  naming_convention:
    - tables: snake_case, plural
    - columns: snake_case
    - indexes: idx_table_columns
    - foreign_keys: fk_table_column

  data_types:
    - appropriate_types_chosen
    - no_oversized_columns
    - use_decimal_for_money
    - use_uuid_or_int_for_ids

  constraints:
    - primary_keys_defined
    - foreign_keys_with_cascade
    - unique_constraints
    - check_constraints
    - not_null_where_appropriate

  indexes:
    - primary_key_indexed
    - foreign_keys_indexed
    - query_columns_indexed
    - composite_indexes_for_multi_column
```

### Query Optimization Review
```yaml
performance_analysis:
  query_patterns:
    - n_plus_1_problems
    - unnecessary_serialization
    - missing_caching
    - over_fetching
    - chatty_api
    - cartesian_explosion

  indexing_strategy:
    - b_tree_index: default, equality_and_range
    - composite_index: multi_column_queries
    - partial_index: filter_conditions
    - unique_index: uniqueness_constraints
    - covering_index: include_additional_columns
    - hash_index: equality_only
    - gin_index: json_array_columns
    - brin_index: very_large_tables

  optimization_techniques:
    - batch_queries: reduce_round_trips
    - eager_loading: avoid_n_plus_1
    - query_result_caching: cache_expensive_queries
    - select_only_needed: avoid_select_star
    - keyset_pagination: avoid_offset
```

### Migration Strategy Review
```yaml
zero_downtime_migrations:
  phase_1_prepare:
    - create_new_table_or_column
    - backfill_data
    - create_indexes
    - verify_data

  phase_2_deploy_code:
    - deploy_code_that_writes_both
    - enable_dual_write
    - monitor_for_errors

  phase_3_backfill:
    - backfill_any_missing_data
    - verify_data_consistency
    - run_validation_queries

  phase_4_deploy_read:
    - deploy_code_that_reads_new
    - monitor_for_errors
    - verify_behavior

  phase_5_cleanup:
    - stop_writing_to_old
    - remove_old_code
    - drop_old_table_or_column
```

### Fintech Patterns Review (if applicable)
```yaml
double_entry_bookkeeping:
  - accounts_table: asset, liability, equity, revenue, expense
  - journal_entries: entry_number, date, description, status
  - journal_entry_lines: debit, credit must_balance
  - balance_validation: triggers for double_entry

audit_trail:
  - audit_logs: immutable table
  - track_all_changes: insert, update, delete
  - old_data_and_new_data: jsonb columns
  - changed_columns: array of modified columns
  - audit_trigger: automatic logging

data_integrity:
  - acid_compliance: transactions
  - constraints: not_null, check, unique, foreign_key
  - validations: at_database_level
  - error_handling: proper rollback
```

---

## Output Template

```markdown
# Database Review Report: [Project/Feature]

**Review Date:** [Date]
**Reviewers:** Database Expert + Architect
**Project/Feature:** [Name]

---

## Executive Summary

**Overall Database Quality:** [Score]/10
**Schema Quality:** [Excellent/Good/Fair/Poor]
**Query Performance:** [Excellent/Good/Fair/Poor]
**Scalability:** [High/Medium/Low]
**Status:** [✅ APPROVED | ⚠️ NEEDS IMPROVEMENT | ❌ PROBLEMATIC]

---

## Schema Review

### Schema Design
[Assessment of schema design, normalization, naming]

### Data Types
[Appropriate use of data types]

### Constraints
[Primary keys, foreign keys, check constraints]

### Indexes
[Index strategy and coverage]

**Findings:**
| Severity | Issue | Table | Fix |
|----------|-------|-------|-----|
| [C/H/M/L] | [Issue] | [Table] | [Fix] |

---

## Query Performance

### Slow Queries
[Analysis of slow queries]

### Index Coverage
[Assessment of index coverage]

### Optimization Opportunities
[Specific optimizations]

**Findings:**
| Severity | Query | Issue | Fix |
|----------|-------|-------|-----|
| [C/H/M/L] | [Query] | [Issue] | [Fix] |

---

## Fintech Patterns (if applicable)

### Ledger Design
[Assessment of ledger implementation]

### Audit Trail
[Assessment of audit trail implementation]

**Findings:**
| Severity | Issue | Component | Fix |
|----------|-------|-----------|-----|
| [C/H/M/L] | [Issue] | [Component] | [Fix] |

---

## Migration Review

### Migration Strategy
[Assessment of migration approach]

### Zero-Downtime Plan
[If applicable]

**Findings:**
| Severity | Issue | Migration | Fix |
|----------|-------|-----------|-----|
| [C/H/M/L] | [Issue] | [Migration] | [Fix] |

---

## Data Architecture

### Data Flow
[Assessment of data flow in system context]

### Integration Points
[Assessment of how database integrates with system]

### Scalability
[Assessment of data layer scalability]

**Findings:**
| Severity | Issue | Impact | Fix |
|----------|-------|--------|-----|
| [C/H/M/L] | [Issue] | [Impact] | [Fix] |

---

## Data Integrity

### ACID Compliance
[Assessment of transaction handling]

### Constraints
[Assessment of constraints]

### Data Validation
[Assessment of data validation]

---

## Findings Summary

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

## Recommendations

### Immediate (Before Deploy)
1. [Recommendation 1]
2. [Recommendation 2]

### Short Term (Next Sprint)
1. [Recommendation 1]
2. [Recommendation 2]

### Long Term (Technical Roadmap)
1. [Recommendation 1]
2. [Recommendation 2]

---

## Database Scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Schema Design | [1-10] | [Notes] |
| Query Performance | [1-10] | [Notes] |
| Data Integrity | [1-10] | [Notes] |
| Scalability | [1-10] | [Notes] |
| Security | [1-10] | [Notes] |
| **Overall** | **[1-10]** | [Notes] |

---

## Decision

**Status:** [✅ APPROVED | ⚠️ NEEDS IMPROVEMENT | ❌ PROBLEMATIC]

**Summary:**
[Brief summary of database quality and main recommendations]

**Blocking Issues:**
[List any issues that should block progress]

---

**Report Generated:** [Timestamp]
**Reviewed by:** Database Expert + Architect
```

---

## Success Criteria

- [ ] Schema design reviewed
- [ ] Data types assessed
- [ ] Constraints evaluated
- [ ] Indexes analyzed
- [ ] Query performance assessed
- [ ] Fintech patterns reviewed (if applicable)
- [ ] Migration strategy evaluated
- [ ] Data integrity verified
- [ ] Scalability analyzed
- [ ] Findings documented with severity
- [ ] Recommendations provided
- [ ] Scorecard completed

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Primary Agents:** duck:database, duck:architect
