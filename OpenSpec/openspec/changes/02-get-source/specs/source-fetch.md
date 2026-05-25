# Source Fetch Spec

## ADDED Requirements

### Fetch video source
#### Scenario: User supplies a YouTube URL
- Given a valid YouTube URL, the system runs `yt-dlp` to download the MP4 file.
- The downloaded file is stored in `user/assets/`.
- If the download fails, an error message is logged and the process exits.
