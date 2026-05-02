#!/bin/bash
# db-review.sh - Database review with Database Expert and Architect
# Usage: em-team db-review [database_description]

set -e

# Description
echo "🗄️  Database Review - Schema & Query Assessment"
echo ""
echo "This command performs a comprehensive database review involving:"
echo "  - Database Expert (schema, queries, migrations, fintech patterns)"
echo "  - Architect (data architecture, integration, scalability)"
echo ""

# Check if database description is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide a database description"
    echo ""
    echo "Usage: em-team db-review \"[database description]\""
    echo ""
    echo "Example:"
    echo "  em-team db-review \"Review schema for payment ledger system\""
    echo "  em-team db-review \"Assess query performance for reporting dashboard\""
    echo "  em-team db-review \"Review migration strategy for user table split\""
    exit 1
fi

DB_DESCRIPTION="$*"

echo "📋 Database: $DB_DESCRIPTION"
echo ""

# Create workflow document
WORKFLOW_FILE=".planning/database-review-workflow.md"
mkdir -p .planning

cat > "$WORKFLOW_FILE" << EOF
# Database Review Workflow

**Date:** $(date +%Y-%m-%d)
**Database:** $DB_DESCRIPTION

## Review Plan

### Stage 1: Database Schema & Query Review (Database Expert)
**Agent:** \`em-agent:database-expert\`
**Trigger:** "Agent: database-expert - Review database for: $DB_DESCRIPTION"

**Assessment:**
- Schema design (normalization, naming, types)
- Query performance and optimization
- Indexing strategy
- Migration plan
- Data integrity (ACID, constraints)
- Fintech patterns (ledger, audit trail) if applicable

### Stage 2: Data Architecture Review (Architect)
**Agent:** \`em-agent:architect\`
**Trigger:** "Agent: architect - Review data architecture for: $DB_DESCRIPTION"

**Assessment:**
- Data architecture in system context
- Integration points
- Data flow
- Scalability of data layer
- Data consistency strategy

### Stage 3: Consolidated Database Assessment
**Agents:** \`em-agent:database-expert\` + \`em-agent:architect\`

**Output:**
- Merged database and architecture findings
- Data-related bottlenecks
- Prioritized optimizations
- Validated migration plan

## Database Review Framework

### Schema Design
- Normalization (1NF, 2NF, 3NF, BCNF)
- Naming conventions (snake_case, plural)
- Data types (appropriate, no oversized)
- Constraints (primary keys, foreign keys, unique, check)
- Indexes (primary, foreign, composite, partial)

### Query Optimization
- N+1 query problems
- Unnecessary serialization
- Missing caching
- Over-fetching
- Chatty API
- Cartesian explosion

### Indexing Strategies
- B-tree: default, equality and range
- Composite: multi-column queries
- Partial: filter conditions
- Unique: uniqueness constraints
- Covering: include additional columns
- Hash: equality only
- GIN: JSON/array columns
- BRIN: very large tables

### Migration Strategy
- Phase 1: Prepare (create new, backfill, indexes)
- Phase 2: Deploy code (dual write)
- Phase 3: Backfill (missing data, validate)
- Phase 4: Deploy read (read new)
- Phase 5: Cleanup (remove old)

### Fintech Patterns (if applicable)
- Double-entry bookkeeping (accounts, journal entries, lines)
- Audit trail (immutable logs, old/new data)
- Balance validation (debits = credits)

## Quality Gates

- [ ] Schema design reviewed
- [ ] Data types assessed
- [ ] Constraints evaluated
- [ ] Indexes analyzed
- [ ] Query performance assessed
- [ ] Migration strategy evaluated
- [ ] Data integrity verified
- [ ] Scalability analyzed
- [ ] Scorecard completed

## Output

Consolidated Database Review Report with:
- Executive Summary
- Schema Review
- Query Performance
- Fintech Patterns (if applicable)
- Migration Review
- Data Architecture
- Findings and Recommendations
- Database Scorecard
- Decision
EOF

echo "✅ Workflow document created: $WORKFLOW_FILE"
echo ""

# Trigger Database Expert agent
echo "🚀 Starting Database Review..."
echo ""
echo "Trigger: Agent: database-expert - Review database for: $DB_DESCRIPTION"
echo "Then: Agent: architect - Review data architecture"
echo ""
echo "The review will assess:"
echo "  - Schema design and normalization"
echo "  - Query performance and optimization"
echo "  - Indexing strategy"
echo "  - Migration plan"
echo "  - Data integrity"
echo "  - Fintech patterns (if applicable)"
echo "  - Data architecture in system context"
echo ""
echo "📝 Next Steps:"
echo "  1. Review the workflow document: $WORKFLOW_FILE"
echo "  2. Trigger Database Expert for schema and query review"
echo "  3. Trigger Architect for data architecture review"
echo "  4. Review consolidated report"
echo ""
echo "🔗 Reference: database-review workflow"
echo ""
