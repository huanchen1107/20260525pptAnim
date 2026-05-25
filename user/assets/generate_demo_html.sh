#!/usr/bin/env bash
set -euo pipefail

# Directory containing sample images (can be overridden via first argument)
SAMPLE_DIR="${1:-sample_images}"
# Output directory for generated HTML demo files
OUTPUT_DIR="demo_html"
mkdir -p "$OUTPUT_DIR"

# Function to run a tool and save HTML output
run_tool() {
  local tool_name="$1"
  for img in "${SAMPLE_DIR}"/*.{png,jpg,jpeg,svg}; do
    [ -e "$img" ] || continue
    local base=$(basename "$img")
    local out_file="${OUTPUT_DIR}/${base%.*}_${tool_name}.html"
    cat <<EOF > "$out_file"
<!DOCTYPE html>
<html><body><img src="$img"/></body></html>
EOF
    echo "Generated $out_file"
  done
}

# Run excalidraw‑control placeholder (simple HTML wrapper)
run_tool "excalidraw" "<!DOCTYPE html><html><body><img src=\"%s\"/></body></html>"

# Run simple alternative tool (same simple HTML wrapper)
run_tool "simple" "<!DOCTYPE html><html><body><img src=\"%s\"/></body></html>"
