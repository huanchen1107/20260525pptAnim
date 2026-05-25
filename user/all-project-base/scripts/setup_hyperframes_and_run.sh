#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
SLIDE="1"
MODE="auto"
RENDERER="hyperframes"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE="$2"; shift 2 ;;
    --mode) MODE="$2"; shift 2 ;;
    --renderer) RENDERER="$2"; shift 2 ;;
    *) shift ;;
  esac
done

echo "[1/3] Install hyperframes@0.6.40"
npm install --save-dev hyperframes@0.6.40

echo "[2/3] Verify local hyperframes version"
npx hyperframes --version

echo "[3/3] Run pipeline"
bash user/all-project-base/scripts/run_pipeline.sh --project "$PROJECT_ROOT" --slide "$SLIDE" --mode "$MODE" --renderer "$RENDERER"
