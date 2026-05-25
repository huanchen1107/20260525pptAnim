#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
SLIDE_FILTER=""
STRICT_NAMES="true"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE_FILTER="$2"; shift 2 ;;
    --no-strict-names) STRICT_NAMES="false"; shift ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

SLIDES_DIR="$PROJECT_ROOT/slides"
[[ -d "$SLIDES_DIR" ]] || { echo "Missing slides dir: $SLIDES_DIR" >&2; exit 1; }

fail=0
for png in "$SLIDES_DIR"/slide-[0-9]*.png; do
  [[ -f "$png" ]] || continue
  id="$(basename "$png" .png)"
  [[ "$id" =~ ^slide-[0-9]+$ ]] || continue
  [[ -n "$SLIDE_FILTER" && "$id" != "slide-$SLIDE_FILTER" ]] && continue

  for required in "$SLIDES_DIR/${id}-audio.mp3" "$SLIDES_DIR/${id}-audio.txt" "$SLIDES_DIR/${id}.html" "$SLIDES_DIR/${id}-storyboard.yml"; do
    [[ -f "$required" ]] || { echo "[validate] missing: $required" >&2; fail=1; }
  done
done

if [[ "$STRICT_NAMES" == "true" ]]; then
  drift=$(find "$SLIDES_DIR" -maxdepth 1 -type f \( -name 'slide-*-slide-*' -o -name 'slide-*-custom-html.html' -o -name 'slide-*-caption*.txt' \))
  if [[ -n "$drift" ]]; then
    echo "[validate] non-canonical files detected:" >&2
    echo "$drift" >&2
    fail=1
  fi
fi

[[ "$fail" -eq 0 ]] || { echo "[validate] FAILED" >&2; exit 1; }
echo "[validate] OK: canonical slide artifacts present"
