#!/usr/bin/env bash
set -euo pipefail

INPUT_PATH="user/assets/slides"
RENDER_MODE="final"
PREVIEW_WIDTH=960
PREVIEW_HEIGHT=540

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      RENDER_MODE="${2:-final}"
      shift 2
      ;;
    --mode=*)
      RENDER_MODE="${1#*=}"
      shift
      ;;
    *)
      INPUT_PATH="$1"
      shift
      ;;
  esac
done

audio_is_decodable() {
  local audio_file="$1"
  ffmpeg -v error -i "$audio_file" -f null - >/dev/null 2>&1
}

if [[ -d "$INPUT_PATH" && "$(basename "$INPUT_PATH")" == slide-* ]]; then
  slide_dirs=("$INPUT_PATH")
else
  slide_dirs=("$INPUT_PATH"/slide-*/)
fi

for slide_dir in "${slide_dirs[@]}"; do
  slide_dir="${slide_dir%/}"
  slide_name=$(basename "$slide_dir")
  slide_num="${slide_name#slide-}"
  source_image="$(find "$slide_dir" -maxdepth 1 -type f \( -iname 'slide-*.png' -o -iname 'slide-*.jpg' -o -iname 'slide-*.jpeg' -o -iname 'slide-*.webp' \) | sort | head -n 1 || true)"
  if [[ -n "${source_image:-}" ]]; then
    artifact_base="$(basename "$source_image")"
    artifact_base="${artifact_base%.*}"
  else
    artifact_base="$slide_name"
  fi

  canonical_audio="${slide_dir}/${artifact_base}.mp3"
  legacy_audio="${slide_dir}/audio-${slide_num}.mp3"
  audio_file="$canonical_audio"
  if [[ ! -f "$audio_file" ]]; then
    audio_file="$legacy_audio"
  fi

  output_mp4="${slide_dir}/${slide_name}.mp4"
  preview_dir="${slide_dir}/preview"
  preview_output_mp4="${preview_dir}/${artifact_base}.preview.mp4"
  scene_dir="${slide_dir}/scene"
  render_dir="${slide_dir}/.render-workspace"
  copied_root_files=()
  copied_root_dirs=()

  if [[ ! -f "${scene_dir}/index.html" ]]; then
    echo "Missing scene for $slide_name, skipping"
    continue
  fi

  rm -rf "$render_dir"
  mkdir -p "$render_dir"

  cp "${scene_dir}/index.html" "${render_dir}/index.html"
  copied_root_files+=("${render_dir}/index.html")
  if [[ -f "${scene_dir}/style.css" ]]; then
    cp "${scene_dir}/style.css" "${render_dir}/style.css"
    copied_root_files+=("${render_dir}/style.css")
  fi
  if [[ -f "${scene_dir}/animation.js" ]]; then
    cp "${scene_dir}/animation.js" "${render_dir}/animation.js"
    copied_root_files+=("${render_dir}/animation.js")
  fi
  if [[ -d "${scene_dir}/assets" ]]; then
    cp -R "${scene_dir}/assets" "${render_dir}/assets"
    copied_root_dirs+=("${render_dir}/assets")
  fi

  render_tmp="${render_dir}/${artifact_base}.render.tmp.mp4"
  audio_mux_tmp="${render_dir}/${artifact_base}.audio.tmp.mp4"

  npx hyperframes render "$render_dir" -c index.html -o "$render_tmp"

  if [[ -f "$audio_file" ]] && audio_is_decodable "$audio_file"; then
    ffmpeg -y -i "$render_tmp" -i "$audio_file" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 192k -shortest "$audio_mux_tmp" -loglevel error
    rm -f "$render_tmp"
  else
    if [[ -f "$audio_file" ]]; then
      echo "Replacing invalid or undecodable audio for $slide_name with silence: $audio_file"
      ffmpeg -y -i "$render_tmp" -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=48000" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 128k -shortest "$audio_mux_tmp" -loglevel error
      rm -f "$render_tmp"
    else
      mv "$render_tmp" "$audio_mux_tmp"
    fi
  fi

  if [[ "$RENDER_MODE" == "preview" ]]; then
    mkdir -p "$preview_dir"
    ffmpeg -y -i "$audio_mux_tmp" -vf "scale=${PREVIEW_WIDTH}:${PREVIEW_HEIGHT}" -map 0:v:0 -map 0:a? -c:v libx264 -preset veryfast -crf 24 -c:a aac -b:a 128k -shortest "$preview_output_mp4" -loglevel error
    rm -f "$audio_mux_tmp"
    echo "Rendered preview animation $preview_output_mp4"
  else
    mv "$audio_mux_tmp" "$output_mp4"
    echo "Rendered animation $output_mp4"
  fi

  for copied_file in "${copied_root_files[@]}"; do
    rm -f "$copied_file"
  done
  for copied_dir in "${copied_root_dirs[@]}"; do
    rm -rf "$copied_dir"
  done
  rm -rf "$render_dir"

done
