---
name: github-release-manager
description: "Manages the full release lifecycle: bumps version, generates release notes from CHANGELOG, creates a git tag, and publishes a GitHub Release. Use when shipping a new version of a project."
version: "1.0.0"
category: "workflow"
origin: "EM-Team (GitHub Management)"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "create release"
  - "publish release"
  - "release version"
  - "release manager"
  - "tag version"
  - "bump version"
  - "ship release"
  - "github release"
intent: "Produce a clean, documented GitHub Release with a proper semver tag, release notes, and optional build artifacts — making every release traceable and understandable to stakeholders."
scenarios:
  - "Shipping a new version after merging a feature branch"
  - "Hotfix release after a production bug is fixed"
  - "Major version bump with breaking changes and migration guide"
  - "Publishing a release with build artifacts (binaries, dist packages)"
best_for: "Any project using GitHub releases for version management and distribution"
estimated_time: "10-15 minutes"
anti_patterns:
  - "Manually writing release notes without pulling from CHANGELOG — creates inconsistency"
  - "Skipping the git tag — GitHub Releases without tags can't be referenced in lockfiles or checksums"
  - "Releasing from a dirty working tree — only release from a clean, merged state"
  - "Releasing without verifying CI is green on the release commit"
  - "Ignoring semantic versioning — patch/minor/major must match the nature of the changes"
related_skills:
  - git-workflow
  - finishing-branch
  - github-pr-manager
  - ci-cd-automation
---

# GitHub Release Manager

## Overview

A release is the formal publication of a version of the software. This skill automates the mechanical parts (version bump, tag, notes, GitHub Release) while requiring human judgment on the version type (patch/minor/major) and the release notes narrative.

## When to Use

- After a feature or hotfix branch is merged to main
- At the end of a sprint when you want to snapshot the deliverable
- When distributing build artifacts (binaries, Docker images, npm packages)

**When NOT to Use:** Continuous deployment where every merge to main auto-deploys — releases are for versioned, discrete deliverables.

## Anti-Patterns

- Releasing with uncommitted changes: always release from a clean, merged commit
- Using `v1.0.0` and `1.0.0` inconsistently: pick a convention and stick to it (recommend `v` prefix for git tags)
- Writing release notes that only list commits: good release notes explain *impact*, not just *changes*
- Skipping pre-release validation: run the full test suite on the exact commit you're releasing

## Process

### Step 1 — Verify Release Readiness

```bash
# Must be on main/master and clean
git status                    # no uncommitted changes
git diff main origin/main     # main is pushed and up to date

# CI must be green on HEAD
gh run list --branch main --limit 5  # all recent runs passed?

# Check what's unreleased since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

### Step 2 — Determine Version Bump

Show the user the unreleased commits and ask:

```
Unreleased changes since v1.3.2:
  feat: add OAuth2 login support
  feat: add order confirmation emails
  fix: login fails with + in email
  chore: upgrade dependencies

Semantic versioning:
  MAJOR (v2.0.0): Breaking changes to public API, schema migration required
  MINOR (v1.4.0): New features, backwards compatible
  PATCH (v1.3.3): Bug fixes only, no new features

Proposed: MINOR → v1.4.0 (new features were added)
Confirm version? [v1.4.0]
```

### Step 3 — Update Version File

Detect version source:

```bash
# Node.js / package.json
npm version minor --no-git-tag-version
# or manually: jq '.version = "1.4.0"' package.json

# Python / pyproject.toml
# bump version field manually or via bump2version

# Go — usually just the git tag (no version file)

# Generic VERSION file
echo "1.4.0" > VERSION
```

### Step 4 — Generate Release Notes

Extract from `CHANGELOG.md` the `## [Unreleased]` section (or the section matching the new version):

**Format:**

```markdown
## Release Notes — v1.4.0

### New Features
- **OAuth2 Login**: Users can now sign in with Google and GitHub accounts
- **Order Confirmation Emails**: Customers receive an email when their order is confirmed

### Bug Fixes
- Fixed login failure for email addresses containing '+' character (#42)

### Maintenance
- Upgraded all dependencies to latest stable versions

### Migration Notes
None — this release is fully backwards compatible.

**Full changelog:** https://github.com/owner/repo/blob/main/CHANGELOG.md
```

