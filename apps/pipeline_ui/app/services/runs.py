from __future__ import annotations

import json
import os
import subprocess
import time
import uuid
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Dict, List, Literal, Optional

from .workspace import workspace_root


RunStatus = Literal["queued", "running", "succeeded", "failed"]


@dataclass
class RunRecord:
  run_id: str
  project_id: str
  slide: Optional[str]
  step: str
  status: RunStatus
  started_at: Optional[float]
  ended_at: Optional[float]
  exit_code: Optional[int]
  log_path: str
  command: List[str]


def runs_root() -> Path:
  root = workspace_root() / ".pipeline_ui" / "runs"
  root.mkdir(parents=True, exist_ok=True)
  return root


def _write_json(path: Path, payload: dict) -> None:
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")


def _read_json(path: Path) -> dict:
  return json.loads(path.read_text(encoding="utf-8"))


def load_run(run_id: str) -> RunRecord:
  rec_path = runs_root() / run_id / "run.json"
  data = _read_json(rec_path)
  return RunRecord(**data)


def tail_log(run_id: str, max_bytes: int = 200_000) -> str:
  rec = load_run(run_id)
  path = Path(rec.log_path)
  if not path.exists():
    return ""
  size = path.stat().st_size
  with path.open("rb") as f:
    if size > max_bytes:
      f.seek(size - max_bytes)
    return f.read().decode("utf-8", errors="replace")


def create_and_run(
  *,
  project_id: str,
  slide: Optional[str],
  step: str,
  command: List[str],
  env: Optional[Dict[str, str]] = None,
) -> RunRecord:
  run_id = uuid.uuid4().hex
  run_dir = runs_root() / run_id
  run_dir.mkdir(parents=True, exist_ok=True)
  log_path = run_dir / "run.log"

  record = RunRecord(
    run_id=run_id,
    project_id=project_id,
    slide=slide,
    step=step,
    status="running",
    started_at=time.time(),
    ended_at=None,
    exit_code=None,
    log_path=str(log_path),
    command=command,
  )
  _write_json(run_dir / "run.json", asdict(record))

  merged_env = os.environ.copy()
  if env:
    merged_env.update(env)

  with log_path.open("wb") as log_fp:
    proc = subprocess.run(
      command,
      cwd=str(workspace_root()),
      env=merged_env,
      stdout=log_fp,
      stderr=subprocess.STDOUT,
      check=False,
    )

  record.exit_code = proc.returncode
  record.ended_at = time.time()
  record.status = "succeeded" if proc.returncode == 0 else "failed"
  _write_json(run_dir / "run.json", asdict(record))
  return record
