---
name: drawio-flowchart
description: >
  Create flowcharts, swim lane diagrams, decision trees, and business process
  diagrams using Draw.io XML. Covers standard shapes, connectors, auto-layout,
  and export to PNG/SVG/PDF. Use when visualizing workflows, processes, or
  decision logic.
version: "1.0.0"
category: "drawio"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "drawio flowchart"
  - "flowchart"
  - "swim lane diagram"
  - "decision tree"
  - "business process diagram"
  - "workflow diagram"
  - "process flow"
intent: >
  Generate Draw.io XML for flowcharts and business process diagrams. Supports
  standard flowchart shapes, swim lane diagrams for cross-team processes,
  decision trees, and workflow visualization with auto-layout.
scenarios:
  - "Creating business process flowcharts with standard shapes"
  - "Designing swim lane diagrams showing responsibilities across teams"
  - "Visualizing decision trees with conditional branching"
  - "Documenting approval workflows and escalation paths"
  - "Exporting process diagrams for documentation or presentations"
best_for: "Business process flowcharts, swim lane diagrams, decision trees, approval workflows"
estimated_time: "5-20 min"
anti_patterns:
  - "Inconsistent flow direction — pick top-to-bottom or left-to-right and stick with it"
  - "Unlabeled decision branches — always label Yes/No or conditions"
  - "Complex multi-process diagrams — split into sub-processes"
  - "Non-standard shapes — use rectangles, diamonds, ovals per convention"
  - "Missing start/end nodes in the flow"
related_skills: ["diagram", "drawio-architecture"]
---

# Draw.io Flowchart

## Overview

Create flowcharts, swim lane diagrams, and business process diagrams using Draw.io (diagrams.net) XML format. Standard shapes: rectangles for processes, diamonds for decisions, ovals for start/end. Supports auto-layout for clean alignment and export to PNG/SVG/PDF.

## When to Use

- Visualizing business processes and workflows
- Creating swim lane diagrams for cross-team responsibilities
- Designing decision trees with conditional logic
- Documenting approval flows and escalation paths
- Mapping technical workflows for system documentation

## When NOT to Use

- System architecture or deployment diagrams (use drawio-architecture)
- Quick inline diagrams in Markdown (use Mermaid via diagram skill)
- Data models or ER diagrams (use diagram skill with Mermaid)

## Process

### 1. Choose Flow Direction

- **Top-to-bottom** — most common for processes
- **Left-to-right** — for timelines and sequential flows

### 2. Standard Shapes

| Shape | Meaning | Draw.io Style |
|-------|---------|---------------|
| Rounded rectangle | Start/End | `ellipse` or `rounded=1;arcSize=50` |
| Rectangle | Process step | `rounded=0` |
| Diamond | Decision point | `rhombus` |
| Parallelogram | Input/Output | `shape=parallelogram` |
| Circle | Connector/jump | `ellipse` |

### 3. Order Processing Flowchart Example

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <!-- Start -->
    <mxCell id="2" value="Order Received" style="ellipse;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
      <mxGeometry x="200" y="20" width="120" height="40" as="geometry"/>
    </mxCell>
    <!-- Decision -->
    <mxCell id="3" value="In Stock?" style="rhombus;fillColor=#fff2cc;strokeColor=#d6b656;" vertex="1" parent="1">
      <mxGeometry x="200" y="100" width="120" height="60" as="geometry"/>
    </mxCell>
    <!-- Process: Ship -->
    <mxCell id="4" value="Ship Order" style="rounded=0;fillColor=#dae8fc;strokeColor=#6c8ebf;" vertex="1" parent="1">
      <mxGeometry x="100" y="200" width="120" height="40" as="geometry"/>
    </mxCell>
    <!-- Process: Backorder -->
    <mxCell id="5" value="Backorder" style="rounded=0;fillColor=#f8cecc;strokeColor=#b85450;" vertex="1" parent="1">
      <mxGeometry x="300" y="200" width="120" height="40" as="geometry"/>
    </mxCell>
    <!-- End -->
    <mxCell id="6" value="Complete" style="ellipse;fillColor=#d5e8d4;strokeColor=#82b366;" vertex="1" parent="1">
      <mxGeometry x="140" y="280" width="120" height="40" as="geometry"/>
    </mxCell>
    <!-- Arrows -->
    <mxCell id="7" style="" edge="1" source="2" target="3" parent="1"/>
    <mxCell id="8" value="Yes" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="3" target="4" parent="1"/>
    <mxCell id="9" value="No" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="3" target="5" parent="1"/>
    <mxCell id="10" style="" edge="1" source="4" target="6" parent="1"/>
  </root>
</mxGraphModel>
```

### 4. Swim Lane Diagrams

For cross-team processes:

```xml
<!-- Pool with lanes -->
<mxCell id="pool" value="Order Process" style="shape=mxgraph.flowchart.pool;horizontal=1;startSize=30;" vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="600" height="300" as="geometry"/>
</mxCell>
<mxCell id="lane1" value="Sales" style="shape=mxgraph.flowchart.lane;horizontal=0;startSize=30;" vertex="1" parent="pool">
  <mxGeometry y="30" width="600" height="135" as="geometry"/>
</mxCell>
<mxCell id="lane2" value="Warehouse" style="shape=mxgraph.flowchart.lane;horizontal=0;startSize=30;" vertex="1" parent="pool">
  <mxGeometry y="165" width="600" height="135" as="geometry"/>
</mxCell>
```

### 5. Auto-Layout

- Use Format > Layout > Vertical/Horizontal Tree for automatic alignment
- Apply after adding all shapes and connections
- Fine-tune spacing manually after auto-layout

## Best Practices

1. **Consistent flow direction** — pick one direction and maintain throughout
2. **Standard shapes only** — rectangles for processes, diamonds for decisions, ovals for start/end
3. **Label all decision branches** — always add Yes/No or condition text
4. **One process per diagram** — split complex flows into sub-processes with connectors
5. **Include a legend** — explain shape meanings and color coding
6. **Color with purpose** — green for success paths, red for error/rejection, blue for standard, yellow for decisions

## Coaching Notes

- **Start with the happy path**: Map the successful flow first, then add error/exception branches
- **Swim lanes clarify ownership**: If multiple teams or systems are involved, swim lanes make responsibility boundaries explicit
- **Sub-processes for depth**: When a box needs more than a sentence, it should be a sub-process (linked diagram)

## Verification

- [ ] Flow direction is consistent (all top-to-bottom or all left-to-right)
- [ ] All decision branches labeled (Yes/No or condition text)
- [ ] Start and end nodes present
- [ ] No orphaned shapes (all connected to the flow)
- [ ] `.drawio` source file saved for version control

## Related Skills

- **diagram** — Excalidraw/Mermaid/SVG for general diagramming
- **drawio-architecture** — Architecture and deployment diagrams with Draw.io
