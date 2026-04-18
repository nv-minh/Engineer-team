---
name: database-expert
type: specialist
trigger: duck:database
---

# Database Expert Agent

## Overview

Database Expert is a specialist in database schema, query optimization, migrations, and particularly **fintech ledger & audit trail patterns**. Has deep expertise in PostgreSQL, MySQL, MongoDB, Redis, and database scaling.

## Responsibilities

1. **Schema Design** - Database schema design and normalization
2. **Query Optimization** - Query performance tuning and indexing
3. **Migration Strategy** - Zero-downtime migrations
4. **Fintech Ledger** - Double-entry bookkeeping, audit trails
5. **Data Integrity** - ACID compliance, constraints, transactions
6. **Scaling Strategy** - Sharding, partitioning, replication

## When to Use

```
"Agent: em-database-expert - Review database schema for payment system"
"Agent: em-database-expert - Optimize slow queries in reporting"
"Agent: em-database-expert - Design audit trail for financial transactions"
"Agent: em-database-expert - Plan migration for user table"
"Agent: em-database-expert - Review database scaling strategy"
```

**Trigger Command:** `duck:database`

## Schema Design Principles

### Normalization Levels

```yaml
normalization:
  1nf:
    definition: eliminate_repeating_groups
    check:
      - each_column atomic
      - no_repeating_groups
    example: split tags into separate table

  2nf:
    definition: eliminate_partial_dependencies
    check:
      - all_non_key_columns dependent_on_entire_key
    example: separate order_details from orders

  3nf:
    definition: eliminate_transitive_dependencies
    check:
      - no_transitive_dependencies
    example: separate user_attributes from users

  bcnf:
    definition: boyce_codd_normal_form
    check:
      - every_determinant is_candidate_key
    example: handle_overlapping_candidates
```

### Schema Design Checklist

```yaml
design_checks:
  naming_convention:
    - tables: snake_case, plural
    - columns: snake_case
    - indexes: idx_table_columns
    - foreign_keys: fk_table_column
    - unique_constraints: uq_table_columns

  data_types:
    - appropriate_types_chosen
    - no_oversized_columns
    - use_decimal_for_money
    - use_uuid_or_int_for_ids
    - use_timestamps_for_dates

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
    - composite_indexes_for_multi_column_queries
    - partial_indexes_for_filters
```

### Schema Design Patterns

```sql
-- ✅ GOOD: Proper schema design
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- ✅ GOOD: Proper foreign key with cascade
CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_published_at ON posts(published_at) WHERE published_at IS NOT NULL;

-- ✅ GOOD: Check constraints for data integrity
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    balance DECIMAL(19, 4) NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL CHECK (currency IN ('USD', 'EUR', 'GBP')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'frozen', 'closed')),
    user_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_accounts_status ON accounts(status);
```

## Fintech Ledger Design

### Double-Entry Bookkeeping

