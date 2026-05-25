# Image to HTML conversion (04B)

## Overview
This change adds a utility to convert each slide image into a responsive HTML file using the **Excalidraw‑control** skill and **HyperFrames**.

## Prerequisites
- Node.js (>=22) and npm installed.
- `hyperframes` CLI (`npm i -D hyperframes`).
- `excalidraw-control` skill available in the environment.

## Usage
```bash
# From the project root
chmod +x user/assets/convert_image_to_html.sh   # ensure executable
./user/assets/convert_image_to_html.sh          # uses default user/assets/slides directory
# Or specify a custom slides directory
./user/assets/convert_image_to_html.sh path/to/custom/slides
```
The script will generate an HTML file for each slide image inside its folder (`slide-<N>.html`).

## Output location
Generated HTML files are written to the same slide directory, e.g.:
```
user/assets/slides/slide-1/slide-1.html
```

## Notes
- The script creates a temporary Excalidraw scene JSON file which is removed after rendering.
- Errors abort the script (`set -euo pipefail`).

## Further steps
- Add unit/integration tests in `tests/`.
- Include this step in the CI pipeline.
