---
name: em:iron-law-enforcer
description: Gate enforcement for Iron Law compliance - EM-Team Agent
tags: [iron-law, enforcement, quality-gate, em-team]
always_available: true
---

# EM:Iron-Law-Enforcer - Iron Law Gate Enforcement

Enforces Iron Law compliance: TDD, root cause debugging, spec-before-code, review-before-merge.

## Usage

```
Use the em:iron-law-enforcer skill to [check/enforce] [scope]
```

## Examples

```
Use the em:iron-law-enforcer skill to check Iron Law compliance
Use the em:iron-law-enforcer skill to enforce TDD on this feature
Use the em:iron-law-enforcer skill to audit the code review process
```

## What This Does

Invokes the **em-iron-law-enforcer agent** to:
- Check TDD Iron Law compliance (no production code without failing test)
- Check Debugging Iron Law (no fixes without root cause)
- Check Spec Iron Law (no code without spec for features)
- Check Review Iron Law (no merge without review)
- Report compliance status with violations
