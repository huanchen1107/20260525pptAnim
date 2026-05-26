#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
SLIDE_FILTER=""
NO_PROMPT="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE_FILTER="$2"; shift 2 ;;
    --no-prompt) NO_PROMPT="true"; shift ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

SLIDES_ROOT="$PROJECT_ROOT/slides"

python_mapper='import json, re, sys
layout_path, caption, duration_s = sys.argv[1], sys.argv[2], float(sys.argv[3])
allowed_ids = set([x for x in (sys.argv[5].split(",") if len(sys.argv) > 5 and sys.argv[5] else []) if x])
caption_l = caption.lower()

# Optional user-provided idea to steer storyboard generation.
idea = sys.argv[4] if len(sys.argv) > 4 else ""
idea_l = (idea or "").lower()

# intent mapping from transcript semantics
intent_patterns = [
    (r"zoom in|focus|emphas|highlight|關鍵|重點", "zoom_in"),
    (r"zoom out|overview|summary|總結|全局", "zoom_out"),
    (r"pan|shift|move to|轉到|移動", "pan"),
    (r"compare|versus|vs|對比|比較", "compare_reveal"),
    (r"step|first|second|then|流程|步驟", "step_reveal"),
    (r"introduc|welcome|start|開始|歡迎", "intro_reveal"),
]

def detect_intents(text):
    intents=[]
    for pat, name in intent_patterns:
        if re.search(pat, text):
            intents.append(name)
    if not intents:
        intents=["intro_reveal","step_reveal","emphasize"]
    return intents

