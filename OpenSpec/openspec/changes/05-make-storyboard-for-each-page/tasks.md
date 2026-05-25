# Tasks for `05-make-storyboard-for-each-page`

## Goal
Create a storyboard HTML file for each slide that defines object visibility, easing, and zoom/pan based on the slide caption semantics.

## Tasks
- [x] **Create storyboard generation script** `generate_storyboard.sh` in `user/assets/` (already added).
- [x] **Make script executable** (`chmod +x generate_storyboard.sh`).
- [x] **Add template and config** (template.html, config.json) if needed (currently inlined in script).
- [x] **Write README** describing usage, required caption format, and CI behavior.
- [x] **Add CI workflow** `.github/workflows/storyboard.yml` to run script after conversion.
- [x] **Create integration test** `tests/storyboard.test.sh` to verify storyboard files are generated and contain expected attributes.
- [x] **Run verification**: execute `./user/assets/generate_storyboard.sh` and inspect outputs.
- [x] **Commit changes** with a clear commit message.
