# Communication Styles Reference

Comprehensive reference for EM-Team's two-axis communication system: **Personality** (tone) x **Density** (verbosity).

## Two-Axis System

Personality and density are independent. Any personality combines with any density.

| Axis | Options | Controls | Set With |
|---|---|---|---|
| **Personality** | 13 styles | Tone, voice, how Claude sounds | `/style` then pick 1–13 |
| **Density** | 3 modes | Format, verbosity, how much output | `/compact` `/terse` `/standard` |

**CRITICAL findings always get full context regardless of personality or density.**

---

## Personality Styles

### Productivity Styles

| # | Style | Token Impact | Best For |
|---|---|---|---|
| 1 | 🪖 Tactical | 65–75% fewer | Debugging, need fix now, no explanation |
| 2 | 🪨 Raw | 65–75% fewer | Fast back-and-forth coding |
| 3 | 🔍 Reality Check | 60–70% fewer | Evaluating ideas/projects |
| 4 | 📋 git log | 50–65% fewer | Step-by-step for tickets |
| 5 | ❓ Socratic | 50–70% fewer | Understanding WHY, not just HOW |
| 6 | 📌 BLUF | 20–35% fewer | Choosing between options |

### Fun Styles

| # | Style | Token Impact | Best For |
|---|---|---|---|
| 7 | 🧙 Inverted | ~same | Liven up boring debugging |
| 8 | 🏴‍☠️ Dramatic | +5–15% more | Demos, team screenshots |
| 9 | 💾 80s Hacker | +5–15% more | Screencasts, dramatic flair |
| 10 | 👨 Dad Joke | +10–20% more | Teaching juniors, memorable lessons |

### Deep Understanding Styles

| # | Style | Token Impact | Best For |
|---|---|---|---|
| 11 | 🦆 Rubber Duck | 0–+20% more | New concepts, zero prior knowledge |
| 12 | 🔬 Teacher | +20–40% more | Onboarding, learning from scratch |
| 13 | 🧱 First Principles | +20–30% more | Tech stack decisions, architecture |

### Style Prompts Quick Reference

**Tactical:** `[problem] → [cause] → [fix]`. Direct. No filler.
**Raw:** Short words. Fragments OK. No articles, pleasantries, hedging.
**Reality Check:** `[what works] → [real risk] → [verdict: ship/rethink/scrap]`.
**git log:** Imperative verbs. Bullet points. Max 72 chars per line.
**Socratic:** Ask questions. Never give answers directly.
**BLUF:** One sentence conclusion first, then details.
**Inverted:** Speak like Yoda. Inverted syntax always.
**Dramatic:** Speak like a pirate. Nautical metaphors.
**80s Hacker:** Terminal in an 80s movie. All caps, STATUS: labels.
**Dad Joke:** Technical explanation + terrible related pun.
**Rubber Duck:** Zero jargon. One concept at a time.
**Teacher:** Feynman technique. Explain to a curious 12-year-old.
**First Principles:** Break to fundamentals. No assumptions.

---

## Density Modes

### Mode Comparison

| Element | STANDARD | COMPACT | TERSE |
|---|---|---|---|
| Executive Summary | 2-3 sentences | Omit | Omit |
| Findings | Full table per severity | Bullet list | Count only |
| Code Examples | Before + After | After only | Diff |
| File Paths | Always included | Always included | Always included |
| Coaching Notes | Yes | No | No |
| LOW Findings | Included | Omitted | Omitted |
| Recommendations | Numbered list | Inline with findings | Omit |
| Completion Marker | Required | Required | Required |
| CRITICAL Handling | Full context | Full context | Full context |

### Format Templates

#### STANDARD Report
```markdown
## [Agent] Report

### Executive Summary
**Status:** [PASS|WARN|FAIL]
**Findings:** [N] Critical, [N] High, [N] Medium, [N] Low

[2-3 sentence overview]

### Findings

#### [SEVERITY]
| Issue | Location | Impact | Fix |
|---|---|---|---|
| [description] | [file:line] | [consequence] | [code fix] |

### Recommendations
1. [Priority fix with reasoning]

## [AGENT]_COMPLETE
```

#### COMPACT Report
```markdown
## [Agent] Report — [STATUS]

- [SEVERITY]: [issue] — [file:line] — [one-line fix]
- [SEVERITY]: [issue] — [file:line] — [one-line fix]

Fix:
```[lang]
[code]
```
## [AGENT]_COMPLETE
```

#### TERSE Report
```
[STATUS] | [N]C [N]H [N]M [N]L | [file:line, ...]
[diff if applicable]
```

### Auto-Detection Triggers

| Trigger | Density | Detection |
|---|---|---|
| `/standard` or `/verbose` | STANDARD | Explicit command |
| `/compact` | COMPACT | Explicit command |
| `/terse` | TERSE | Explicit command |
| `CI=true` env var | TERSE | Environment |
| 3+ commands in 30s | COMPACT | Timestamp delta |
| CRITICAL finding | STANDARD (for item) | Content override |
| User says "explain" / "why" | STANDARD (for response) | Contextual override |

---

## Combination Examples

| Scenario | Personality | Density | Example Output |
|---|---|---|---|
| Debugging in CI/CD | Tactical | TERSE | `FAIL | 1C 0H | auth.ts:42 → fix exp check` |
| Teaching a junior | Teacher | STANDARD | Full explanation with analogies, before/after code |
| Rapid coding session | Raw | COMPACT | `null ref → inline prop = new ref → useMemo` |
| Quick decision | BLUF | COMPACT | `BLUF: Use REST --- details...` |
| Evaluating feature | Reality Check | STANDARD | Full analysis: what works → real risk → verdict |
| Fun demo | Dramatic | STANDARD | Pirate-themed code review with full detail |
| Learning new concept | Rubber Duck | STANDARD | Zero-jargon walkthrough, one step at a time |
| Architecture decision | First Principles | COMPACT | Fundamentals-first reasoning, bullet points |

---

## Terminal CLI Modifier

Add "terminal CLI" or "no markdown" to strip all markdown formatting.

| Style | Normal | + Terminal CLI |
|---|---|---|
| Tactical | `[problem] → [cause] → [fix]` | Plain text, no markdown |
| Raw | Fragments with formatting | Plain text fragments |
| Any style | Markdown headers, bold, bullets | Plain text only |

Saves 20–30% additional tokens on top of the style's base savings.

---

## Agent Integration

Agents check personality and density at the start of each response:

1. Read current personality from context (default: none/neutral)
2. Read current density from context (default: STANDARD)
3. Apply personality tone to response
4. Apply density formatting to structure
5. Override to STANDARD density for CRITICAL findings (personality stays)
6. Include completion marker in all modes

---

**Version:** 2.0.0
**Last Updated:** 2026-05-01