try:
    with open(layout_path, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception:
    data = {}

objs = data.get("objects", []) if isinstance(data, dict) else []
if not isinstance(objs, list):
    objs = []

ids=[]
for obj in objs:
    oid = obj.get("id") or obj.get("name") or obj.get("type")
    if oid and str(oid).strip():
        ids.append(str(oid).strip())

if not ids:
    ids = ["curtain","title","title_center","subtitle","main_image","progress_fill","pass_text"]

if allowed_ids:
    ids = [x for x in ids if x in allowed_ids]
    if not ids:
        ids = [x for x in ["title","title_center","subtitle","main_image","progress_fill","pass_text"] if x in allowed_ids]
    if not ids:
        ids = list(allowed_ids)[:4]

# Prefer semantic ids if present
priority = ["title","title_center","subtitle","progress","progress_fill","note","status","frame"]
ranked=[]
for p in priority:
    for oid in ids:
        if p in oid.lower() and oid not in ranked:
            ranked.append(oid)
for oid in ids:
    if oid not in ranked:
        ranked.append(oid)
ids = ranked[:10]

steer_text = caption_l + "\n" + idea_l
intents = detect_intents(steer_text)

# map intent -> action set
intent_actions = {
    "intro_reveal": ["fade_in","slide_in_up"],
    "step_reveal": ["fade_up","draw_in"],
    "emphasize": ["pulse","highlight"],
    "zoom_in": ["zoom_in"],
    "zoom_out": ["zoom_out"],
    "pan": ["pan_x"],
    "compare_reveal": ["split_reveal","swap_focus"],
}

actions=[]
t=0.6
min_gap=0.9
for i, oid in enumerate(ids):
    intent = intents[i % len(intents)]
    act_list = intent_actions.get(intent, ["fade_in"])
    act = act_list[i % len(act_list)]
    dur = 0.6 if act not in ("zoom_in","zoom_out","pan_x") else 1.2
    actions.append((oid, t, act, dur, intent))
    t += min_gap

# Canonical strong actions for presentation readability.
if "title" in ids:
    actions = [a for a in actions if a[0] != "title"]
    actions.insert(0, ("title", 0.30, "word_by_word", 2.00, "title_intro"))
if "title_center" in ids:
    actions = [a for a in actions if a[0] != "title_center"]
    actions.insert(0, ("title_center", 0.30, "word_by_word", 2.20, "title_intro"))
if "subtitle" in ids:
    actions = [a for a in actions if a[0] != "subtitle"]
    actions.insert(1 if len(actions) > 0 else 0, ("subtitle", 2.20, "fade_up", 0.90, "caption_intro"))
if "progress_fill" in ids:
    actions = [a for a in actions if a[0] != "progress_fill"]
    actions.append(("progress_fill", 0.20, "progress_fill", max(1.0, duration_s - 0.40), "timeline_progress"))
if "title" not in ids and "main_image" in ids:
    actions.append(("main_image", 0.35, "zoom_in", min(2.4, max(0.8, duration_s * 0.42)), "image_intro"))
    actions.append(("main_image", min(2.8, max(0.9, duration_s * 0.56)), "pulse", 1.10, "image_emphasis"))

# Honor explicit "write a pass at 10s red color font" style suggestion from idea.
red_pass_t = 10.0
m = re.search(r"(\d+(?:\.\d+)?)\s*s.*red", idea_l)
if m:
    try:
        red_pass_t = float(m.group(1))
    except ValueError:
        red_pass_t = 10.0
red_pass_t = max(0.0, min(red_pass_t, max(0.0, duration_s - 0.8)))
if "red" in idea_l and ("font" in idea_l or "color" in idea_l):
    if "title" in ids:
        target = "title"
    elif "pass_text" in ids:
        target = "pass_text"
    else:
        target = ids[0]
    actions.append((target, red_pass_t, "font_red_pass", 1.20, "red_font_pass"))
if ("pass" in idea_l) and ("pass_text" in ids):
    pass_t2 = min(red_pass_t + 1.0, max(0.0, duration_s - 0.2))
    actions.append(("pass_text", red_pass_t, "fade_up", 1.00, "pass_marker"))
    actions.append(("pass_text", pass_t2, "font_red_pass", 1.20, "pass_marker"))

# If the idea includes explicit "Specific suggestions", keep only requested core actions.
if "specific suggestions" in idea_l:
    allowed = {"word_by_word", "fade_up", "progress_fill", "font_red_pass", "zoom_in", "zoom_out", "pulse", "highlight"}
    filtered = []
    for oid, at, act, dur, intent in actions:
        if act not in allowed:
            continue
        if act == "word_by_word" and oid not in ("title", "title_center"):
            continue
        if act == "fade_up" and oid != "subtitle":
            if oid != "pass_text":
                continue
        if act == "progress_fill" and oid != "progress_fill":
            continue
        if act == "font_red_pass" and oid not in ("title", "pass_text"):
            continue
        if act in ("zoom_in", "zoom_out", "pulse", "highlight") and oid not in ("main_image", "title"):
            continue
        filtered.append((oid, at, act, dur, intent))
    actions = filtered

# ensure at least one event every 5 seconds (05/06 requirement)
# NOTE: disable global pacing guards to avoid perceived full-scene drift.

# print yaml snippet
for oid, at, act, dur, intent in actions:
    print(f"  - id: {oid}")
    print(f"    at: {at:.2f}")
    print(f"    action: {act}")
    print(f"    duration: {dur:.2f}")
    print(f"    intent: {intent}")
'

for image in "$SLIDES_ROOT"/slide-[0-9]*.png; do
  [[ -f "$image" ]] || continue
  id="$(basename "$image" .png)"
  [[ "$id" =~ ^slide-[0-9]+$ ]] || continue
  [[ -n "$SLIDE_FILTER" && "$id" != "slide-$SLIDE_FILTER" ]] && continue

  audio="$SLIDES_ROOT/${id}-audio.mp3"
  text_file="$SLIDES_ROOT/${id}-audio.txt"
  layout_json="$SLIDES_ROOT/${id}-scene_layout.json"
  html_file="$SLIDES_ROOT/${id}.html"
  out="$SLIDES_ROOT/${id}-storyboard.yml"

  duration="5.00"
  if [[ -f "$audio" ]] && command -v ffprobe >/dev/null 2>&1; then
    duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio" | awk '{printf "%.2f", $1+0.5}')
  fi

  if [[ "$NO_PROMPT" != "true" && -t 0 ]]; then
    read -r -p "Duration for ${id} in seconds [${duration}]: " input_duration
    if [[ -n "${input_duration:-}" && "$input_duration" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
      duration="$input_duration"
    fi
  fi

  caption=""
  caption_block=""
  narration_block=""
  if [[ -f "$text_file" ]]; then
    caption="$(python3 - <<'PY' "$text_file"
import sys
from pathlib import Path
p = Path(sys.argv[1])
lines = [ln.strip() for ln in p.read_text(encoding='utf-8', errors='replace').replace('\r','').splitlines() if ln.strip()]
print(" | ".join(lines))
PY
)"
    caption_block="$(python3 - <<'PY' "$text_file"
import sys
from pathlib import Path
p = Path(sys.argv[1])
lines = [ln.rstrip() for ln in p.read_text(encoding='utf-8', errors='replace').replace('\r','').splitlines() if ln.strip()]
for ln in lines:
    print("  " + ln.replace('"',''))
PY
)"
    narration_block="$(python3 - <<'PY' "$text_file"
import sys
from pathlib import Path
p = Path(sys.argv[1])
lines = [ln.rstrip() for ln in p.read_text(encoding='utf-8', errors='replace').replace('\r','').splitlines() if ln.strip()]
print("\n".join(lines))
PY
)"
  fi
  caption_safe="${caption//\"/}"

  idea_file="$SLIDES_ROOT/${id}-storyboard-idea.txt"
  idea_user=""
  if [[ -f "$idea_file" ]]; then
    idea_user="$(tr -d '\r' < "$idea_file" | sed 's/[[:space:]]*$//')"
    # Keep only human-authored part to avoid recursive abstract/narration duplication.
    if printf "%s" "$idea_user" | rg -q "^User ideas:"; then
      idea_user="$(printf "%s\n" "$idea_user" | awk 'found{print} /^User ideas:/{found=1}')"
      idea_user="${idea_user#User ideas:}"
      idea_user="$(printf "%s" "$idea_user" | sed '1{/^[[:space:]]*$/d;}')"
    fi
    idea_user="$(python3 - <<'PY' "$idea_user"
