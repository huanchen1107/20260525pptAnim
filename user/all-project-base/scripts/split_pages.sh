#!/usr/bin/env bash
set -euo pipefail

VIDEO="user/project-1/source/A2Z-original.mp4"
AUDIO_SRC="user/project-1/source/A2Z-original-audio.mp3"
PDF="user/project-1/source/A2ZpdfExcalidraw.pdf"
SLIDES_DIR="user/project-1/slides"

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
  start=$(awk -v p="$PER_SLIDE" -v i="$i" 'BEGIN{printf "%.3f", (i-1)*p}')
  end=$(awk -v p="$PER_SLIDE" -v i="$i" 'BEGIN{printf "%.3f", i*p}')

  pdftoppm -f "$i" -l "$i" -png -r 300 -singlefile "$PDF" "$SLIDES_DIR/slide-${i}"
  ffmpeg -y -i "$AUDIO_SRC" -ss "$start" -to "$end" -c:a libmp3lame -q:a 2 "$SLIDES_DIR/slide-${i}-audio.mp3" -loglevel error
  if command -v whisper >/dev/null; then
    whisper "$SLIDES_DIR/slide-${i}-audio.mp3" --model tiny --output_dir "$SLIDES_DIR" --output_format txt >/dev/null 2>&1 || true
    mv "$SLIDES_DIR/slide-${i}-audio.mp3.txt" "$SLIDES_DIR/slide-${i}-caption.txt" 2>/dev/null || echo "# caption placeholder" > "$SLIDES_DIR/slide-${i}-caption.txt"
  else
    echo "# caption placeholder" > "$SLIDES_DIR/slide-${i}-caption.txt"
  fi

  printf '{"page":%d,"start":%s,"end":%s}' "$i" "$start" "$end" >> "$SLIDES_DIR/timestamps.json"
  [[ "$i" -lt "$PAGE_COUNT" ]] && printf ',' >> "$SLIDES_DIR/timestamps.json"
done
printf ']' >> "$SLIDES_DIR/timestamps.json"

echo "Generated flat slide assets under $SLIDES_DIR"
