## Why

We want to evaluate alternative approaches to converting raster images (PNG/JPEG/SVG) into responsive HTML pages. Comparing the built‑in `excalidraw‑control` skill with another tool will help us choose the most efficient, size‑optimal, and easy‑to‑maintain solution for future pipelines.

## What Changes

- Add a benchmark script `compare_skills.sh` that runs both `excalidraw‑control` and the chosen alternative on a set of sample images.
- Collect timing, output size, and a basic visual‑diff metric.
- Generate a markdown report `benchmark_report.md` summarizing the results.
- Add CI job `skill-comparison.yml` to execute the benchmark on each PR.

## Capabilities

- `skill-comparison`: Executes and records performance of two image‑to‑HTML conversion tools.

## Impact

- Adds a new devDependency for the alternative tool.
- Introduces a separate CI workflow for experimentation.
- No impact on the production pipeline (04B).
