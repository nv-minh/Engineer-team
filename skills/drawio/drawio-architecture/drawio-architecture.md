---
name: drawio-architecture
description: >
  Create system architecture, deployment, and component diagrams using Draw.io XML.
  Supports C4 model levels, UML component diagrams, AWS/Azure/GCP cloud shapes,
  and export to PNG/SVG/PDF.
version: "3.0.0"
category: "drawio"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers: ["drawio architecture", "architecture diagram", "c4 diagram", "deployment diagram", "cloud architecture", "system design diagram", "draw.io"]
intent: >
  Generate Draw.io XML for system architecture diagrams. Supports C4 model
  (context, container, component), cloud provider shapes (AWS, Azure, GCP),
  and deployment diagrams for technical documentation.
scenarios:
  - "Creating C4 model context or container diagrams for system design"
  - "Visualizing microservices architecture with real service names"
  - "Designing cloud deployment diagrams with AWS/Azure/GCP shapes"
best_for: "System architecture diagrams, C4 model, cloud deployment diagrams, UML component diagrams"
estimated_time: "5-30 min"
anti_patterns:
  - "Cramming multiple abstraction levels into one diagram — use C4 layers"
  - "Missing legend explaining colors and shapes"
  - "Diagrams without a title or last-updated date"
  - "Storing only PNG — always keep the .drawio source file in version control"
related_skills: ["diagram", "architecture-zoom-out"]

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

# Draw.io Architecture

[ROLE]
Act as an architecture diagram expert. Generate Draw.io XML for system architecture diagrams using C4 model layering, cloud provider shapes, and consistent styling.

[OBJECTIVE]
Produce Draw.io architecture diagrams where each diagram covers one abstraction level (C4), connections are labeled with protocols, legends explain color coding, and `.drawio` source files are committed to version control.

[RULES]
1. <thought>Before creating a diagram, determine: What C4 level is appropriate for the audience? What cloud shapes are needed? What color scheme distinguishes system types?</thought>
2. One diagram, one concern — separate context, container, and component diagrams.
3. Use consistent styling — same colors, fonts, and arrow styles across all project diagrams.
4. Always include a legend explaining color coding and shape meanings.
5. Label all connections with protocol, data format, and direction.
6. Date-stamp living documents — add "Last updated: YYYY-MM-DD".
7. DO NOT cram multiple abstraction levels into one diagram.
8. DO NOT create diagrams without a title or legend.
9. DO NOT store only PNG — always keep the .drawio source file in version control.
10. Use blue for application containers, green for databases, orange for external systems, gray for infrastructure.
11. ABC: C4 is about audience — Level 1 for executives, Level 2 for architects, Level 3 for developers. Choose the right level.

[PROCESS]

### C4 Abstraction Levels

| Level | Diagram | Audience |
|-------|---------|----------|
| 1 | System Context | All stakeholders |
| 2 | Container | Developers, architects |
| 3 | Component | Developers |

### C4 Container Diagram Example

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <mxCell id="2" value="Web Application&#xa;[React, TypeScript]" style="rounded=1;whiteSpace=wrap;fillColor=#438DD5;fontColor=#ffffff;" vertex="1" parent="1">
      <mxGeometry x="100" y="100" width="160" height="80" as="geometry"/>
    </mxCell>
    <mxCell id="3" value="API Server&#xa;[Go, Gin]" style="rounded=1;whiteSpace=wrap;fillColor=#438DD5;fontColor=#ffffff;" vertex="1" parent="1">
      <mxGeometry x="400" y="100" width="160" height="80" as="geometry"/>
    </mxCell>
    <mxCell id="4" value="Database&#xa;[PostgreSQL]" style="shape=cylinder3;fillColor=#6DB33F;fontColor=#ffffff;" vertex="1" parent="1">
      <mxGeometry x="420" y="260" width="120" height="80" as="geometry"/>
    </mxCell>
    <mxCell id="5" value="REST/JSON" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="2" target="3" parent="1"/>
    <mxCell id="6" value="SQL/TCP" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="3" target="4" parent="1"/>
  </root>
</mxGraphModel>
```

### Cloud Architecture

- Use shape libraries: AWS (`shape=mxgraph.aws4.*`), Azure (`mxgraph.azure.*`), GCP
- Group resources by VPC/region using container shapes
- Label all connections with protocol and data format

### Export and Version Control

- Save as `.drawio` — XML text format, diffable in Git
- Export PNG/SVG/PDF for documentation and presentations

### Verification

- [ ] Diagram has a clear title and legend
- [ ] All connections labeled with protocol/data format
- [ ] Abstraction level is consistent
- [ ] `.drawio` source file committed to version control
- [ ] Colors and shapes are consistent with project conventions

[RESPONSE FORMAT]
Return results conforming to `output_schema`. Include `status`, `implementation` with Draw.io XML, `patterns_applied`, and `recommendations`.
