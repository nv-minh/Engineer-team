---
name: drawio-flowchart
description: >
  Create flowcharts, swim lane diagrams, decision trees, and business process
  diagrams using Draw.io XML. Covers standard shapes, connectors, auto-layout,
  and export to PNG/SVG/PDF.
version: "3.0.0"
category: "drawio"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["drawio flowchart", "flowchart", "swim lane diagram", "decision tree", "business process diagram", "workflow diagram", "process flow"]
intent: >
  Generate Draw.io XML for flowcharts and business process diagrams. Supports
  standard flowchart shapes, swim lane diagrams, decision trees, and workflow visualization.
scenarios:
  - "Creating business process flowcharts with standard shapes"
  - "Designing swim lane diagrams showing responsibilities across teams"
  - "Visualizing decision trees with conditional branching"
best_for: "Business process flowcharts, swim lane diagrams, decision trees, approval workflows"
estimated_time: "5-20 min"
anti_patterns:
  - "Inconsistent flow direction — pick top-to-bottom or left-to-right and stick with it"
  - "Unlabeled decision branches — always label Yes/No or conditions"
  - "Complex multi-process diagrams — split into sub-processes"
  - "Missing start/end nodes in the flow"
related_skills: ["diagram", "drawio-architecture"]

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

# Draw.io Flowchart

[ROLE]
Act as a flowchart diagram expert. Generate Draw.io XML for business process flowcharts, swim lane diagrams, and decision trees using standard shapes and consistent flow direction.

[OBJECTIVE]
Produce Draw.io flowcharts where flow direction is consistent, decision branches are labeled, start/end nodes are present, and swim lanes clarify ownership boundaries.

[RULES]
1. <thought>Before creating a flowchart, determine: What is the happy path? What decision points exist? Are multiple teams involved (swim lanes)? Should sub-processes be separate diagrams?</thought>
2. Pick one flow direction (top-to-bottom or left-to-right) and maintain throughout.
3. Use standard shapes — rectangles for processes, diamonds for decisions, ovals for start/end.
4. Label all decision branches with Yes/No or condition text.
5. Include start and end nodes in every flow.
6. DO NOT mix flow directions in the same diagram.
7. DO NOT leave decision branches unlabeled.
8. DO NOT create complex multi-process diagrams — split into sub-processes.
9. DO NOT omit start/end nodes.
10. Use swim lanes when multiple teams or systems are involved.
11. Color with purpose — green for success paths, red for error/rejection, blue for standard, yellow for decisions.
12. ABC: Start with the happy path first, then add error/exception branches. Swim lanes make responsibility boundaries explicit.

[PROCESS]

### Standard Shapes

| Shape | Meaning | Draw.io Style |
|-------|---------|---------------|
| Rounded rectangle | Start/End | `ellipse` or `rounded=1;arcSize=50` |
| Rectangle | Process step | `rounded=0` |
| Diamond | Decision point | `rhombus` |
| Parallelogram | Input/Output | `shape=parallelogram` |

### Flowchart Example

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <mxCell id="2" value="Order Received" style="ellipse;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
      <mxGeometry x="200" y="20" width="120" height="40" as="geometry"/>
    </mxCell>
    <mxCell id="3" value="In Stock?" style="rhombus;fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="1">
      <mxGeometry x="200" y="100" width="120" height="60" as="geometry"/>
    </mxCell>
    <mxCell id="4" value="Ship Order" style="rounded=0;fillColor=#dae8fc;" vertex="1" parent="1">
      <mxGeometry x="100" y="200" width="120" height="40" as="geometry"/>
    </mxCell>
    <mxCell id="5" value="Backorder" style="rounded=0;fillColor=#f8cecc;" vertex="1" parent="1">
      <mxGeometry x="300" y="200" width="120" height="40" as="geometry"/>
    </mxCell>
    <mxCell id="7" style="" edge="1" source="2" target="3" parent="1"/>
    <mxCell id="8" value="Yes" edge="1" source="3" target="4" parent="1"/>
    <mxCell id="9" value="No" edge="1" source="3" target="5" parent="1"/>
  </root>
</mxGraphModel>
```

### Swim Lane Diagrams

```xml
<mxCell id="pool" value="Order Process" style="shape=mxgraph.flowchart.pool;horizontal=1;" vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="600" height="300" as="geometry"/>
</mxCell>
<mxCell id="lane1" value="Sales" style="shape=mxgraph.flowchart.lane;" vertex="1" parent="pool"/>
<mxCell id="lane2" value="Warehouse" style="shape=mxgraph.flowchart.lane;" vertex="1" parent="pool"/>
```

### Verification

- [ ] Flow direction is consistent
- [ ] All decision branches labeled
- [ ] Start and end nodes present
- [ ] No orphaned shapes (all connected)
- [ ] `.drawio` source file saved for version control

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with Draw.io XML, `patterns_applied`, and `recommendations`.
