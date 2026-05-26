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
  subtitle=""
  subtitle_display=""
  cue_lines=""
  cue_b64=""
  if [[ -f "$audio_text_file" ]]; then
    cue_lines="$(tr -d '\r' < "$audio_text_file" | sed '/^[[:space:]]*$/d')"
    cue_lines="$(python3 - <<'PY' "$cue_lines"
import re,sys
txt=sys.argv[1] if len(sys.argv)>1 else ""
lines=[x.strip() for x in txt.splitlines() if x.strip()]
if lines:
    last=lines[-1]
    if not re.search(r'[。！？.!?]$', last):
        if len(last) >= 6:
            lines[-1] = last + "…"
        else:
            lines = lines[:-1]
print("\n".join(lines))
PY
)"
    caption="$(printf '%s\n' "$cue_lines" | sed -n '1p')"
    subtitle=""
    subtitle_display=""
    cue_b64="$(python3 -c 'import base64,sys; s=sys.stdin.read(); print(base64.b64encode(s.encode("utf-8")).decode("ascii"))' <<< "$cue_lines")"
  elif [[ -f "$fallback_caption_file" ]]; then
    caption="$(tr -d '\r' < "$fallback_caption_file" | sed '/^[[:space:]]*$/d' | head -n 1)"
  fi
  [[ -n "$caption" ]] || caption="$slide_name"
  [[ -n "$subtitle" ]] || subtitle=""
  [[ -n "$subtitle_display" ]] || subtitle_display=""
  subtitle_safe="${subtitle//\"/}"
  cue_b64_safe="${cue_b64//\"/}"
  caption_safe="${caption//\"/}"

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
<!DOCTYPE html><html><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="icon" href="data:image/svg+xml,%3Csvg xmlns=%22http://www.w3.org/2000/svg%22/%3E"><style>html,body{margin:0;background:#070b13;color:#fff;font-family:Arial,sans-serif} .wrap{width:1920px;height:1080px;position:relative;overflow:hidden;background:#070b13} img{position:absolute;inset:0;width:100%;height:100%;object-fit:contain;border:0;box-shadow:none} #title_center{position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);width:78%;text-align:center;font-size:84px;font-weight:900;line-height:1.08;letter-spacing:.01em;color:#fff;text-shadow:0 8px 30px rgba(0,0,0,.58);z-index:6;opacity:0} #pass_text{position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);font-size:120px;font-weight:900;letter-spacing:.04em;color:#ff2f2f;text-shadow:0 10px 38px rgba(0,0,0,.45);z-index:7;opacity:0} .progress{position:absolute;left:50%;bottom:34px;transform:translateX(-50%);width:70%;height:18px;border:2px solid #6f8ab3;border-radius:999px;overflow:hidden;background:rgba(255,255,255,.08);z-index:4} .progress-fill{width:100%;height:100%;background:linear-gradient(90deg,#60a5fa,#22d3ee);transform:scaleX(0);transform-origin:left center} .obj-label{position:absolute;background:#ef4444;color:#fff;font:700 22px/1.2 Arial,sans-serif;padding:6px 10px;border-radius:8px;z-index:20;box-shadow:0 4px 14px rgba(0,0,0,.35)} .obj-label.main{left:26px;top:26px} .obj-label.title{left:50%;top:calc(50% - 168px);transform:translateX(-50%)} .obj-label.pass{left:50%;top:calc(50% - 98px);transform:translateX(-50%)} .obj-label.progress{left:50%;bottom:62px;transform:translateX(-50%)}</style></head><body><div class="wrap"><img id="main_image" src="./${slide_name}.png" alt="${slide_name}"><div id="title_center">${caption_safe}</div><div id="pass_text">PASS</div><div class="progress"><div id="progress_fill" class="progress-fill"></div></div><div class="obj-label main">id: main_image</div><div class="obj-label title">id: title_center</div><div class="obj-label pass">id: pass_text</div><div class="obj-label progress">id: progress_fill</div></div></body></html>
HTML
  fi

  echo "Generated ${html_file}"
done
