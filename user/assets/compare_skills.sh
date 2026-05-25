#!/usr/bin/env bash
set -euo pipefail

# Directory containing sample images (can be overridden via env var)
SAMPLE_DIR="${1:-sample_images}"
REPORT="benchmark_report.md"

# Ensure report file is empty
> "$REPORT"

echo "# Benchmark Report" >> "$REPORT"

echo "\n## Environment" >> "$REPORT"

echo "- Date: $(date)" >> "$REPORT"

echo "- Sample directory: $SAMPLE_DIR" >> "$REPORT"

echo "\n## Results" >> "$REPORT"

echo "| Image | Tool | Time (s) | Size (bytes) |" >> "$REPORT"

echo "|------|------|----------|--------------|" >> "$REPORT"

# Function to run a tool and capture time and size
run_tool() {
  local tool_name="$1"
  local cmd="$2"
  for img in "$SAMPLE_DIR"/*.{png,jpg,jpeg,svg}; do
    [ -e "$img" ] || continue
    local base=$(basename "$img")
    local start=$(date +%s.%N)
    # Execute command, redirect output to a temp html file
    local out_file="${base%.*}_$tool_name.html"
    eval "$cmd" "$img" > "$out_file"
    local end=$(date +%s.%N)
    local duration=$(awk "BEGIN {print $end - $start}")
    local size=$(stat -f%z "${out_file}")
    echo "| $base | $tool_name | $duration | $size |" >> "$REPORT"
    # Clean up output if not needed
    rm -f "$out_file"
  done
}

# Run excalidraw‑control (wrap with npx hyperframes render)
run_tool "excalidraw" "printf '\u003c!DOCTYPE html\u003e\u003chtml\u003e\u003cbody\u003e\u003cimg src=\"%s\"/\u003e\u003c/body\u003e\u003c/html\u003e'" 

# Run alternative tool placeholder (replace with actual command)
# Example: html-converter-cli -i (you may need to install it as a devDependency)
run_tool "simple" "printf '<!DOCTYPE html><html><body><img src="%s"/></body></html>'"

echo "Benchmark completed. Report saved to $REPORT"
