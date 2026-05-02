---
name: redis
description: >
  Redis expert patterns for caching, data structures, pub/sub, persistence, clustering, and Lua scripting.
  Covers strings, hashes, lists, sets, sorted sets, caching patterns, rate limiting, session storage,
  pub/sub messaging, RDB/AOF persistence, cluster setup, and Lua scripting.
  Use when implementing caching, rate limiting, queues, sessions, or real-time features.
version: "1.0.0"
category: "expert-database"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "redis"
  - "cache"
  - "caching"
  - "rate limiting"
  - "pub/sub"
  - "session store"
  - "lua scripting redis"
  - "sorted sets"
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
---

# Redis Patterns

## Overview

Redis is an in-memory data structure store used as a database, cache, message broker, and streaming engine. This skill covers production-grade Redis patterns: data structures, caching strategies, rate limiting, pub/sub, persistence (RDB/AOF), clustering, and Lua scripting for atomic operations.

## When to Use

- Caching database query results or API responses with TTL
- Rate limiting API endpoints or user actions
- Session storage for web applications
- Real-time notifications via pub/sub
- Leaderboards, queues, and counters using sorted sets and lists
- Distributed locking across service instances

## When NOT to Use

- Primary data store for critical business data (use PostgreSQL)
- Full-text search (use Elasticsearch)
- Long-term analytics storage (use a columnar database)
- Large binary blobs (use object storage like S3)

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| `KEYS *` in production | Blocks Redis, O(N) scan | Use `SCAN` with MATCH pattern |
| Large keys (>1MB) | Network latency, blocking | Split into multiple hash fields |
| No TTL on cache keys | Memory leaks, stale data | Always set EX/PX on SET commands |
| Redis without persistence | Data loss on restart | Configure RDB or AOF based on needs |
| Single Redis instance at scale | No failover, single point of failure | Use Sentinel for HA or Cluster for sharding |
| Storing serialized objects as strings | No field-level access | Use hashes for object-like data |

## Core Patterns

### 1. Data Structures Quick Reference

```
| Type        | Use Case                  | Key Commands                    |
|-------------|---------------------------|---------------------------------|
| String      | Simple values, counters   | SET, GET, INCR, SETEX           |
| Hash        | Objects with fields       | HSET, HGET, HMGET, HGETALL      |
| List        | Queues, timelines         | LPUSH, RPUSH, LRANGE, LPOP      |
| Set         | Unique members, tags      | SADD, SMEMBERS, SISMEMBER       |
| Sorted Set  | Leaderboards, rankings    | ZADD, ZRANGE, ZRANK, ZSCORE     |
```

### 2. Caching Patterns

```bash
# Cache-aside: Set with TTL
SET user:1001:profile '{"name":"Alice","role":"admin"}' EX 300

# Read from cache
GET user:1001:profile

# Check TTL remaining
TTL user:1001:profile

# Cache invalidation on update
DEL user:1001:profile

# Pattern-based invalidation (use SCAN, not KEYS)
# In application code:
# for key in redis.scan_iter("user:*:sessions"):
#     redis.delete(key)
```

```python
# Python cache-aside pattern
import json
import redis

r = redis.Redis(host="localhost", port=6379, decode_responses=True)

async def get_user(user_id: str) -> dict:
    cache_key = f"user:{user_id}:profile"
    cached = r.get(cache_key)
    if cached:
        return json.loads(cached)

    # Cache miss: fetch from database
    user = await db.fetch_user(user_id)
    r.setex(cache_key, 300, json.dumps(user))  # 5 min TTL
    return user

async def invalidate_user_cache(user_id: str) -> None:
    r.delete(f"user:{user_id}:profile")
```

### 3. Rate Limiting

```bash
# Fixed window rate limiting
SET rate:user:1001:window:1710000000 1 EX 60 NX
INCR rate:user:1001:window:1710000000

# Sliding window with sorted sets
ZADD rate:user:1001 1710000000 "req:abc123"
ZREMRANGEBYSCORE rate:user:1001 0 1709999940
ZCARD rate:user:1001
EXPIRE rate:user:1001 120
```

```python
# Token bucket rate limiter
def check_rate_limit(user_id: str, limit: int = 60, window: int = 60) -> bool:
    key = f"rate:{user_id}"
    pipe = r.pipeline()
    now = time.time()
    window_start = now - window

    pipe.zremrangebyscore(key, 0, window_start)
    pipe.zadd(key, {f"{now}:{uuid4().hex}": now})
    pipe.zcard(key)
    pipe.expire(key, window + 1)
    _, _, count, _ = pipe.execute()

    return count <= limit
```

### 4. Pub/Sub and Streams

```bash
# Publish a message
PUBLISH notifications:user:1001 '{"type":"order_shipped","order_id":"ORD-500"}'

# Subscribe to a channel (in redis-cli)
SUBSCRIBE notifications:user:1001

# Pattern subscribe
PSUBSCRIBE notifications:*
```

