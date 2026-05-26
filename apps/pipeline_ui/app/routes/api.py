from __future__ import annotations

from fastapi import APIRouter
from fastapi.responses import FileResponse
from fastapi.responses import StreamingResponse
from typing import Optional
import shlex
import io
import zipfile
import re
from pathlib import Path

from ..services.workspace import list_projects, list_slides, read_slide_caption
from ..services.pipeline import run_pipeline, read_storyboard, run_step
from ..services.runs import load_run, tail_log
from ..services.storyboard_ideas import read_idea, write_idea, ensure_default_idea
from ..services.runs import create_and_run
from ..services.workspace import user_root, project_slides_dir
from ..services.status import pipeline_status
from ..services.timeline import get_timeline, save_timeline


router = APIRouter()


def _parse_page_range(start: Optional[int], end: Optional[int]) -> tuple[Optional[int], Optional[int]]:
  if start is None and end is None:
    return None, None
  s = 1 if start is None else max(1, int(start))
  e = s if end is None else max(s, int(end))
  return s, e


def _slide_num(path_name: str) -> Optional[int]:
  m = re.match(r"^slide-([0-9]+)\.", path_name)
  if not m:
    return None
  return int(m.group(1))


def _parse_storyboard_objects(storyboard: str) -> list[dict]:
  objs: list[dict] = []
  in_objects = False
  current: Optional[dict] = None
  for raw in storyboard.splitlines():
    line = raw.strip()
    if not in_objects:
      if line == "objects:":
        in_objects = True
      continue
    if not line:
      continue
    if line.startswith("- id:"):
      if current and current.get("id"):
        objs.append(current)
      current = {"id": line.replace("- id:", "", 1).strip(), "at": "0.00", "action": "fade_in", "duration": "0.80", "intent": "manual"}
      continue
    if current is None:
      continue
    if line.startswith("at:"):
      current["at"] = line.replace("at:", "", 1).strip()
    elif line.startswith("action:"):
      current["action"] = line.replace("action:", "", 1).strip()
    elif line.startswith("duration:"):
      current["duration"] = line.replace("duration:", "", 1).strip()
    elif line.startswith("intent:"):
      current["intent"] = line.replace("intent:", "", 1).strip()
  if current and current.get("id"):
    objs.append(current)
  return objs


def _render_storyboard_objects_yaml(objects: list[dict]) -> str:
  lines: list[str] = ["objects:"]
  for item in objects:
    obj_id = str(item.get("id") or "").strip()
    if not obj_id:
      continue
    at = str(item.get("at") or "0.00").strip()
    action = str(item.get("action") or "fade_in").strip()
    duration = str(item.get("duration") or "0.80").strip()
    intent = str(item.get("intent") or "manual").strip()
    lines.append(f"  - id: {obj_id}")
    lines.append(f"    at: {at}")
    lines.append(f"    action: {action}")
    lines.append(f"    duration: {duration}")
    lines.append(f"    intent: {intent}")
  return "\n".join(lines).rstrip() + "\n"


def _storyboard_path(project_id: str, slide_id: str) -> Path:
  return project_slides_dir(project_id) / f"{slide_id}-storyboard.yml"


def _html_path(project_id: str, slide_id: str) -> Path:
  return project_slides_dir(project_id) / f"{slide_id}.html"


def _humanize_object_name(obj_id: str) -> str:
  explicit = {
    "main_image": "Main Image",
    "title_center": "Center Title",
    "pass_text": "Pass Marker Text",
    "progress_fill": "Progress Fill Bar",
    "subtitle": "Subtitle",
    "title": "Title",
  }
  if obj_id in explicit:
    return explicit[obj_id]
  text = obj_id.replace("-", " ").replace("_", " ").strip()
  return " ".join([w.capitalize() for w in text.split()]) if text else obj_id


@router.get("/projects")
def api_projects() -> dict:
  return {"projects": list_projects()}


@router.get("/projects/{project_id}/slides")
def api_project_slides(project_id: str) -> dict:
  return {"slides": list_slides(project_id)}


@router.post("/pipeline/run")
def api_run_pipeline(payload: dict) -> dict:
  project_id = str(payload.get("project_id") or "")
  slide = payload.get("slide")
  renderer = str(payload.get("renderer") or "hyperframes")
  mode = str(payload.get("mode") or "final")
  rec = run_pipeline(project_id=project_id, slide=slide, renderer=renderer, mode=mode)
  return {"run": rec.__dict__}


@router.post("/pipeline/step/{step_name}")
def api_run_step(step_name: str, payload: dict) -> dict:
  project_id = str(payload.get("project_id") or "")
  slide = payload.get("slide")
  mode = str(payload.get("mode") or "final")
  renderer = str(payload.get("renderer") or "hyperframes")
  source_mode = str(payload.get("source_mode") or "tsx")
  rec = run_step(project_id=project_id, step=step_name, slide=slide, mode=mode, renderer=renderer, source_mode=source_mode)
  return {"run": rec.__dict__}


