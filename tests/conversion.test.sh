#!/usr/bin/env bash
set -euo pipefail

# Ensure script is executable
chmod +x user/assets/convert_image_to_html.sh

# Run conversion
./user/assets/convert_image_to_html.sh

# Verify that staged pipeline artifacts were generated for each slide directory
missing=0
for dir in user/assets/slides/slide-*/; do
  base=$(basename "$dir")
  html_file="$dir/${base}.html"
  analysis_file="$dir/analysis/visual_analysis.yaml"
  semantic_file="$dir/analysis/semantic_blocks.yaml"
  storyboard_file="$dir/analysis/storyboard.yaml"
  scene_index="$dir/scene/index.html"
  scene_style="$dir/scene/style.css"
  scene_animation="$dir/scene/animation.js"

  if [[ ! -f "$html_file" ]]; then
    echo "Missing HTML file: $html_file"
    missing=1
  fi
  if [[ ! -f "$analysis_file" ]]; then
    echo "Missing analysis file: $analysis_file"
    missing=1
  fi
  if [[ ! -f "$semantic_file" ]]; then
    echo "Missing semantic file: $semantic_file"
    missing=1
  fi
  if [[ ! -f "$storyboard_file" ]]; then
    echo "Missing storyboard file: $storyboard_file"
    missing=1
  fi
  if [[ ! -f "$scene_index" ]]; then
    echo "Missing scene file: $scene_index"
    missing=1
  fi
  if [[ ! -f "$scene_style" ]]; then
    echo "Missing scene file: $scene_style"
    missing=1
  fi
  if [[ ! -f "$scene_animation" ]]; then
    echo "Missing scene file: $scene_animation"
    missing=1
  else
    echo "Found: $html_file"
  fi
done

if [[ $missing -eq 1 ]]; then
  echo "One or more HTML files missing. Test failed."
  exit 1
else
  echo "All staged pipeline artifacts generated successfully. Test passed."
fi

# Cross-platform path stability check with a space-containing path.
temp_root="$(mktemp -d)"
space_root="$temp_root/space dir"
mkdir -p "$space_root/slide-99"
cp user/assets/slides/slide-1/slide-1.png "$space_root/slide-99/slide-99-99.png"
printf '%s\n' 'Space path slide' > "$space_root/slide-99/caption-99.txt"

./user/assets/convert_image_to_html.sh "$space_root"

if [[ ! -f "$space_root/slide-99/analysis/visual_analysis.yaml" ]]; then
  echo "Space-path conversion failed: analysis artifact missing"
  exit 1
fi
if [[ ! -f "$space_root/slide-99/scene/index.html" ]]; then
  echo "Space-path conversion failed: scene artifact missing"
  exit 1
fi
if [[ ! -f "$space_root/slide-99/slide-99.html" ]]; then
  echo "Space-path conversion failed: compatibility HTML missing"
  exit 1
fi
