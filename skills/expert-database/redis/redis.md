---
name: redis
description: >
  Redis expert patterns for caching, data structures, pub/sub, persistence, clustering, and Lua scripting.
  Use when implementing caching, rate limiting, queues, sessions, or real-time features.
version: "3.0.0"
category: "expert-database"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["redis", "cache", "caching", "rate limiting", "pub/sub", "session store", "lua scripting redis", "sorted sets"]
intent: >
  Equip developers with expert-level Redis patterns for caching, data structures, rate limiting,
  pub/sub, persistence, clustering, and Lua scripting for atomic operations.
scenarios:
  - "Implementing a caching layer with TTL, cache-aside pattern, and invalidation strategies"
  - "Building a rate limiter with sorted sets or sliding window algorithm"
  - "Setting up Redis pub/sub for real-time notifications or event-driven architecture"
best_for: "Redis caching, data structures, rate limiting, pub/sub, persistence, Lua scripting"
estimated_time: "20-40 min"
anti_patterns:
  - "Using KEYS command in production instead of SCAN for key pattern matching"
  - "Storing large values (>1MB) in single keys instead of splitting into hashes"
  - "Running Redis without persistence or backup in production data stores"
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

# Redis Patterns

[ROLE]
Act as a Redis expert. Deliver cache-aside patterns with TTL, rate limiting with sorted sets, Lua scripts for atomicity, and proper persistence configuration.

[OBJECTIVE]
Produce Redis implementations where cache keys have TTL, pattern matching uses SCAN, Lua scripts handle atomic multi-step operations, and persistence matches the use case.

[RULES]
1. <thought>Before using Redis, determine: Is this caching (TTL + eviction), a data structure (sorted set, stream), or a coordination primitive (lock, rate limiter)?</thought>
2. Always set TTL on cache keys — memory is finite.
3. Use SCAN, never KEYS — KEYS blocks Redis for potentially seconds.
4. Use Lua scripts for atomic multi-step operations (check-then-set, read-then-write).
5. Use hashes for object-like data, not serialized strings.
6. Pipeline batch operations — reduces latency from N * RTT to 1 * RTT.
7. DO NOT use `KEYS *` in production — use SCAN with MATCH pattern.
8. DO NOT store large values (>1MB) in single keys — split into hashes.
9. DO NOT run Redis without persistence for data stores — configure RDB or AOF.
10. Set `maxmemory` and `maxmemory-policy` for all production instances.
11. Use sorted sets for rate limiting with sliding window.
12. ABC: Lua scripts give you atomicity — Redis executes Lua atomically, no other command runs during script execution. Use this for distributed locks and rate limiters.

[PROCESS]

### Data Structures

| Type | Use Case | Key Commands |
|------|----------|-------------|
| String | Simple values, counters | SET, GET, INCR, SETEX |
| Hash | Objects with fields | HSET, HGET, HGETALL |
| List | Queues, timelines | LPUSH, RPUSH, LPOP |
| Set | Unique members, tags | SADD, SMEMBERS |
| Sorted Set | Leaderboards, rankings | ZADD, ZRANGE, ZRANK |

### Caching Patterns

```python
async def get_user(user_id: str) -> dict:
    cache_key = f"user:{user_id}:profile"
    cached = r.get(cache_key)
    if cached: return json.loads(cached)
    user = await db.fetch_user(user_id)
    r.setex(cache_key, 300, json.dumps(user))
    return user
```

### Rate Limiting

```python
def check_rate_limit(user_id: str, limit: int = 60, window: int = 60) -> bool:
    key = f"rate:{user_id}"
    pipe = r.pipeline()
    now = time.time()
    pipe.zremrangebyscore(key, 0, now - window)
    pipe.zadd(key, {f"{now}:{uuid4().hex}": now})
    pipe.zcard(key)
    pipe.expire(key, window + 1)
    _, _, count, _ = pipe.execute()
    return count <= limit
```

### Distributed Locking

```python
def release_lock(lock_name: str, identifier: str) -> bool:
    script = """
    if redis.call("get", KEYS[1]) == ARGV[1] then
        return redis.call("del", KEYS[1])
    else return 0 end
    """
    return r.eval(script, 1, lock_name, identifier) == 1
```

### Streams (Event Persistence)

```python
r.xadd("events:orders", {"order_id": "ORD-500", "status": "created"})
r.xgroup_create("events:orders", "order-processors", id="0", mkstream=True)
messages = r.xreadgroup("order-processors", "worker-1", {"events:orders": ">"}, count=10, block=5000)
```

### Persistence Configuration

```
# RDB for cache, AOF for data store
appendonly yes
appendfsync everysec
maxmemory 2gb
maxmemory-policy allkeys-lru
requirepass your-strong-password
```

### Verification

- [ ] All cache keys have TTL set
- [ ] SCAN used instead of KEYS for all pattern matching
- [ ] Hash data structures used for object-like data
- [ ] Rate limiting uses sorted sets with sliding window
- [ ] Distributed locks use Lua scripts for atomic check-and-delete
- [ ] Persistence configured appropriately (RDB for cache, AOF for data store)
- [ ] Memory limit and eviction policy set
- [ ] Pipeline used for batch operations

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation`, `patterns_applied`, and `recommendations`.