Notes are written for the *audience* (users/stakeholders), not developers. "Fixed timing-safe comparison" → "Fixed a security issue in the login flow."

### Step 5 — Commit Version Bump

```bash
git add package.json CHANGELOG.md VERSION  # whichever files changed
git commit -m "chore: bump version to v1.4.0"
git push
```

### Step 6 — Create Git Tag

```bash
git tag -a v1.4.0 -m "Release v1.4.0 — OAuth2 login and order confirmation emails"
git push origin v1.4.0
```

### Step 7 — Create GitHub Release

```bash
gh release create v1.4.0 \
  --title "v1.4.0 — OAuth2 login and order confirmation emails" \
  --notes "$(cat /tmp/release-notes.md)" \
  [--target main] \
  [--prerelease]   # add this flag for beta/rc releases
```

### Step 8 — Attach Artifacts (optional)

```bash
# Build artifacts first
npm run build
# or: make release / cargo build --release / etc.

# Attach to the release
gh release upload v1.4.0 dist/app-linux-amd64 dist/app-darwin-amd64 dist/app.zip
```

### Step 9 — Announce (optional)

For significant releases, generate an announcement:

```markdown
🚀 **v1.4.0 Released**

We're shipping two new features in this release:

**OAuth2 Login** — Sign in with Google or GitHub, no password required.
**Order Confirmation Emails** — Automatic emails when orders are confirmed.

Plus a bug fix for login failures with '+' in email addresses.

→ [Release notes](https://github.com/owner/repo/releases/tag/v1.4.0)
→ [Install / Upgrade](https://...)
```

## Hotfix Release Process

For urgent production fixes:

```bash
# Branch from the current release tag
git checkout -b hotfix/1.3.3 v1.3.2

# Apply the fix
# ... fix code ...

git commit -m "fix: critical auth bypass in OAuth callback"

# Tag directly from hotfix branch
git tag -a v1.3.3 -m "Hotfix: critical auth bypass"
git push origin hotfix/1.3.3 v1.3.3

# GitHub Release
gh release create v1.3.3 \
  --title "v1.3.3 — Security hotfix" \
  --notes "Critical: fixes auth bypass in OAuth callback. All users should upgrade immediately."

# Merge hotfix back to main
git checkout main && git merge hotfix/1.3.3 && git push
```

## Pre-release (Beta/RC)

```bash
# Tag as pre-release
git tag -a v2.0.0-rc.1 -m "Release candidate 1 for v2.0.0"
git push origin v2.0.0-rc.1

gh release create v2.0.0-rc.1 \
  --title "v2.0.0 Release Candidate 1" \
  --prerelease \
  --notes "Release candidate for v2.0.0. Please test and report issues."
```

## Coaching Notes

> **ABC - Always Be Coaching:**

1. **Semantic versioning is a contract.** When you bump MINOR, you're promising backwards compatibility. When you bump MAJOR, you're telling downstream users to prepare for changes. Breaking that promise destroys trust faster than any bug.

2. **Release notes are for humans, not machines.** "chore(deps): bump axios from 1.4 to 1.5" is a git commit message. "Updated dependencies for security fixes" is a release note. Translate technical changes into user-visible impact.

3. **Tag before release, not after.** The tag is the canonical marker of what was released. Creating the GitHub Release first and tagging later is backwards — someone might download the wrong code.

4. **Hotfixes go to both the release branch AND main.** Forgetting to merge a hotfix back to main means the bug reappears in the next release.

## Verification

- [ ] Working tree is clean and CI is green on HEAD
- [ ] Version bumped in all relevant files (`package.json`, `VERSION`, etc.)
- [ ] `CHANGELOG.md` updated with release notes under the new version
- [ ] Version bump committed and pushed to main
- [ ] Git tag created and pushed (`git tag -a v{version}`)
- [ ] GitHub Release created with title and notes
- [ ] Build artifacts attached (if applicable)
- [ ] Release visible at `https://github.com/owner/repo/releases/tag/v{version}`

## Artifact Export

When `EM_TEAM_ARTIFACT_EXPORT` is enabled:

After release, export to:
`plans/YYYY-MM-DD-HHMM-release-v{version}.md`

Include: version, release type (major/minor/patch/hotfix), release notes, tag SHA, artifact list.
