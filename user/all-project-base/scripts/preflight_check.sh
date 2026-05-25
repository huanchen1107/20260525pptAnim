#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
STRICT="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --strict) STRICT="true"; shift ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

SOURCE_DIR="$PROJECT_ROOT/source"
SLIDES_DIR="$PROJECT_ROOT/slides"
OUTPUTS_DIR="$PROJECT_ROOT/outputs"
DOCS_DIR="$PROJECT_ROOT/docs"

fail() { echo "[preflight] ERROR: $1" >&2; exit 1; }
warn() { echo "[preflight] WARN: $1" >&2; }

[[ -d "$PROJECT_ROOT" ]] || fail "Missing project root: $PROJECT_ROOT"
[[ -d "$SOURCE_DIR" ]] || fail "Missing source dir: $SOURCE_DIR"
[[ -d "$SLIDES_DIR" ]] || fail "Missing slides dir: $SLIDES_DIR"
[[ -d "$OUTPUTS_DIR" ]] || warn "Missing outputs dir: $OUTPUTS_DIR (will be created by pipeline)"
[[ -d "$DOCS_DIR" ]] || warn "Missing docs dir: $DOCS_DIR"

video_count=$(find "$SOURCE_DIR" -maxdepth 1 -type f -name '*.mp4' | wc -l | tr -d ' ')
pdf_count=$(find "$SOURCE_DIR" -maxdepth 1 -type f -name '*.pdf' | wc -l | tr -d ' ')
tsx_count=$(find "$SOURCE_DIR" -maxdepth 1 -type f -name '*.tsx' | wc -l | tr -d ' ')

[[ "$video_count" -gt 0 ]] || fail "No source video (*.mp4) found in $SOURCE_DIR"
[[ "$pdf_count" -gt 0 ]] || fail "No source PDF (*.pdf) found in $SOURCE_DIR"
[[ "$tsx_count" -gt 0 ]] || warn "No TSX source (*.tsx) found in $SOURCE_DIR"

for tool in ffmpeg ffprobe pdftoppm pdfinfo; do
  command -v "$tool" >/dev/null 2>&1 || fail "Required tool not found: $tool"
done

if find "$SLIDES_DIR" -maxdepth 1 -type d -name 'slide-*' | grep -q .; then
  fail "Legacy slide directories found under $SLIDES_DIR (expected flat files only)"
fi

legacy_audio_count=$(find "$SLIDES_DIR" -maxdepth 1 -type f -name 'slide-*-audio-[0-9]*.mp3' | wc -l | tr -d ' ')
legacy_caption_count=$(find "$SLIDES_DIR" -maxdepth 1 -type f -name 'slide-*-caption*.txt' | wc -l | tr -d ' ')
if [[ "$legacy_audio_count" != "0" || "$legacy_caption_count" != "0" ]]; then
  msg="Legacy duplicates detected (audio-variant: $legacy_audio_count, caption-variant: $legacy_caption_count)"
  if [[ "$STRICT" == "true" ]]; then
    fail "$msg"
  else
    warn "$msg"
  fi
fi

echo "[preflight] OK: $PROJECT_ROOT (video=$video_count, pdf=$pdf_count, tsx=$tsx_count)"
