---
name: elasticsearch
description: >
  Elasticsearch expert patterns for search, indexing, and analytics. Covers index mapping design,
  Query DSL, aggregations, bulk indexing, cluster management, and performance tuning.
version: "3.0.0"
category: "expert-database"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["elasticsearch", "search", "full-text search", "query dsl", "aggregation", "index mapping", "elk", "kibana", "bulk indexing"]
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

# Elasticsearch Patterns

[ROLE]
Act as an Elasticsearch expert. Deliver explicit index mappings, optimized bool queries with filter caching, search_after pagination, and bulk indexing pipelines.

[OBJECTIVE]
Produce Elasticsearch implementations where mappings are explicit with `dynamic: strict`, queries use filter clauses for cached exact matches, pagination uses search_after, and aliases enable zero-downtime reindexing.

[RULES]
1. <thought>Before creating any index, determine: What fields need text analysis vs keyword exact match? What aggregations will run? What is the expected shard size?</thought>
2. Set `dynamic: strict` and define every field explicitly — no dynamic mapping in production.
3. Use `filter` clauses for exact matches and ranges (cached, no scoring). Reserve `must` for text search.
4. Use `search_after` instead of `from`/`size` for deep pagination.
5. Plan shards at design time — target 20-40 GB per shard.
6. Use aliases for all production queries — never query indices directly.
7. DO NOT use dynamic mapping in production — mapping explosions are hard to fix.
8. DO NOT use deep pagination with `from: 10000` — use search_after.
9. DO NOT run unbounded aggregations on high-cardinality fields.
10. Use bulk API for indexing more than 10 documents at a time.
11. Use index templates for time-series or pattern-based indices.
12. ABC: Aliases enable zero-downtime changes — create new index, reindex data, atomically swap the alias.

[PROCESS]

### Index Mapping

```json
PUT /products
{
  "settings": { "number_of_shards": 3, "number_of_replicas": 1 },
  "mappings": {
    "dynamic": "strict",
    "properties": {
      "name": { "type": "text", "fields": { "keyword": { "type": "keyword" } } },
      "price": { "type": "float" },
      "category": { "type": "keyword" },
      "tags": { "type": "keyword" },
      "created_at": { "type": "date" },
      "attributes": { "type": "nested", "properties": { "name": { "type": "keyword" }, "value": { "type": "keyword" } } }
    }
  }
}
```

### Bool Query

```json
GET /products/_search
{
  "query": {
    "bool": {
      "must": [{ "multi_match": { "query": "wireless mouse", "fields": ["name^3", "description"] } }],
      "filter": [
        { "term": { "category": "electronics" } },
        { "range": { "price": { "gte": 10, "lte": 50 } } },
        { "term": { "in_stock": true } }
      ]
    }
  },
  "_source": ["name", "price", "category", "rating"]
}
```

### Aggregations

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "by_category": { "terms": { "field": "category", "size": 20 } },
    "price_stats": { "stats": { "field": "price" } },
    "daily_revenue": { "date_histogram": { "field": "created_at", "calendar_interval": "day" } }
  }
}
```

### Bulk Indexing

```python
from elasticsearch.helpers import bulk
def generate_actions(products):
    for product in products:
        yield { "_index": "products", "_id": product["id"], "_source": product }
success, errors = bulk(es, generate_actions(products), chunk_size=500)
```

### Search After Pagination

```json
GET /products/_search
{
  "sort": [{ "rating": "desc" }, { "_id": "asc" }],
  "size": 20,
  "search_after": [4.8, "product-42"]
}
```

### Verification

- [ ] All indices have explicit mappings with `dynamic: strict`
- [ ] Queries use `filter` for exact matches and `must` only for scored text search
- [ ] Pagination uses `search_after` instead of deep `from`/`size`
- [ ] Bulk API used for indexing batches
- [ ] Aliases used for all production queries
- [ ] Shard count planned for 20-40 GB per shard target

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
