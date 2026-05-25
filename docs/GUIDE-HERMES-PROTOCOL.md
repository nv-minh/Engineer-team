# EM-Team: Hermes Protocol v4.0.0

> Guide cho team. Covers kiến trúc Hermes, lợi ích thực tế, và cách sử dụng.

---

## 1. Hermes Protocol là gì?

Hermes Protocol là chuẩn cấu trúc cho toàn bộ agents, skills, và workflows trong EM-Team, dựa trên triết lý của [NousResearch Hermes models](https://nousresearch.com/):

1. **Absolute Steerability** — Agent tuân thủ tuyệt đối qua structured blocks
2. **Flawless Tool Use** — JSON Schema cho mọi skill input/output
3. **Local/Cloud Agnostic** — Chạy được trên Anthropic, OpenAI, Ollama, vLLM

---

## 2. Lợi ích thực tế

### 2.1 Agent chính xác hơn — ít phải re-prompt

**Trước:** Prompt dạng prose dài. Agent đọc rồi "hiểu theo cách của nó", đôi khi bỏ qua bước, tự ý thêm thứ không cần.

**Sau:** `[RULES]` numbered + `[PROCESS]` step-by-step. Rule `<thought>` buộc agent suy nghĩ trước khi hành động.

```markdown
[RULES]
1. Output <thought> before every action.
2. NEVER patch symptoms. Find root cause first.
3. Create regression test BEFORE implementing fix.
```

### 2.2 Output nhất quán — dễ verify, dễ so sánh

**Trước:** Mỗi lần chạy code-review, output format khác nhau.

**Sau:** `output_schema` định nghĩa rõ output structure:

```yaml
output_schema:
  type: object
  required: [status, assessment, findings]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    assessment: { type: string, enum: [APPROVE, REQUEST_CHANGES, COMMENT] }
    findings:
      type: array
      items:
        type: object
        required: [severity, issue, location, fix]
```

Mỗi lần chạy → output cùng format → dễ so sánh giữa các lần.

### 2.3 Error handling tự động — agent tự retry

**Trước:** Skill fail → "có vấn đề gì đó".

**Sau:** `error_schema` trả về structured error:

```json
{
  "error_type": "missing_input",
  "message": "Spec file not found at path",
  "suggestion": "Provide valid spec path or create spec first",
  "retry_possible": true
}
```

Agent đọc error → tự sửa params → retry. Max 3 lần trước khi report BLOCKED.

### 2.4 Workflow dài không bị lạc — context pruning

**Trước:** Greenfield 12 stages → đến stage 8, Claude quên quyết định ở stage 2-3.

**Sau:** ReAct + context pruning. Mỗi stage tạo state snapshot (~500 tokens):

```yaml
workflow_state:
  current_phase: BUILD
  completed_phases:
    - phase: DEFINE
      status: PASS
      summary: "Spec approved. Tech stack: Next.js + PostgreSQL."
    - phase: PLAN
      status: PASS
      summary: "15 tasks planned. 3 phases."
  next_action: "Task 5 — Create UserService"
```

Carry forward chỉ thông tin quan trọng. Discard log thừa.

### 2.5 Context nhẹ hơn ~70% — respond nhanh, rẻ hơn

| Metric | Trước | Sau |
|--------|-------|-----|
| Tổng dòng code | 55,327 | 15,657 |
| Giảm | — | **-72%** |

Cùng nội dung nhưng concise. Claude đọc nhanh hơn, tốn ít token hơn.

### 2.6 Dùng local model được

Muốn chạy Hermes 3 qua Ollama cho summarization tasks (thay vì trả API)?

```bash
export LLM_PROVIDER=ollama
export LLM_MODEL=hermes3
# Done. haiku-client.sh tự switch endpoint.
```

Không cần thì bỏ qua — default vẫn là Anthropic.

---

## 3. Cấu trúc Agent (mới)

### Trước (prose)

```markdown
## Role Identity
You are a methodical debug engineer who applies...

## Status Protocol
| Status | Meaning | When to Use |
...

## Coaching Mandate (ABC)
- Every code review comment should teach...

## Overview
The Debugger agent performs systematic...

## When to Use
- Investigating bugs
- Diagnosing issues
...
```

### Sau (Hermes blocks)

```markdown
[ROLE]
Methodical debug engineer. Scientific method for root cause analysis.

[OBJECTIVE]
Find root cause. Implement fix with regression test. Verify.

[RULES]
1. Output <thought> before every investigation step.
2. NEVER patch symptoms. Find root cause first.
3. Max 5 hypotheses. Rank by probability.
4. ABC: Explain WHY the bug occurred, not just WHAT changed.

[AVAILABLE SKILLS]
- systematic-debugging
- test-driven-development

[PROCESS]
Phase 1 - INVESTIGATE: Gather symptoms, logs, stack traces.
Phase 2 - ANALYZE: Form ranked hypotheses with evidence.
Phase 3 - HYPOTHESIZE: Test each hypothesis.
Phase 4 - IMPLEMENT: Fix root cause, write regression test.

[RESPONSE FORMAT]
Reference output_schema in frontmatter.

[HANDOFF]
→ executor: { root_cause_analysis, fix_specification }
→ code-reviewer: { fix_diff, debugging_findings }
```

---

## 4. Cấu trúc Skill (mới)

### Thêm vào frontmatter

```yaml
---
name: code-review
# ... existing keys unchanged ...

input_schema:
  type: object
  required: [target]
  properties:
    target: { type: string, description: "PR URL or file path" }
    depth: { type: string, enum: [standard, deep], default: standard }

output_schema:
  type: object
  required: [status, assessment, findings]
  properties:
    status: { type: string, enum: [DONE, DONE_WITH_CONCERNS, NEEDS_CONTEXT, BLOCKED] }
    assessment: { type: string, enum: [APPROVE, REQUEST_CHANGES, COMMENT] }
    findings: { type: array, items: { ... } }

error_schema:
  type: object
  required: [error_type, message]
  properties:
    error_type: { type: string, enum: [missing_input, ambiguous_scope, blocked, tool_failure, validation_error] }
    message: { type: string }
    suggestion: { type: string }
---
```

---

## 5. Workflow ReAct (mới)

### Mỗi stage = Thought → Action → Observation

```markdown
### Stage 1: Investigate

<thought>
Observe: Bug report received. Login timeout after 30s.
Analyze: Need to reproduce and gather evidence.
Plan: Invoke debugger agent in find_root_cause mode.
</thought>

<action>
type: invoke_agent
target: debugger
params: { mode: find_root_cause, symptoms: ["login timeout 30s"] }
</action>

<observation>
result: Root cause identified — DB connection pool exhausted.
gate_status: PASS
</observation>

**State Snapshot:**
workflow_state:
  current_phase: DEFINE
  root_cause: "DB connection pool exhausted"
  next_action: "Plan fix"
```

---

## 6. LLM Provider Configuration

### Env vars

| Variable | Default | Description |
|----------|---------|-------------|
| `LLM_PROVIDER` | `anthropic` | Provider: anthropic, openai, ollama, vllm, custom |
| `LLM_BASE_URL` | Auto-detected | API endpoint URL |
| `LLM_API_KEY` | `$ANTHROPIC_AUTH_TOKEN` | Authentication key |
| `LLM_MODEL` | Provider default | Model identifier |

### Ví dụ

```bash
# Anthropic (default — không cần set gì)
# Chỉ cần ANTHROPIC_AUTH_TOKEN

# Ollama local
export LLM_PROVIDER=ollama
export LLM_MODEL=hermes3

# OpenAI
export LLM_PROVIDER=openai
export LLM_API_KEY=sk-xxx

# vLLM server
export LLM_PROVIDER=vllm
export LLM_BASE_URL=http://gpu-server:8000/v1

# Custom endpoint
export LLM_PROVIDER=custom
export LLM_BASE_URL=http://my-server/v1
export LLM_API_KEY=my-key
export LLM_MODEL=my-model
```

---

## 7. Validation

```bash
# Check toàn bộ compliance
bash scripts/validate-hermes.sh

# Output chi tiết
bash scripts/validate-hermes.sh --verbose

# Expected output:
# Agents:    38/38 with schema, 38/38 with blocks
# Skills:    85/85 with schema
# Workflows: 25/25 with ReAct
# Soft language: 0 violations
```

---

## 8. Templates tham khảo

| Template | Path | Mục đích |
|----------|------|----------|
| Skill JSON Schema | `templates/hermes-skill-schema.template.md` | Format chuẩn cho input/output/error schema |
| ReAct Workflow | `templates/hermes-react-workflow.template.md` | Format chuẩn cho ReAct blocks trong workflows |

---

## 9. Cấu hình bắt buộc

Để Feature Workspace và Artifact Export hoạt động, cần set env vars trong `.claude/settings.local.json` của **project đích** (không phải EM-Team repo):

```json
{
  "env": {
    "EM_TEAM_ARTIFACT_EXPORT": "true",
    "EM_TEAM_SESSION_AUDIT": "true",
    "EM_TEAM_ATOMIC_COMMITS": "true",
    "LLM_PROVIDER": "anthropic"
  }
}
```

| Toggle | Mặc định | Tác dụng |
|--------|----------|----------|
| `EM_TEAM_ARTIFACT_EXPORT` | `false` | **Bắt buộc** cho Feature Workspace. Không bật = không có `.em-feature-context`, không track cross-prompt |
| `EM_TEAM_SESSION_AUDIT` | `false` | Log session vào `.em-team/logs/` |
| `EM_TEAM_ATOMIC_COMMITS` | `true` | 1 commit per task khi executor chạy |
| `LLM_PROVIDER` | `anthropic` | Provider cho summarization: `anthropic`, `openai`, `ollama`, `vllm`, `custom` |

---

## 10. Quick Reference

### Trigger agents

```
em:planner           # Create plan
em:executor          # Execute plan
em:debugger          # Debug systematically
em:code-reviewer     # Code review (5-axis or 9-axis)
em:architect         # Architecture design
```

### Check compliance

```bash
bash scripts/validate-hermes.sh           # Full check
grep "input_schema:" agents/debugger.md    # Verify specific file
grep "\[ROLE\]" agents/debugger.md         # Verify block structure
```

### Switch LLM provider

```bash
export LLM_PROVIDER=ollama LLM_MODEL=hermes3   # Local
export LLM_PROVIDER=anthropic                    # Cloud (default)
```

### Feature Workspace

```bash
bash scripts/artifact-register.sh workspace                # List all workspaces
bash scripts/artifact-register.sh context                   # Show active feature
bash scripts/artifact-register.sh switch user-dashboard     # Switch back to old feature
# Next prompt continues updating that feature's workspace
```
