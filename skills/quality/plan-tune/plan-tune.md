---
name: plan-tune
description: >
  Learn which outputs the user finds valuable versus noisy over time. Builds a dual-track
  developer profile (declared preferences + inferred from behavior) to adjust agent output
  style, question frequency, and information density. Tracks acceptance and rejection
  patterns to self-improve across sessions.
version: "2.1.0"
category: "quality"
origin: "gstack + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "tune preferences"
  - "plan tune"
  - "adjust output"
  - "less questions"
  - "more detail"
  - "preferences"
  - "stop asking about"
  - "developer profile"
intent: >
  Build a persistent developer profile that learns what the user finds valuable. Track declared
  preferences, infer preferences from behavior (acceptance/rejection patterns), and adjust
  agent output to maximize signal and minimize noise across sessions.
scenarios:
  - "Developer wants fewer clarifying questions for routine tasks"
  - "Developer prefers full explanations for unfamiliar domains but terse output for familiar ones"
  - "Agent asks about the same thing every session and the user wants it to remember"
  - "Developer wants to declare 'never ask me about X again'"
  - "Team lead wants to set output preferences for the whole team"
best_for: "reducing repetitive interactions, personalizing agent output, cross-session learning"
estimated_time: "5-10 min (initial), continuous (passive)"
anti_patterns:
  - "Asking the user to configure everything upfront instead of learning from behavior"
  - "Ignoring explicit preference declarations"
  - "Over-fitting on a single session's patterns"
  - "Applying preferences from one project context to a different project"
related_skills:
  - style-switcher
  - context-engineering
---

# Plan Tune

## Overview

