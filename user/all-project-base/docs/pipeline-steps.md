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

## 3) Split source to flat slide assets
Run:
- `bash user/all-project-base/scripts/split_pages.sh`

Expected outputs in `user/<project-name>/slides/`:
- `slide-N.png`
- `slide-N-audio.mp3`
- `slide-N-audio.txt`
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
