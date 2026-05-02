---
name: postgresql
description: >
  PostgreSQL expert patterns for schema design, indexing, query optimization, and advanced features.
  Covers table design, indexing strategies, PL/pgSQL, JSONB, full-text search, window functions,
  CTEs, EXPLAIN ANALYZE, partitioning, and performance tuning.
  Use when designing schemas, writing complex queries, or optimizing PostgreSQL performance.
version: "1.0.0"
category: "expert-database"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "postgresql"
  - "postgres"
  - "sql"
  - "jsonb"
  - "indexing"
  - "explain analyze"
  - "plpgsql"
  - "full-text search"
  - "window functions"
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
---

# PostgreSQL Patterns

## Overview

PostgreSQL is the most advanced open-source relational database, offering JSONB, full-text search, window functions, CTEs, PL/pgSQL, and powerful indexing. This skill covers production-grade PostgreSQL patterns: schema design, indexing strategies, advanced queries, performance tuning, and administration.

## When to Use

- Designing database schemas with constraints, indexes, and relationships
- Writing complex queries with CTEs, window functions, and aggregations
- Using PostgreSQL-specific features (JSONB, full-text search, arrays, pgvector)
- Optimizing slow queries with EXPLAIN ANALYZE
- Setting up partitioning, replication, and backup strategies

## When NOT to Use

- Simple key-value lookups at massive scale (use Redis)
- Full-text search on billions of documents (use Elasticsearch)
- Time-series data with high write throughput (use TimescaleDB extension)

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Index on every column | Slow writes, wasted disk | Index only WHERE/JOIN columns |
| `SELECT *` everywhere | Unnecessary I/O, breaks on schema changes | Name every column explicitly |
| TEXT for JSON data | No query operators, no validation | Use JSONB with GIN index |
| `LIKE '%term%'` | Cannot use B-tree index | Use full-text search or pg_trgm |
| Deep pagination with OFFSET | Scans and discards rows | Use keyset pagination with WHERE |
| Unlogged tables for speed | Data lost on crash | Use normal tables with proper tuning |

## Core Patterns

### 1. Table Design with Constraints

```sql
-- Core table with proper constraints and types
CREATE TABLE orders (
    id          BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    status      TEXT NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
    total       NUMERIC(10,2) NOT NULL CHECK (total >= 0),
    metadata    JSONB DEFAULT '{}',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### 2. Indexing Strategies

```sql
-- B-tree index for equality and range (default)
CREATE INDEX idx_orders_customer_status ON orders (customer_id, status);

-- Partial index for common filtered queries
CREATE INDEX idx_orders_pending ON orders (created_at)
    WHERE status = 'pending';

-- GIN index for JSONB containment queries
CREATE INDEX idx_orders_metadata ON orders USING GIN (metadata);

-- GIN index for full-text search
CREATE INDEX idx_articles_search ON articles USING GIN (to_tsvector('english', title || ' ' || body));

-- Covering index (include columns to avoid table lookup)
CREATE INDEX idx_orders_covering ON orders (customer_id) INCLUDE (total, status);

-- Unique partial index
CREATE UNIQUE INDEX idx_user_active_email ON users (email) WHERE deleted_at IS NULL;

-- BRIN index for naturally ordered large tables (timestamps)
CREATE INDEX idx_logs_created_brin ON access_logs USING BRIN (created_at);
```

### 3. Advanced Queries

```sql
-- CTE for readable complex queries
WITH monthly_totals AS (
    SELECT customer_id,
           date_trunc('month', created_at) AS month,
           SUM(total) AS month_total
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id, date_trunc('month', created_at)
)
SELECT customer_id, month, month_total,
       LAG(month_total) OVER (PARTITION BY customer_id ORDER BY month) AS prev_month,
       month_total - LAG(month_total) OVER (PARTITION BY customer_id ORDER BY month) AS growth
FROM monthly_totals
ORDER BY customer_id, month;

-- Window functions for rankings
SELECT customer_id, total,
       RANK() OVER (PARTITION BY customer_id ORDER BY total DESC) AS order_rank,
       SUM(total) OVER (PARTITION BY customer_id ORDER BY created_at
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders
WHERE status = 'delivered';

-- Upsert with ON CONFLICT
INSERT INTO products (sku, name, price)
VALUES ('SKU-001', 'Widget', 29.99)
ON CONFLICT (sku) DO UPDATE SET
    name = EXCLUDED.name,
    price = EXCLUDED.price,
    updated_at = now();
```

### 4. JSONB Patterns

```sql
-- Insert JSONB data
INSERT INTO orders (customer_id, total, metadata)
VALUES (1, 99.99, '{"source": "web", "items": 3, "coupon": "SAVE10"}');

-- Query nested JSONB
SELECT * FROM orders WHERE metadata->>'source' = 'web';
SELECT * FROM orders WHERE metadata @> '{"coupon": "SAVE10"}';
SELECT * FROM orders WHERE metadata ? 'coupon';

-- Update JSONB fields
UPDATE orders SET metadata = jsonb_set(metadata, '{items}', '5');

-- Add key to JSONB
UPDATE orders SET metadata = metadata || '{"notes": "rush delivery"}';

-- Remove key from JSONB
UPDATE orders SET metadata = metadata - 'coupon';

-- GIN index for JSONB queries
CREATE INDEX idx_orders_metadata ON orders USING GIN (metadata jsonb_path_ops);
```

### 5. Full-Text Search

```sql
-- Create search vector column
ALTER TABLE articles ADD COLUMN search_vector TSVECTOR;

CREATE INDEX idx_articles_fts ON articles USING GIN (search_vector);

-- Update search vector with trigger
CREATE OR REPLACE FUNCTION articles_search_vector_update()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.body, '')), 'B');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER articles_search_vector_trigger
    BEFORE INSERT OR UPDATE OF title, body ON articles
    FOR EACH ROW EXECUTE FUNCTION articles_search_vector_update();

