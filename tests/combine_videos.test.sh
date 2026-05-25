#!/usr/bin/env bash
set -euo pipefail

MASTER_VIDEO="user/assets/presentation-master.mp4"

# Run the combine script
./user/assets/combine_videos.sh

if [[ ! -f "$MASTER_VIDEO" ]]; then
  echo "Test Failed: Master video $MASTER_VIDEO was not created."
  exit 1
fi

# Check if file is not empty
if [[ ! -s "$MASTER_VIDEO" ]]; then
  echo "Test Failed: Master video $MASTER_VIDEO is empty."
  exit 1
fi

# Also check using ffprobe if available
if command -v ffprobe &> /dev/null; then
  duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$MASTER_VIDEO")
  echo "Master video created successfully with duration: $duration seconds."
  if ! ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$MASTER_VIDEO" | grep -q audio; then
    echo "Test Failed: Master video does not contain an audio stream."
    exit 1
  fi
else
  echo "Master video created successfully."
fi
