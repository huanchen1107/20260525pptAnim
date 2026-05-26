from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Dict, List

from .workspace import list_slides, project_slides_dir, user_root


RE_DURATION = re.compile(r'^\s*duration:\s*"?(?P<d>[0-9]+(?:\.[0-9]+)?)"?\s*$', re.MULTILINE)


def timeline_path(project_id: str) -> Path:
  return user_root() / project_id / "slides" / "timeline.json"


def _read_storyboard_duration(slides_dir: Path, slide_id: str) -> float:
  sb = slides_dir / f"{slide_id}-storyboard.yml"
  if not sb.exists():
    return 5.0
  text = sb.read_text(encoding="utf-8", errors="replace")
  m = RE_DURATION.search(text)
  if not m:
    return 5.0
  try:
    return max(0.1, float(m.group("d")))
  except ValueError:
    return 5.0


def _default_timeline(project_id: str) -> List[Dict]:
  slides = list_slides(project_id)
  slides_dir = project_slides_dir(project_id)
  out: List[Dict] = []
  t = 0.0
  for s in slides:
    duration = _read_storyboard_duration(slides_dir, s)
    out.append({
      "slide_id": s,
      "start": round(t, 2),
      "end": round(t + duration, 2),
      "duration": round(duration, 2),
    })
    t += duration
  return out


def get_timeline(project_id: str) -> List[Dict]:
  p = timeline_path(project_id)
  if p.exists():
    try:
      data = json.loads(p.read_text(encoding="utf-8"))
      if isinstance(data, list):
        return data
    except json.JSONDecodeError:
      pass
  data = _default_timeline(project_id)
  save_timeline(project_id, data)
  return data


def save_timeline(project_id: str, entries: List[Dict]) -> None:
  p = timeline_path(project_id)
  p.parent.mkdir(parents=True, exist_ok=True)
  p.write_text(json.dumps(entries, ensure_ascii=False, indent=2), encoding="utf-8")

