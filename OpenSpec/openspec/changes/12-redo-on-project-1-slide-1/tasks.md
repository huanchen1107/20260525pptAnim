## 1. Prepare Redo Scope

- [ ] 1.1 Identify all existing `slide-1` artifacts in `user/project-1/slides/`
- [ ] 1.2 Classify canonical files vs legacy/duplicate files
- [ ] 1.3 Define exact keep/remove list for `slide-1`

## 2. Regenerate Slide-1

- [ ] 2.1 Re-run split stage for `slide-1` inputs only
- [ ] 2.2 Re-run storyboard generation for `slide-1`
- [ ] 2.3 Re-run HTML/layout generation for `slide-1`
- [ ] 2.4 Re-run preview/final rendering for `slide-1`

## 3. Normalize Outputs

- [ ] 3.1 Enforce canonical naming (`slide-1.*`, `slide-1-audio.*`, etc.)
- [ ] 3.2 Remove legacy or duplicate `slide-1` files
- [ ] 3.3 Ensure flat structure (no per-slide subfolders)

## 4. Verify and Document

- [ ] 4.1 Verify `slide-1` can be combined by shared `combine_videos.sh`
- [ ] 4.2 Record before/after artifact inventory for `slide-1`
- [ ] 4.3 Update docs if script behavior changes were needed
