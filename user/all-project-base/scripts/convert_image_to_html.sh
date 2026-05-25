#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
SLIDE_FILTER=""
FRAME_RATE=30
DEFAULT_DURATION_SECONDS="5.0"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE_FILTER="$2"; shift 2 ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done
SLIDES_DIR="$PROJECT_ROOT/slides"

for image_file in "$SLIDES_DIR"/slide-[0-9]*.png; do
  [[ -f "$image_file" ]] || continue
  slide_name="$(basename "$image_file" .png)"
  [[ "$slide_name" =~ ^slide-[0-9]+$ ]] || continue
  [[ -n "$SLIDE_FILTER" && "$slide_name" != "slide-$SLIDE_FILTER" ]] && continue

  audio_text_file="$SLIDES_DIR/${slide_name}-audio.txt"
  fallback_caption_file="$SLIDES_DIR/${slide_name}-caption.txt"
  layout_json_file="$SLIDES_DIR/${slide_name}-scene_layout.json"
  custom_html_file="$SLIDES_DIR/${slide_name}-custom-html.html"
  html_file="$SLIDES_DIR/${slide_name}.html"
  audio_file="$SLIDES_DIR/${slide_name}-audio.mp3"

  caption="$slide_name"
  if [[ -f "$audio_text_file" ]]; then
    caption="$(tr -d '\r' < "$audio_text_file" | sed '/^[[:space:]]*$/d' | head -n 1)"
  elif [[ -f "$fallback_caption_file" ]]; then
    caption="$(tr -d '\r' < "$fallback_caption_file" | sed '/^[[:space:]]*$/d' | head -n 1)"
  fi
  [[ -n "$caption" ]] || caption="$slide_name"

  duration_seconds="$DEFAULT_DURATION_SECONDS"
  if [[ -f "$audio_file" ]] && command -v ffprobe >/dev/null 2>&1; then
    raw_duration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio_file" 2>/dev/null || true)"
    [[ -n "$raw_duration" ]] && duration_seconds="$(awk -v d="$raw_duration" 'BEGIN { printf "%.2f", d + 0.50 }')"
  fi
  duration_frames="$(awk -v duration="$duration_seconds" -v fps="$FRAME_RATE" 'BEGIN { printf "%d", (duration * fps) + 0.5 }')"

  if [[ ! -f "$layout_json_file" ]] && python3 -c 'import requests' >/dev/null 2>&1; then
    python3 "${script_dir}/../utils/orchestrator.py" "$image_file" "$layout_json_file" || true
  fi
  if [[ -f "$layout_json_file" ]]; then
    python3 "${script_dir}/../utils/render_html_from_layout.py" "$layout_json_file" "$custom_html_file" "$duration_frames" || true
  fi

  if [[ -f "$custom_html_file" ]]; then
    if rg -qi '<html|<!doctype' "$custom_html_file"; then
      cp "$custom_html_file" "$html_file"
    else
      {
        echo '<!DOCTYPE html>'
        echo '<html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
        echo '<link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22/%3E">'
        echo "<title>${slide_name}</title></head><body>"
        cat "$custom_html_file"
        echo '</body></html>'
      } > "$html_file"
    fi
  else
    cat > "$html_file" <<HTML
<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22/%3E"><style>html,body{margin:0;background:#111;color:#fff;font-family:Arial,sans-serif} .wrap{width:1920px;height:1080px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:24px} img{max-width:90%;max-height:70%;object-fit:contain;border:2px solid #333} h1{font-size:56px;margin:0}</style></head><body><div class="wrap"><h1>${caption}</h1><img src="./${slide_name}.png" alt="${slide_name}"></div></body></html>
HTML
  fi

  echo "Generated ${html_file}"
done
