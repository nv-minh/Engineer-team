# API Design Reference

Shared API design patterns referenced by api-interface-design, api-testing, backend-patterns skills.

---

## REST API Conventions

### URL Structure
```
GET    /api/v1/users          # List
POST   /api/v1/users          # Create
GET    /api/v1/users/:id      # Get single
PUT    /api/v1/users/:id      # Full update
PATCH  /api/v1/users/:id      # Partial update
DELETE /api/v1/users/:id      # Delete
GET    /api/v1/users/:id/orders # Nested resource
```

### Response Format (Envelope)
```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 150
  },
  "errors": []
}
```

### Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ]
  }
}
```

## HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation failure |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | Authenticated but not authorized |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate, version conflict |
| 422 | Unprocessable | Business rule violation |
| 429 | Too Many Requests | Rate limited |
| 500 | Internal Error | Unexpected server error |

## Pagination

```
GET /api/v1/users?page=1&per_page=20&sort=created_at&order=desc

Response:
{
  "data": [...],
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 150,
    "total_pages": 8
  }
}
```

## API Versioning

| Strategy | Example | Pros | Cons |
|----------|---------|------|------|
| URL path | `/api/v1/users` | Simple, clear | URL changes |
| Header | `Accept: application/vnd.api.v1+json` | Clean URLs | Less visible |
| Query param | `/api/users?version=1` | Simple | Not RESTful |

**Recommended:** URL path versioning — clearest for consumers.

## Rate Limiting Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```
