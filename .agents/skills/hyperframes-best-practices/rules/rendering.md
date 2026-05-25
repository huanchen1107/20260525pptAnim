# Rendering & CLI Reference in HyperFrames

The HyperFrames CLI provides developer tools to preview compositions interactively and render production-ready MP4s locally.

## Development Preview

Launch the local dev server and hot-reloading browser studio to preview your compositions:

```bash
npx hyperframes preview
```

### Options:
* `--port <number>` - Specify a custom port (default is `8080`).
* `--scale <number>` - Adjust browser preview scaling (e.g., `0.5` for half size).

---

## Production Render

Render the entire HTML-native timeline into a highly optimized, high-fidelity MP4 file:

```bash
npx hyperframes render
```

### Common Rendering Command Examples:

* **Basic 1080p rendering (30fps):**
  ```bash
  npx hyperframes render --width=1920 --height=1080 --fps=30 --output=output.mp4
  ```

* **High-FPS 4K rendering (60fps) for premium animations:**
  ```bash
  npx hyperframes render --width=3840 --height=2160 --fps=60 --output=ultra_hd.mp4
  ```

* **Vertical aspect ratio (9:16) for social/mobile content:**
  ```bash
  npx hyperframes render --width=1080 --height=1920 --fps=30 --output=vertical_reel.mp4
  ```

* **Scale down quality for quick preview renders:**
  ```bash
  npx hyperframes render --scale=0.5 --output=fast_check.mp4
  ```

---

## Command Flags Reference

| Flag | Type | Description |
|---|---|---|
| `-w, --width` | `number` | Width of the output canvas in pixels (default: `1920`). |
| `-h, --height` | `number` | Height of the output canvas in pixels (default: `1080`). |
| `-f, --fps` | `number` | Output framerate (default: `30`). |
| `-o, --output` | `string` | Output file path (default: `dist/output.mp4`). |
| `-s, --scale` | `number` | Scaling multiplier for quick renders (e.g., `0.25` or `0.5`). |
| `--quality` | `string` | Output compression factor: `low` \| `medium` \| `high` (default: `medium`). |
| `--headless` | `boolean`| Run Puppeteer browser headlessly (default: `true`). |

---

## Quick One-Frame Render Check (Sanity Testing)

To verify light layers, positions, or text overflows at a specific point on the timeline without rendering the entire file, export a single still frame:

```bash
npx hyperframes still --frame=90 --output=still_frame.png
```

* `--frame` is zero-based. At `30fps`, `--frame=90` represents the exact 3-second mark.