Plan Tune learns which agent outputs the user finds valuable versus noisy, building a developer profile over time. It uses a dual-track approach: declared preferences (what the user explicitly states) and inferred preferences (what the user's behavior reveals). The result is an agent that asks better questions, produces more relevant output, and wastes less of the developer's time on noise.

This skill works alongside `style-switcher` (which controls personality and density) by adding a persistent memory layer that learns across sessions.

## When to Use

- The agent asks the same questions every session and the user is frustrated
- The user says "stop asking about X" or "I always want Y"
- Output density or detail level needs to be different for different contexts
- Building a team-wide preference profile for consistent agent behavior
- Onboarding a new developer who wants the agent to adapt to their style

## When NOT to Use

- First session with no history -- let interactions happen naturally first
- One-off tasks where preferences will not carry over
- The user explicitly says "just do it" -- no tuning needed, just execute

## Anti-Patterns

- Asking 20 preference questions on first run -- learn passively, confirm actively
- Storing preferences without timestamps -- stale preferences are worse than no preferences
- Applying project-specific preferences globally -- database preferences from a backend project do not apply to a frontend project
- Treating inferred preferences as equal to declared preferences -- declared always wins

## Process

### Step 1: Initialize the Profile

Create or load the developer profile.

```
Profile location:
  .claude/preferences/developer-profile.yaml

Profile structure:
  version: "1.0"
  last_updated: <timestamp>
  declared:        # User explicitly stated these
    output:
      density: <standard|compact|terse>
      coaching: <always|when-novel|never>
      examples: <always|when-ambiguous|never>
    questions:
      <topic>: <always-ask|never-ask|context-dependent>
    domains:
      <domain>: <expert|intermediate|beginner>
  inferred:        # Learned from behavior
    acceptance_rate:
      <output_type>: <percentage>
    rejection_patterns:
      - pattern: <what was rejected>
        frequency: <count>
    follow_rate:
      <question_type>: <percentage of questions user follows>
    session_signals:
      - signal: <what was observed>
        timestamp: <when>
        confidence: <low|medium|high>
```

### Step 2: Declare Preferences

Allow the user to explicitly set preferences. These override all inferences.

```
Declaration commands:

"Never ask me about [X]"       -> questions.<X>: never-ask
"Always ask before [Y]"        -> questions.<Y>: always-ask
"I'm an expert at [Z]"         -> domains.<Z>: expert
"I'm learning [W]"             -> domains.<W>: beginner
"Stop showing code examples"   -> output.examples: never
"Always explain your reasoning" -> output.coaching: always
"Less detail on [X]"           -> output.detail_overrides.<X>: compact
"More detail on [Y]"           -> output.detail_overrides.<Y>: standard
```

Declaration prompt template:

```markdown
## Current Preferences

### Output
- Density: <current>
- Coaching: <current>
- Code examples: <current>

### Question Policy
| Topic | Policy |
|---|---|
| <topic> | <policy> |

### Domain Expertise
| Domain | Level |
|---|---|
| <domain> | <level> |

### Inferred Patterns (pending confirmation)
- <inference> (<confidence> confidence)

To change: "never ask about X", "I'm expert at Y", "always show examples"
To confirm/deny inferences: "yes, that's right" / "no, that's wrong"
```

### Step 3: Infer Preferences Passively

Watch behavior across interactions and build inference signals.

```
Inference signals:

ACCEPTANCE SIGNALS (user finds this valuable):
  - User says "good", "thanks", "perfect", "exactly"
  - User copy-pastes the output
  - User builds directly on the output without modification
  - User asks follow-up questions about the output

REJECTION SIGNALS (user finds this noisy):
  - User says "too long", "skip the explanation", "just the fix"
  - User ignores parts of the output
  - User rephrases the same request (previous output was not right)
  - User interrupts with "just do it"

QUESTION FOLLOW RATE:
  - User answers the question -> positive signal
  - User says "just pick one" -> question was low-value
  - User says "doesn't matter" -> question was noise
  - User ignores the question entirely -> question was noise
```

Inference confidence levels:

```
LOW (1-2 signals):
  - Single session observation
  - Could be context-dependent
  - Do not act on this yet

MEDIUM (3-5 signals):
  - Observed across multiple sessions
  - Pattern is consistent
  - Propose to user for confirmation

HIGH (6+ signals):
  - Strong, consistent pattern
  - Observed across many sessions and contexts
  - Apply automatically, surface in next preferences review
```

### Step 4: Apply Preferences to Output

Adjust agent behavior based on the profile.

```
Output adjustment rules:

1. DECLARED preferences are always respected (override everything)
2. INFERRED preferences with HIGH confidence are applied automatically
3. INFERRED preferences with MEDIUM confidence are proposed for confirmation
4. INFERRED preferences with LOW confidence are collected but not acted on

Adjustments by preference:

output.density:
  standard -> full reports with coaching
  compact  -> bullets only, code fixes, no coaching
  terse    -> one-liner status, diff only

output.coaching:
  always      -> every response includes teaching
  when-novel  -> coaching only for new concepts
  never       -> no coaching, just output

questions.<topic>:
  always-ask        -> always prompt for this
  never-ask         -> use sensible defaults, do not prompt
  context-dependent -> ask only when the context is ambiguous

domains.<domain>:
  expert      -> skip basics, use jargon, terse explanations
  intermediate -> brief explanations, some jargon
  beginner    -> full explanations, no jargon, step-by-step
```

### Step 5: Self-Improvement Loop

Periodically review and refine the profile.

```
Review triggers:
  - Every 10 sessions (automatic)
  - User says "review preferences" or "plan tune"
  - Rejection rate exceeds 30% for any output type
  - New domain or project context detected

Review process:
1. Surface all inferred preferences with MEDIUM+ confidence
2. Ask user to confirm or deny each
3. Promote confirmed inferences to declared preferences
4. Discard rejected inferences
5. Remove stale preferences (older than 30 sessions with no reinforcement)
```

### Step 6: Project-Scoped Preferences

Preferences can be project-specific.

```
Preference resolution order (most specific wins):
1. Project-level: .claude/preferences/developer-profile.yaml
2. User-level: ~/.claude/preferences/developer-profile.yaml
3. Defaults: standard density, when-novel coaching, context-dependent questions

Project-specific overrides:
  - If a project has a domain focus (e.g., fintech backend), domain expertise
    defaults may differ from global
  - If a project has a team profile, team preferences override individual
  - If a project has CONTRIBUTING.md or style guides, those inform defaults
```

## Coaching Notes

> **ABC - Always Be Coaching:** Plan Tune embodies a principle that applies to all engineering tools: the best tool is the one that adapts to you, not the one that makes you adapt to it. A developer profile is not configuration overhead -- it is accumulated knowledge that makes every future interaction more efficient.

1. **Declared beats inferred, always.** When a user says "never ask me about database schema decisions," that is final. No amount of behavioral inference should override an explicit declaration. Inference is for the gaps between what the user states and what the user actually does.

2. **The best preferences are invisible.** If the user never notices the adjustment, the system is working. The moment a user has to say "you should know I prefer X by now" is the moment the system failed.

3. **Confidence levels prevent premature optimization.** A single session where the user rejects a long explanation does not mean they always want terse output. They might have been in a hurry. Three sessions with consistent rejection is a pattern worth acting on.

4. **Preferences have a half-life.** A preference set six months ago may no longer be relevant. Developers learn, projects change, contexts shift. Stale preferences should degrade gracefully, not persist forever.

## Verification

After setting up or updating plan-tune:

- [ ] Developer profile file exists at `.claude/preferences/developer-profile.yaml`
- [ ] Declared preferences are stored and respected in output
- [ ] Inference signals are being collected (check after 2-3 sessions)
- [ ] Inference confidence levels are assigned correctly
- [ ] LOW confidence inferences are not being acted on
- [ ] HIGH confidence inferences are applied automatically
- [ ] MEDIUM confidence inferences are proposed for confirmation
- [ ] Project-scoped preferences override global when present
- [ ] Stale preferences have a degradation mechanism (30-session window)
- [ ] Preference review can be triggered manually ("plan tune")

## Related Skills

- `style-switcher` -- controls personality and density axes (complementary to plan-tune)
- `context-engineering` -- optimizes agent context setup (plan-tune is part of context optimization)
