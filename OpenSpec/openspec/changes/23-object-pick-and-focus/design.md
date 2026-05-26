## Overview

Implement a deterministic object-linking interaction in the Pipeline UI:

1. Objects editor enters "Pick" mode for a specific action row.
2. Left preview shows overlay boxes for known object IDs.
3. User clicks an overlay box to assign the row's `id`.
4. Focusing any row highlights its object overlay immediately.

## UX Behavior

### A) Pick on Canvas
- Each object row includes a `Pick` button.
- Clicking `Pick` sets active pick target row and visually arms the preview.
- Clicking an overlay box sets row `id` and exits pick mode.
- Esc key or second click on `Pick` cancels pick mode.

### B) Focus Highlight
- When a row gains focus/click, read row `id`.
- If matching overlay exists, emphasize it (stroke/glow/label).
- If no match exists, clear highlight and show subtle hint.

## Data Sources

- Object catalog from `/api/storyboard/{project}/{slide}/object-catalog`.
- Optional geometry source (first available):
  1. `slide-N-scene_layout.json` object boxes
  2. deterministic fallback mapping for known IDs (`main_image`, `title_center`, `pass_text`, `progress_fill`)

## API Surface

No required new backend API for MVP if geometry is computed client-side from known IDs.
Optional endpoint for robust geometry:
- `GET /api/storyboard/{project}/{slide}/object-boxes`

## Accessibility

- Keyboard support for row focus and pick cancel (`Esc`).
- Visible state badges: `Picking…`, `Bound`, `Missing`.

## Safety / Compatibility

- No pipeline script changes required.
- No storyboard schema change required (`id/action/at/duration/intent` remains unchanged).
- Works with existing slide HTML and object catalog endpoints.
