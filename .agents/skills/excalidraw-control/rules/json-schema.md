# Excalidraw JSON Schema Reference

Every programmatically generated whiteboard diagram must comply with Excalidraw's official JSON dictionary layout.

## Base Document Schema

An Excalidraw file is a JSON object containing global settings and an array of individual element shapes:

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [
    // Array of element objects
  ],
  "appState": {
    "gridSize": 20,
    "viewBackgroundColor": "#ffffff",
    "theme": "light"
  },
  "files": {}
}
```

---

## Elements Schema Reference

Every object inside the `elements` array must have these base fields:

```json
{
  "id": "unique-random-string",
  "type": "rectangle | ellipse | arrow | text | line",
  "x": 100,
  "y": 100,
  "width": 200,
  "height": 80,
  "angle": 0,
  "strokeColor": "#1e1e1e",
  "backgroundColor": "transparent",
  "fillStyle": "hachure | solid | transparent",
  "strokeWidth": 1,
  "strokeStyle": "solid | dashed | dotted",
  "roughness": 1,
  "opacity": 100,
  "groupIds": [],
  "roundness": null,
  "seed": 123456,
  "version": 1,
  "versionNonce": 654321,
  "isDeleted": false,
  "boundElements": [],
  "updated": 1716380000000
}
```

---

## Specialized Shapes Syntax

### 1. Text Element (`type: "text"`)
Requires additional properties to map fonts and handle wrapping:

```json
{
  "type": "text",
  "text": "My Label",
  "fontSize": 16,
  "fontFamily": 1, // 1 = Hand-drawn, 2 = Sans-serif, 3 = Monospace
  "textAlign": "center | left | right",
  "verticalAlign": "middle | top | bottom",
  "baseline": 15
}
```

### 2. Arrow Element (`type: "arrow"`)
Arrow paths are governed by standard relative coordinate arrays:

```json
{
  "type": "arrow",
  "x": 300,
  "y": 140,
  "width": 100,
  "height": 50,
  "points": [
    [0, 0],    // Start offset relative to x, y
    [50, 50],   // Waypoint offset
    [100, 50]   // End offset
  ],
  "startArrowhead": null,
  "endArrowhead": "arrow"
}
```

---

## Code Generation Safety Rules

1. **Deterministic Seeds:** Always supply an integer value for `"seed"` (e.g., `1000` to `999999`) to prevent the renderer from resetting shape variations during edits.
2. **Epoch Timestamps:** Supply a valid Unix epoch timestamp in milliseconds for the `"updated"` property.
3. **No circular dependencies:** Ensure `boundElements` references are reciprocal (e.g. if the node points to the arrow, the arrow's startBinding must point to the node).