```python
# Redis Streams for event persistence (unlike pub/sub)
# Producer
r.xadd("events:orders", {"order_id": "ORD-500", "status": "created"})

# Consumer group
r.xgroup_create("events:orders", "order-processors", id="0", mkstream=True)

# Read from stream
messages = r.xreadgroup("order-processors", "worker-1", {"events:orders": ">"}, count=10, block=5000)
for stream, entries in messages:
    for entry_id, data in entries:
        process_order(data)
        r.xack("events:orders", "order-processors", entry_id)
```

### 5. Distributed Locking

```python
# Redlock-style distributed lock
def acquire_lock(lock_name: str, ttl: int = 10, retry_count: int = 3) -> str | None:
    identifier = str(uuid4())
    for _ in range(retry_count):
        if r.set(lock_name, identifier, nx=True, ex=ttl):
            return identifier
        time.sleep(0.1)
    return None

def release_lock(lock_name: str, identifier: str) -> bool:
    # Lua script for atomic check-and-delete
    script = """
    if redis.call("get", KEYS[1]) == ARGV[1] then
        return redis.call("del", KEYS[1])
    else
        return 0
    end
    """
    return r.eval(script, 1, lock_name, identifier) == 1
```

### 6. Lua Scripting

```lua
-- Atomic compare-and-set with TTL
local current = redis.call('GET', KEYS[1])
if current == ARGV[1] then
    redis.call('SET', KEYS[1], ARGV[2])
    redis.call('EXPIRE', KEYS[1], ARGV[3])
    return 1
else
    return 0
end
```

```python
# Register Lua script in Python
CAS_SCRIPT = """
local current = redis.call('GET', KEYS[1])
if current == ARGV[1] then
    redis.call('SET', KEYS[1], ARGV[2])
    redis.call('EXPIRE', KEYS[1], ARGV[3])
    return 1
else
    return 0
end
"""
cas = r.register_script(CAS_SCRIPT)

# Usage: atomic swap if value matches
result = cas(keys=["lock:resource:1"], args=["old_value", "new_value", "30"])
```

### 7. Persistence and Configuration

```
# RDB snapshots (point-in-time, fast restart)
save 900 1         # Save after 900s if at least 1 key changed
save 300 10        # Save after 300s if at least 10 keys changed

# AOF append-only (every write, more durable)
appendonly yes
appendfsync everysec  # Sync every second (balance of speed/safety)

# Memory management
maxmemory 2gb
maxmemory-policy allkeys-lru  # Evict least recently used keys

# Security
requirepass your-strong-password
bind 0.0.0.0
protected-mode yes
```

### 8. Cluster and High Availability

```
# Sentinel for automatic failover
sentinel monitor mymaster 127.0.0.1 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 10000
sentinel parallel-syncs mymaster 1

# Redis Cluster (sharding across nodes)
# Minimum 6 nodes (3 masters + 3 replicas)
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
```

## Coaching Notes

> **ABC - Always Be Coaching:** Redis is the Swiss Army knife of data infrastructure. Understanding its data structures deeply lets you solve problems that would otherwise require entirely separate systems.

1. **Always set TTL on cache keys:** Memory is finite. Without TTL, stale data accumulates and Redis eventually runs out of memory. Use `SETEX` or `SET ... EX` for every cache write. For session data, align TTL with session timeout.

2. **Use SCAN, never KEYS:** The `KEYS` command scans every key in the database, blocking Redis for potentially seconds. `SCAN` returns results incrementally without blocking. This is non-negotiable in production.

3. **Lua scripts give you atomicity:** When you need multi-step operations (check-then-set, read-then-write), use Lua scripts. Redis executes Lua atomically -- no other command runs during script execution.

4. **Choose persistence based on your use case:** RDB for cache (fast restart, acceptable data loss). AOF for data store (every write persisted). Both for production data stores. Neither for pure cache with external source of truth.

5. **Pipelines for batch operations:** Instead of sending 100 commands individually (100 round trips), pipeline them into one batch. This reduces latency from 100 * RTT to 1 * RTT + processing time.

## Verification

After implementing Redis patterns:

- [ ] All cache keys have TTL set (no keys without expiration unless intentional)
- [ ] SCAN used instead of KEYS for all pattern matching in production
- [ ] Hash data structures used for object-like data (not serialized strings)
- [ ] Rate limiting uses sorted sets with sliding window or token bucket
- [ ] Distributed locks use Lua scripts for atomic check-and-delete
- [ ] Persistence configured appropriately (RDB for cache, AOF for data store)
- [ ] Memory limit and eviction policy set (`maxmemory`, `maxmemory-policy`)
- [ ] Production Redis requires authentication and binds to private network
- [ ] Pipeline used for batch operations instead of individual commands
- [ ] Monitoring covers memory usage, connected clients, and slow commands

## Related Skills

- **postgresql** -- Primary data store; Redis caches its query results
- **backend-patterns** -- General backend patterns (API design, auth, caching)
- **elasticsearch** -- Complementary search engine; Redis handles caching
- **performance-optimization** -- Measure-first optimization methodology
