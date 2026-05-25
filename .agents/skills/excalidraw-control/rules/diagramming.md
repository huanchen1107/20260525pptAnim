# Structured Diagramming in Excalidraw

To ensure AI-generated whiteboards do not suffer from overlapping shapes, misaligned text, or disconnected arrows, follow these programmatic layout algorithms.

## Node Placement Grid

Always lay out elements along a virtual `50px` grid:

* Round all coordinates (`x`, `y`) and sizes (`width`, `height`) to the nearest multiple of `10`.
* **Horizontal flow:**
  ```javascript
  node1.x = 100;
  node2.x = node1.x + node1.width + horizontalGap; // e.g., 100 + 200 + 100 = 400
  ```
* **Vertical flow:**
  ```javascript
  node1.y = 100;
  node2.y = node1.y + node1.height + verticalGap; // e.g., 100 + 80 + 80 = 260
  ```

---

## Arrow Bindings

To keep arrows anchored to nodes when shapes move, bind their coordinate references directly in the JSON:

1. **Points coordinate offsets:** Arrow `points` must be relative to the arrow's own `x` and `y` root.
2. **Start and End Bindings:** Use `startBinding` and `endBinding` properties referencing the target node's `id`.
3. **Bound Arrow Offset:** Ensure the arrow's start/end coordinates hit exactly the border of the connected node:

```json
{
  "type": "arrow",
  "x": 300,
  "y": 140,
  "width": 100,
  "height": 0,
  "points": [[0, 0], [100, 0]],
  "startBinding": { "elementId": "node-1", "focus": 0, "gap": 5 },
  "endBinding": { "elementId": "node-2", "focus": 0, "gap": 5 }
}
```

---

## Container & Grouping Best Practices

When representing systems that contain subsystems (e.g., a "Vite App" containing "GSAP" and "Lottie" layers):

1. **Backdrop Box:** Create a large rectangle representing the container with `strokeColor: "#ccc"`, `strokeStyle: "dashed"`, and `fillStyle: "transparent"`.
2. **Layering order:** Put the backdrop box at the **beginning** of your JSON array so it renders behind all child nodes.
3. **`groupIds` Registration:** Register both the backdrop box and its internal children with matching `groupIds` strings:
   ```json
   "groupIds": ["group-frontend-container"]
   ```

---

## Sequence Diagrams Layout

To build sequential workflows (e.g., Client Request → API Gateway → DB Query):

* Represent actors as vertical tall rectangles at the top of the canvas.
* Drop vertical dashed "lifelines" from the center-bottom of each actor:
  * Lifeline `x` = actor.x + (actor.width / 2)
* Draw horizontal request arrows between lifelines at progressive `y` intervals:
  * Event 1: `y = 200`
  * Event 2: `y = 280`
  * Event 3: `y = 360`
