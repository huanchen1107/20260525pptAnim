# image-to-html-conversion Specification

## Purpose
TBD - created by archiving change 04-convert-image-to-html-using-hyperframe-excalidraw-skills. Update Purpose after archive.
## Requirements
### Requirement: Image-to-HTML conversion capability
The system SHALL provide a deterministic, script‑driven conversion from raster images (PNG, JPEG, SVG) to responsive HTML pages using the `excalidraw‑control` skill to generate an Excalidraw scene and `hyperframes render` to produce the final HTML output.

#### Scenario: Successful conversion of a PNG image
- **WHEN** the user executes `bash convert_image_to_html.sh` in the project root with `user/assets/images/logo.png` present,
- **THEN** an HTML file `user/assets/generated-html/logo.html` is created containing a responsive HTML representation of `logo.png` generated via Excalidraw and HyperFrame.

#### Scenario: Handling unsupported file types
- **WHEN** `convert_image_to_html.sh` encounters a file with an unsupported extension (e.g., `.txt`),
- **THEN** the script logs a warning and skips the file without terminating the process.

#### Scenario: CI integration
- **WHEN** the CI pipeline runs the asset‑preparation stage,
- **THEN** `convert_images.sh` is executed automatically, and all generated HTML files are committed to the repository if changes are detected.

