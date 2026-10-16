#!/usr/bin/env bash
set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_BIN="${HYPERFRAMES_PYTHON:-$SKILL_ROOT/runtime/.venv/bin/python}"
VOICE_NAME="${PIPER_VOICE:-fa_IR-amir-medium}"
VOICE_DIR="${PIPER_DATA_DIR:-$HOME/.cache/video-edit/piper}"

usage() {
  printf 'Usage: %s OUTPUT.wav "Persian text"\n' "$0" >&2
}

if [ "$#" -ne 2 ]; then
  usage
  exit 2
fi

OUTPUT_FILE="$1"
TEXT="$2"

if [ ! -x "$PYTHON_BIN" ]; then
  printf 'Skill Python environment not found: %s\nRun scripts/install-tools.sh first.\n' "$PYTHON_BIN" >&2
  exit 1
fi

if [ -e "$OUTPUT_FILE" ]; then
  printf 'Output already exists; choose a new path: %s\n' "$OUTPUT_FILE" >&2
  exit 1
fi

mkdir -p "$VOICE_DIR" "$(dirname "$OUTPUT_FILE")"

if [ ! -s "$VOICE_DIR/$VOICE_NAME.onnx" ] || [ ! -s "$VOICE_DIR/$VOICE_NAME.onnx.json" ]; then
  "$PYTHON_BIN" -m piper.download_voices --download-dir "$VOICE_DIR" "$VOICE_NAME"
fi

"$PYTHON_BIN" -m piper \
  --data-dir "$VOICE_DIR" \
  --model "$VOICE_NAME" \
  --output_file "$OUTPUT_FILE" \
  -- "$TEXT"

printf 'Created Persian voice draft: %s\n' "$OUTPUT_FILE"
