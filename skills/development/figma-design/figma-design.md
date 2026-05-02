---
name: figma-design
description: >
  Convert Figma designs to production-ready code. Uses Figma MCP server to access
  design specs directly — exact colors, spacing, typography, component hierarchy.
  Generates React, Vue, or framework-specific code from Figma file URLs.
version: "1.0.0"
category: "development"
origin: "figma-design-to-code + EM-Team"
tools: [Read, Write, Bash, Grep, Glob]
triggers:
  - "figma"
  - "design to code"
  - "implement this design"
  - "figma to react"
  - "figma to vue"
  - "convert figma"
  - "design token"
  - "figma.com"
intent: >
  Generate production-ready code from Figma designs using the Figma MCP server.
  Access exact design specifications (colors, spacing, typography, layout) directly
  from Figma files instead of manual inspection and guessing.
scenarios:
  - "Implementing a full page UI from a Figma file URL"
  - "Converting a Figma Button component to React with variants"
  - "Extracting design tokens (colors, typography) from Figma styles"
  - "Generating a responsive layout from a Figma frame with auto-layout"
  - "Implementing a specific component from a Figma design system"
best_for: "Figma-to-code conversion, design token extraction, pixel-perfect UI implementation"
estimated_time: "10-30 min"
anti_patterns:
  - "Guessing spacing/colors instead of fetching exact values from Figma"
  - "Implementing the entire file at once instead of component-by-component"
  - "Ignoring Figma auto-layout constraints when generating responsive code"
  - "Hardcoding values that should be design tokens"
related_skills: ["frontend-patterns", "diagram", "api-interface-design", "browser-testing"]
---

# Figma Design-to-Code

## Overview

Convert Figma designs into production-ready code using the Figma MCP server. Access exact design specifications — colors, spacing, typography, component hierarchy — directly from Figma files instead of manual inspection.

## When to Use

- Implementing UI from Figma designs
- Converting Figma components to React/Vue/etc.
- Extracting design tokens (colors, spacing, typography)
- Understanding component hierarchy from design files
- Ensuring pixel-perfect implementation

## When NOT to Use

- You don't have a Figma file URL (use the brainstorming skill instead)
- You need to create a new design (use a design tool)
- The design doesn't exist yet (spec it first with spec-driven-development)

## Required Setup

### Figma API Token

1. Go to Figma account settings → "Personal access tokens"
2. Generate new token with read access
3. Set environment variable:

```bash
export FIGMA_API_KEY="figd_xxxxxxxxxxxxxxxx"
```

### Figma URL Structure

```
https://www.figma.com/file/{file_key}/{file_name}?node-id={node_id}
                          ^^^^^^^^^^              ^^^^^^^^^^
                          Required                Optional (specific frame)
```

## Available MCP Tools

### get_file
Retrieves complete Figma file data including all pages, frames, and components.

### get_file_nodes
Gets specific nodes from a Figma file by their IDs — use when you only need a specific component.

### get_images
Exports images from Figma nodes in various formats (PNG, JPG, SVG, PDF).

### get_components
Lists all components in a file or team library — use for design system extraction.

### get_styles
Retrieves style definitions (colors, text, effects) — use for design token extraction.

## Process

### Step 1: Fetch Design Data

```
1. Extract file_key from the Figma URL
2. Call get_file or get_file_nodes to fetch design structure
3. Identify target components/frames to implement
```

### Step 2: Extract Design Specs

```
1. Colors → extract fill/stroke values, convert to CSS
2. Spacing → extract padding/margin/gap from auto-layout
3. Typography → extract font family, size, weight, line-height
4. Component hierarchy → map Figma layers to component structure
```

### Step 3: Generate Code

```
1. Create component structure matching Figma hierarchy
2. Apply exact CSS values from design specs
3. Handle responsive breakpoints if defined in design
4. Generate TypeScript types for component props if applicable
```

### Step 4: Verify

```
1. Compare generated code against design specs
2. Check colors match exactly (hex values)
3. Verify spacing values match auto-layout
4. Confirm component hierarchy is correct
```

## Example Usage

### Full Page Implementation

```
User: Implement this Figma design in React + Tailwind
https://www.figma.com/file/ABC123/MyDesign?node-id=1-100

AI: [Fetches design data]
    [Extracts colors, spacing, typography]
    [Generates React components with Tailwind classes]
    [Outputs component files with exact design values]
```

### Component Extraction

```
User: Create the Button component from this Figma file in React

AI: [Calls get_components]
    [Finds Button component and variants]
    [Generates typed React component with variant props]
```

### Design Token Export

```
User: Extract design tokens from this Figma file

AI: [Calls get_styles]
    [Extracts color palette]
    [Extracts typography scale]
    [Generates CSS variables or Tailwind config]
```

## Best Practices

1. **Provide Figma URL directly** — always include the full URL
2. **Specify target framework** — "React + Tailwind", "Vue 3 Composition API"
3. **Request specific components first** — "Header and Footer only", "Mobile version only"
4. **Implement component-by-component** — don't try to convert the entire file at once
5. **Extract design tokens early** — colors and typography first, then components

## Coaching Notes

- Figma auto-layout maps directly to Flexbox/Grid — pay attention to `layoutMode`, `itemSpacing`, `paddingLeft/Right`
- Component variants in Figma map to prop-based variants in code
- Design tokens should be extracted as CSS custom properties or theme config, not hardcoded
- Always verify colors in both light and dark mode if the design specifies them

## Verification

- [ ] Colors match Figma exactly (check hex values)
- [ ] Spacing matches auto-layout values
- [ ] Typography matches Figma text styles
- [ ] Component hierarchy mirrors Figma layers
- [ ] Responsive behavior matches Figma frames
- [ ] Design tokens extracted, not hardcoded

## Related Skills

- **frontend-patterns** - React/Vue component patterns for generated code
- **diagram** - Visualize component architecture before implementing
- **api-interface-design** - If the design includes API-driven data
- **browser-testing** - Visual regression testing after implementation
