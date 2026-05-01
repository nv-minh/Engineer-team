---
name: design-review
description: UI/UX design review with Frontend Expert and Product Manager agents
version: "2.0.0"
category: "team"
origin: "agent-skills"
agents_used:
  - "duck:product"
  - "duck:frontend"
skills_used:
  - "frontend-patterns"
  - "code-review"
  - "browser-testing"
  - "performance-optimization"
estimated_time: "2-4 hours"
---

# Design Review Workflow

## Overview

The Design Review workflow focuses on UI/UX evaluation, combining the Frontend Expert's technical assessment of interface implementation with the Product Manager's validation of user experience and business requirements.

## When to Use

- New UI/UX designs before implementation
- Component library updates
- Design system changes
- User flow modifications
- Accessibility compliance review
- Performance optimization for user interfaces

## Lifecycle

DEFINE ──→ PLAN ──→ BUILD ──→ VERIFY ──→ REVIEW ──→ SHIP
  (1)       (2)       (3)       (4)        (5)       (6)
   │         │         │         │          │         │
   ▼         ▼         ▼         ▼          ▼         ▼
 GATE 1    GATE 2    GATE 3    GATE 4     GATE 5    DONE

### Phase Mapping

| Lifecycle Phase | Workflow Stage |
|-----------------|----------------|
| DEFINE | Product Requirements Review (Stage 1) |
| PLAN | UI/UX Technical Review (Stage 2) |
| BUILD | Design implementation based on review findings |
| VERIFY | Accessibility audit, responsive design, performance checks |
| REVIEW | Consolidated Design Assessment (Stage 3) |
| SHIP | Approved design handed off for implementation |

### Verification Gates

#### Gate 1: Definition Complete
- [ ] User stories validated with INVEST criteria
- [ ] User flows reviewed
- [ ] Acceptance criteria assessed
- [ ] Business value confirmed
PASS → proceed | FAIL → return to DEFINE

#### Gate 2: Plan Complete
- [ ] Component architecture reviewed
- [ ] State management assessed
- [ ] Core Web Vitals analyzed
- [ ] Responsive design verified
- [ ] Accessibility audit completed
PASS → proceed | FAIL → return to PLAN

#### Gate 3: Build Complete
- [ ] Design recommendations implemented
- [ ] Responsive layouts created
- [ ] Accessibility standards met
PASS → proceed | FAIL → return to BUILD

#### Gate 4: Verification Complete
- [ ] WCAG 2.1 AA compliance verified
- [ ] Performance targets met (LCP, FID, CLS)
- [ ] Cross-browser testing passed
PASS → proceed | FAIL → return to BUILD

#### Gate 5: Review Complete
- [ ] Findings merged and prioritized
- [ ] UX issues identified
- [ ] Recommendations actionable
- [ ] Scorecard completed
PASS → proceed to SHIP | FAIL → return to BUILD

## Workflow Stages

### Stage 1: Product Requirements Review (Product Manager)

**Agent:** `duck:product`

**Actions:**
- Validate user stories
- Review user flows
- Assess business requirements
- Validate acceptance criteria
- Review market fit

**Input:**
- User stories
- Wireframes/mockups
- Requirements document
- User flows

**Output:** Product Requirements Review Report

**Quality Gate:**
- [ ] User stories validated (INVEST criteria)
- [ ] User flows reviewed
- [ ] Acceptance criteria assessed
- [ ] Business value confirmed

---

### Stage 2: UI/UX Technical Review (Frontend Expert)

**Agent:** `duck:frontend`

**Actions:**
- Review React/Next.js component architecture
- Assess state management strategy
- Evaluate Core Web Vitals (LCP, FID, CLS)
- Review responsive design
- Conduct accessibility audit (WCAG 2.1 AA/AAA)
- Review performance optimization

**Input:**
- Design mockups
- Component specifications
- User flows
- Performance requirements

**Output:** Frontend Expert UI/UX Review Report

**Quality Gate:**
- [ ] Component architecture reviewed
- [ ] State management assessed
- [ ] Core Web Vitals analyzed
- [ ] Responsive design verified
- [ ] Accessibility audit completed
- [ ] Performance assessed

---

### Stage 3: Consolidated Design Assessment

**Agents:** `duck:product` + `duck:frontend`

**Actions:**
- Merge business and technical findings
- Identify UX issues
- Prioritize improvements
- Create actionable recommendations

**Output:** Consolidated Design Review Report

**Quality Gate:**
- [ ] Findings merged
- [ ] UX issues identified
- [ ] Improvements prioritized
- [ ] Recommendations actionable

