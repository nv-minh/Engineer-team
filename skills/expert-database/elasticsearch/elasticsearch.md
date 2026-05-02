---
name: elasticsearch
description: >
  Elasticsearch expert patterns for search, indexing, and analytics. Covers index mapping design,
  Query DSL (match, term, bool, nested, aggregations), bulk indexing, cluster management,
  ELK stack integration, and performance tuning.
  Use when implementing full-text search, log analytics, or complex document queries.
version: "1.0.0"
category: "expert-database"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "elasticsearch"
  - "search"
  - "full-text search"
  - "query dsl"
  - "aggregation"
  - "index mapping"
  - "elk"
  - "kibana"
  - "bulk indexing"
intent: >
  Equip developers with expert-level Elasticsearch patterns for index design, query writing,
  aggregations, bulk operations, cluster management, and performance tuning.
scenarios:
  - "Designing index mappings with custom analyzers and field types for a product search"
  - "Writing complex bool queries with filters, aggregations, and sorting for analytics"
  - "Setting up bulk indexing pipeline and monitoring cluster health"
best_for: "Elasticsearch index design, Query DSL, aggregations, bulk indexing, cluster management"
estimated_time: "25-45 min"
anti_patterns:
  - "Using dynamic mapping in production instead of explicit index mappings"
  - "Deep pagination with from/size instead of search_after for large result sets"
  - "Running unbounded aggregations without size limits on high-cardinality fields"
related_skills: ["postgresql", "backend-patterns"]
---

# Elasticsearch Patterns

## Overview

Elasticsearch is a distributed search and analytics engine built on Apache Lucene. This skill covers production-grade Elasticsearch patterns: index mapping design, Query DSL, aggregations, bulk indexing, cluster management, ELK stack integration, and performance tuning.

## When to Use

- Full-text search with relevance ranking and faceted navigation
- Log and event analytics with aggregations
- Autocomplete and type-ahead suggestions
- Document storage with complex nested relationships
- Time-series data analysis with date histograms

## When NOT to Use

- Primary transactional data store (use PostgreSQL)
- Simple key-value lookups (use Redis)
- Real-time streaming with sub-second latency requirements (use Kafka + dedicated stream processing)
- Graph relationships with deep traversals (use a graph database)

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Dynamic mapping in production | Unexpected types, mapping explosions | Set `dynamic: strict`, define explicit mappings |
| Deep pagination (`from: 10000`) | Memory-heavy, slow, disabled by default | Use `search_after` with point-in-time |
| Unbounded aggregations | High memory, slow responses | Set `size` on terms aggs, use `cardinality` first |
| Too many shards per index | Overhead, poor resource utilization | Target 20-40 GB per shard |
| Storing documents without mapping | Mapping conflicts between indices | Create index templates before indexing |
| `match_all` queries without filters | Full scan, no relevance scoring | Always add filters to narrow results |

## Core Patterns

### 1. Index Mapping Design

```json
// Create index with explicit mapping
PUT /products
{
  "settings": {
    "number_of_shards": 3,
    "number_of_replicas": 1,
    "analysis": {
      "analyzer": {
        "custom_search": {
          "type": "custom",
          "tokenizer": "standard",
          "filter": ["lowercase", "stemmer", "synonym_filter"]
        }
      },
      "filter": {
        "synonym_filter": {
          "type": "synonym",
          "synonyms": ["laptop,notebook", "phone,mobile"]
        }
      }
    }
  },
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "name":        { "type": "text", "analyzer": "custom_search", "fields": { "keyword": { "type": "keyword" } } },
      "description": { "type": "text" },
      "price":       { "type": "float" },
      "category":    { "type": "keyword" },
      "tags":        { "type": "keyword" },
      "rating":      { "type": "float" },
      "in_stock":    { "type": "boolean" },
      "created_at":  { "type": "date" },
      "attributes":  { "type": "nested",
                       "properties": {
                         "name":  { "type": "keyword" },
                         "value": { "type": "keyword" }
                       }
                     }
    }
  }
}
```

