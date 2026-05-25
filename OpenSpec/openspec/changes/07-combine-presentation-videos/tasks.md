## 1. Setup & Scripts

- [x] 1.1 Create `user/assets/combine_videos.sh` bash script.
- [x] 1.2 Implement the logic to dynamically discover all `slide-*-animation.mp4` files, sort them numerically, and write them to an `inputs.txt` file for `ffmpeg`.
- [x] 1.3 Implement the `ffmpeg concat` command in the script to generate `presentation-master.mp4`.
- [x] 1.4 Make the script executable.

## 2. Integration Tests

- [x] 2.1 Create integration test `tests/combine_videos.test.sh` that asserts `presentation-master.mp4` is created and is not empty.
- [x] 2.2 Make the test script executable.

## 3. CI/CD Integration

- [x] 3.1 Update `.github/workflows/render_animation.yml` to trigger the `combine_videos.sh` script after the individual animations have been successfully rendered.
- [x] 3.2 Configure the workflow to upload `user/assets/presentation-master.mp4` as a GitHub Actions artifact.

## 4. Verification

- [x] 4.1 Run `tests/combine_videos.test.sh` locally to verify the master video generation successfully stitches all slide animations together.
- [x] 4.2 Add `OpenSpec/changes/07-combine-presentation-videos/README.md` to document the new script.
