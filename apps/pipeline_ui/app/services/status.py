from __future__ import annotations

from pathlib import Path
from typing import Optional

from .workspace import project_slides_dir, user_root


def _exists(path: Path) -> bool:
  try:
    return path.exists()
  except OSError:
    return False


def pipeline_status(project_id: str, slide_id: Optional[str]) -> dict:
  slides_dir = project_slides_dir(project_id)

  def slide_ok(name: str) -> bool:
    return _exists(slides_dir / name)

  if slide_id:
    png = slide_ok(f"{slide_id}.png")
    audio = slide_ok(f"{slide_id}-audio.mp3")
    audio_txt = slide_ok(f"{slide_id}-audio.txt")
    html = slide_ok(f"{slide_id}.html")
    sb = slide_ok(f"{slide_id}-storyboard.yml")
    mp4 = slide_ok(f"{slide_id}.mp4")
    srt = slide_ok(f"{slide_id}.srt")

    split_ok = png and audio and audio_txt
    convert_ok = html
    storyboard_ok = sb
    render_ok = mp4
    deliver_ok = mp4 and srt
    validate_ok = split_ok and convert_ok and storyboard_ok
    combine_ok = False
  else:
    # Project-level combine output.
    combine_ok = _exists((user_root() / project_id / "outputs" / "presentation-master.mp4"))
    split_ok = convert_ok = storyboard_ok = render_ok = validate_ok = deliver_ok = False

  def state(done: bool) -> str:
    return "completed" if done else "pending"

  return {
    "split": state(split_ok),
    "convert": state(convert_ok),
    "storyboard": state(storyboard_ok),
    "render": state(render_ok),
    "combine": state(combine_ok),
    "validate": state(validate_ok),
    "deliver": state(deliver_ok),
  }
