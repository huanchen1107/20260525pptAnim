---
name: excalidraw-control
description: Programmatic diagramming, system mapping, and whiteboard layout control in Excalidraw
metadata:
  tags: excalidraw, diagram, flowchart, schema, whiteboard, mapping
---

## When to use

Use this skill whenever you are asked to generate, update, represent, or inspect system architecture diagrams, database flowcharts, sequence diagrams, or mental maps in Excalidraw format (`.excalidraw` JSON or canvas).

## Style & Layout Guidelines

To create premium, highly readable diagrams that look hand-crafted and professional, adhere to the following rules:

1. **Aesthetic Consistency:**
   * **Stroke Style:** Use `sloppy` for informal/brainstorming diagrams; use `architect` or `sharp` for professional system architectures.
   * **Fill Style:** Use `hachure` (diagonal lines) or `solid` for highlight elements; keep background elements `transparent`.
   * **Color Palette:** Stick to a curated three-color limit:
     * **Primary (Boxes):** `#1e1e1e` (Sleek Dark) or `#4a90e2` (Harmonious Blue).
     * **Secondary (Accents):** `#e67e22` (Orange) or `#2ecc71` (Green).
     * **Background:** `#ffffff` (Clean white) or `#121212` (Dark Mode canvas).
   * **Typography:** Use the default hand-drawn font family (`1`) for annotations, and the sans-serif font family (`2`) for structured code blocks or label schemas.

2. **Sizing & Spacing Standards:**
   * **Standard Node Box:** `200` width x `80` height.
   * **Standard Spacing (Horizontal):** `100px` minimum between sequential nodes.
   * **Standard Spacing (Vertical):** `80px` minimum between flowchart branches.
   * **Text Padding:** Leave at least `10px` internal padding inside container rectangles.

---

## Tool & MCP Integration

If the **Excalidraw MCP Server** or excalidraw tools are active, you can interact with the canvas programmatically using JSON blocks:

* **Creating new diagrams:** Generate a complete list of Excalidraw elements (`type`, `x`, `y`, `width`, `height`, `strokeColor`, etc.).
* **Updating connections:** Adjust starting/ending coordinates of connector arrows when moving nodes to ensure arrows remain bound.

---

## Technical Sub-Rules

For advanced diagram formats or database mapping structures, load the relevant sub-rule:

1. **Structured Flowcharts:** See [rules/diagramming.md](rules/diagramming.md) for drawing sequence diagrams, branching flows, and container groups.
2. **JSON Element Schema:** See [rules/json-schema.md](rules/json-schema.md) for strict syntax validation dictionaries matching Excalidraw's format.
