#!/usr/bin/env bash
set -euo pipefail

SLIDES_ROOT="user/assets/slides"

chmod +x user/assets/generate_storyboard.sh

./user/assets/generate_storyboard.sh

declare -a missing=()
declare -a bad=()

for slide_dir in "$SLIDES_ROOT"/slide-*/; do
  slide_dir="${slide_dir%/}"
  slide_name=$(basename "$slide_dir")
  storyboard_file="${slide_dir}/analysis/storyboard.yaml"
  scene_index="${slide_dir}/scene/index.html"

  if [[ ! -f "$storyboard_file" ]]; then
    missing+=("$slide_name analysis/storyboard.yaml")
    continue
  fi

  if [[ ! -f "$scene_index" ]]; then
    missing+=("$slide_name scene/index.html")
    continue
  fi

  if ! grep -q '^fps: 30' "$storyboard_file"; then
    bad+=("$slide_name (missing fps)")
  fi

  if ! grep -q '^scenes:' "$storyboard_file"; then
    bad+=("$slide_name (missing scenes)")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "Error: Missing pipeline artifacts for slides: ${missing[*]}"
  exit 1
fi

if [[ ${#bad[@]} -gt 0 ]]; then
  echo "Error: Invalid storyboard YAML: ${bad[*]}"
  exit 1
fi

echo "All storyboard YAML and scene files are present."
