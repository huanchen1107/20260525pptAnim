# 07-combine-presentation-videos

This change adds the final step to the video generation pipeline: stitching all individual slide animations (`slide-*-animation.mp4`) together into a single presentation master video (`presentation-master.mp4`).

## Artifacts
- `user/assets/combine_videos.sh`: Uses `ffmpeg concat` to merge the slide videos numerically without re-encoding.
- `tests/combine_videos.test.sh`: Verifies the generation of the master video.
- Updated `.github/workflows/render_animation.yml`: Automatically runs the concatenation step in CI.

## Dependencies
This script relies on `ffmpeg` being installed on the host machine. In GitHub Actions ubuntu-latest runners, `ffmpeg` is pre-installed.
