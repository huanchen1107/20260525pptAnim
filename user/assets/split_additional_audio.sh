#!/usr/bin/env bash
# split_additional_audio.sh – Extract audio for slides defined in timeline.md
# Works for slides that may not have been created by split_pages.sh

set -euo pipefail

AUDIO_SRC="user/assets/A2Z-original-audio.mp3"
TIMELINE="user/assets/timeline.md"
OUTPUT_DIR="user/assets/slides"

# Read timeline lines (skip header)
while IFS= read -r line; do
  # Expect format: - Slide N: start=Xs, end=Ys
  if [[ $line =~ ^-\ Slide\ ([0-9]+):\ start=([0-9.]+)s,\ end=([0-9.]+)s ]]; then
    slide_num="${BASH_REMATCH[1]}"
    start="${BASH_REMATCH[2]}"
    end="${BASH_REMATCH[3]}"
    # Ensure slide folder exists
    slide_dir="$OUTPUT_DIR/slide-$slide_num"
    mkdir -p "$slide_dir"
    
    # Check if start is less than end
    if (( $(echo "$start < $end" | bc -l) )); then
      # Extract audio
      ffmpeg -nostdin -y -i "$AUDIO_SRC" -ss "$start" -to "$end" -c:a libmp3lame -q:a 2 "$slide_dir/audio-$slide_num.mp3" -loglevel error
      echo "✅ audio-$slide_num.mp3 created ( $start -> $end )"
    else
      echo "⚠️ Skipping audio-$slide_num.mp3 because start ($start) >= end ($end)"
    fi
  fi
done < <(grep -E "^- Slide" "$TIMELINE")