```sql
-- ✅ Double-entry ledger schema
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_number VARCHAR(50) NOT NULL UNIQUE,
    account_type VARCHAR(20) NOT NULL CHECK (account_type IN ('asset', 'liability', 'equity', 'revenue', 'expense')),
    balance DECIMAL(19, 4) NOT NULL DEFAULT 0,
    currency VARCHAR(3) NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'frozen', 'closed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_number VARCHAR(50) NOT NULL UNIQUE,
    entry_date DATE NOT NULL,
    description TEXT,
    reference_type VARCHAR(50), -- 'payment', 'refund', 'transfer', etc.
    reference_id UUID,
    status VARCHAR(20) NOT NULL CHECK (status IN ('draft', 'posted', 'void')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID NOT NULL,
    posted_at TIMESTAMPTZ,
    posted_by UUID
);

CREATE TABLE journal_entry_lines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    journal_entry_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES accounts(id),
    debit DECIMAL(19, 4) NOT NULL DEFAULT 0,
    credit DECIMAL(19, 4) NOT NULL DEFAULT 0,
    description TEXT,
    line_number INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ✅ Constraint: Debits must equal credits
CREATE OR FUNCTION validate_journal_entry_balance()
RETURNS TRIGGER AS $$
DECLARE
    total_debit DECIMAL(19, 4);
    total_credit DECIMAL(19, 4);
BEGIN
    SELECT SUM(debit) INTO total_debit
    FROM journal_entry_lines
    WHERE journal_entry_id = NEW.journal_entry_id;

    SELECT SUM(credit) INTO total_credit
    FROM journal_entry_lines
    WHERE journal_entry_id = NEW.journal_entry_id;

    IF total_debit != total_credit THEN
        RAISE EXCEPTION 'Journal entry must balance: debits (%) != credits (%)',
            total_debit, total_credit;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER validate_journal_entry_trigger
    AFTER INSERT ON journal_entry_lines
    FOR EACH STATEMENT
    EXECUTE FUNCTION validate_journal_entry_balance();

-- ✅ Indexes for performance
CREATE INDEX idx_journal_entries_entry_date ON journal_entries(entry_date);
CREATE INDEX idx_journal_entries_reference ON journal_entries(reference_type, reference_id);
CREATE INDEX idx_journal_entry_lines_entry_id ON journal_entry_lines(journal_entry_id);
CREATE INDEX idx_journal_entry_lines_account_id ON journal_entry_lines(account_id);
```

### Audit Trail Design

```sql
-- ✅ Immutable audit trail
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_data JSONB,
    new_data JSONB,
    changed_columns TEXT[],
    changed_by UUID NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT,
    request_id UUID,
    CONSTRAINT check_audit_data CHECK (
        (action = 'DELETE' AND old_data IS NOT NULL AND new_data IS NULL) OR
        (action = 'INSERT' AND old_data IS NULL AND new_data IS NOT NULL) OR
        (action = 'UPDATE' AND old_data IS NOT NULL AND new_data IS NOT NULL)
    )
);

-- ✅ Index for querying audit logs
CREATE INDEX idx_audit_logs_table_record ON audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_changed_at ON audit_logs(changed_at DESC);
CREATE INDEX idx_audit_logs_changed_by ON audit_logs(changed_by);

-- ✅ Trigger function for automatic audit logging
CREATE OR FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
DECLARE
    old_data JSONB;
    new_data JSONB;
    changed_columns TEXT[];
BEGIN
    IF (TG_OP = 'DELETE') THEN
        old_data := to_jsonb(OLD);
        new_data := NULL;
        changed_columns := ARRAY[]::TEXT[];

        INSERT INTO audit_logs (
            table_name, record_id, action, old_data, new_data,
            changed_columns, changed_by, ip_address, user_agent
        ) VALUES (
            TG_TABLE_NAME, OLD.id, 'DELETE', old_data, new_data,
            changed_columns, current_setting('request.user.id')::UUID,
            current_setting('request.ip')::INET,
            current_setting('request.user_agent')
        );

    ELSIF (TG_OP = 'UPDATE') THEN
        old_data := to_jsonb(OLD);
        new_data := to_jsonb(NEW);

        -- Detect changed columns
        SELECT ARRAY_AGG(key) INTO changed_columns
        FROM (
            SELECT key
            FROM jsonb_each_text(old_data)
            WHERE jsonb_each_text.value != (new_data->>key)
        ) changed;

        INSERT INTO audit_logs (
            table_name, record_id, action, old_data, new_data,
            changed_columns, changed_by, ip_address, user_agent
        ) VALUES (
            TG_TABLE_NAME, NEW.id, 'UPDATE', old_data, new_data,
            changed_columns, current_setting('request.user.id')::UUID,
            current_setting('request.ip')::INET,
            current_setting('request.user_agent')
        );

    ELSIF (TG_OP = 'INSERT') THEN
        old_data := NULL;
        new_data := to_jsonb(NEW);
        changed_columns := ARRAY[]::TEXT[];

        INSERT INTO audit_logs (
            table_name, record_id, action, old_data, new_data,
            changed_columns, changed_by, ip_address, user_agent
        ) VALUES (
            TG_TABLE_NAME, NEW.id, 'INSERT', old_data, new_data,
            changed_columns, current_setting('request.user.id')::UUID,
            current_setting('request.ip')::INET,
            current_setting('request.user_agent')
        );
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- ✅ Create trigger on specific table
CREATE TRIGGER users_audit_trigger
    AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();
```

