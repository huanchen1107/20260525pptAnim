from __future__ import annotations

import re
from pathlib import Path

from .workspace import project_slides_dir


RE_SLIDE_ID = re.compile(r"^slide-[0-9]+$")


def idea_path(project_id: str, slide_id: str) -> Path:
  if not RE_SLIDE_ID.match(slide_id):
    raise ValueError("Invalid slide_id")
  return project_slides_dir(project_id) / f"{slide_id}-storyboard-idea.txt"


def read_idea(project_id: str, slide_id: str) -> str:
  p = idea_path(project_id, slide_id)
  return p.read_text(encoding="utf-8") if p.exists() else ""


def write_idea(project_id: str, slide_id: str, idea: str) -> None:
  p = idea_path(project_id, slide_id)
  p.write_text((idea or "").replace("\r\n", "\n"), encoding="utf-8")


def _default_idea_text(project_id: str, slide_id: str) -> str:
  slides_dir = project_slides_dir(project_id)
  audio_txt = slides_dir / f"{slide_id}-audio.txt"
  storyboard_yml = slides_dir / f"{slide_id}-storyboard.yml"
  caption = ""
  if audio_txt.exists():
    caption = (audio_txt.read_text(encoding="utf-8", errors="replace").strip().splitlines() or [""])[0].strip()

  storyboard_abstract = ""
  if storyboard_yml.exists():
    raw = storyboard_yml.read_text(encoding="utf-8", errors="replace")
    action_lines: list[str] = []
    for line in raw.splitlines():
      s = line.strip()
      if s.startswith("action:"):
        action_lines.append(s.replace("action:", "", 1).strip())
      if len(action_lines) >= 8:
        break
    if action_lines:
      storyboard_abstract = "Storyboard abstract:\n- Existing actions: " + ", ".join(action_lines) + ".\n\n"

  # Default storyboard "idea" is meant to be human-editable guidance,
  # not a rigid spec. Keep it short and concrete.
  header = f"Slide: {slide_id}"
  if caption:
    header += f"\nNarration: {caption}"

  # A simple presentation grammar baseline.
  return (
    f"{header}\n\n"
    f"{storyboard_abstract}"
    "Goal:\n"
    "- Communicate the main point clearly.\n\n"
    "Motion plan (default):\n"
    "- Start: clean canvas, then reveal title.\n"
    "- Middle: emphasize 1-2 key phrases.\n"
    "- End: subtle settle (no chaos).\n\n"
    "Specific suggestions:\n"
    "- Title: word-by-word reveal (1.5-2.5s).\n"
    "- Subtitle/caption: fade-up after title (0.6-1.2s).\n"
    "- Progress: fill across duration.\n"
  )


def ensure_default_idea(project_id: str, slide_id: str) -> None:
  p = idea_path(project_id, slide_id)
  if p.exists():
    existing = p.read_text(encoding="utf-8", errors="replace").strip()
    if existing:
      return
  write_idea(project_id, slide_id, _default_idea_text(project_id, slide_id))