@router.get("/pipeline/status")
def api_pipeline_status(project_id: str, slide: Optional[str] = None) -> dict:
  return {"project_id": project_id, "slide": slide, "status": pipeline_status(project_id, slide)}


@router.get("/runs/{run_id}")
def api_get_run(run_id: str) -> dict:
  rec = load_run(run_id)
  return {"run": rec.__dict__, "log": tail_log(run_id)}


@router.get("/storyboard/{project_id}/{slide_id}")
def api_get_storyboard(project_id: str, slide_id: str) -> dict:
  return {"slide_id": slide_id, "storyboard": read_storyboard(project_id, slide_id)}


@router.get("/storyboard/{project_id}/{slide_id}/objects")
def api_get_storyboard_objects(project_id: str, slide_id: str) -> dict:
  raw = read_storyboard(project_id, slide_id)
  return {"slide_id": slide_id, "objects": _parse_storyboard_objects(raw)}


@router.get("/storyboard/{project_id}/{slide_id}/object-catalog")
def api_get_storyboard_object_catalog(project_id: str, slide_id: str) -> dict:
  html = _html_path(project_id, slide_id)
  ids: list[str] = []
  if html.exists():
    raw = html.read_text(encoding="utf-8", errors="replace")
    ids = re.findall(r'\bid="([^"]+)"', raw)
    ids = list(dict.fromkeys(ids))
  catalog = [{"id": obj_id, "name": _humanize_object_name(obj_id)} for obj_id in ids]
  return {"slide_id": slide_id, "objects": catalog}


@router.put("/storyboard/{project_id}/{slide_id}/objects")
def api_put_storyboard_objects(project_id: str, slide_id: str, payload: dict) -> dict:
  objects = payload.get("objects") or []
  if not isinstance(objects, list):
    return {"error": "objects must be list"}
  path = _storyboard_path(project_id, slide_id)
  if not path.exists():
    return {"error": "storyboard not found"}
  raw = path.read_text(encoding="utf-8", errors="replace")
  replacement = _render_storyboard_objects_yaml(objects)
  if "\nobjects:\n" in raw:
    updated = re.sub(r"\nobjects:\n[\s\S]*$", "\n" + replacement, raw)
  elif raw.startswith("objects:\n"):
    updated = replacement
  else:
    sep = "" if raw.endswith("\n") else "\n"
    updated = raw + sep + replacement
  path.write_text(updated, encoding="utf-8")
  return {"slide_id": slide_id, "objects": _parse_storyboard_objects(updated)}


@router.get("/storyboard/{project_id}/{slide_id}/idea")
def api_get_storyboard_idea(project_id: str, slide_id: str) -> dict:
  # Ensure defaults exist so the UI starts with a designed baseline.
  ensure_default_idea(project_id, slide_id)
  return {"slide_id": slide_id, "idea": read_idea(project_id, slide_id)}


@router.put("/storyboard/{project_id}/{slide_id}/idea")
def api_put_storyboard_idea(project_id: str, slide_id: str, payload: dict) -> dict:
  idea = str(payload.get("idea") or "")
  write_idea(project_id, slide_id, idea)
  return {"slide_id": slide_id, "idea": idea}

@router.get("/thumb/{project_id}/{slide_id}")
def api_get_slide_thumb(project_id: str, slide_id: str):
  # Serve slide PNG as thumbnail for the UI.
  png = project_slides_dir(project_id) / f"{slide_id}.png"
  if not png.exists():
    return {"error": "missing thumbnail"}
  return FileResponse(str(png), media_type="image/png")


@router.get("/caption/{project_id}/{slide_id}")
def api_get_slide_caption(project_id: str, slide_id: str) -> dict:
  return {"slide_id": slide_id, "caption": read_slide_caption(project_id, slide_id)}


@router.get("/result/{project_id}/{slide_id}")
def api_get_slide_result(project_id: str, slide_id: str):
  mp4 = project_slides_dir(project_id) / f"{slide_id}.mp4"
  if not mp4.exists():
    return {"error": "missing result"}
  return FileResponse(str(mp4), media_type="video/mp4")


@router.get("/srt/{project_id}/{slide_id}")
def api_get_slide_srt(project_id: str, slide_id: str):
  srt = project_slides_dir(project_id) / f"{slide_id}.srt"
  if not srt.exists():
    return {"error": "missing srt"}
  return FileResponse(str(srt), media_type="text/plain; charset=utf-8", filename=f"{slide_id}.srt")


