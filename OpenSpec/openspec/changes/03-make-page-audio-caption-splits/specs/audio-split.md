# Audio‑Slide Split Spec

## ADDED Requirements

### Requirement: Split video into per‑page assets
#### Scenario: Process the source video and SRT to generate slide folders
- Input: `user/assets/source-video.mp4` and `user/assets/A2Zsrt.srt`.
- Detect slide boundaries using `ffmpeg` scene‑change detection.
- For each slide `N` create a folder `slide-N/` containing:
  * `slide-N.png` – the first frame of the slide (at 00:01 for the first slide).
  * `audio-N.mp3` – the audio segment for that slide, trimmed losslessly.
  * `process_page.sh` – a helper script that runs the above steps for the page.
- Skip any silent subtitle sections.
- All generated files are named with the `NN-` prefix matching the slide number.

#### Expected outcome
- After running `split_pages.sh` the `slide‑N/` directories are created and can be used downstream for HyperFrame generation.
