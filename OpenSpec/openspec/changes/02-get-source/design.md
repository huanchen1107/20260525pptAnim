# Design – Get Source

## Numbering Rule

All OpenSpec change directories must follow the **two‑digit numeric prefix** naming convention (`<NN>-<short-name>`).

## Overview

The purpose of this change is to acquire and organize all required source assets for the PPT animation project.

### Steps
1. **Asset Identification** – List all required images, videos, templates, and data files.
2. **Acquisition** – Download or copy assets into the repository under `src/`.
3. **Verification** – Ensure each asset matches licensing and version requirements.
4. **Documentation** – Record asset locations in `assets.txt` and update `source-config.md`.

## Guidelines
- Follow the same numbering rule for any sub‑folders or generated artifacts.
- Keep assets immutable; updates should create a new version under a new directory.

## Example Structure
```
OpenSpec/changes/02-get-source/
├─ README.md
├─ design.md   ← (this file)
├─ proposal.md
├─ tasks.md
└─ specs/
    └─ source-fetch.md
```
