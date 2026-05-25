#!/usr/bin/env bash
set -euo pipefail

SLIDES_ROOT="${1:-user/assets/slides}"
FRAME_RATE=30
DEFAULT_DURATION_SECONDS="5.00"

determine_duration_seconds() {
  local audio_file="$1"
  if [[ -f "$audio_file" ]] && command -v ffprobe >/dev/null 2>&1; then
    local raw_duration
    raw_duration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null || true)"
    if [[ -n "${raw_duration:-}" ]]; then
      awk -v duration="$raw_duration" 'BEGIN { printf "%.2f", duration + 0.50 }'
      return
    fi
  fi

  printf '%s' "$DEFAULT_DURATION_SECONDS"
}

write_storyboard_yaml() {
  local output_file="$1"
  local slide_name="$2"
  local duration_seconds="$3"

  cat > "$output_file" <<EOF
duration: "$duration_seconds"
fps: $FRAME_RATE
slide: "$slide_name"
scenes:
  - id: background_enter
    time: 0.00
    label: "Background fade in"
  - id: frame_enter
    time: 0.30
    label: "Frame / layout enter"
  - id: title_enter
    time: 0.80
    label: "Title fade up"
  - id: detail_enter
    time: 1.40
    label: "Body copy and details"
  - id: settle
    time: 2.00
    label: "Settle state"
EOF
}

if [[ -d "$SLIDES_ROOT" && "$(basename "$SLIDES_ROOT")" == slide-* ]]; then
  slide_dirs=("$SLIDES_ROOT")
else
  slide_dirs=("$SLIDES_ROOT"/slide-*/)
fi

for slide_dir in "${slide_dirs[@]}"; do
  slide_dir="${slide_dir%/}"
  [[ -d "$slide_dir" ]] || continue
  slide_name="$(basename "$slide_dir")"
  slide_num="${slide_name#slide-}"
  audio_file="${slide_dir}/audio-${slide_num}.mp3"
  analysis_dir="${slide_dir}/analysis"
  output_file="${analysis_dir}/storyboard.yaml"

  mkdir -p "$analysis_dir"
  duration_seconds="$(determine_duration_seconds "$audio_file")"
  write_storyboard_yaml "$output_file" "$slide_name" "$duration_seconds"
  cp "$output_file" "${slide_dir}/storyboard.yml"

  echo "Generated storyboard YAML $output_file"
done
