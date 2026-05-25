---
name: django
description: >
  Django framework patterns for full-stack Python web development. Covers ORM, views, URLs,
  admin, REST framework, middleware, templates, forms, authentication, testing, and deployment.
  Use when building Django web apps, REST APIs with DRF, or content management systems.
version: "3.0.0"
category: "expert-python"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["django", "django rest framework", "drf", "django orm", "django admin", "python web", "migrations"]
intent: >
  Equip developers with production-grade Django patterns covering models, views, templates,
  REST APIs, admin customization, middleware, testing, and deployment.
scenarios:
  - "Building a Django web application with models, views, templates, and admin"
  - "Creating a REST API with Django REST Framework and serializers"
  - "Optimizing Django ORM queries to avoid N+1 problems"
best_for: "Django web apps, DRF APIs, ORM patterns, admin customization, testing"
estimated_time: "20-40 min"
anti_patterns:
  - "Placing business logic in views instead of service layers or model methods"
  - "Using .all() and iterating without select_related/prefetch_related causing N+1 queries"
  - "Running Django with DEBUG=True in production or using the development server"
related_skills: ["python-patterns", "backend-patterns", "test-driven-development"]

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

# Django Patterns

[ROLE]
Act as a Django expert. Deliver production-grade Django code with optimized ORM queries, DRF serializers, custom admin, and proper deployment settings.

[OBJECTIVE]
Build Django applications where models use proper constraints and indexes, views are thin, ORM queries avoid N+1 with select_related/prefetch_related, and DRF handles API serialization.

[RULES]
1. <thought>Before writing any Django code, determine: Does this need a model change (migration)? Is this a view (HTTP) or service (logic)? Will this query cause N+1?</thought>
2. Always start with a custom User model extending `AbstractUser` — swapping mid-project is painful.
3. Use `select_related` for ForeignKey, `prefetch_related` for ManyToMany — non-negotiable.
4. Keep views thin — business logic in model methods, managers, or service modules.
5. Use Django REST Framework for any API — serializers, viewsets, and routers.
6. Split settings by environment — `base.py`, `development.py`, `production.py`.
7. DO NOT place business logic in views — delegate to services or model methods.
8. DO NOT use `.all()` and iterate without select_related/prefetch_related.
9. DO NOT run with `DEBUG=True` in production.
10. DO NOT use the development server in production — use Gunicorn + Nginx.
11. Use Flyway/Liquibase-style migration discipline — review before applying, test rollback.
12. ABC: select_related and prefetch_related are non-negotiable. Profile with django-debug-toolbar and fix every N+1 query.

[PROCESS]

### Models and ORM

```python
class TimestampedModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    class Meta: abstract = True

class Article(TimestampedModel):
    title = models.CharField(max_length=200, db_index=True)
    slug = models.SlugField(unique=True)
    body = models.TextField()
    status = models.CharField(max_length=20, choices=[("draft", "Draft"), ("published", "Published")], default="draft", db_index=True)
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name="articles")
    class Meta:
        ordering = ["-created_at"]
        indexes = [models.Index(fields=["status", "-created_at"])]
```

### Query Optimization

```python
articles = Article.objects.select_related("author").prefetch_related("tags").filter(status="published").annotate(comment_count=Count("comments"))
results = Article.objects.filter(Q(title__icontains=query) | Q(body__icontains=query), status="published")
```

### Django REST Framework

```python
class ArticleSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source="author.get_full_name", read_only=True)
    class Meta:
        model = Article
        fields = ["id", "title", "slug", "body", "status", "author_name", "created_at"]

class ArticleViewSet(viewsets.ModelViewSet):
    serializer_class = ArticleSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    def get_queryset(self):
        return Article.objects.select_related("author").prefetch_related("tags").all()
    def perform_create(self, serializer):
        serializer.save(author=self.request.user)
```

### Admin

```python
@admin.register(Article)
class ArticleAdmin(admin.ModelAdmin):
    list_display = ["title", "author", "status", "created_at"]
    list_filter = ["status", "created_at", "tags"]
    search_fields = ["title", "body"]
    prepopulated_fields = {"slug": ("title",)}
```

### Testing

```python
class ArticleAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user("testuser", "test@test.com", "password123")
    def test_create_article(self):
        self.client.force_authenticate(self.user)
        response = self.client.post("/api/articles/", {"title": "Test", "body": "Content", "status": "draft"})
        self.assertEqual(response.status_code, 201)
```

### Production Settings

```python
SECRET_KEY = os.environ["SECRET_KEY"]
DEBUG = False
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```

### Verification

- [ ] Custom User model extends `AbstractUser`
- [ ] All list views use `select_related` / `prefetch_related`
- [ ] Business logic in services or model methods, not views
- [ ] Admin customized with `list_display`, `list_filter`, `search_fields`
- [ ] DRF serializers validate all input
- [ ] Production settings have SSL redirects, secure cookies, no DEBUG

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with code, `patterns_applied`, and `recommendations`.
