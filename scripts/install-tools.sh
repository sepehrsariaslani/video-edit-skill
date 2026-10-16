#!/usr/bin/env bash
set -euo pipefail

SKILL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$SKILL_ROOT/runtime"
PYTHON_BIN="${PYTHON_BIN:-python3.11}"

install_ffmpeg() {
  if command -v ffmpeg >/dev/null 2>&1 && command -v ffprobe >/dev/null 2>&1; then
    printf 'FFmpeg and ffprobe already available: %s\n' "$(command -v ffmpeg)"
    return
  fi

  case "$(uname -s)" in
    Darwin)
      if ! command -v brew >/dev/null 2>&1; then
        printf 'Homebrew is required to install FFmpeg on macOS. Install Homebrew, then rerun this script.\n' >&2
        exit 1
      fi
      brew install ffmpeg
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        if [ "$(id -u)" -eq 0 ]; then
          apt-get update
          apt-get install -y ffmpeg
        elif command -v sudo >/dev/null 2>&1; then
          sudo apt-get update
          sudo apt-get install -y ffmpeg
        else
          printf 'Install ffmpeg with your system package manager, then rerun this script.\n' >&2
          exit 1
        fi
      else
        printf 'This script supports apt-based Linux. Install ffmpeg with your package manager, then rerun.\n' >&2
        exit 1
      fi
      ;;
    *)
      printf 'Unsupported OS for automatic FFmpeg installation. Install ffmpeg and ffprobe, then rerun.\n' >&2
      exit 1
      ;;
  esac
}

install_whisper_cpp() {
  if command -v whisper-cli >/dev/null 2>&1 || command -v whisper-cpp >/dev/null 2>&1; then
    printf 'whisper.cpp already available: %s\n' "$(command -v whisper-cli || command -v whisper-cpp)"
    return
  fi

  case "$(uname -s)" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        brew install whisper.cpp
      else
        printf 'Install whisper.cpp with Homebrew to enable HyperFrames local transcription.\n' >&2
      fi
      ;;
    Linux)
      printf 'whisper.cpp is optional here; HyperFrames can build it when transcription is first used.\n'
      ;;
    *)
      printf 'whisper.cpp was not installed automatically on this OS.\n'
      ;;
  esac
}

install_python_tools() {
  if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    printf 'Python 3.11 is required. Install it or set PYTHON_BIN to a compatible Python 3.11 executable.\n' >&2
    exit 1
  fi

  PYTHON_VERSION="$($PYTHON_BIN -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
  if [ "$PYTHON_VERSION" != "3.11" ]; then
    printf 'Expected Python 3.11, found %s. Set PYTHON_BIN to a Python 3.11 executable.\n' "$PYTHON_VERSION" >&2
    exit 1
  fi

  VENV="$RUNTIME_DIR/.venv"
  if command -v uv >/dev/null 2>&1; then
    uv venv --allow-existing --python "$PYTHON_BIN" "$VENV"
    uv pip install --python "$VENV/bin/python" -r "$RUNTIME_DIR/requirements.txt"
  else
    "$PYTHON_BIN" -m venv "$VENV"
    "$VENV/bin/python" -m pip install --upgrade pip
    "$VENV/bin/python" -m pip install -r "$RUNTIME_DIR/requirements.txt"
  fi
  export HYPERFRAMES_PYTHON="$VENV/bin/python"
}

install_node_tools() {
  if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    printf 'Node.js 22.12+ and npm are required. Install Node.js, then rerun this script.\n' >&2
    exit 1
  fi

  NVM_SCRIPT="${NVM_DIR:-$HOME/.nvm}/nvm.sh"
  if [ -s "$NVM_SCRIPT" ]; then
    # Keep nvm's Node and npm pair ahead of any older system installation.
    # shellcheck disable=SC1090
    . "$NVM_SCRIPT"
    if nvm version default >/dev/null 2>&1; then
      nvm use --silent default >/dev/null
    fi
  fi

  NODE_BIN="$(command -v node)"
  NPM_BIN="$(command -v npm)"
  export PATH="$(dirname "$NODE_BIN"):$PATH"
  NODE_MAJOR="$("$NODE_BIN" -p 'Number(process.versions.node.split(".")[0])')"
  NODE_MINOR="$("$NODE_BIN" -p 'Number(process.versions.node.split(".")[1])')"
  if [ "$NODE_MAJOR" -lt 22 ] || { [ "$NODE_MAJOR" -eq 22 ] && [ "$NODE_MINOR" -lt 12 ]; }; then
    printf 'Node.js 22.12+ is required; found %s.\n' "$($NODE_BIN --version)" >&2
    exit 1
  fi

  # Runtime packages use platform binaries directly; do not run arbitrary package hooks.
  "$NODE_BIN" "$NPM_BIN" ci --prefix "$RUNTIME_DIR" --ignore-scripts --no-audit --no-fund

  HYPERFRAMES_BIN="$RUNTIME_DIR/node_modules/.bin/hyperframes"
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
  if [ ! -x "$HYPERFRAMES_BROWSER_PATH" ]; then
    printf 'Browser path is not executable: %s\n' "$HYPERFRAMES_BROWSER_PATH" >&2
    exit 1
  fi
  export HYPERFRAMES_BROWSER_PATH
  printf 'Using browser: %s\n' "$HYPERFRAMES_BROWSER_PATH"
  "$HYPERFRAMES_BIN" doctor
}

install_ffmpeg
install_whisper_cpp
install_python_tools
install_node_tools

printf '\nInstalled tool versions:\n'
ffmpeg -version | head -n 1
ffprobe -version | head -n 1
"$RUNTIME_DIR/.venv/bin/whisper" --help >/dev/null
"$RUNTIME_DIR/.venv/bin/yt-dlp" --version
"$RUNTIME_DIR/.venv/bin/python" -c 'import cv2; print("OpenCV", cv2.__version__, "contrib ximgproc:", hasattr(cv2, "ximgproc"))'
"$RUNTIME_DIR/node_modules/.bin/hyperframes" --version
printf 'Puppeteer Core %s\n' "$("$NODE_BIN" -p 'require(process.argv[1]).version' "$RUNTIME_DIR/node_modules/puppeteer-core/package.json")"
if command -v whisper-cli >/dev/null 2>&1; then
  printf 'whisper.cpp %s\n' "$(command -v whisper-cli)"
elif command -v whisper-cpp >/dev/null 2>&1; then
  printf 'whisper.cpp %s\n' "$(command -v whisper-cpp)"
fi
printf '\nToolchain installation finished. AI model weights download on first use.\n'
