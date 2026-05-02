---
name: drawio-architecture
description: >
  Create system architecture, deployment, and component diagrams using Draw.io XML.
  Supports C4 model levels, UML component diagrams, AWS/Azure/GCP cloud shapes,
  and export to PNG/SVG/PDF. Use when designing architecture diagrams for
  documentation or design reviews.
version: "1.0.0"
category: "drawio"
origin: "full-stack-skills + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "drawio architecture"
  - "architecture diagram"
  - "c4 diagram"
  - "deployment diagram"
  - "cloud architecture"
  - "system design diagram"
  - "draw.io"
intent: >
  Generate Draw.io XML for system architecture diagrams. Supports C4 model
  (context, container, component), cloud provider shapes (AWS, Azure, GCP),
  UML component diagrams, and deployment diagrams for technical documentation.
scenarios:
  - "Creating C4 model context or container diagrams for system design"
  - "Visualizing microservices architecture with real service names"
  - "Designing cloud deployment diagrams with AWS/Azure/GCP shapes"
  - "Generating UML component or package diagrams"
  - "Documenting system architecture for design reviews"
best_for: "System architecture diagrams, C4 model, cloud deployment diagrams, UML component diagrams"
estimated_time: "5-30 min"
anti_patterns:
  - "Cramming multiple abstraction levels into one diagram — use C4 layers"
  - "Missing legend explaining colors and shapes"
  - "Diagrams without a title or last-updated date"
  - "Inconsistent styling across diagrams in the same project"
  - "Storing only PNG — always keep the .drawio source file in version control"
related_skills: ["diagram", "architecture-zoom-out"]
---

# Draw.io Architecture

## Overview

Create system architecture diagrams using Draw.io (diagrams.net) XML format. Supports C4 model for layered abstraction, cloud provider shape libraries (AWS, Azure, GCP), UML component diagrams, and deployment diagrams. Output as `.drawio` XML for version control, export to PNG/SVG/PDF for documentation.

## When to Use

- Designing system architecture for microservices, monoliths, or cloud systems
- Creating C4 model diagrams (Level 1-3: Context, Container, Component)
- Building deployment or infrastructure diagrams for cloud providers
- Generating UML component or package diagrams for design reviews
- Documenting architecture decisions alongside code in version control

## When NOT to Use

- Simple flowcharts or process diagrams (use drawio-flowchart skill)
- Quick inline diagrams in Markdown (use Mermaid via diagram skill)
- Wireframes or UI mockups (use figma-design skill)

## Process

### 1. Choose Abstraction Level (C4 Model)

| Level | Diagram | Audience |
|-------|---------|----------|
| 1 | System Context | All stakeholders |
| 2 | Container | Developers, architects |
| 3 | Component | Developers |
| 4 | Code | Developers (rarely needed) |

### 2. C4 Container Diagram Example

```xml
<mxGraphModel>
  <root>
    <mxCell id="0"/>
    <mxCell id="1" parent="0"/>
    <!-- Web App -->
    <mxCell id="2" value="Web Application&#xa;[React, TypeScript]" style="rounded=1;whiteSpace=wrap;fillColor=#438DD5;fontColor=#ffffff;" vertex="1" parent="1">
      <mxGeometry x="100" y="100" width="160" height="80" as="geometry"/>
    </mxCell>
    <!-- API Server -->
    <mxCell id="3" value="API Server&#xa;[Go, Gin]" style="rounded=1;whiteSpace=wrap;fillColor=#438DD5;fontColor=#ffffff;" vertex="1" parent="1">
      <mxGeometry x="400" y="100" width="160" height="80" as="geometry"/>
    </mxCell>
    <!-- Database -->
    <mxCell id="4" value="Database&#xa;[PostgreSQL]" style="shape=cylinder3;fillColor=#6DB33F;fontColor=#ffffff;" vertex="1" parent="1">
      <mxGeometry x="420" y="260" width="120" height="80" as="geometry"/>
    </mxCell>
    <!-- Connections -->
    <mxCell id="5" value="REST/JSON" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="2" target="3" parent="1"/>
    <mxCell id="6" value="SQL/TCP" style="edgeStyle=orthogonalEdgeStyle;" edge="1" source="3" target="4" parent="1"/>
  </root>
</mxGraphModel>
```

### 3. Cloud Architecture

- Use shape libraries: AWS (`shape=mxgraph.aws4.*`), Azure (`mxgraph.azure.*`), GCP
- Label all connections with protocol and data format
- Group resources by VPC/region using container shapes

### 4. Export and Version Control

- **Save as `.drawio`** — XML text format, diffable in Git
- **Export PNG/SVG/PDF** — for documentation, presentations, wiki embedding
- **Confluence/Google Drive** — use Draw.io plugins for inline editing

## Best Practices

1. **One diagram, one concern** — separate context, container, and component diagrams
2. **Consistent styling** — same colors, fonts, and arrow styles across all project diagrams
3. **Always include a legend** — explain color coding and shape meanings
4. **Layer with C4** — use multiple diagrams at different abstraction levels
5. **Date-stamp living documents** — add "Last updated: YYYY-MM-DD" label
6. **Label all connections** — show protocol, data format, and direction

## Coaching Notes

- **C4 is about audience**: Level 1 is for executives, Level 2 for architects, Level 3 for developers. Choose the right level for your audience
- **`.drawio` in Git**: The XML format is text-based and diffable. Always commit `.drawio` files alongside code
- **Color encodes role**: Use blue for application containers, green for databases, orange for external systems, gray for infrastructure

## Verification

- [ ] Diagram has a clear title and legend
- [ ] All connections labeled with protocol/data format
- [ ] Abstraction level is consistent (not mixing C4 levels)
- [ ] `.drawio` source file committed to version control
- [ ] Colors and shapes are consistent with project conventions

## Related Skills

- **diagram** — Excalidraw/Mermaid/SVG diagrams for other use cases
- **architecture-zoom-out** — Analyzing codebase to produce architecture understanding
