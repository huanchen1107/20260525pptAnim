## ADDED Requirements

### Requirement: Master Video Concatenation
The system SHALL provide a script to combine all numerically sorted slide animation videos into a single master video file using `ffmpeg`.

#### Scenario: Successful compilation of all slides
- **WHEN** the user executes `bash user/assets/combine_videos.sh` after rendering the slide animations
- **THEN** the script identifies all `slide-*-animation.mp4` files, sorts them numerically, and outputs a `user/assets/presentation-master.mp4` file containing all videos in sequence without loss of quality.

#### Scenario: Missing slide videos
- **WHEN** the combination script is run but no `.mp4` slide animations are found
- **THEN** the script logs an error indicating that no videos were found and exits with a non-zero code.