---

## Handoff Contracts

### To Product Manager
```yaml
provides:
  - user_stories
  - wireframes
  - mockups
  - user_flows

expects:
  - user_story_validation
  - flow_review
  - acceptance_criteria_assessment
  - business_value_confirmation
```

### Product Manager → Frontend Expert
```yaml
provides:
  - validated_user_stories
  - flow_requirements
  - acceptance_criteria
  - business_context

expects:
  - ui_ux_review
  - component_assessment
  - accessibility_audit
  - performance_analysis
```

### Frontend Expert → Consolidation
```yaml
provides:
  - ui_findings
  - component_assessment
  - accessibility_report
  - performance_metrics

expects:
  - consolidation
  - ux_improvements
  - recommendations
```

---

## UI/UX Review Framework

### Visual Design Assessment
```yaml
visual_design:
  color:
    - palette_appropriate_for_brand
    - contrast_ratios_meet_wcag_aa
    - color_usage_consistent
    - dark_mode_considered

  typography:
    - font_hierarchy_clear
    - line_length_appropriate
    - font_sizes_accessible
    - font_pairing_harmonious

  spacing:
    - consistent_spacing_system
    - breathing_room_adequate
    - alignment_consistent
    - grid_system_used

  imagery:
    - images_high_quality
    - alt_text_provided
    - lazy_loading_implemented
    - responsive_images_used
```

### User Experience Assessment
```yaml
user_experience:
  navigation:
    - navigation_intuitive
    - menu_structure_logical
    - breadcrumbs_present
    - search_functional

  flows:
    - user_flows_smooth
    - edge_cases_handled
    - error_states_defined
    - success_states_clear

  feedback:
    - loading_indicators_present
    - progress_shown
    - errors_clear_and_actionable
    - confirmations_for_destructive

  accessibility:
    - keyboard_navigation_works
    - screen_reader_compatible
    - focus_indicators_visible
    - color_not_only_indicator
```

### Responsive Design Assessment
```yaml
responsive_design:
  breakpoints:
    - mobile_small_320px
    - mobile_375px
    - tablet_768px
    - desktop_1440px
    - large_desktop_1920px

  testing:
    - content_fits_all_viewports
    - no_horizontal_scroll
    - touch_targets_adequate
    - text_readable_without_zoom
```

### Performance Assessment
```yaml
performance_metrics:
  lcp_largest_contentful_paint:
    target: "< 2.5s"
    assessment: "[✅/⚠️/❌]"

  fid_first_input_delay:
    target: "< 100ms"
    assessment: "[✅/⚠️/❌]"

  cls_cumulative_layout_shift:
    target: "< 0.1"
    assessment: "[✅/⚠️/❌]"

  bundle_size:
    target: "< 200KB (gzipped)"
    assessment: "[✅/⚠️/❌]"
```

---

## Accessibility Checklist

### WCAG 2.1 AA Compliance
- [ ] Color contrast ratio 4.5:1 for normal text
- [ ] Color contrast ratio 3:1 for large text
- [ ] All functionality available via keyboard
- [ ] Focus indicators visible
- [ ] Error identification clear
- [ ] Labels provided for all inputs
- [ ] Alternative text for images
- [ ] Headers properly nested
- [ ] Lists properly marked up
- [ ] ARIA landmarks used appropriately

### WCAG 2.1 AAA Compliance (Enhanced)
- [ ] Color contrast ratio 7:1 for normal text
- [ ] Color contrast ratio 4.5:1 for large text
- [ ] No errors are easy to correct
- [ ] Context-sensitive help available

---

## Output Template

