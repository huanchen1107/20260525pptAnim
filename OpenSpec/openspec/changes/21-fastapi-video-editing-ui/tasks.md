## 1. FastAPI Foundation

- [ ] 1.1 Create FastAPI app skeleton (`app/main.py` or equivalent)
- [ ] 1.2 Add health and basic metadata endpoints
- [ ] 1.3 Add config for workspace root, projects root, and script allowlist

## 2. Pipeline Execution APIs

- [ ] 2.1 Implement endpoint to run full pipeline with args (`project`, `slide`, `mode`, `renderer`)
- [ ] 2.2 Implement endpoint to run individual steps (split/convert/storyboard/render/combine/validate)
- [ ] 2.3 Capture and persist run status, exit code, and logs
- [ ] 2.4 Add run query endpoint by `run_id`

## 3. Storyboard Editing APIs

- [ ] 3.1 Implement read endpoint for `slide-N-storyboard.yml`
- [ ] 3.2 Implement write endpoint for manual YAML edits
- [ ] 3.3 Implement per-page idea text storage endpoint
- [ ] 3.4 Implement regenerate endpoint that uses idea text as storyboard input context

## 4. UI Controls

- [ ] 4.1 Build pipeline control panel (project/slide/mode/step controls)
- [ ] 4.2 Build per-page storyboard editor panel
- [ ] 4.3 Add text box for "storyboard development idea" on each page
- [ ] 4.4 Add run log panel with stage status

## 5. Integration With Existing Scripts

- [ ] 5.1 Add service wrapper for `run_pipeline.sh`
- [ ] 5.2 Add service wrapper for `generate_storyboard.sh`
- [ ] 5.3 Add service wrapper for `render_animation.sh`
- [ ] 5.4 Ensure script wrappers validate inputs and reject unsafe paths

## 6. Validation and Smoke Checks

- [ ] 6.1 Smoke test: run one slide through UI-triggered pipeline path
- [ ] 6.2 Smoke test: edit storyboard idea for one page and regenerate
- [ ] 6.3 Smoke test: save edited storyboard and render preview
- [ ] 6.4 Document known limitations and fallback CLI commands

## 7. Docs and Handoff

- [ ] 7.1 Add developer docs for API endpoints and local run instructions
- [ ] 7.2 Add user guide for storyboard editing workflow
- [ ] 7.3 Add troubleshooting section for pipeline errors in UI
