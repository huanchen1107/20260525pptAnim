# Proposal for Change 02-get-source

**Goal:** Retrieve all required source assets (YouTube videos, SRT subtitle files, PDF documents, images, templates, etc.) and place them in a structured `src/` directory.

**Background:** The PPT animation pipeline depends on external media – the source video, its subtitles, and any reference PDFs. Centralising these assets simplifies reproducibility and complies with licensing.

**Scope:**
- Download a YouTube video (or any provided video URL) using `yt-dlp`.
- Obtain the matching subtitle file (`.srt`).
- Pull any supporting PDFs or additional assets referenced in `source-config.md`.
- Verify checksums and licensing information.
- Store everything under `src/` with clear naming conventions.

**Success Criteria:**
- `src/video.mp4`, `src/subtitles.srt`, and any referenced PDFs exist.
- A manifest file `src/assets.txt` lists each asset with its source URL and checksum.
- CI validation confirms asset presence and integrity.