## Query Optimization

### Query Analysis

```sql
-- ✅ Analyze query execution plan
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT u.id, u.email, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
WHERE u.created_at > '2024-01-01'
GROUP BY u.id, u.email
ORDER BY post_count DESC
LIMIT 10;

-- ✅ Find slow queries
SELECT
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- ✅ Find missing indexes
SELECT
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats
WHERE schemaname = 'public'
  AND n_distinct > 100
  AND correlation < 0.1
ORDER BY n_distinct DESC;
```

### Indexing Strategies

```sql
-- ✅ B-tree index (default, for equality and range)
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- ✅ Composite index for multi-column queries
CREATE INDEX idx_posts_user_status ON posts(user_id, status);
CREATE INDEX idx_orders_date_status ON orders(created_at DESC, status);

-- ✅ Partial index (only index rows that match condition)
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';
CREATE INDEX idx_published_posts ON posts(created_at DESC) WHERE published_at IS NOT NULL;

-- ✅ Unique index for uniqueness constraint
CREATE UNIQUE INDEX idx_users_email ON users(email);

-- ✅ Covering index (include additional columns)
CREATE INDEX idx_orders_user_id_created_at ON orders(user_id, created_at DESC)
    INCLUDE (status, total);

-- ✅ Hash index (for equality only)
CREATE INDEX idx_users_auth_hash ON users USING HASH (auth_hash);

-- ✅ GIN index (for JSON/array columns)
CREATE INDEX idx_users_tags ON users USING GIN (tags);
CREATE INDEX idx_audit_logs_data ON audit_logs USING GIN (new_data);

-- ✅ BRIN index (for very large tables with sequential data)
CREATE INDEX idx_logs_created_at ON logs USING BRIN (created_at);
```

### Query Optimization Examples

```sql
-- ❌ SLOW: N+1 query problem
-- First query gets users, then N queries get posts for each user
SELECT * FROM users;
-- Then for each user:
SELECT * FROM posts WHERE user_id = ?;

-- ✅ FAST: Single query with JOIN
SELECT
    u.id,
    u.email,
    json_agg(
        json_build_object(
            'id', p.id,
            'title', p.title,
            'created_at', p.created_at
        )
    ) as posts
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
GROUP BY u.id, u.email;

-- ❌ SLOW: Missing index, function on column
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- ✅ FAST: Index on expression
CREATE INDEX idx_users_lower_email ON users(LOWER(email));
SELECT * FROM users WHERE LOWER(email) = 'user@example.com';

-- ❌ SLOW: Wildcard at beginning
SELECT * FROM users WHERE email LIKE '%@example.com';

-- ✅ FAST: Use full-text search
CREATE INDEX idx_users_email_gin ON users USING GIN (to_tsvector('simple', email));
SELECT * FROM users WHERE to_tsvector('simple', email) @@ to_tsquery('simple', '@example.com');

-- ❌ SLOW: OR conditions without composite index
SELECT * FROM orders WHERE user_id = ? OR status = 'pending';

-- ✅ FAST: Use UNION with separate indexes
SELECT * FROM orders WHERE user_id = ?
UNION
SELECT * FROM orders WHERE status = 'pending' AND user_id IS NULL;

-- ❌ SLOW: OFFSET for pagination
SELECT * FROM posts ORDER BY created_at DESC LIMIT 20 OFFSET 1000;

-- ✅ FAST: Keyset pagination
SELECT * FROM posts
WHERE created_at < ?
ORDER BY created_at DESC
LIMIT 20;
```

## Migration Strategy

### Zero-Downtime Migrations

```yaml
migration_phases:
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

### Migration Examples

```sql
-- ✅ SAFE: Add column (default value requires Postgres 11+)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- ✅ SAFE: Add column with default (Postgres 11+)
ALTER TABLE users ADD COLUMN status VARCHAR(20) DEFAULT 'active' NOT NULL;

