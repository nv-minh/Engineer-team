# EM-Team Git Hooks

Git hooks để enforce quality gates trong EM-Team system.

Source: agent-skills + GSD best practices

## Hooks Available

### 1. pre-commit
Chạy trước khi commit để đảm bảo code quality.

**Kiểm tra:**
- TypeScript type check (nếu có)
- Linting (ESLint, Prettier, etc.)
- Unit tests
- Common issues (console.log, TODO without issue, large files)

**Cài đặt:**
```bash
cp em-team/hooks/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit
```

### 2. commit-msg
Validates commit message format.

**Kiểm tra:**
- Conventional Commits format
- Commit type hợp lệ
- Subject length (max 72 characters)
- Issue reference (recommended)

**Format:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `refactor` - Refactoring
- `test` - Tests
- `docs` - Documentation
- `chore` - Maintenance
- `style` - Code style
- `perf` - Performance
- `ci` - CI/CD
- `build` - Build system
- `revert` - Revert commit

**Cài đặt:**
```bash
cp em-team/hooks/commit-msg .git/hooks/
chmod +x .git/hooks/commit-msg
```

### 3. pre-push
Chạy trước khi push để đảm bảo everything ready.

**Kiểm tra:**
- Full test suite
- Build check
- Security audit
- Uncommitted changes
- Protected branch warning

**Cài đặt:**
```bash
cp em-team/hooks/pre-push .git/hooks/
chmod +x .git/hooks/pre-push
```

## Cài đặt tất cả hooks

```bash
# Copy tất cả hooks
cp em-team/hooks/* .git/hooks/

# Make executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg
chmod +x .git/hooks/pre-push
```

## Skip hooks (không khuyến khích)

```bash
# Skip pre-commit
git commit --no-verify

# Skip commit-msg
git commit --no-verify -m "message"

# Skip pre-push
git push --no-verify
```

⚠️ **Warning:** Skipping hooks bypasses quality gates!

## Customization

Mỗi hook có thể được customize cho project của bạn:

1. Mở hook file
2. Thêm/bỏ kiểm tra tùy ý
3. Giữ nguyên structure và colors

## Troubleshooting

### Hook không chạy?
- Kiểm tra permission: `ls -la .git/hooks/`
- Make executable: `chmod +x .git/hooks/HOOK_NAME`

### Lỗi permission denied?
- Run: `chmod +x .git/hooks/pre-commit`

### Muốn tạm thời disable?
- Comment out hook code, hoặc
- Use `--no-verify` flag (not recommended)

## Quality Gates Enforced

| Gate | Hook | Purpose |
|------|------|---------|
| Type check | pre-commit | Catch type errors early |
| Linting | pre-commit | Consistent code style |
| Tests | pre-commit, pre-push | TDD Iron Law |
| Build | pre-push | Ensure buildable |
| Security | pre-push | No vulnerabilities |
| Format | commit-msg | Conventional commits |

---

# Git Hooks

## brownfield-pr-check

Pre-push hook. When `.em-brownfield/` exists, warns about which brownfield modules
the push affects. Non-blocking (always exits 0).

Install:
```bash
cp hooks/brownfield-pr-check .git/hooks/pre-push
chmod +x .git/hooks/pre-push
```

Bypass: `git push --no-verify`

---

**EM-Team Version:** 1.0.0
**Last Updated:** 2026-04-18
