# Tasks for `06-create-page-animation`

## Goal
Use hyperframes to render `slide-N-animation.mp4` for each slide based on the storyboard and audio and slide HTML content.

## Tasks
- [x] **Extract render script**: Make sure `user/assets/render_animation.sh` handles rendering the storyboard to MP4, integrating audio (`--audio`) if present.
  - *Note:* Currently blocked because `npx hyperframes render` requires an `index.html` file in the directory even when `-c` is passed. We need to either create a dummy `index.html` or rename the storyboard during rendering.
- [x] **Clean up 05**: Remove the rendering steps from the `storyboard.yml` workflow, keeping `05` strictly about generating the storyboard HTML.
- [x] **Add render workflow**: Create `.github/workflows/render_animation.yml` to trigger the rendering of MP4 files.
- [x] **Create integration test**: Write `tests/render_animation.test.sh` to verify `slide-N-animation.mp4` files are generated successfully.
- [x] **Write README**: Add documentation in `OpenSpec/changes/06-create-page-animation/README.md`.
- [x] **Run verification**: Execute the rendering script and ensure the `.mp4` files are correctly generated in each slide directory.
- [x] **Commit changes**.
