import json
import sys

def render_html(layout_file, output_file, duration_frames=150):
    with open(layout_file, 'r') as f:
        data = json.load(f)

    canvas = data.get("canvas", {})
    width = canvas.get("width", 1920)
    height = canvas.get("height", 1080)
    bg_color = canvas.get("bg_color", "#ffffff")
    bg_size = canvas.get("bg_size", "auto")

    html = f"""
    <style>
      .scene-container {{
          position: absolute;
          inset: 0;
          width: {width}px;
          height: {height}px;
          background: {bg_color} !important;
          background-image: 
              linear-gradient(to right, #d9d9d0 1px, transparent 1px),
              linear-gradient(to bottom, #d9d9d0 1px, transparent 1px) !important;
          background-size: {bg_size} !important;
          overflow: hidden;
          z-index: 50 !important;
      }}
      .scene-object {{
          position: absolute;
          box-sizing: border-box;
      }}
    </style>
    <div class="scene-container" id="excalidrawStage" data-hf-scene="excalidrawStage" data-hf-start="0" data-hf-end="{duration_frames}">
    """

    for obj in data.get("objects", []):
        obj_id = obj.get("id", "")
        obj_type = obj.get("type", "box")
        x = obj.get("x", 0)
        y = obj.get("y", 0)
        w = obj.get("w", 0)
        h = obj.get("h", 0)
        z_index = obj.get("zIndex", 1)
        style = obj.get("style", {})
        text = obj.get("text", "")

        style_str = f"left: {x}px; top: {y}px; z-index: {z_index}; "
        if w is not None and w != "auto":
            style_str += f"width: {w}px; "
        if h is not None and h != "auto":
            style_str += f"height: {h}px; "

        for k, v in style.items():
            # Convert camelCase to kebab-case
            kebab_k = "".join(["-" + c.lower() if c.isupper() else c for c in k])
            style_str += f"{kebab_k}: {v}; "

        html += f'      <div id="{obj_id}" class="scene-object {obj_id}" style="{style_str}">{text}</div>\n'

    # Add the GSAP script for animations 
    # Animates elements based on which IDs are present in the layout JSON
    html += """
    </div>
    <script>
      window.applyCustomAnimation = function (tl, durationSecs) {
        // Animate main container/frame if present
        if (document.getElementById("window-frame")) {
          tl.from("#window-frame", {scale: 0.94, opacity: 0, duration: 0.6}, 0.3);
        }
        if (document.getElementById("window-inner-border")) {
          tl.from("#window-inner-border", {opacity: 0, duration: 0.4}, 0.6);
        }
        if (document.getElementById("window-divider")) {
          tl.from("#window-divider", {scaleX: 0, transformOrigin: "left center", duration: 0.4}, 0.8);
        }
        if (document.getElementById("window-title")) {
          tl.from("#window-title", {x: -50, opacity: 0, duration: 0.4}, 0.9);
        }
        if (document.getElementById("window-controls")) {
          tl.from("#window-controls", {opacity: 0, duration: 0.3}, 1.1);
        }

        // Animate titles
        if (document.getElementById("title")) {
          tl.from("#title", {y: 30, opacity: 0, duration: 0.5}, 1.2);
        }
        if (document.getElementById("subtitle")) {
          tl.from("#subtitle", {y: 20, opacity: 0, duration: 0.5}, 1.4);
        }

        // Animate side notes and accents
        if (document.getElementById("sticky-accent")) {
          tl.from("#sticky-accent", {scale: 0, rotation: 0, opacity: 0, duration: 0.4}, 1.6);
        }
        if (document.getElementById("note")) {
          tl.from("#note", {x: -40, opacity: 0, duration: 0.5}, 1.8);
        }
        if (document.getElementById("status")) {
          tl.from("#status", {opacity: 0, duration: 0.4}, 2.0);
        }

        // Animate progress box and fill
        if (document.getElementById("progress-box")) {
          tl.from("#progress-box", {opacity: 0, duration: 0.4}, 2.1);
        }
        if (document.getElementById("progress-fill")) {
          // We animate it to full width over the timeline duration
          tl.fromTo("#progress-fill", 
            { scaleX: 0, transformOrigin: "left center" },
            { scaleX: 1, duration: durationSecs, ease: "none" }, 
            0
          );
        }
      };
    </script>
    """

    with open(output_file, 'w') as f:
        f.write(html)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python render_html_from_layout.py <layout_json> <output_html> [duration_frames]")
        sys.exit(1)
    
    duration = 150
    if len(sys.argv) >= 4:
        try:
            duration = int(sys.argv[3])
        except ValueError:
            pass
            
    render_html(sys.argv[1], sys.argv[2], duration)