```markdown
# Design Review Report: [Feature/Component]

**Review Date:** [Date]
**Reviewers:** Product Manager + Frontend Expert
**Project/Feature:** [Name]

---

## Executive Summary

**Overall UI/UX Quality:** [Score]/10
**Business Value:** [High/Medium/Low]
**Accessibility Compliance:** [WCAG 2.1 AA/AAA/Non-Compliant]
**Responsive Design:** [Fully/Partially/Not] Responsive
**Performance Rating:** [Excellent/Good/Fair/Poor]
**Status:** [✅ APPROVED | ⚠️ NEEDS WORK | ❌ REJECTED]

---

## Product Requirements Review

### User Stories Validation (INVEST)
| Criterion | Status | Notes |
|-----------|--------|-------|
| Independent | [✅/⚠️/❌] | [Notes] |
| Negotiable | [✅/⚠️/❌] | [Notes] |
| Valuable | [✅/⚠️/❌] | [Notes] |
| Estimable | [✅/⚠️/❌] | [Notes] |
| Small | [✅/⚠️/❌] | [Notes] |
| Testable | [✅/⚠️/❌] | [Notes] |

### User Flows Review
[Assessment of user flows]

### Acceptance Criteria
[Assessment of acceptance criteria quality]

---

## UI/UX Technical Review

### Visual Design
**Color:** [Score]/10 - [Assessment]
**Typography:** [Score]/10 - [Assessment]
**Spacing:** [Score]/10 - [Assessment]
**Imagery:** [Score]/10 - [Assessment]

### User Experience
**Navigation:** [Score]/10 - [Assessment]
**Flows:** [Score]/10 - [Assessment]
**Feedback:** [Score]/10 - [Assessment]
**Accessibility:** [Score]/10 - [Assessment]

### Responsive Design
| Viewport | Width | Status | Issues |
|----------|-------|--------|--------|
| Mobile Small | 320px | [✅/❌] | [Issues] |
| Mobile | 375px | [✅/❌] | [Issues] |
| Tablet | 768px | [✅/❌] | [Issues] |
| Desktop | 1440px | [✅/❌] | [Issues] |
| Large Desktop | 1920px | [✅/❌] | [Issues] |

### Performance
**LCP:** [X.Xs] (< 2.5s target) - [✅/⚠️/❌]
**FID:** [XXms] (< 100ms target) - [✅/⚠️/❌]
**CLS:** [X.XX] (< 0.1 target) - [✅/⚠️/❌]

---

## Accessibility Audit

### WCAG 2.1 Compliance
**Level:** [AA/AAA/Non-Compliant]

### Automated Testing Results
**Tool:** axe-core
**Issues Found:** [Number]
- Critical: [Number]
- Serious: [Number]
- Moderate: [Number]
- Minor: [Number]

### Manual Testing Results
- [✅/❌] Keyboard navigation works
- [✅/❌] Screen reader compatible
- [✅/❌] Color contrast meets WCAG AA
- [✅/❌] Focus indicators visible

### Accessibility Checklist
- [ ] All images have alt text
- [ ] Form inputs have labels
- [ ] Color contrast meets WCAG AA
- [ ] Keyboard navigation works
- [ ] Focus indicators visible
- [ ] ARIA labels used appropriately
- [ ] Semantic HTML used
- [ ] Error messages accessible

---

## Findings

### Critical Issues (Must Fix)
| Issue | Impact | Fix |
|-------|--------|-----|
| [Issue] | [Impact] | [Fix] |

### High Issues (Should Fix)
| Issue | Impact | Fix |
|-------|--------|-----|
| [Issue] | [Impact] | [Fix] |

### Medium Issues (Nice to Have)
| Issue | Impact | Fix |
|-------|--------|-----|
| [Issue] | [Impact] | [Fix] |

---

## Recommendations

### Immediate (Before Implementation)
1. [Recommendation 1]
2. [Recommendation 2]

### Short Term (During Implementation)
1. [Recommendation 1]
2. [Recommendation 2]

### Long Term (Future Enhancements)
1. [Recommendation 1]
2. [Recommendation 2]

---

## Design Scorecard

| Dimension | Score | Notes |
|-----------|-------|-------|
| Visual Design | [1-10] | [Notes] |
| User Experience | [1-10] | [Notes] |
| Accessibility | [1-10] | [Notes] |
| Performance | [1-10] | [Notes] |
| Responsive Design | [1-10] | [Notes] |
| **Overall** | **[1-10]** | [Notes] |

---

## Decision

**Status:** [✅ APPROVED | ⚠️ NEEDS WORK | ❌ REJECTED]

**Rationale:**
[Reasoning for decision]

**Required Changes (if NEEDS WORK):**
- [Change 1]
- [Change 2]

**Blocking Issues (if REJECTED):**
- [Issue 1]
- [Issue 2]

---

**Report Generated:** [Timestamp]
**Reviewed by:** Product Manager + Frontend Expert
```

---

## Success Criteria

- [ ] User stories validated (INVEST criteria)
- [ ] User flows reviewed
- [ ] UI/UX design assessed
- [ ] Component architecture reviewed
- [ ] Accessibility audit completed
- [ ] Performance analyzed
- [ ] Responsive design verified
- [ ] Findings documented
- [ ] Recommendations provided
- [ ] Scorecard completed

---

**Workflow Version:** 1.0.0
**Last Updated:** 2026-04-19
**Primary Agents:** duck:product, duck:frontend
