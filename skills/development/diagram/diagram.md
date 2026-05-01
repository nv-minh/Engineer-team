---
name: diagram
description: "Create professional diagrams for architecture, design systems, workflows, and data models. Supports Excalidraw JSON (interactive/editable), Mermaid (GitHub-native rendering), and SVG (universal static). Diagrams that argue visually — shape mirrors meaning, not decoration."
version: "1.0.0"
category: "development"
origin: "excalidraw-diagram-skill (coleam00) + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "diagram"
  - "visualize"
  - "architecture diagram"
  - "flowchart"
  - "sequence diagram"
  - "design system diagram"
  - "component diagram"
  - "ER diagram"
  - "create diagram"
  - "draw diagram"
intent: "Generate professional diagrams that make visual arguments. Auto-select best output format (Excalidraw/Mermaid/SVG) based on use case. Include evidence artifacts in technical diagrams."
scenarios:
  - "Visualizing microservices architecture with real service names and data flows"
  - "Creating design system component hierarchy (atoms -> molecules -> organisms)"
  - "Documenting API request/response sequences with actual payloads"
  - "Mapping database schema relationships in ER diagram"
  - "Illustrating CI/CD pipeline with actual tool names"
  - "Comparing before/after architecture migration"
best_for: "Architecture diagrams, design system visualization, flowcharts, sequence diagrams, ER diagrams, deployment diagrams"
estimated_time: "5-30 min"
anti_patterns:
  - "Uniform card grids where every box looks the same — shape should encode meaning"
  - "Diagrams without evidence artifacts (code snippets, real endpoint names)"
  - "Overcrowded single-view diagrams — use multi-zoom instead"
  - "Excalidraw for simple flows that Mermaid handles better"
  - "Mermaid for complex layouts needing pixel-perfect positioning"
related_skills: ["architecture-zoom-out", "api-interface-design", "frontend-patterns", "backend-patterns"]
---

# Diagram

## Overview

Multi-format diagram skill. Creates diagrams that argue visually — shape mirrors concept, not decoration. Supports:

- **Excalidraw JSON** — interactive, editable in excalidraw.com, hand-drawn aesthetic, pixel-perfect control
- **Mermaid** — text-based, renders natively in GitHub/Markdown, great for simple flows
- **SVG** — static, universal, embeddable anywhere

The core principle: a good diagram passes the isomorphism test. If you remove the labels, the visual structure should still communicate the concept. Fan-outs look different from timelines. Hierarchies look different from pipelines. Shape encodes meaning.

## When to Use

- Visualizing system architecture, component relationships, data flows
- Documenting design system structure (atomic design hierarchy, token systems)
- Creating flowcharts for business logic or user journeys
- Sequence diagrams for API interactions
- ER diagrams for database schemas
- Deployment and infrastructure diagrams
- Before/after architecture comparisons
- CI/CD pipeline visualization

## When NOT to Use

- Simple bullet lists convey the same information — a diagram is not a decorated list
- The diagram would need a 30-minute explanation — split into multiple zoom levels
- Text-based architecture map suffices — use the architecture-zoom-out skill instead
- The audience only needs a quick text summary — diagrams add latency to comprehension when misapplied

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Uniform card grid | Every box looks the same, no visual argument | Use shape, size, and color to encode role |
| No evidence artifacts | "Service A -> Service B" is meaningless | Use real names, endpoints, code snippets |
| Everything in one diagram | Overcrowded, unreadable | Multi-zoom: summary, sections, detail |
| Excalidraw for simple flows | Overkill for 5-node linear flow | Use Mermaid instead |
| Mermaid for complex layouts | Breaks on precise positioning needs | Use Excalidraw instead |

## Process

### Step 1: Classify

Determine what kind of diagram is needed and who will consume it.

Ask three questions:
1. **What type?** Architecture, flowchart, sequence, ER, deployment, design system, comparison
2. **Who is the audience?** Engineers, stakeholders, designers, all of the above
3. **What output format?**

Format selection guide:

| Criteria | Format |
|---|---|
| Interactive/editable needed | Excalidraw |
| Must render in GitHub Markdown | Mermaid |
| Static embed in docs/wiki | SVG |
| Complex layout with many components | Excalidraw (pixel control) |
| Simple linear or branching flow | Mermaid (text-based, fast) |
| Design system with pixel alignment | Excalidraw |
| Quick architecture overview in PR comment | Mermaid |

### Step 2: Map Concepts

Identify the structural elements before touching any tool.

1. **List all entities** — services, components, tables, actors, states
2. **Map relationships** — one-to-many, many-to-many, one-to-one, depends-on, produces, consumes
3. **Identify groups/clusters** — bounded contexts, layers, namespaces, deployment units
4. **Determine flow direction** — top-to-bottom (processes), left-to-right (timelines), radial (hubs)

Output: a text-based concept map listing entities and their connections. This becomes the skeleton for layout.

### Step 3: Choose Visual Pattern

Match the concept structure to a visual pattern. The pattern determines how elements are arranged.

