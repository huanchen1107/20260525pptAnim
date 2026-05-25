# Unfinished Work Memo (Next Session)

## Current Status
- Default pipeline is **TSX-first** and runs end-to-end in `ffmpeg` mode.
- Canonical naming rules are enforced and validated.
- Content-driven storyboard mapper is implemented in `generate_storyboard.sh`.
- Whisper transcription is integrated into pipeline via `split_pages.sh`.

## Outstanding Items
1. **Dynamic object motion not yet visible in output**
   - Cause: current successful path is `--renderer ffmpeg` (static image+audio render).
   - Needed: implement storyboard-to-animation adapter in HyperFrames path.

2. **HyperFrames EPERM environment issue**
   - Error: `listen EPERM ... 0.0.0.0` in restricted runtime.
   - Action: run HyperFrames rendering in local unrestricted terminal.

3. **Optional local setup helper**
   - Script: `user/all-project-base/scripts/setup_hyperframes_and_run.sh`
   - Purpose: install/pin `hyperframes@0.6.40`, version check, and run pipeline.

## Recommended First Commands Next Time
1. `./startup.sh`
2. `git status`
3. `bash user/all-project-base/scripts/run_pipeline.sh --project user/project-1 --slide 1 --mode auto --renderer hyperframes`
4. If HyperFrames still fails, run:
   - `bash user/all-project-base/scripts/run_pipeline.sh --project user/project-1 --slide 1 --mode auto --renderer ffmpeg`

## Implementation Priority Next Session
1. Build storyboard-consumption runtime adapter (YML -> DOM actions).
2. Wire adapter into HyperFrames render path (`slide-N.html` runtime).
3. Verify zoom/pan/emphasize/show-up effects on slide-1.
4. Roll out to slide-2..N after slide-1 passes.
