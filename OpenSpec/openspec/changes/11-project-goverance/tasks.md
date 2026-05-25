## 1. Governance Baseline

- [ ] 1.1 Define top-down governance rule in shared docs (`user/all-project-base/docs/`)
- [ ] 1.2 Define canonical per-project folder contract (`source`, flat `slides`, `outputs`, `docs`)
- [ ] 1.3 Define canonical slide artifact naming rules

## 2. Shared Ownership Enforcement

- [ ] 2.1 Ensure shell pipeline entrypoints live under `user/all-project-base/scripts/`
- [ ] 2.2 Ensure Python utilities live under `user/all-project-base/utils/`
- [ ] 2.3 Remove or deprecate project-local duplicates of shared logic

## 3. Multi-Project Execution Model

- [ ] 3.1 Document project-by-project execution flow for multiple source sets
- [ ] 3.2 Document required outputs and validation checkpoints per project
- [ ] 3.3 Define migration notes for legacy `slides/slide-N/` directory layouts

## 4. Documentation Sync

- [ ] 4.1 Update root workflow docs to point at shared scripts
- [ ] 4.2 Add canonical pipeline steps doc in `user/all-project-base/docs/`
- [ ] 4.3 Add project-local pointer docs that reference shared governance

## 5. Verification

- [ ] 5.1 Verify no stale references to deprecated project-local script paths remain
- [ ] 5.2 Verify governance docs are sufficient for onboarding a new `project-2`
