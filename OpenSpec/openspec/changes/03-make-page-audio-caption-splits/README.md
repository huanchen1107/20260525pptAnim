# Make Page Audio Splits & Slide Packages

## Overview
This change introduces an automated workflow that converts a source video (`A2Z-original.mp4`) and its accompanying PDF (`A2ZpdfExcalidraw.pdf`) into per‑slide assets suitable for HyperFrame PPT animation.

- **PNG** of each PDF page (300 DPI) is generated first.
- **MP3** audio segment is then extracted from the video for that slide (using `ffmpeg` with `-y` to overwrite automatically).
- **Caption** is produced by Whisper from the extracted audio (or a placeholder if Whisper is not installed).
- A tiny helper script `process_page.sh` allows re‑processing an individual slide.

All assets are placed under `user/assets/slides/slide‑N/` where `N` is the slide number.

## Prerequisites
- `ffmpeg`
- `pdfinfo` and `pdftoppm` (poppler‑utils)
- `whisper` CLI (optional, for caption generation)

## Usage
```bash
cd user/assets
bash split_pages.sh            # process all slides
# or process a single slide
bash split_pages.sh 3          # only generate slide‑3 assets
```

## Output Layout
```
user/assets/slides/
├─ slide-1/
│  ├─ slide-1.png
│  ├─ audio-1.mp3
│  ├─ caption-1.txt
│  └─ process_page.sh
├─ slide-2/ …
```
Each folder contains everything needed to replay or edit that slide independently.

## Design Highlights
- The script first renders the PDF page to PNG, then extracts the audio segment. This order avoids the previous `-to value smaller than -ss` error.
- Timestamp detection uses ffmpeg scene‑change detection; the first slide always starts at **1 s**.
- If the last slide has no following timestamp, the video duration is used as `end_time`.
- Overwrite handling (`-y`) ensures the script can be re‑run without manual prompts.

## Verification
1. Run `bash split_pages.sh`.
2. Ensure a `slide‑N/` directory exists for each PDF page.
3. Spot‑check a few PNGs and MP3s (e.g., `ffprobe audio‑N.mp3`).
4. Verify captions are present.

## References
- Script: `user/assets/split_pages.sh`
- Source config: `user/assets/source-config.md`
