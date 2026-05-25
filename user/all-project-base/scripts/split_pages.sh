#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
SLIDE_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE_FILTER="$2"; shift 2 ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

VIDEO="$PROJECT_ROOT/source/A2Z-original.mp4"
AUDIO_SRC="$PROJECT_ROOT/source/A2Z-original-audio.mp3"
PDF="$PROJECT_ROOT/source/A2ZpdfExcalidraw.pdf"
SLIDES_DIR="$PROJECT_ROOT/slides"

mkdir -p "$SLIDES_DIR"

if ! command -v pdfinfo >/dev/null || ! command -v pdftoppm >/dev/null || ! command -v ffmpeg >/dev/null; then
  echo "Missing required tools (pdfinfo/pdftoppm/ffmpeg)." >&2
  exit 1
fi

PAGE_COUNT=$(pdfinfo "$PDF" | awk '/Pages:/ {print $2}')
[[ -n "$PAGE_COUNT" ]] || { echo "Cannot read PDF pages" >&2; exit 1; }

DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$VIDEO")
PER_SLIDE=$(awk -v d="$DURATION" -v p="$PAGE_COUNT" 'BEGIN{printf "%.3f", d/p}')

printf '[' > "$SLIDES_DIR/timestamps.json"
for ((i=1;i<=PAGE_COUNT;i++)); do
  slide_id="slide-${i}"
  if [[ -n "$SLIDE_FILTER" && "$slide_id" != "slide-$SLIDE_FILTER" ]]; then
    continue
  fi

  start=$(awk -v p="$PER_SLIDE" -v i="$i" 'BEGIN{printf "%.3f", (i-1)*p}')
  end=$(awk -v p="$PER_SLIDE" -v i="$i" 'BEGIN{printf "%.3f", i*p}')

  rm -f "$SLIDES_DIR/${slide_id}-audio"*.mp3
  rm -f "$SLIDES_DIR/${slide_id}-audio"*.txt
  rm -f "$SLIDES_DIR/${slide_id}-caption"*.txt

  pdftoppm -f "$i" -l "$i" -png -r 300 -singlefile "$PDF" "$SLIDES_DIR/${slide_id}"
  ffmpeg -y -i "$AUDIO_SRC" -ss "$start" -to "$end" -c:a libmp3lame -q:a 2 "$SLIDES_DIR/${slide_id}-audio.mp3" -loglevel error
  if command -v whisper >/dev/null; then
    whisper "$SLIDES_DIR/${slide_id}-audio.mp3" --model tiny --output_dir "$SLIDES_DIR" --output_format txt >/dev/null 2>&1 || true
    mv "$SLIDES_DIR/${slide_id}-audio.mp3.txt" "$SLIDES_DIR/${slide_id}-audio.txt" 2>/dev/null || echo "# caption placeholder" > "$SLIDES_DIR/${slide_id}-audio.txt"
  else
    echo "# caption placeholder" > "$SLIDES_DIR/${slide_id}-audio.txt"
  fi

  printf '{"page":%d,"start":%s,"end":%s},' "$i" "$start" "$end" >> "$SLIDES_DIR/timestamps.json"
done
sed -i '' 's/,$//' "$SLIDES_DIR/timestamps.json" 2>/dev/null || true
printf ']' >> "$SLIDES_DIR/timestamps.json"

echo "Generated flat slide assets under $SLIDES_DIR"
