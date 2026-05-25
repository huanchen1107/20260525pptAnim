# Proposal for Change 01-system-check

**Goal:** Ensure the development environment, OpenSpec tooling, HyperFrame framework, and Excalidraw-related skill suites are correctly installed, configured, and functional.

**Background:** The project depends on several custom skill packages (`hyperframes-best-practices`, `excalidraw-control`) and the OpenSpec CLI. Any misconfiguration can cause downstream failures across all subsequent changes.

**Scope:**
- Verify that the `hyperframes-best-practices` and `excalidraw-control` skill directories exist and each contains a valid `SKILL.md` definition.
- Confirm the OpenSpec CLI builds without errors (`npm install && npm run build` if applicable) and reports the expected version.
- Run `openspec validate system-check` to validate the OpenSpec schema for this change.
- Check that the repository’s Git configuration matches the remote on GitHub.

**Success Criteria:**
- All skill directories are present and contain the required metadata.
- `openspec --version` returns the current version.
- `openspec validate system-check` exits with a success message and no lint errors.
- No missing dependencies or configuration mismatches are reported.
