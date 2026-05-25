## Context

The project currently processes PowerPoint slides into audio and visual assets. To enhance the workflow, we need a new capability that converts raster images (PNG/JPEG/SVG) into responsive HTML pages using HyperFrame and the Excalidraw‑control skill. This will allow the generated HTML to be embedded directly into web‑based presentations.

## Goals / Non-Goals

**Goals:**
- Provide a deterministic, script‑driven conversion from images to HTML.
- Leverage existing `excalidraw‑control` skill to generate Excalidraw scene JSON.
- Use `hyperframes render` (npm package) to produce responsive HTML output.
- Keep the process fully automated and CI‑compatible.

**Non-Goals:**
- Manual hand‑tuning of the generated HTML layout.
- Support for vector‑only formats beyond the basic raster types.
- Runtime editing of the Excalidraw scene after generation.

## Decisions

- **Orchestration script:** A Bash script (`convert_image_to_html.sh`) will handle scanning the source directory, invoking the local `excalidraw‑control` skill via its CLI, and piping the result to `hyperframes render`.
- **Dependency management:** `excalidraw‑control` is provided as a local skill within the repository; `hyperframes-cli` will be installed as an npm devDependency (`npm i -D hyperframes-cli`).
- **Output location:** Generated HTML files will be placed in each slide folder as `user/assets/slides/slide-<N>/slide-<N>.html` (e.g., `slide-1/slide-1.html`).
- **CI integration:** The script will be added to the asset‑preparation stage of the CI pipeline, ensuring HTML is regenerated on each commit.
- **Error handling:** The script will abort on any failure of the skill or rendering step, returning a non‑zero exit code for CI visibility.

## Risks / Trade-offs

- **Skill stability:** The `excalidraw‑control` skill is experimental; changes to its CLI could break the script. Mitigation: pin the skill version in the repository and run integration tests.
- **HTML size:** HyperFrame may generate verbose markup for complex images, impacting page load. Mitigation: enable HyperFrame's minification options and validate output size in CI.
- **Platform compatibility:** The script relies on Bash and npm; Windows environments may require WSL or equivalent.
