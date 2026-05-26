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

SLIDES_DIR="$PROJECT_ROOT/slides"

to_srt_time() {
  python3 - <<'PY' "$1"
import sys
t=max(0.0,float(sys.argv[1]))
h=int(t//3600); t-=h*3600
m=int(t//60); t-=m*60
s=int(t); ms=int(round((t-s)*1000))
if ms==1000: s+=1; ms=0
print(f"{h:02d}:{m:02d}:{s:02d},{ms:03d}")
PY
}

for txt in "$SLIDES_DIR"/slide-[0-9]*-audio.txt; do
  [[ -f "$txt" ]] || continue
  slide_id="$(basename "$txt" -audio.txt)"
  [[ "$slide_id" =~ ^slide-[0-9]+$ ]] || continue
  [[ -n "$SLIDE_FILTER" && "$slide_id" != "slide-$SLIDE_FILTER" ]] && continue

  audio="$SLIDES_DIR/${slide_id}-audio.mp3"
  out="$SLIDES_DIR/${slide_id}.srt"
  duration="5.0"
  if [[ -f "$audio" ]] && command -v ffprobe >/dev/null 2>&1; then
    duration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio" 2>/dev/null || echo 5)"
  fi

  lines=()
  while IFS= read -r line; do
    [[ -n "${line//[[:space:]]/}" ]] || continue
    lines+=("$line")
  done < <(tr -d '\r' < "$txt")
  n="${#lines[@]}"
  if [[ "$n" -eq 0 ]]; then
    : > "$out"
    echo "Generated $out (empty)"
    continue
  fi

  seg="$(python3 - <<'PY' "$duration" "$n"
import sys
d=max(0.1,float(sys.argv[1])); n=max(1,int(sys.argv[2]))
print(max(0.8,d/n))
PY
)"

  : > "$out"
  for ((i=0;i<n;i++)); do
    start="$(python3 - <<'PY' "$seg" "$i"
import sys
print(float(sys.argv[1])*int(sys.argv[2]))
PY
)"
    end="$(python3 - <<'PY' "$seg" "$i" "$duration" "$n"
import sys
seg=float(sys.argv[1]); i=int(sys.argv[2]); d=float(sys.argv[3]); n=int(sys.argv[4])
if i==n-1: print(d)
else: print(min(d, seg*(i+1)-0.05))
PY
)"
    {
      echo "$((i+1))"
      echo "$(to_srt_time "$start") --> $(to_srt_time "$end")"
      echo "${lines[$i]}"
      echo
    } >> "$out"
  done

  echo "Generated $out"
done
