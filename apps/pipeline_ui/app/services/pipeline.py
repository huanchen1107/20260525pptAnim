from __future__ import annotations

import re
from pathlib import Path
from typing import Optional

from .runs import RunRecord, create_and_run
from .workspace import project_slides_dir, user_root


RE_SLIDE_ID = re.compile(r"^slide-[0-9]+$")


def _script(path: str) -> str:
  p = Path(path)
  if p.parts[:2] != ("user", "all-project-base"):
    raise ValueError("Script path not allowlisted")
  return str(p)


def run_pipeline(project_id: str, slide: Optional[str], renderer: str, mode: str) -> RunRecord:
  if slide is not None and not RE_SLIDE_ID.match(slide):
    raise ValueError("Invalid slide id")

  project_root = str(user_root() / project_id)
  cmd = ["bash", _script("user/all-project-base/scripts/run_pipeline.sh"), "--project", project_root, "--renderer", renderer, "--mode", mode]
  if slide is not None:
    cmd += ["--slide", slide.replace("slide-", "")]
  return create_and_run(project_id=project_id, slide=slide, step="run_pipeline", command=cmd)


def run_step(
  *,
  project_id: str,
  step: str,
  slide: Optional[str],
  mode: str = "final",
  renderer: str = "hyperframes",
  source_mode: str = "tsx",
) -> RunRecord:
  if slide is not None and not RE_SLIDE_ID.match(slide):
    raise ValueError("Invalid slide id")

  project_root = str(user_root() / project_id)
  slide_num = slide.replace("slide-", "") if slide else None

  if step == "split":
    cmd = ["bash", _script("user/all-project-base/scripts/split_pages.sh"), "--project", project_root, "--source-mode", source_mode]
    if slide_num:
      cmd += ["--slide", slide_num]
  elif step == "convert":
    cmd = ["bash", _script("user/all-project-base/scripts/convert_image_to_html.sh"), "--project", project_root]
    if slide_num:
      cmd += ["--slide", slide_num]
  elif step == "storyboard":
    cmd = ["bash", _script("user/all-project-base/scripts/generate_storyboard.sh"), "--project", project_root, "--no-prompt"]
    if slide_num:
      cmd += ["--slide", slide_num]
  elif step == "render":
    cmd = ["bash", _script("user/all-project-base/scripts/render_animation.sh"), "--project", project_root, "--renderer", renderer, "--mode", mode]
    if slide_num:
      cmd += ["--slide", slide_num]
  elif step == "combine":
    if slide_num:
      raise ValueError("combine does not support single slide")
    cmd = ["bash", _script("user/all-project-base/scripts/combine_videos.sh"), "--project", project_root]
  elif step == "validate":
    cmd = ["bash", _script("user/all-project-base/scripts/validate_slide_artifacts.sh"), "--project", project_root]
    if slide_num:
      cmd += ["--slide", slide_num]
  else:
    raise ValueError("Unknown step")

  return create_and_run(project_id=project_id, slide=slide, step=f"step:{step}", command=cmd)


def read_storyboard(project_id: str, slide_id: str) -> str:
  if not RE_SLIDE_ID.match(slide_id):
    raise ValueError("Invalid slide id")
  p = project_slides_dir(project_id) / f"{slide_id}-storyboard.yml"
  return p.read_text(encoding="utf-8") if p.exists() else ""
