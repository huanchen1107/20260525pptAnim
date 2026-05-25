#!/usr/bin/env bash
set -euo pipefail

# Verify that animation MP4 files are generated for each slide.

SLIDES_ROOT="user/assets/slides"

# Run the generation scripts first (in case files are missing)
./user/assets/convert_image_to_html.sh
./user/assets/generate_storyboard.sh
./user/assets/render_animation.sh

# Iterate over slide directories
declare -a missing=()
declare -a invalid=()

for slide_dir in "$SLIDES_ROOT"/slide-*/; do
  slide_name=$(basename "$slide_dir")
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

  if [[ ! -f "$mp4_file" ]]; then
    missing+=("$slide_name")
    continue
  fi
  
  # Check if file size is > 0
  if [[ ! -s "$mp4_file" ]]; then
    invalid+=("$slide_name (file is empty)")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Error: Missing animation MP4 files for slides: ${missing[*]}"
  exit 1
fi

if [[ ${#invalid[@]} -gt 0 ]]; then
  echo "Error: Invalid animation MP4 files (empty): ${invalid[*]}"
  exit 1
fi

echo "All animation MP4 files generated successfully."
exit 0
