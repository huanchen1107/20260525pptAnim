#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
SLIDE_FILTER=""
SOURCE_MODE="tsx"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE_FILTER="$2"; shift 2 ;;
    --source-mode) SOURCE_MODE="$2"; shift 2 ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

VIDEO="$PROJECT_ROOT/source/A2Z-original.mp4"
AUDIO_SRC="$PROJECT_ROOT/source/A2Z-original-audio.mp3"
PDF="$PROJECT_ROOT/source/A2ZpdfExcalidraw.pdf"
TSX="$PROJECT_ROOT/source/A2Z.tsx"
SLIDES_DIR="$PROJECT_ROOT/slides"
mkdir -p "$SLIDES_DIR"

command -v ffmpeg >/dev/null || { echo "Missing ffmpeg" >&2; exit 1; }
command -v ffprobe >/dev/null || { echo "Missing ffprobe" >&2; exit 1; }

if [[ "$SOURCE_MODE" == "tsx" ]]; then
  PAGE_COUNT=$(find "$SLIDES_DIR" -maxdepth 1 -type f -name 'slide-[0-9]*.png' | sed -E 's|.*slide-([0-9]+)\.png|\1|' | sort -n | tail -n1)
  if [[ -z "${PAGE_COUNT:-}" ]]; then
    [[ -f "$PDF" ]] || { echo "TSX mode needs existing slide-N.png files or PDF fallback present." >&2; exit 1; }
    command -v pdfinfo >/dev/null || { echo "Missing pdfinfo" >&2; exit 1; }
    command -v pdftoppm >/dev/null || { echo "Missing pdftoppm" >&2; exit 1; }
    PAGE_COUNT=$(pdfinfo "$PDF" | awk '/Pages:/ {print $2}')
    for ((i=1;i<=PAGE_COUNT;i++)); do
      pdftoppm -f "$i" -l "$i" -png -r 300 -singlefile "$PDF" "$SLIDES_DIR/slide-${i}"
    done
  fi
else
  command -v pdfinfo >/dev/null || { echo "Missing pdfinfo" >&2; exit 1; }
  command -v pdftoppm >/dev/null || { echo "Missing pdftoppm" >&2; exit 1; }
  PAGE_COUNT=$(pdfinfo "$PDF" | awk '/Pages:/ {print $2}')
  for ((i=1;i<=PAGE_COUNT;i++)); do
    pdftoppm -f "$i" -l "$i" -png -r 300 -singlefile "$PDF" "$SLIDES_DIR/slide-${i}"
  done
fi

DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO")
PER_SLIDE=$(awk -v d="$DURATION" -v p="$PAGE_COUNT" 'BEGIN{printf "%.3f", d/p}')
printf '[' > "$SLIDES_DIR/timestamps.json"
for ((i=1;i<=PAGE_COUNT;i++)); do
  slide_id="slide-${i}"
  [[ -n "$SLIDE_FILTER" && "$slide_id" != "slide-$SLIDE_FILTER" ]] && continue
  start=$(awk -v p="$PER_SLIDE" -v i="$i" 'BEGIN{printf "%.3f", (i-1)*p}')
  end=$(awk -v p="$PER_SLIDE" -v i="$i" 'BEGIN{printf "%.3f", i*p}')
  rm -f "$SLIDES_DIR/${slide_id}-audio"*.mp3 "$SLIDES_DIR/${slide_id}-audio"*.txt
  ffmpeg -y -i "$AUDIO_SRC" -ss "$start" -to "$end" -c:a libmp3lame -q:a 2 "$SLIDES_DIR/${slide_id}-audio.mp3" -loglevel error
  text_out="$SLIDES_DIR/${slide_id}-audio.txt"
  if command -v whisper >/dev/null; then
    whisper "$SLIDES_DIR/${slide_id}-audio.mp3" --model tiny --output_dir "$SLIDES_DIR" --output_format txt >/dev/null 2>&1 || true
    [[ -s "$text_out" ]] || printf 'Slide %s narration segment (%.2fs-%.2fs).\n' "$i" "$start" "$end" > "$text_out"
  else
    printf 'Slide %s narration segment (%.2fs-%.2fs).\n' "$i" "$start" "$end" > "$text_out"
  fi
  printf '{"page":%d,"start":%s,"end":%s},' "$i" "$start" "$end" >> "$SLIDES_DIR/timestamps.json"
done
sed -i '' 's/,$//' "$SLIDES_DIR/timestamps.json" 2>/dev/null || true
printf ']' >> "$SLIDES_DIR/timestamps.json"
echo "Generated flat slide assets under $SLIDES_DIR (source_mode=$SOURCE_MODE)"