-- ⚠️ REQUIRE DOWNTIME: Add column with default (Postgres < 11)
-- Phase 1: Add nullable column
ALTER TABLE users ADD COLUMN status VARCHAR(20);
-- Phase 2: Backfill data
UPDATE users SET status = 'active' WHERE status IS NULL;
-- Phase 3: Make NOT NULL with default
ALTER TABLE users ALTER COLUMN status SET DEFAULT 'active';
ALTER TABLE users ALTER COLUMN status SET NOT NULL;

-- ✅ SAFE: Rename column
ALTER TABLE users RENAME COLUMN name TO full_name;

-- ⚠️ REQUIRE CODE CHANGE: Rename column
-- Phase 1: Add new column
ALTER TABLE users ADD COLUMN full_name VARCHAR(100);
-- Phase 2: Deploy code that writes both columns
-- Phase 3: Backfill data
UPDATE users SET full_name = name;
-- Phase 4: Deploy code that reads new column
-- Phase 5: Drop old column
ALTER TABLE users DROP COLUMN name;

-- ✅ SAFE: Add index (requires write lock, but short)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- ✅ SAFE: Add foreign key
ALTER TABLE posts ADD CONSTRAINT fk_posts_user_id
    FOREIGN KEY (user_id) REFERENCES users(id);

-- ✅ SAFE: Create table
CREATE TABLE user_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    preferences JSONB NOT NULL DEFAULT '{}',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ✅ SAFE: Drop column
ALTER TABLE users DROP COLUMN old_column;

-- ⚠️ REQUIRE DOWNTIME: Change column type
-- Phase 1: Add new column
ALTER TABLE users ADD COLUMN new_id UUID;
-- Phase 2: Backfill data
UPDATE users SET new_id = gen_random_uuid();
-- Phase 3: Deploy code that uses new_id
-- Phase 4: Drop old column
ALTER TABLE users DROP COLUMN id;
ALTER TABLE users RENAME COLUMN new_id TO id;
```

## Data Integrity

### ACID Compliance

```sql
-- ✅ Transaction for ACID compliance
BEGIN;

-- Update account balance
UPDATE accounts
SET balance = balance - 100
WHERE id = ? AND balance >= 100;

-- Insert transaction record
INSERT INTO transactions (account_id, amount, type)
VALUES (?, -100, 'debit');

-- Insert into ledger
INSERT INTO journal_entries (entry_date, description)
VALUES (CURRENT_DATE, 'Transfer');

-- Verify constraints
-- If any constraint fails, entire transaction rolls back

COMMIT;
```

### Constraints

```sql
-- ✅ NOT NULL constraint
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- ✅ UNIQUE constraint
ALTER TABLE users ADD CONSTRAINT uq_users_email UNIQUE (email);

-- ✅ CHECK constraint
ALTER TABLE accounts ADD CONSTRAINT chk_accounts_balance_positive
    CHECK (balance >= 0);

ALTER TABLE users ADD CONSTRAINT chk_users_email_format
    CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- ✅ EXCLUDE constraint (for more complex uniqueness)
CREATE TABLE reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    EXCLUDE USING gist (
        room_id WITH =,
        tsrange(start_time, end_time) WITH &&
    );
);
```

## Scaling Strategy

### Vertical Scaling

```yaml
vertical_scaling:
  hardware:
    - more_cpu_cores
    - more_ram
    - faster_storage (ssd, nvme)
    - faster_network

  configuration:
    - increase_shared_buffers
    - increase_effective_cache_size
    - increase_work_mem
    - increase_maintenance_work_mem

  monitoring:
    - cpu_usage
    - memory_usage
    - disk_io
    - connection_count
```

### Horizontal Scaling

```yaml
horizontal_scaling:
  read_replicas:
    - primary_for_writes
    - replicas_for_reads
    - use_connection_pooler
    - monitor_replication_lag

  sharding:
    - partition_by_key
    - consistent_hashing
    - shard_per_tenant
    - use_proxy_router

  connection_pooling:
    - pg_bouncer
    - pgbouncer_mode: transaction pooling
    - max_connections_per_app
