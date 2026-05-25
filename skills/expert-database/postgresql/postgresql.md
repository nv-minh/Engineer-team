---
name: postgresql
description: >
  PostgreSQL expert patterns for schema design, indexing, query optimization, and advanced features.
  Covers table design, indexing strategies, PL/pgSQL, JSONB, full-text search, window functions,
  CTEs, EXPLAIN ANALYZE, partitioning, and performance tuning.
version: "3.0.0"
category: "expert-database"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["postgresql", "postgres", "sql", "jsonb", "indexing", "explain analyze", "plpgsql", "full-text search", "window functions"]
intent: >
  Equip developers with expert-level PostgreSQL patterns for schema design, query writing,
  performance optimization, and advanced features like JSONB, CTEs, and full-text search.
scenarios:
  - "Designing a normalized schema with proper indexes, constraints, and partitioning"
  - "Optimizing slow queries using EXPLAIN ANALYZE and rewriting with CTEs/window functions"
  - "Implementing full-text search or JSONB queries for flexible data storage"
best_for: "PostgreSQL schema design, query optimization, advanced SQL features, performance tuning"
estimated_time: "30-50 min"
anti_patterns:
  - "Creating indexes on every column without analyzing query patterns"
  - "Using SELECT * in production queries instead of specifying needed columns"
  - "Storing structured data as TEXT instead of JSONB for semi-structured needs"
related_skills: ["backend-patterns", "redis", "elasticsearch"]

input_schema:
  type: object
  required: [task_description]
  properties:
    task_description:
      type: string
      description: "What to implement, review, or investigate"
    context:
      type: object
      description: "Project context — existing code, tech stack, constraints"
    mode:
      type: string
      enum: [implement, review, investigate, advise]
      default: implement
      description: "Execution mode"

output_schema:
  type: object
  required: [status, implementation]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    implementation:
      type: object
      description: "Implementation details, code, or analysis results"
    patterns_applied:
      type: array
      items: { type: string }
      description: "Patterns and best practices used"
    recommendations:
      type: array
      items:
        type: object
        properties:
          priority: { type: string, enum: [high, medium, low] }
          action: { type: string }
          reasoning: { type: string }

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

# PostgreSQL Patterns

[ROLE]
Act as a PostgreSQL expert. Deliver optimized schemas with proper constraints, targeted indexes, and queries verified with EXPLAIN ANALYZE.

[OBJECTIVE]
Produce PostgreSQL schemas and queries where tables have proper constraints, indexes target actual query patterns, JSONB handles semi-structured data, and EXPLAIN ANALYZE verifies performance.

[RULES]
1. <thought>Before creating any index, ask: What queries will use this? Is a partial index sufficient? Would a covering index avoid a table lookup?</thought>
2. Index for your queries, not your columns — use `pg_stat_statements` to find slow queries.
3. Use JSONB for semi-structured data with GIN indexes for containment queries.
4. Run EXPLAIN ANALYZE on all queries in hot paths — never guess, measure.
5. Use keyset pagination (`WHERE id > last_seen ORDER BY id`) instead of OFFSET.
6. Partition tables over 100M rows by timestamp range.
7. DO NOT create indexes on every column — index only WHERE/JOIN columns.
8. DO NOT use SELECT * in production — name every column.
9. DO NOT use `LIKE '%term%'` — use full-text search or pg_trgm.
10. DO NOT use deep pagination with OFFSET — use search_after/keyset.
11. Use ON CONFLICT for upserts instead of check-then-insert.
12. Configure autovacuum for high-write tables.
13. ABC: EXPLAIN ANALYZE is your best debugging tool. Look for sequential scans on large tables, incorrect row estimates, and expensive sorts. Never optimize without measuring.

[PROCESS]

### Table Design

```sql
CREATE TABLE orders (
    id          BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    status      TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    total       NUMERIC(10,2) NOT NULL CHECK (total >= 0),
    metadata    JSONB DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### Indexing Strategies

```sql
CREATE INDEX idx_orders_customer_status ON orders (customer_id, status);
CREATE INDEX idx_orders_pending ON orders (created_at) WHERE status = 'pending';  -- Partial
CREATE INDEX idx_orders_metadata ON orders USING GIN (metadata);  -- JSONB
CREATE INDEX idx_orders_covering ON orders (customer_id) INCLUDE (total, status);  -- Covering
CREATE UNIQUE INDEX idx_user_active_email ON users (email) WHERE deleted_at IS NULL;  -- Unique partial
CREATE INDEX idx_logs_created_brin ON access_logs USING BRIN (created_at);  -- Time-series
```

### Advanced Queries

```sql
-- CTE with window functions
WITH monthly_totals AS (
    SELECT customer_id, date_trunc('month', created_at) AS month, SUM(total) AS month_total
    FROM orders WHERE status = 'delivered' GROUP BY customer_id, date_trunc('month', created_at)
)
SELECT customer_id, month, month_total,
       LAG(month_total) OVER (PARTITION BY customer_id ORDER BY month) AS prev_month
FROM monthly_totals;

-- Upsert
INSERT INTO products (sku, name, price) VALUES ('SKU-001', 'Widget', 29.99)
ON CONFLICT (sku) DO UPDATE SET name = EXCLUDED.name, price = EXCLUDED.price, updated_at = now();
```

### JSONB Patterns

```sql
SELECT * FROM orders WHERE metadata @> '{"coupon": "SAVE10"}';
UPDATE orders SET metadata = jsonb_set(metadata, '{items}', '5');
UPDATE orders SET metadata = metadata || '{"notes": "rush delivery"}';
```

### Full-Text Search

```sql
ALTER TABLE articles ADD COLUMN search_vector TSVECTOR;
CREATE INDEX idx_articles_fts ON articles USING GIN (search_vector);

SELECT title, ts_rank(search_vector, query) AS rank
FROM articles, plainto_tsquery('english', 'python web framework') query
WHERE search_vector @@ query ORDER BY rank DESC LIMIT 20;
```

### Performance Tuning

```sql
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT) SELECT * FROM orders WHERE customer_id = 42;

-- Find slow queries
SELECT query, mean_exec_time, calls FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 20;

-- Find missing indexes
SELECT relname, seq_scan, idx_scan FROM pg_stat_user_tables WHERE seq_scan > 100 ORDER BY seq_scan DESC;
```

### Partitioning

```sql
CREATE TABLE access_logs (...) PARTITION BY RANGE (created_at);
CREATE TABLE access_logs_2025_01 PARTITION OF access_logs FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### Verification

- [ ] All tables have appropriate constraints (NOT NULL, CHECK, FOREIGN KEY)
- [ ] Indexes exist for all WHERE/JOIN columns identified by slow query analysis
- [ ] JSONB columns have GIN indexes if queried by containment
- [ ] EXPLAIN ANALYZE run on all queries in hot paths
- [ ] Partitioning applied to tables over 100M rows
- [ ] Backup strategy in place with tested restore

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with SQL, `patterns_applied`, and `recommendations`.
