## Context
We currently generate individual MP4 videos for each slide using `hyperframes render`. To present a seamless, continuous slideshow experience, these individual segment videos must be stitched together sequentially into a single output video.

## Goals / Non-Goals
**Goals:**
- Concatenate `slide-*-animation.mp4` files in numerical order.
- Use `ffmpeg` to securely and quickly merge the video segments without re-encoding, preserving the original quality and frame rate.
- Generate a `presentation-master.mp4` output file.

**Non-Goals:**
- Adding transitional effects between slides (e.g., crossfades). This can be complex without re-encoding, so we'll stick to a direct cut.
- Editing the individual slide videos directly.

## Decisions
1. **Tooling**: We will use `ffmpeg` with the `concat` demuxer. 
   - *Rationale*: It is standard, incredibly fast because it simply copies streams without re-encoding, and operates reliably in headless CI environments.
2. **List File Generation**: The script `combine_videos.sh` will dynamically generate an `inputs.txt` file listing all discovered `.mp4` slide videos in sorted numerical order (e.g., slide-1, slide-2, slide-10).
   - *Rationale*: `ffmpeg concat` requires an input text file. Numerically sorting is required so `slide-10` comes after `slide-9`, not `slide-1`.

## Risks / Trade-offs
- **Risk**: Resolution, codec, or frame rate mismatches between individual slide videos can cause `ffmpeg concat` to fail.
  - **Mitigation**: All videos are rendered uniformly via the `hyperframes render` pipeline (1080x1920, 30fps), so they are guaranteed to match.
