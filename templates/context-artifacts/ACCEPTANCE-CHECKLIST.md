# ACCEPTANCE-CHECKLIST.md - Deliverable Acceptance Checklist (成果物受領チェックリスト)

**Project:** [Project Name]
**Release:** [Version / Sprint]
**Delivery Date:** YYYY-MM-DD
**Prepared by:** [Name]

---

## Purpose

This checklist documents the completeness and acceptability of a delivery package before client sign-off. Both the development team and the client representative verify each item. Discrepancies are noted and resolved before sign-off.

---

## 1. Source Code & Build (ソースコード・ビルド)

| Item | Expected | Actual | Status | Notes |
|---|---|---|---|---|
| Source code delivered (repository access or archive) | ✅ | | [ ] | |
| All features in scope implemented | ✅ | | [ ] | |
| Code compiles/builds without errors | ✅ | | [ ] | |
| No hardcoded credentials or secrets | ✅ | | [ ] | |
| All TODOs resolved or documented | ✅ | | [ ] | |
| Branch/tag for this release created | ✅ | | [ ] | Tag: [name] |

---

## 2. Testing (テスト)

| Item | Expected | Actual | Status | Notes |
|---|---|---|---|---|
| Unit tests included | ✅ | | [ ] | |
| Unit test coverage | ≥ [80]% | [N]% | [ ] | |
| Integration tests included | ✅ | | [ ] | |
| All tests passing in CI | ✅ | | [ ] | |
| UAT execution log provided | ✅ | | [ ] | |
| UAT pass rate | ≥ 95% | [N]% | [ ] | |
| Zero Critical UAT defects open | ✅ | | [ ] | |
| High defects: resolved or risk-accepted | ✅ | | [ ] | Open High: [N] |

---

## 3. Documentation (ドキュメント)

| Item | Expected | Actual | Status | Notes |
|---|---|---|---|---|
| Requirements document (REQUIREMENTS.md) | ✅ Final version | | [ ] | Version: [X.X] |
| Basic Design document (BASIC-DESIGN.md) | ✅ Final version | | [ ] | Version: [X.X] |
| Detailed Design documents | ✅ All modules | | [ ] | [N] modules |
| API documentation (Swagger/OpenAPI or equivalent) | ✅ | | [ ] | |
| Database schema documentation | ✅ | | [ ] | |
| README with setup instructions | ✅ | | [ ] | |
| CHANGELOG / Release notes | ✅ | | [ ] | |
| Architecture Decision Records (ADRs) | ✅ (if any) | | [ ] | [N] ADRs |

---

## 4. Deployment & Operations (デプロイ・運用)

| Item | Expected | Actual | Status | Notes |
|---|---|---|---|---|
| Deployment guide (step-by-step) | ✅ | | [ ] | |
| Environment variables documented | ✅ | | [ ] | |
| System verified in staging environment | ✅ | | [ ] | |
| System deployed to production (if in scope) | [Yes/No] | | [ ] | |
| Rollback procedure documented | ✅ | | [ ] | |
| Monitoring and alerting configured | [Yes/No] | | [ ] | |
| Backup/restore procedure documented | [Yes/No] | | [ ] | |

---

## 5. Security (セキュリティ)

| Item | Expected | Actual | Status | Notes |
|---|---|---|---|---|
| Security audit completed | ✅ | | [ ] | |
| OWASP Top 10 vulnerabilities addressed | ✅ | | [ ] | |
| No known Critical security vulnerabilities | ✅ | | [ ] | |
| Dependency vulnerability scan clean | ✅ | | [ ] | |
| Secrets management documented | ✅ | | [ ] | |

---

## 6. Known Issues & Limitations (既知の問題・制限事項)

> List all known issues that are being accepted as part of this delivery.
> Each issue must be acknowledged by the client representative.

| Defect/Issue ID | Description | Severity | Planned Fix Release |
|---|---|---|---|
| DEF-003 | [Description] | Medium | v[X.X] (YYYY-MM-DD) |
| — | None | — | — |

**Client acknowledgment:** By signing this checklist, the client acknowledges the known issues listed above and accepts the delivery with these limitations.

---

## 7. Training & Support Handoff (トレーニング・引き継ぎ)

| Item | Expected | Actual | Status | Notes |
|---|---|---|---|---|
| Training session conducted (if in scope) | [Yes/No] | | [ ] | Date: YYYY-MM-DD |
| Training materials provided | [Yes/No] | | [ ] | |
| Support contact defined | ✅ | | [ ] | Contact: [Name, email] |
| Support period start date | YYYY-MM-DD | | [ ] | |
| Support period end date | YYYY-MM-DD | | [ ] | |
| Escalation path documented | ✅ | | [ ] | |

---

## 8. Contract Compliance (契約確認)

| Item | Contract Requirement | Actual | Status | Notes |
|---|---|---|---|---|
| Delivery date | YYYY-MM-DD | YYYY-MM-DD | [ ] | |
| Features in scope | [N] features | [N] features | [ ] | |
| Performance SLA met | [Spec from contract] | [Measured] | [ ] | |
| IP ownership documentation | ✅ | | [ ] | |
| License compliance | ✅ | | [ ] | |

---

## Discrepancy Log (不一致事項)

| # | Item | Expected | Actual | Resolution | Status |
|---|---|---|---|---|---|
| 1 | [Item] | [Expected] | [Actual] | [How resolved] | Open / Resolved |

---

## Sign-Off (受領サイン)

### Development Team Certification
We certify that the deliverables listed above are complete, tested, and ready for acceptance.

| Role | Name | Signature | Date |
|---|---|---|---|
| Tech Lead | | | |
| Project Manager | | | |
| QA Lead | | | |

### Client Acceptance
By signing below, the client confirms receipt and acceptance of the delivery package as described above, subject to the known issues listed in Section 6.

| Role | Name | Signature | Date |
|---|---|---|---|
| Client Technical Lead | | | |
| Client Project Manager | | | |
| Client Executive Sponsor | | | |

**Overall Acceptance Decision:** ✅ Accepted | ⚠️ Accepted with conditions | ❌ Not accepted

**Conditions (if applicable):**
[Any conditions attached to this acceptance]

---

**Delivery date:** YYYY-MM-DD
**Acceptance date:** YYYY-MM-DD
**Document version:** 1.0