-- Search with ranking
SELECT title, ts_rank(search_vector, query) AS rank
FROM articles, plainto_tsquery('english', 'python web framework') query
WHERE search_vector @@ query
ORDER BY rank DESC
LIMIT 20;
```

### 6. Performance Tuning

```sql
-- Analyze query plan
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT * FROM orders WHERE customer_id = 42 AND status = 'pending';

-- Key things to look for in EXPLAIN output:
-- Seq Scan on large table = missing index
-- high actual rows vs estimated rows = stale statistics (run ANALYZE)
-- Sort with high cost = consider index with ORDER BY
-- Nested Loop with high row estimates = consider join strategy change

-- Find slow queries
SELECT query, mean_exec_time, calls, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Find missing indexes (high seq_scan on large tables)
SELECT relname, seq_scan, idx_scan, seq_scan::float / GREATEST(idx_scan, 1) AS ratio
FROM pg_stat_user_tables
WHERE seq_scan > 100
ORDER BY ratio DESC;

-- Table bloat check
SELECT relname, n_live_tup, n_dead_tup,
       n_dead_tup::float / GREATEST(n_live_tup, 1) AS bloat_ratio
FROM pg_stat_user_tables
WHERE n_dead_tup > 10000
ORDER BY bloat_ratio DESC;
```

### 7. Partitioning

```sql
-- Range partitioning for time-series data
CREATE TABLE access_logs (
    id          BIGSERIAL,
    user_id     BIGINT NOT NULL,
    path        TEXT NOT NULL,
    status_code INT NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (created_at);

-- Monthly partitions
CREATE TABLE access_logs_2025_01 PARTITION OF access_logs
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
CREATE TABLE access_logs_2025_02 PARTITION OF access_logs
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

-- Auto-create partitions with pg_partman extension
-- CREATE EXTENSION pg_partman;
-- SELECT partman.create_parent('public.access_logs', 'created_at', 'native', 'monthly');
```

## Coaching Notes

> **ABC - Always Be Coaching:** PostgreSQL is not just a data store -- it is an application platform. Mastering its features eliminates entire layers of middleware.

1. **Index for your queries, not your columns:** Create indexes based on actual WHERE, JOIN, and ORDER BY patterns. Use `pg_stat_statements` to find slow queries, then index for those. A partial index on a common filter (e.g., WHERE status = 'pending') is often more effective than a general index.

2. **JSONB is PostgreSQL's secret weapon:** Use JSONB for semi-structured data, flexible attributes, and evolving schemas. With a GIN index, containment queries (`@>`) are fast. It eliminates the need for separate document stores in many cases.

3. **EXPLAIN ANALYZE is your best debugging tool:** Before optimizing any query, run EXPLAIN ANALYZE and read the plan. Look for sequential scans on large tables, incorrect row estimates, and expensive sorts. Never guess -- measure.

4. **Partition tables over 100M rows:** Range partitioning on timestamp columns makes queries faster, maintenance easier (drop old partitions instead of DELETE), and VACUUM cheaper. Use pg_partman for automatic partition management.

5. **Keyset pagination beats OFFSET:** For large datasets, `WHERE id > last_seen_id ORDER BY id LIMIT 20` is constant time. `OFFSET 100000 LIMIT 20` scans and discards 100,000 rows.

## Verification

After implementing PostgreSQL patterns:

- [ ] All tables have appropriate constraints (NOT NULL, CHECK, FOREIGN KEY)
- [ ] Indexes exist for all WHERE/JOIN columns identified by slow query analysis
- [ ] JSONB columns have GIN indexes if queried by containment
- [ ] Full-text search uses tsvector columns with GIN indexes, not LIKE patterns
- [ ] EXPLAIN ANALYZE run on all queries in hot paths (no sequential scans on large tables)
- [ ] Partitioning applied to tables over 100M rows
- [ ] VACUUM and ANALYZE running regularly (autovacuum configured for high-write tables)
- [ ] Backup strategy in place (pg_dump or WAL archiving) with tested restore
- [ ] Roles follow least privilege (no superuser for application connections)

## Related Skills

- **backend-patterns** -- General backend patterns (API design, auth, caching)
- **redis** -- Caching layer for PostgreSQL query results
- **elasticsearch** -- Full-text search when PostgreSQL FTS is insufficient
- **api-testing** -- Testing database queries through API endpoints
- **performance-optimization** -- Measure-first optimization methodology
