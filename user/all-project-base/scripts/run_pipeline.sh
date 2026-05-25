#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
PIPELINE_MODE="final"
SLIDE_FILTER=""
RENDERER="hyperframes"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="${2:-user/project-1}"; shift 2 ;;
    --slide) SLIDE_FILTER="${2:-}"; shift 2 ;;
    --renderer) RENDERER="${2:-hyperframes}"; shift 2 ;;
    --mode) PIPELINE_MODE="${2:-final}"; shift 2 ;;
    --mode=*) PIPELINE_MODE="${1#*=}"; shift ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

if [[ "$PIPELINE_MODE" == "auto" ]]; then
  PIPELINE_MODE="preview"
  if [[ -n "$SLIDE_FILTER" ]]; then
    echo "[auto] Running single-slide preview for ${PROJECT_ROOT} slide-${SLIDE_FILTER}"
  else
    echo "[auto] Running project preview for ${PROJECT_ROOT}"
  fi
fi

bash ./user/all-project-base/scripts/preflight_check.sh --project "$PROJECT_ROOT"
slide_args=()
if [[ -n "$SLIDE_FILTER" ]]; then
  slide_args=(--slide "$SLIDE_FILTER")
fi

bash ./user/all-project-base/scripts/convert_image_to_html.sh --project "$PROJECT_ROOT" "${slide_args[@]}"
bash ./user/all-project-base/scripts/generate_storyboard.sh --project "$PROJECT_ROOT" "${slide_args[@]}"
bash ./user/all-project-base/scripts/render_animation.sh --project "$PROJECT_ROOT" --renderer "$RENDERER" --mode "$PIPELINE_MODE" "${slide_args[@]}"

if [[ "$PIPELINE_MODE" != "preview" && -z "$SLIDE_FILTER" ]]; then
  bash ./user/all-project-base/scripts/combine_videos.sh --project "$PROJECT_ROOT"
fi

echo "Pipeline complete for $PROJECT_ROOT ($PIPELINE_MODE mode, renderer=$RENDERER)"
