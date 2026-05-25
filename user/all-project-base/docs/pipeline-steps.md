# Pipeline Steps (All Projects)

## 1) Prepare project folders
Create (or confirm) these folders:
- `user/<project-name>/source/`
- `user/<project-name>/slides/`
- `user/<project-name>/outputs/`
- `user/<project-name>/docs/`

## 2) Put source files into `source/`
Place project inputs in:
- `user/<project-name>/source/`

## 3) Split source to flat slide assets (required)
Run:
- `bash user/all-project-base/scripts/split_pages.sh`

Expected outputs in `user/<project-name>/slides/`:
- `slide-N.png`
- `slide-N-audio.mp3`
- `slide-N-audio.txt` (Whisper transcription; required downstream)
- `timestamps.json`
- `slide-metadata.yaml`

## 4) Generate storyboard files
Run:
- `bash user/all-project-base/scripts/generate_storyboard.sh`

Expected outputs:
- `slide-N-storyboard.yml`

## 5) Generate HTML/layout
Run:
- `bash user/all-project-base/scripts/convert_image_to_html.sh`

Expected outputs:
- `slide-N.html`

## 6) Render videos
Preview:
- `bash user/all-project-base/scripts/render_animation.sh --mode preview`

Final:
- `bash user/all-project-base/scripts/render_animation.sh --mode final`

Expected outputs:
- `slide-N.preview.mp4` (preview)
- `slide-N.mp4` (final)

## 7) Combine final slide videos
Run:
- `bash user/all-project-base/scripts/combine_videos.sh`

Expected output:
- `user/<project-name>/outputs/presentation-master.mp4`

## 8) Enforce structure rules
- Do not create `slides/slide-N/` folders.
- Keep all slide artifacts as flat files in `slides/`.
- Keep shared scripts in `user/all-project-base/scripts/`.
- Keep shared Python utilities in `user/all-project-base/utils/`.

## Corrections History
- See  for structural fixes and rationale.


## 9) Validate canonical artifacts
Run:
- `bash user/all-project-base/scripts/validate_slide_artifacts.sh --project user/<project-name>`

This verifies per-slide canonical files exist: `png`, `audio.mp3`, `audio.txt`, `html`, `storyboard.yml`.


## 10) Storyboard-to-Animation Application (Required for Dynamic Motion)
- `generate_storyboard.sh` defines object-level intent (`zoom_in`, `zoom_out`, `pan`, `fade_in`, `emphasize`, etc.).
- A renderer adapter step must apply storyboard actions to HTML object IDs at runtime (HyperFrames path).
- Without this adapter, outputs are static even if storyboard files exist (for example `--renderer ffmpeg`).
- Dynamic object control is validated only when storyboard actions are consumed during render.


## HyperFrames Setup Helper (When Needed)
If local HyperFrames version/setup is uncertain, use:
- `bash user/all-project-base/scripts/setup_hyperframes_and_run.sh --project user/project-1 --slide 1 --mode auto --renderer hyperframes`

This helper performs:
1. Install/pin `hyperframes@0.6.40`
2. Verify local HyperFrames version
3. Run pipeline with provided arguments
