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
caption_l = caption.lower()

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
    ids = ["title","subtitle","progress_fill"]

# Prefer semantic ids if present
priority = ["title","subtitle","progress","progress_fill","note","status","frame"]
ranked=[]
for p in priority:
    for oid in ids:
        if p in oid.lower() and oid not in ranked:
            ranked.append(oid)
for oid in ids:
    if oid not in ranked:
        ranked.append(oid)
ids = ranked[:10]

intents = detect_intents(caption_l)

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

# ensure at least one event every 5 seconds (05/06 requirement)
last = actions[-1][1] if actions else 0.0
cp = 5.0
while cp < duration_s:
    if cp - last >= 4.5:
        actions.append(("global", cp, "micro_emphasis", 0.4, "pacing_guard"))
        last = cp
    cp += 5.0

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
  [[ -f "$text_file" ]] && caption="$(tr -d '\r' < "$text_file" | sed '/^[[:space:]]*$/d' | head -n 1)"
  caption_safe="${caption//\"/}"

  object_yaml="$(python3 -c "$python_mapper" "$layout_json" "$caption_safe" "$duration" 2>/dev/null || true)"
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
caption: "$caption_safe"
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