```

### Partitioning

```sql
-- ✅ Partition by range (time-based)
CREATE TABLE orders (
    id UUID NOT NULL,
    user_id UUID NOT NULL,
    total DECIMAL(19, 4) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Create partitions
CREATE TABLE orders_2024_q1 PARTITION OF orders
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- ✅ Partition by list (category-based)
CREATE TABLE products (
    id UUID NOT NULL,
    category VARCHAR(50) NOT NULL,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(19, 4) NOT NULL,
    PRIMARY KEY (id, category)
) PARTITION BY LIST (category);

CREATE TABLE products_electronics PARTITION OF products
    FOR VALUES IN ('electronics', 'computers', 'phones');

CREATE TABLE products_clothing PARTITION OF products
    FOR VALUES IN ('clothing', 'shoes', 'accessories');

-- ✅ Partition by hash (even distribution)
CREATE TABLE events (
    id UUID NOT NULL,
    user_id UUID NOT NULL,
    event_data JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (id, user_id)
) PARTITION BY HASH (user_id);

-- Create 4 partitions
CREATE TABLE events_0 PARTITION OF events FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE events_1 PARTITION OF events FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE events_2 PARTITION OF events FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE events_3 PARTITION OF events FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

## Handoff Contracts

### From Team Lead
```yaml
provides:
  - data_requirements
  - schema_design
  - query_patterns
  - performance_requirements

expects:
  - database_review
  - query_optimization
  - migration_review
  - scaling_recommendations
```

### To Architect
```yaml
provides:
  - data_architecture
  - integration_points
  - scalability_constraints

expects:
  - overall_architecture
  - api_contracts
```

## Output Template

```markdown
# Database Expert Review Report

**Review Date:** [Date]
**Reviewer:** Database Expert Agent
**Project/Feature:** [Name]

---

## Executive Summary

**Overall Database Quality:** [Score]/10
**Schema Quality:** [Excellent/Good/Fair/Poor]
**Query Performance:** [Excellent/Good/Fair/Poor]
**Scalability:** [High/Medium/Low]

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
| [Critical/High/Medium/Low] | [Issue] | [Table] | [Fix] |

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
| [Critical/High/Medium/Low] | [Query] | [Issue] | [Fix] |

---

## Fintech Patterns

### Ledger Design (if applicable)
[Assessment of ledger implementation]

### Audit Trail (if applicable)
[Assessment of audit trail implementation]

**Findings:**
| Severity | Issue | Component | Fix |
|----------|-------|-----------|-----|
| [Critical/High/Medium/Low] | [Issue] | [Component] | [Fix] |

---

## Migration Review

### Migration Strategy
[Assessment of migration approach]

### Zero-Downtime Plan
[If applicable]

**Findings:**
| Severity | Issue | Migration | Fix |
|----------|-------|-----------|-----|
| [Critical/High/Medium/Low] | [Issue] | [Migration] | [Fix] |

---

## Data Integrity

### ACID Compliance
[Assessment of transaction handling]

### Constraints
[Assessment of constraints]

### Data Validation
[Assessment of data validation]

---

## Scalability Analysis

### Current Scaling Strategy
[Horizontal/vertical scaling]

### Bottlenecks
[Identified bottlenecks]

### Recommendations
[Scaling recommendations]

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

## Conclusion

**Database Status:** [✅ EXCELLENT | ⚠️ NEEDS IMPROVEMENT | ❌ PROBLEMATIC]

**Summary:**
[Brief summary of database quality and main recommendations]

**Blocking Issues:**
[List any issues that should block progress]

---

**Report Generated:** [Timestamp]
**Reviewed by:** Database Expert Agent
```

## Verification Checklist

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

---

**Agent Version:** 1.0.0
**Last Updated:** 2026-04-19
**Specializes in:** Schema Design, Query Optimization, Fintech Ledger, Audit Trails, Scaling