@router.get("/source-pdf/{project_id}")
def api_get_source_pdf(project_id: str, start: Optional[int] = None, end: Optional[int] = None):
  source_dir = user_root() / project_id / "source"
  if not source_dir.exists():
    return {"error": "missing source directory"}
  pdfs = sorted(source_dir.glob("*.pdf"))
  if not pdfs:
    pdfs = sorted(source_dir.glob("*.PDF"))
  if not pdfs:
    return {"error": "missing source pdf"}
  pdf = pdfs[0]
  s, e = _parse_page_range(start, end)
  if s is not None and e is not None:
    # Optional page-range extraction if pypdf is available; fallback to full pdf otherwise.
    try:
      from pypdf import PdfReader, PdfWriter  # type: ignore
      reader = PdfReader(str(pdf))
      writer = PdfWriter()
      total = len(reader.pages)
      ps = max(1, min(total, s))
      pe = max(ps, min(total, e))
      for i in range(ps - 1, pe):
        writer.add_page(reader.pages[i])
      buf = io.BytesIO()
      writer.write(buf)
      buf.seek(0)
      fn = f"{pdf.stem}-p{ps}-{pe}.pdf"
      headers = {"Content-Disposition": f'attachment; filename="{fn}"'}
      return StreamingResponse(buf, media_type="application/pdf", headers=headers)
    except Exception:
      pass
  return FileResponse(str(pdf), media_type="application/pdf", filename=pdf.name)


@router.get("/deliverables/{project_id}/bundle")
def api_get_deliverables_bundle(project_id: str, kind: str = "mp4", start: Optional[int] = None, end: Optional[int] = None):
  slides_dir = project_slides_dir(project_id)
  if kind not in ("mp4", "srt"):
    return {"error": "kind must be mp4 or srt"}
  ext = kind
  pattern = f"slide-*.{ext}"
  files = sorted(slides_dir.glob(pattern))
  s, e = _parse_page_range(start, end)
  if s is not None and e is not None:
    files = [f for f in files if (_slide_num(f.name) is not None and s <= int(_slide_num(f.name)) <= e)]

  # Fallback: if no full-set files yet, try sample slide-1 asset.
  if not files:
    sample = slides_dir / f"slide-1.{ext}"
    if sample.exists():
      files = [sample]
    else:
      return {"error": f"missing {ext} deliverables"}

  buf = io.BytesIO()
  with zipfile.ZipFile(buf, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    for f in files:
      zf.write(f, arcname=f.name)
  buf.seek(0)
  filename = f"{project_id}-{kind}-deliverables.zip"
  headers = {"Content-Disposition": f'attachment; filename="{filename}"'}
  return StreamingResponse(buf, media_type="application/zip", headers=headers)


@router.post("/storyboard/{project_id}/{slide_id}/regenerate")
def api_regenerate_storyboard(project_id: str, slide_id: str) -> dict:
  project_root = str(user_root() / project_id)
  cmd = ["bash", "user/all-project-base/scripts/generate_storyboard.sh", "--project", project_root, "--slide", slide_id.replace("slide-", ""), "--no-prompt"]
  rec = create_and_run(project_id=project_id, slide=slide_id, step="generate_storyboard", command=cmd)
  return {"run": rec.__dict__}


@router.post("/storyboard/{project_id}/{slide_id}/regenerate-and-run")
def api_regenerate_and_run_storyboard(project_id: str, slide_id: str, payload: dict) -> dict:
  project_root = str(user_root() / project_id)
  slide_num = slide_id.replace("slide-", "")
  mode = str(payload.get("mode") or "final")
  renderer = str(payload.get("renderer") or "hyperframes")
  command = " && ".join([
    "bash user/all-project-base/scripts/generate_storyboard.sh "
    f"--project {shlex.quote(project_root)} --slide {shlex.quote(slide_num)} --no-prompt",
    "bash user/all-project-base/scripts/run_pipeline.sh "
    f"--project {shlex.quote(project_root)} --renderer {shlex.quote(renderer)} --mode {shlex.quote(mode)} --slide {shlex.quote(slide_num)}",
  ])
  rec = create_and_run(
    project_id=project_id,
    slide=slide_id,
    step="regen_storyboard_and_run_pipeline",
    command=["bash", "-lc", command],
  )
  return {"run": rec.__dict__}


@router.get("/timeline/{project_id}")
def api_get_timeline(project_id: str) -> dict:
  return {"project_id": project_id, "timeline": get_timeline(project_id)}


@router.put("/timeline/{project_id}")
def api_put_timeline(project_id: str, payload: dict) -> dict:
  timeline = payload.get("timeline") or []
  if not isinstance(timeline, list):
    raise ValueError("timeline must be list")
  save_timeline(project_id, timeline)
  return {"project_id": project_id, "timeline": timeline}
