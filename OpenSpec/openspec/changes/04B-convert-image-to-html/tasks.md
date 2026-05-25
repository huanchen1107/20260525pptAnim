# Tasks for `04-convert-image-to-html-using-hyperframe-excalidraw-skills`

## Goal
Convert each page image to an HTML file using HyperFrame and the Excalidraw‑control skill.

## Tasks
- [x] **Create conversion script** `convert_image_to_html.sh` in `user/assets/` that:
  - Scans each `user/assets/slides/slide-*/` directory for an image file.
  - Uses the `excalidraw-control` skill to generate an Excalidraw scene for the image.
  - Calls `hyperframes render` to produce a responsive HTML file.
  - Writes the HTML output to `user/assets/slides/slide-<N>/slide-<N>.html`.
- [x] **Make script executable** (`chmod +x convert_image_to_html.sh`).
- [x] **Add README** in the change directory describing usage, prerequisites, and output location.
- [x] **Add `hyperframes` as a devDependency** via `npm i -D hyperframes`.
- [ ] **Write unit/integration tests** in `tests/` to verify:
  - Successful conversion of a sample PNG.
  - Generated HTML is syntactically valid and renders correctly.
- [ ] **Run verification**:
  - Execute `bash convert_image_to_html.sh`.
- [x] **Update CI pipeline** to run `convert_image_to_html.sh` as part of the asset‑preparation stage.
- [ ] **Commit changes** with a clear commit message.

## Verification Plan
- **Automated Tests**: Use the project’s test runner (`npm test` or `pytest`) to run the conversion on fixture images and compare the output against stored snapshots.
- **Manual Check**: Open generated HTML files in a browser and verify that the layout matches the source images.

## Open Questions
_None – all required information is captured in the `proposal.md` and `design.md` artifacts._
