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

for txt in "$SLIDES_DIR"/slide-[0-9]*-audio.txt; do
  [[ -f "$txt" ]] || continue
  base="$(basename "$txt" -audio.txt)"
  [[ "$base" =~ ^slide-[0-9]+$ ]] || continue
  [[ -n "$SLIDE_FILTER" && "$base" != "slide-$SLIDE_FILTER" ]] && continue

  python3 - <<'PY' "$txt"
import re, sys
from pathlib import Path
p = Path(sys.argv[1])
lines = [ln.strip() for ln in p.read_text(encoding="utf-8", errors="replace").replace("\r","").splitlines() if ln.strip()]
out = []
for ln in lines:
    ln = re.sub(r"\s+", " ", ln).strip()
    if ln:
        out.append(ln)
if out:
    last = out[-1]
    # If the final caption looks truncated, make it explicit rather than abrupt.
    if not re.search(r"[。！？.!?…]$", last):
        if len(last) >= 6:
            out[-1] = last + "…"
        else:
            out.pop()
p.write_text("\n".join(out) + ("\n" if out else ""), encoding="utf-8")
print(f"Normalized {p}")
PY
done

