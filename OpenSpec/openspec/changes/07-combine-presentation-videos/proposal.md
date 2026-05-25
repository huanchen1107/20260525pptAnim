## Why
We currently generate a highly-polished `.mp4` video for each individual slide (e.g., `slide-1-animation.mp4`, `slide-2-animation.mp4`). However, we don't have a single compiled video of the entire presentation. To deliver a complete presentation experience, we need to stitch all these individual slide videos together sequentially into one master video file.

## What Changes
- Add a new bash script (e.g., `user/assets/combine_videos.sh`) that uses `ffmpeg` to concatenate all `slide-*-animation.mp4` files in numerical order.
- Create an integration test (`tests/combine_videos.test.sh`) to verify the master video is generated correctly.
- Add or update the GitHub Actions workflow to trigger the combination step after all slide animations have successfully rendered.

## Capabilities

### New Capabilities
- `combine-presentation-videos`: A capability that uses FFmpeg to concatenate multiple MP4 slide animations into a single master MP4 presentation file.

### Modified Capabilities
- None

## Impact
- Adds a new dependency on `ffmpeg` in the CI pipeline and local environment.
- Modifies the GitHub Actions pipeline to handle video concatenation and artifact upload for the master video.
