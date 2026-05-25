#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
SLIDE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [[ -z "$SLIDE" ]]; then
  echo "Usage: $0 --project user/project-1 --slide <N>" >&2
  exit 1
fi

bash user/all-project-base/scripts/split_pages.sh --project "$PROJECT_ROOT" --slide "$SLIDE"
bash user/all-project-base/scripts/convert_image_to_html.sh --project "$PROJECT_ROOT" --slide "$SLIDE"
bash user/all-project-base/scripts/generate_storyboard.sh --project "$PROJECT_ROOT" --slide "$SLIDE" --no-prompt
