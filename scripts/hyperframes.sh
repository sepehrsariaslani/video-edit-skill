#!/usr/bin/env bash
set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HYPERFRAMES_BIN="$SKILL_ROOT/runtime/node_modules/.bin/hyperframes"

if [ ! -x "$HYPERFRAMES_BIN" ]; then
  printf 'HyperFrames is not installed. Run scripts/install-tools.sh first.\n' >&2
  exit 1
fi

if [ -z "${HYPERFRAMES_BROWSER_PATH:-}" ]; then
  case "$(uname -s)" in
    Darwin)
      if [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
        HYPERFRAMES_BROWSER_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
      fi
      ;;
    Linux)
      for browser_name in google-chrome chromium chromium-browser; do
        if command -v "$browser_name" >/dev/null 2>&1; then
          HYPERFRAMES_BROWSER_PATH="$(command -v "$browser_name")"
          break
        fi
      done
      ;;
  esac
fi

if [ -z "${HYPERFRAMES_BROWSER_PATH:-}" ]; then
  "$HYPERFRAMES_BIN" browser ensure
  HYPERFRAMES_BROWSER_PATH="$("$HYPERFRAMES_BIN" browser path)"
fi

export HYPERFRAMES_BROWSER_PATH
exec "$HYPERFRAMES_BIN" "$@"
