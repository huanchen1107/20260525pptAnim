## Why
We need to experimentally compare the built‑in `excalidraw‑control` skill with an alternative image‑to‑HTML conversion tool to determine which provides better performance, smaller output size, and easier integration.

## What Changes
- **Benchmark script** `compare_skills.sh`:
  - Takes a directory of sample images.
  - Runs `excalidraw‑control` and the alternative tool on each image.
  - Measures execution time and output file size.
  - Generates a visual diff (optional) using `diff-pdf` or similar.
  - Writes a markdown report `benchmark_report.md`.
- **CI workflow** `.github/workflows/skill-comparison.yml`:
  - Installs both tools.
  - Executes `compare_skills.sh`.
  - Publishes the `benchmark_report.md` as an artifact.
- **Dependencies**:
  - Add the alternative tool as a devDependency in `package.json` (e.g., `some-html-converter`).

## Capabilities
- `skill-comparison`: Runs a performance/size benchmark between two image‑to‑HTML conversion approaches.

## Impact
- Introduces a new experimental CI job; production pipeline (04B) remains unchanged.
- Adds a new devDependency.
- Provides data‑driven decision making for future pipelines.
