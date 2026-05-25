#!/usr/bin/env bash
set -euo pipefail

SLIDES_ROOT="user/assets/slides"
OUTPUT_VIDEO="user/assets/presentation-master.mp4"
WORK_DIR="/private/tmp/pipeline-combine"
INPUTS_FILE="${WORK_DIR}/inputs.txt"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
touch "$INPUTS_FILE"

for slide_dir in "$SLIDES_ROOT"/slide-*/; do
  slide_dir="${slide_dir%/}"
  slide_name=$(basename "$slide_dir")
  slide_num="${slide_name#slide-}"
  source_image="$(find "$slide_dir" -maxdepth 1 -type f \( -iname 'slide-*.png' -o -iname 'slide-*.jpg' -o -iname 'slide-*.jpeg' -o -iname 'slide-*.webp' \) | sort | head -n 1 || true)"
  if [[ -n "${source_image:-}" ]]; then
    artifact_base="$(basename "$source_image")"
    artifact_base="${artifact_base%.*}"
  else
    artifact_base="$slide_name"
  fi

  mp4_file="${slide_dir}/${artifact_base}.mp4"
  legacy_mp4_file="${slide_dir}/${slide_name}-animation.mp4"
  if [[ ! -f "$mp4_file" && -f "$legacy_mp4_file" ]]; then
    mp4_file="$legacy_mp4_file"
  fi

  audio_file="${slide_dir}/${artifact_base}.mp3"
  legacy_audio_file="${slide_dir}/audio-${slide_num}.mp3"
  if [[ ! -f "$audio_file" && -f "$legacy_audio_file" ]]; then
    audio_file="$legacy_audio_file"
  fi

  if [[ ! -f "$mp4_file" ]]; then
    continue
  fi

  input_file="$mp4_file"
  if ! ffprobe -v error -select_streams a:0 -show_entries stream=codec_type -of csv=p=0 "$mp4_file" | grep -q audio; then
    if [[ -f "$audio_file" ]]; then
      muxed_file="${WORK_DIR}/${slide_name}.mp4"
      ffmpeg -y -i "$mp4_file" -i "$audio_file" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 192k -shortest "$muxed_file" -loglevel error
      input_file="$muxed_file"
    fi
  fi

  abs_path="$(pwd)/${input_file}"
  echo "file '${abs_path}'" >> "$INPUTS_FILE"
done

if [[ ! -s "$INPUTS_FILE" ]]; then
  echo "Error: No animation videos found in slide directories to combine."
  rm -rf "$WORK_DIR"
  exit 1
fi

echo "Combining the following videos:"
cat "$INPUTS_FILE"

ffmpeg -y -f concat -safe 0 -i "$INPUTS_FILE" -c:v libx264 -preset veryfast -crf 18 -pix_fmt yuv420p -c:a aac -b:a 128k "$OUTPUT_VIDEO"

echo "Successfully created master video at $OUTPUT_VIDEO"

rm -rf "$WORK_DIR"
