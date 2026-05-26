from __future__ import annotations

import os
import re
from pathlib import Path


RE_PROJECT = re.compile(r"^project-[0-9]+$")
RE_SLIDE = re.compile(r"^slide-([0-9]+)$")


def workspace_root() -> Path:
  # repo root is current working directory when running uvicorn from repo
  return Path(os.getcwd()).resolve()


def user_root() -> Path:
  return workspace_root() / "user"


def list_projects() -> list[str]:
  root = user_root()
  if not root.exists():
    return []
  out: list[str] = []
  for entry in sorted(root.iterdir()):
    if not entry.is_dir():
      continue
    if RE_PROJECT.match(entry.name):
      out.append(entry.name)
  return out


def project_slides_dir(project_id: str) -> Path:
  if not RE_PROJECT.match(project_id):
    raise ValueError("Invalid project_id")
  return user_root() / project_id / "slides"


def list_slides(project_id: str) -> list[str]:
  slides_dir = project_slides_dir(project_id)
  if not slides_dir.exists():
    return []
  slide_nums: list[int] = []
  for html in slides_dir.glob("slide-*.html"):
    m = RE_SLIDE.match(html.stem)
    if not m:
      continue
    slide_nums.append(int(m.group(1)))
  return [f"slide-{n}" for n in sorted(set(slide_nums))]


def read_slide_caption(project_id: str, slide_id: str) -> str:
  if not RE_PROJECT.match(project_id):
    raise ValueError("Invalid project_id")
  if not RE_SLIDE.match(slide_id):
    raise ValueError("Invalid slide_id")
  p = project_slides_dir(project_id) / f"{slide_id}-audio.txt"
  if not p.exists():
    return ""
  lines = p.read_text(encoding="utf-8", errors="replace").replace("\r\n", "\n").splitlines()
  for line in lines:
    s = line.strip()
    if s:
      return s
  return ""