### 2. Query DSL Patterns

```json
// Bool query: must (scored) + filter (cached, not scored)
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "multi_match": { "query": "wireless mouse", "fields": ["name^3", "description"], "type": "best_fields" } }
      ],
      "filter": [
        { "term": { "category": "electronics" } },
        { "range": { "price": { "gte": 10, "lte": 50 } } },
        { "term": { "in_stock": true } }
      ],
      "must_not": [
        { "term": { "tags": "discontinued" } }
      ]
    }
  },
  "sort": [
    { "_score": { "order": "desc" } },
    { "rating": { "order": "desc" } }
  ],
  "_source": ["name", "price", "category", "rating"]
}

// Nested query for object arrays
GET /products/_search
{
  "query": {
    "nested": {
      "path": "attributes",
      "query": {
        "bool": {
          "must": [
            { "term": { "attributes.name": "color" } },
            { "term": { "attributes.value": "black" } }
          ]
        }
      }
    }
  }
}

// Autocomplete with prefix query
GET /products/_search
{
  "query": {
    "multi_match": {
      "query": "wire",
      "type": "phrase_prefix",
      "fields": ["name", "description"]
    }
  },
  "size": 5
}
```

### 3. Aggregations

```json
// Bucket + metric aggregations for analytics
GET /products/_search
{
  "size": 0,
  "query": { "term": { "category": "electronics" } },
  "aggs": {
    "price_ranges": {
      "range": {
        "field": "price",
        "ranges": [
          { "key": "budget", "to": 25 },
          { "key": "mid", "from": 25, "to": 75 },
          { "key": "premium", "from": 75 }
        ]
      },
      "aggs": {
        "avg_rating": { "avg": { "field": "rating" } },
        "top_sellers": {
          "terms": { "field": "tags", "size": 5 }
        }
      }
    },
    "by_category": {
      "terms": { "field": "category", "size": 20 }
    },
    "price_stats": {
      "stats": { "field": "price" }
    }
  }
}

// Date histogram for time-series
GET /orders/_search
{
  "size": 0,
  "aggs": {
    "daily_revenue": {
      "date_histogram": {
        "field": "created_at",
        "calendar_interval": "day",
        "format": "yyyy-MM-dd"
      },
      "aggs": {
        "revenue": { "sum": { "field": "total" } },
        "order_count": { "value_count": { "field": "_id" } }
      }
    }
  }
}
```

### 4. Bulk Indexing

```json
// Bulk API: index, update, delete in one request
POST /_bulk
{"index": {"_index": "products", "_id": "1"}}
{"name": "Widget A", "price": 19.99, "category": "tools"}
{"index": {"_index": "products", "_id": "2"}}
{"name": "Widget B", "price": 29.99, "category": "tools"}
{"update": {"_index": "products", "_id": "1"}}
{"doc": {"price": 17.99}}
{"delete": {"_index": "products", "_id": "3"}}
```

```python
# Python bulk indexing with helpers
from elasticsearch.helpers import bulk

def generate_actions(products):
    for product in products:
        yield {
            "_index": "products",
            "_id": product["id"],
            "_source": {
                "name": product["name"],
                "price": product["price"],
                "category": product["category"],
            }
        }

# Batch size of 500 for optimal throughput
success, errors = bulk(es, generate_actions(products), chunk_size=500, raise_on_error=False)
for error in errors:
    logger.error("Bulk index error: %s", error)
```

### 5. Index Templates and Aliases

