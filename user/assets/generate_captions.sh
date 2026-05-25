#!/usr/bin/env bash

# generate_captions.sh
# Iterate over each slide-N folder under user/assets/slides and generate a caption file
# using OpenAI Whisper (tiny model) from the corresponding audio-N.mp3.

set -euo pipefail

BASE_SLIDE_DIR="$(pwd)/user/assets/slides"

if ! command -v whisper > /dev/null; then
  echo "Error: whisper CLI not found. Install it first (pip install -U openai-whisper)."
  exit 1
fi

shopt -s nullglob
for slide_dir in "$BASE_SLIDE_DIR"/slide-*; do
  if [[ -d "$slide_dir" ]]; then
    # Find the audio file inside the slide folder (pattern audio-*.mp3)
    audio_file=$(find "$slide_dir" -maxdepth 1 -type f -name 'audio-*.mp3' | head -n 1)
    if [[ -n "$audio_file" ]]; then
      echo "Generating caption for $audio_file ..."
      whisper "$audio_file" --model tiny --output_dir "$slide_dir" --output_format txt > /dev/null 2>&1
      # Whisper creates <audio_file>.txt ; rename to caption-<slide>.txt
      base_name=$(basename "$audio_file" .mp3)
      slide_num="${slide_dir##*/slide-}"
      mv "$slide_dir/${base_name}.txt" "$slide_dir/caption-${slide_num}.txt" || true
    else
      echo "Warning: audio file not found in $slide_dir, skipping."
    fi
  fi
done

echo "Caption generation completed."
