# Project Initial

## Objective
Rebuild this repository as a Codex-driven PPT/image to Excalidraw-style HTML -> GSAP -> HyperFrames pipeline.

## Current State
- Remotion-specific assets are no longer the center of the repo
- The new pipeline is documented in `pipeline.md`
- Local agent skills now define the slide-processing workflow
- Startup flow supports Codex by default

## Next Tasks
1. Keep the `pipeline.md` artifact contract as the source of truth.
2. Maintain the local skill pack under `.agents/skills/`.
3. Keep slide generation, rendering, and QA aligned with the new pipeline stages.
