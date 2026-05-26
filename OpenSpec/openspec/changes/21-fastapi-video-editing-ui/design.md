## Overview

Build a FastAPI application that wraps the existing pipeline scripts and exposes:

1. Project/slide controls
2. Step-by-step execution controls
3. Per-page storyboard editing and idea input
4. Run status/log visibility

The design must preserve existing script contracts and avoid breaking CLI workflows.

## Architecture

### Backend

- **FastAPI App**
  - REST endpoints for pipeline steps and status
  - storyboard read/write/regenerate endpoints
  - optional SSE/WebSocket stream for live logs
- **Pipeline Service Layer**
  - thin wrappers over existing shell entrypoints:
    - `run_pipeline.sh`
    - `generate_storyboard.sh`
    - `render_animation.sh`
  - executes commands with controlled args (`project`, `slide`, `mode`, `renderer`)
  - captures stdout/stderr and exit status
- **Storyboard Service**
  - loads `slide-N-storyboard.yml`
  - stores page idea text (sidecar file, e.g. `slide-N-storyboard-idea.txt` or project JSON)
  - applies idea text as override input for regeneration

### Frontend (Server-rendered or lightweight SPA)

- **Pipeline Control Panel**
  - project selector
  - slide selector (all or one)
  - run mode selector
  - per-step run buttons and "run full pipeline"
- **Storyboard Editor Panel**
  - page tabs/cards (`slide-1`, `slide-2`, ...)
  - text area: "How this page should develop"
  - storyboard YAML editor area
  - actions:
    - Save idea
    - Regenerate from idea
    - Save YAML
    - Preview render current page
- **Run Log Panel**
  - live command logs
  - success/failure badges per step

## API Surface (Initial)

- `GET /api/projects`
- `GET /api/projects/{project_id}/slides`
- `POST /api/pipeline/run` (full or selected step)
- `POST /api/pipeline/step/{step_name}/run`
- `GET /api/runs/{run_id}`
- `GET /api/storyboard/{project_id}/{slide_id}`
- `PUT /api/storyboard/{project_id}/{slide_id}` (manual YAML update)
- `PUT /api/storyboard/{project_id}/{slide_id}/idea` (save idea text)
- `POST /api/storyboard/{project_id}/{slide_id}/regenerate` (idea-aware)

## Data Model

- **RunRecord**
  - `run_id`, `project_id`, `slide_id?`, `step`, `status`, `started_at`, `ended_at`, `exit_code`, `log_path`
- **StoryboardIdea**
  - `project_id`, `slide_id`, `idea_text`, `updated_at`, `updated_by?`
- **StoryboardDoc**
  - `project_id`, `slide_id`, `yaml_content`, `updated_at`

## Storyboard Idea Flow

1. User writes page idea in the slide text box.
2. UI saves idea via `PUT /idea`.
3. User clicks regenerate.
4. Backend passes idea context into storyboard generation path.
5. Generated YAML is returned and shown for manual edits.
6. User saves YAML and triggers preview render.

## Safety and Operational Rules

- Keep all command execution in allowlisted script paths.
- Validate `project_id`/`slide_id` against expected naming patterns.
- Store logs per run for traceability.
- Do not block server workers on long jobs; use background tasks/queue model.

## Rollout Strategy

1. Phase 1: Read-only UI + run steps + log view.
2. Phase 2: Storyboard idea text box + regenerate API.
3. Phase 3: Full storyboard editor + page preview loop.
4. Phase 4: Hardening, auth (if needed), and CI checks.