```json
// Index template for time-series indices
PUT _index_template/logs
{
  "index_patterns": ["logs-*"],
  "priority": 100,
  "template": {
    "settings": {
      "number_of_shards": 1,
      "number_of_replicas": 1,
      "lifecycle.name": "logs-policy"
    },
    "mappings": {
      "dynamic": "strict",
      "properties": {
        "timestamp": { "type": "date" },
        "level":     { "type": "keyword" },
        "message":   { "type": "text" },
        "service":   { "type": "keyword" }
      }
    }
  }
}

// Alias for zero-downtime reindex
POST /_aliases
{
  "actions": [
    { "remove": { "index": "products_v1", "alias": "products" } },
    { "add":    { "index": "products_v2", "alias": "products" } }
  ]
}
```

### 6. Search After Pagination

```json
// First page
GET /products/_search
{
  "query": { "match_all": {} },
  "sort": [
    { "rating": "desc" },
    { "_id": "asc" }
  ],
  "size": 20
}

// Next page: use last document's sort values
GET /products/_search
{
  "query": { "match_all": {} },
  "sort": [
    { "rating": "desc" },
    { "_id": "asc" }
  ],
  "size": 20,
  "search_after": [4.8, "product-42"]
}
```

### 7. Cluster Management

```json
// Check cluster health
GET /_cluster/health

// Node stats
GET /_nodes/stats

// Index stats
GET /products/_stats

// Pending tasks
GET /_cluster/pending_tasks

// Snapshot and restore
PUT /_snapshot/backup
{
  "type": "fs",
  "settings": { "location": "/mnt/backups/es" }
}

PUT /_snapshot/backup/snapshot_2025_01_15
POST /_snapshot/backup/snapshot_2025_01_15/_restore
```

```bash
# Monitor slow queries
# Add to elasticsearch.yml:
# index.search.slowlog.threshold.query.warn: 5s
# index.search.slowlog.threshold.query.info: 2s
# index.indexing.slowlog.threshold.index.warn: 10s
```

## Coaching Notes

> **ABC - Always Be Coaching:** Elasticsearch is not a database you "set and forget." It rewards deliberate index design and punishes sloppy mapping with performance degradation that compounds over time.

1. **Define explicit mappings before indexing:** Dynamic mapping is convenient for prototyping but dangerous in production. A single mistyped field can create a mapping that prevents proper indexing of future documents. Set `dynamic: strict` and define every field.

2. **Filters for performance, must for relevance:** Use `filter` clauses in bool queries for exact matches and ranges. Filters are cached and don't compute relevance scores. Reserve `must` for text search where scoring matters.

3. **Use search_after instead of from/size:** Deep pagination (`from: 10000`) is disabled by default because it forces Elasticsearch to build a sorted set of all matching documents. `search_after` uses the sort values of the last result as a cursor, making it constant time regardless of page depth.

4. **Plan shards at design time:** Target 20-40 GB per shard. Too few shards = poor parallelism. Too many = overhead from segment management. Use ILM (Index Lifecycle Management) to roll over indices when they reach a size limit.

5. **Aliases enable zero-downtime changes:** Never query indices directly in production. Use aliases. When you need to reindex (new mapping, new analysis), create the new index, reindex data, then atomically swap the alias.

## Verification

After implementing Elasticsearch patterns:

- [ ] All indices have explicit mappings with `dynamic: strict`
- [ ] Queries use `filter` for exact matches and `must` only for scored text search
- [ ] Pagination uses `search_after` instead of deep `from`/`size`
- [ ] Bulk API used for indexing more than 10 documents at a time
- [ ] Index templates defined for time-series or pattern-based indices
- [ ] Aliases used for all production queries (not direct index names)
- [ ] Shard count planned for 20-40 GB per shard target
- [ ] Snapshot/restore configured and tested for backups
- [ ] Slow query logging enabled with appropriate thresholds
- [ ] Cluster health monitored (green status, no unassigned shards)

## Related Skills

- **postgresql** -- Primary data store; Elasticsearch indexes its data for search
- **backend-patterns** -- General backend patterns (API design, caching, services)
- **redis** -- Caching layer for Elasticsearch query results
- **performance-optimization** -- Measure-first optimization methodology