| Concept Structure | Visual Pattern | Example |
|---|---|---|
| One source, many targets | Fan-out | API gateway routing to microservices |
| Many sources, one target | Convergence | Multiple data sources into analytics pipeline |
| Hierarchical relationships | Tree | Org chart, file system, class inheritance |
| Time-ordered events | Timeline | Deployment history, event sourcing |
| Continuous cyclic process | Spiral/Cycle | CI/CD pipeline, event loop |
| Layered architecture | Layers (stacked) | Frontend / Backend / Database |
| Before/after comparison | Side-by-Side | Architecture migration |
| Transformation pipeline | Assembly Line | ETL pipeline, build system |
| Component matrix | Grid | Design system component catalog |
| Atomic design hierarchy | Hexagon/Nested | Atoms -> Molecules -> Organisms |

### Step 4: Layout

Position elements with discipline.

**Spacing rules:**
- 80-120px between elements (Excalidraw)
- Consistent margins within containers
- Align on a grid — eyeball alignment reads as sloppy

**Visual hierarchy:**
- Title (largest, top or center)
- Section subtitles (medium, per cluster)
- Element labels (standard)
- Annotations and evidence artifacts (small, monospace)

**Container discipline:**
- Default to free-floating text for labels
- Group elements in containers only when grouping IS the meaning (bounded contexts, deployment units)
- Every container must earn its border

**Color coding:**
- Pull semantic colors from `references/color-palette.md`
- Never use color as the only differentiator — pair with shape or label
- Keep to 4-5 distinct colors maximum per diagram

### Step 5: Generate

Output in the selected format. Use reference files for syntax and templates.

| Format | Reference File |
|---|---|
| Excalidraw JSON | `references/excalidraw-templates.md`, `references/excalidraw-json-schema.md` |
| Mermaid | `references/mermaid-patterns.md` |
| Design system diagrams | `references/design-system-templates.md` |
| Colors | `references/color-palette.md` |

**Excalidraw generation:**
1. Build the JSON array of elements in order: containers first, then shapes, then text, then arrows
2. Assign IDs with a naming convention (e.g., `svc-users`, `arrow-1`)
3. Calculate positions using the grid from Step 4
4. Add text elements with `containerId` binding to their parent shapes
5. Add arrows with `startBinding` and `endBinding`

**Mermaid generation:**
1. Start with the diagram type declaration (`flowchart`, `sequenceDiagram`, `erDiagram`, etc.)
2. Define nodes and connections
3. Add subgraphs for groups
4. Include notes and styling

**SVG generation:**
1. Define the SVG canvas with viewBox
2. Create `<g>` groups for clusters
3. Draw shapes with semantic colors
4. Add text labels
5. Draw connection paths

### Step 6: Validate

Verify the diagram communicates effectively.

**For all formats:**
- Isomorphism test: cover the labels. Can someone reconstruct the concept from shape and layout alone?
- Evidence check: are real names, endpoints, or code snippets included?
- Density check: is the diagram readable at a glance, or does it require study?
- Color check: do colors follow the palette? Are there more than 5 distinct colors?

**For Excalidraw:**
- Render the JSON in excalidraw.com or a local viewer
- Check for overlapping text
- Check for misaligned arrows (arrows should connect to shape edges, not float)
- Check for unbalanced spacing
- Fix issues in a loop until clean

**For Mermaid:**
- Verify syntax renders without errors in a Mermaid live editor
- Check that subgraph labels are not clipped
- Verify arrow directions match the intended flow
- Test that the diagram renders at different viewport widths

## Coaching Notes

1. **Shape = Meaning.** If you remove the labels, the diagram should still convey the concept. Fan-outs look different from timelines. Trees look different from pipelines. This is the isomorphism test. A diagram that fails this test is just a labeled grid — use a table instead.

2. **Evidence artifacts.** Technical diagrams include real code snippets, actual API endpoints, real service names. Not "Service A -> Service B" but "user-service -> payment-gateway (POST /api/v2/charges)". Evidence makes diagrams specific enough to debug from.

3. **Format selection matters.** Mermaid is fast and GitHub-native but breaks on complex layouts — the auto-layout engine fights you on anything non-trivial. Excalidraw gives pixel control but requires generating JSON. SVG is universal but verbose. Pick the right tool for the job, not the one you know best.

4. **Multi-zoom architecture.** For comprehensive systems, do not cram everything into one diagram. Create three views: summary flow (10,000ft), section boundaries (showing bounded contexts), and detail views (per-section internals). This matches how engineers actually read diagrams — scan, orient, drill.

5. **Container discipline.** Drawing a box around everything is tempting but noisy. Only group elements when the grouping carries meaning. "These services are in the same deployment unit" is a reason to group. "These services are adjacent" is not.

## Verification

- [ ] Correct format selected for use case (Excalidraw/Mermaid/SVG)
- [ ] Visual pattern matches concept structure (fan-out, tree, layers, etc.)
- [ ] Evidence artifacts included (real names, code snippets, endpoints)
- [ ] Isomorphism test: diagram communicates without labels
- [ ] No overlapping text or misaligned arrows
- [ ] Color coding follows references/color-palette.md
- [ ] Excalidraw JSON renders correctly (if applicable)
- [ ] Mermaid syntax is valid and renders (if applicable)
- [ ] Maximum 4-5 distinct colors used
- [ ] Containers only used where grouping carries meaning

## Related Skills

- **architecture-zoom-out** — Text-based architecture maps when diagrams are overkill
- **api-interface-design** — API contracts that pair well with sequence diagrams
- **frontend-patterns** — Component architecture that benefits from visual documentation
- **backend-patterns** — Service architecture and data flow diagrams
