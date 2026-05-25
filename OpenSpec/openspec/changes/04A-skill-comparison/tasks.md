# Tasks for `04A-skill-comparison`

## Goal
Experimentally compare the built‑in `excalidraw‑control` skill with an alternative image‑to‑HTML conversion tool to determine the optimal approach for future pipelines.

## Tasks
- [ ] **Select alternative tool** – decide which image‑to‑HTML converter to benchmark (e.g., `html-converter-cli`).
- [ ] **Add devDependency** – run `npm i -D <alternative-tool>` and commit the change.
- [ ] **Create benchmark script** `compare_skills.sh` (already added) that:
  - Accepts a directory of sample images.
  - Runs `excalidraw‑control` and the alternative tool on each image.
  - Measures execution time and output size.
  - Generates `benchmark_report.md`.
- [ ] **Write CI workflow** `.github/workflows/skill-comparison.yml` to:
  - Install both tools.
  - Execute `compare_skills.sh`.
  - Publish `benchmark_report.md` as an artifact.
- [ ] **Add automated test** that runs `compare_skills.sh` on a small fixture and validates the report contains entries for both tools.
- [ ] **Run verification**:
  - Trigger the CI job (push a branch or use `gh workflow run`).
  - Review `benchmark_report.md` for timing and size results.
- [ ] **Document results** in `README.md` and update any relevant project documentation.
- [ ] **Commit all changes** with a clear commit message (e.g., `test: add skill‑comparison experiment`).

## Verification Plan
- **Automated**: `npm test` (or `pytest`) runs the benchmark script and checks that the markdown report includes rows for both tools.
- **Manual**: After CI finishes, open `benchmark_report.md` to confirm the collected metrics.

## Open Questions
- **Alternative tool**: `html-converter-cli` – a simple CLI that converts PNG/JPEG to HTML
- **Performance threshold**: < 100 ms per image
- **Run schedule**: Manual (triggered only when you run the benchmark)