import sys
txt = sys.argv[1] if len(sys.argv)>1 else ""
lines = txt.splitlines()
out = []
skip = False
for ln in lines:
    s = ln.strip()
    if s.startswith("Storyboard abstract:"):
        skip = True
        continue
    if s.startswith("Narration (full):"):
        skip = True
        continue
    if s.startswith("User ideas:"):
        skip = False
        continue
    if skip:
        # continue skipping auto-generated section lines until a blank + non-indented section header appears
        if s == "":
            continue
        if s.startswith("- Existing actions:"):
            continue
        # keep skipping generic narration payload lines
        if len(s) > 0:
            continue
    out.append(ln)
print("\n".join([x for x in out if x.strip()]))
PY
)"
  fi

  # Build storyboard abstract from existing storyboard, then combine with user idea.
  storyboard_abstract="$(python3 - <<'PY' "$out"
import sys, re
from pathlib import Path
p = Path(sys.argv[1])
if not p.exists():
    print("")
    raise SystemExit
raw = p.read_text(encoding='utf-8', errors='replace')
actions = []
for ln in raw.splitlines():
    m = re.match(r'^\s*action:\s*(.+)\s*$', ln)
    if m:
        actions.append(m.group(1).strip())
if actions:
    print("Storyboard abstract:")
    print("- Existing actions: " + ", ".join(actions[:12]))
PY
)"

  if [[ -n "${idea_user//[[:space:]]/}" ]]; then
    idea_combined="${storyboard_abstract}"$'\n\n'"Narration (full):"$'\n'"${narration_block}"$'\n\n'"User ideas:"$'\n'"${idea_user}"
  else
    idea_combined="${storyboard_abstract}"$'\n\n'"Narration (full):"$'\n'"${narration_block}"
  fi
  # Keep idea txt aligned with abstract-first rule.
  if [[ -n "${idea_combined//[[:space:]]/}" ]]; then
    printf "%s\n" "$idea_combined" > "$idea_file"
  fi

  idea_safe="${idea_combined//\"/}"
  allowed_ids="$(python3 - <<'PY' "$html_file"
import re,sys
from pathlib import Path
p=Path(sys.argv[1])
if not p.exists():
    print("")
    raise SystemExit
raw=p.read_text(encoding='utf-8', errors='replace')
ids=re.findall(r'\bid="([^"]+)"', raw)
print(",".join(dict.fromkeys(ids)))
PY
)"
  object_yaml="$(python3 -c "$python_mapper" "$layout_json" "$caption_safe" "$duration" "$idea_combined" "$allowed_ids" 2>/dev/null || true)"
  if [[ -z "$object_yaml" ]]; then
    object_yaml="  - id: title
    at: 0.80
    action: fade_in
    duration: 0.50
    intent: fallback"
  fi

  cat > "$out" <<YML
slide: "$id"
duration: "$duration"
fps: 30
caption: |
$caption_block
idea: "$idea_safe"
scenes:
  - id: intro
    start: 0.00
    end: 1.20
  - id: content
    start: 1.20
    end: 4.20
  - id: outro
    start: 4.20
    end: $duration
objects:
$object_yaml
YML

  echo "Generated $out"
done
