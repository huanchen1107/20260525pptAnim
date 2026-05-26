## Why

The current storyboard/object editor allows selecting object IDs from a dropdown, but two critical UX gaps remain:

- No direct "pick on canvas" interaction from the slide thumbnail.
- No focus/highlight linkage between an action row and its target object.

These gaps make object targeting slower and less reliable when users iterate quickly on animation actions.

## What Changes

- Add **Pick on Canvas** mode in the Objects editor.
- Add **row-focus object highlight** on the left thumbnail/result frame.
- Keep existing save/regenerate pipeline behavior unchanged.

## Capabilities

### New Capabilities
- `object-pick-on-canvas`: Bind an action row to an object by clicking the rendered slide overlay.
- `object-focus-highlight`: Highlight the bound object whenever an action row is focused.

### Modified Capabilities
- `fastapi-pipeline-ui`: enrich Objects UX without changing artifact contract.
