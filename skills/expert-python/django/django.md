---
name: django
description: >
  Django framework patterns for full-stack Python web development. Covers ORM, views, URLs,
  admin, REST framework, middleware, templates, forms, authentication, testing, and deployment.
  Use when building Django web apps, REST APIs with DRF, or content management systems.
version: "1.0.0"
category: "expert-python"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "django"
  - "django rest framework"
  - "drf"
  - "django orm"
  - "django admin"
  - "python web"
  - "migrations"
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
---

# Django Patterns

## Overview

Django is a batteries-included Python web framework following the MTV (Model-Template-View) pattern. This skill covers production-grade Django development: ORM patterns, view design, URL routing, admin customization, Django REST Framework, middleware, forms, authentication, testing, and deployment. Focus on patterns that scale beyond the tutorial.

## When to Use

- Building content-heavy web applications (CMS, e-commerce, SaaS)
- Creating REST APIs with Django REST Framework
- Rapid prototyping with admin interface and ORM
- Projects requiring built-in auth, sessions, and middleware
- Applications with complex data models and relationships

## When NOT to Use

- Lightweight microservices (use FastAPI or Flask)
- Real-time WebSocket-heavy apps (use FastAPI with Channels or Socket.IO)
- Serverless functions (Django's overhead is too heavy)

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|---|---|---|
| Fat views with business logic | Hard to test and reuse | Use services.py or model methods |
| N+1 queries with `.all()` | Dozens of DB round trips | Use `select_related` / `prefetch_related` |
| `DEBUG = True` in production | Security risk, memory leak | Set via env var, never commit |
| Sync views for async-friendly Django | Misses performance gains | Use `async def` views for I/O-bound handlers |
| Raw SQL without parameterization | SQL injection vulnerability | Use ORM or parameterized `raw()` |
| God models with 50+ methods | Untestable, unmaintainable | Extract to managers, queries, services |

## Core Patterns

### 1. Project Structure

```
project/
├── manage.py
├── config/               # Project settings
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   ├── users/
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── serializers.py
│   │   ├── urls.py
│   │   ├── services.py     # Business logic
│   │   └── tests/
│   └── orders/
├── templates/
├── static/
├── requirements/
│   ├── base.txt
│   ├── development.txt
│   └── production.txt
└── docker-compose.yml
```

### 2. Models and ORM Patterns

```python
from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    """Custom user model -- always start with this."""
    phone = models.CharField(max_length=20, blank=True)

class TimestampedModel(models.Model):
    """Abstract base model with created/updated timestamps."""
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

class Article(TimestampedModel):
    title = models.CharField(max_length=200, db_index=True)
    slug = models.SlugField(unique=True)
    body = models.TextField()
    status = models.CharField(
        max_length=20,
        choices=[("draft", "Draft"), ("published", "Published")],
        default="draft",
        db_index=True,
    )
    author = models.ForeignKey(User, on_delete=models.CASCADE, related_name="articles")
    tags = models.ManyToManyField("Tag", blank=True, related_name="articles")

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            models.Index(fields=["status", "-created_at"]),
        ]

    def __str__(self):
        return self.title

class Tag(models.Model):
    name = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.name
```

### 3. Query Optimization

```python
from django.db.models import Prefetch, Count, Q

# select_related for ForeignKey (JOIN)
articles = Article.objects.select_related("author").all()

# prefetch_related for ManyToMany (2 queries)
articles = Article.objects.prefetch_related("tags").all()

# Combined with filtering
articles = (
    Article.objects
    .select_related("author")
    .prefetch_related(Prefetch("tags", queryset=Tag.objects.filter(name__startswith="py")))
    .filter(status="published")
    .annotate(comment_count=Count("comments"))
)

# Only load needed columns
articles = Article.objects.only("title", "slug", "created_at")

# Complex lookups with Q objects
from django.db.models import Q
results = Article.objects.filter(
    Q(title__icontains=query) | Q(body__icontains=query),
    status="published",
)
```

### 4. Views and URLs

```python
# Function-based views (simple, explicit)
from django.shortcuts import render, get_object_or_404, redirect
from django.contrib.auth.decorators import login_required

def article_list(request):
    articles = Article.objects.select_related("author").filter(status="published")
    return render(request, "articles/list.html", {"articles": articles})

@login_required
def article_create(request):
    if request.method == "POST":
        form = ArticleForm(request.POST)
        if form.is_valid():
            article = form.save(commit=False)
            article.author = request.user
            article.save()
            return redirect(article.get_absolute_url())
    else:
        form = ArticleForm()
    return render(request, "articles/form.html", {"form": form})

# Class-based views (less code, more conventions)
from django.views.generic import ListView, DetailView, CreateView

class ArticleListView(ListView):
    model = Article
    template_name = "articles/list.html"
    context_object_name = "articles"
    paginate_by = 20

    def get_queryset(self):
        return (
            Article.objects
            .select_related("author")
            .filter(status="published")
        )

# URLs
from django.urls import path
from . import views

urlpatterns = [
    path("articles/", views.ArticleListView.as_view(), name="article-list"),
    path("articles/<slug:slug>/", views.article_detail, name="article-detail"),
    path("articles/new/", views.article_create, name="article-create"),
]
```

### 5. Django REST Framework

```python
from rest_framework import serializers, viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

# Serializers
class ArticleSerializer(serializers.ModelSerializer):
    author_name = serializers.CharField(source="author.get_full_name", read_only=True)
    tag_names = serializers.StringRelatedField(source="tags", many=True, read_only=True)

    class Meta:
        model = Article
        fields = ["id", "title", "slug", "body", "status", "author_name", "tag_names", "created_at"]
        read_only_fields = ["slug", "created_at"]

# ViewSets
class ArticleViewSet(viewsets.ModelViewSet):
    serializer_class = ArticleSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        return Article.objects.select_related("author").prefetch_related("tags").all()

    def perform_create(self, serializer):
        serializer.save(author=self.request.user)

    @action(detail=True, methods=["post"])
    def publish(self, request, pk=None):
        article = self.get_object()
        article.status = "published"
        article.save()
        return Response(self.get_serializer(article).data)

# Router
from rest_framework.routers import DefaultRouter
router = DefaultRouter()
router.register("articles", ArticleViewSet)
```

### 6. Admin Customization

```python
from django.contrib import admin

@admin.register(Article)
class ArticleAdmin(admin.ModelAdmin):
    list_display = ["title", "author", "status", "created_at"]
    list_filter = ["status", "created_at", "tags"]
    search_fields = ["title", "body"]
    prepopulated_fields = {"slug": ("title",)}
    raw_id_fields = ["author"]
    date_hierarchy = "created_at"
    readonly_fields = ["created_at", "updated_at"]
```

### 7. Testing

```python
import pytest
from django.test import TestCase, Client
from rest_framework.test import APIClient

class ArticleAPITest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user("testuser", "test@test.com", "password123")

    def test_create_article(self):
        self.client.force_authenticate(self.user)
        response = self.client.post("/api/articles/", {
            "title": "Test Article",
            "body": "Content here",
            "status": "draft",
        })
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data["author_name"], "testuser")

    def test_list_published_only(self):
        Article.objects.create(title="Pub", body="...", status="published", author=self.user)
        Article.objects.create(title="Draft", body="...", status="draft", author=self.user)
        response = self.client.get("/api/articles/")
        self.assertEqual(len(response.data["results"]), 1)
```

### 8. Deployment Settings

```python
# settings/production.py
import os
SECRET_KEY = os.environ["SECRET_KEY"]
DEBUG = False
ALLOWED_HOSTS = os.environ.get("ALLOWED_HOSTS", "").split(",")
DATABASES = {"default": {"ENGINE": "django.db.backends.postgresql", ...}}
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
```

```bash
# Deployment commands
python manage.py collectstatic --noinput
python manage.py migrate --noinput
gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 4
```

## Coaching Notes

> **ABC - Always Be Coaching:** Django's "batteries included" philosophy means the framework has already solved most problems. Your job is learning which battery to use and when.

1. **Always start with a custom User model:** Even if you don't need extra fields now, swapping User models mid-project is extremely painful. Run `AbstractUser` from day one.

2. **select_related and prefetch_related are non-negotiable:** Any time you access a related object in a loop, you have an N+1 query. Profile with `django-debug-toolbar` and fix every one.

3. **Keep views thin:** Views handle HTTP (request parsing, response formatting). Business logic goes in model methods, managers, or dedicated service modules. This makes logic testable without HTTP.

4. **Use Django REST Framework for any API:** DRF's serializers, viewsets, and routers eliminate boilerplate. The browsable API alone saves hours of debugging.

5. **Split settings by environment:** `base.py`, `development.py`, `production.py`. Never commit secrets. Use `DJANGO_SETTINGS_MODULE` to select the right one.

## Verification

After implementing Django patterns:

- [ ] Custom User model extends `AbstractUser` (not default User)
- [ ] All list views use `select_related` / `prefetch_related` (verify with debug toolbar)
- [ ] Business logic lives in services or model methods, not views
- [ ] Admin is customized with `list_display`, `list_filter`, `search_fields`
- [ ] DRF serializers validate all input, ViewSets handle CRUD consistently
- [ ] Tests use `APIClient` for API tests, `TestCase` for view tests
- [ ] Production settings have SSL redirects, secure cookies, no DEBUG
- [ ] Static files served via WhiteNoise or CDN, not Django
- [ ] Migrations are reviewed before applying, rollback tested

## Related Skills

- **python-patterns** -- Core Python patterns (type hints, async, data models, testing)
- **backend-patterns** -- General backend patterns (API design, auth, caching)
- **test-driven-development** -- TDD red-green-refactor cycle
- **api-interface-design** -- Contract-first API design methodology
- **security-hardening** -- OWASP Top 10 security patterns
