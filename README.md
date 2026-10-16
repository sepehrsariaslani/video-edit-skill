# Video Edit skill

A Codex skill for short-form video editing in DaVinci Resolve, including the user's Persian café-accounting reel workflow. It keeps the Resolve project and native Fusion graphics editable while using media tools for intake, transcription, analysis, browser captures, and supporting motion graphics.

## Install the skill

Clone this repository into the Codex skills directory:

```sh
git clone https://github.com/sepehrsariaslani/video-edit-skill.git ~/.codex/skills/video-edit
```

Restart Codex or reload skills if the new skill does not appear. Then open a terminal in the skill folder and install the local toolchain:

```sh
cd ~/.codex/skills/video-edit
./scripts/install-tools.sh
```

The installer supports macOS with Homebrew and Debian/Ubuntu with apt. It installs FFmpeg/ffprobe at the OS level and keeps Whisper, OpenCV contrib, yt-dlp, HyperFrames, Puppeteer Core, Kokoro ONNX, SoundFile, and Transformers under `runtime/`. It also installs whisper.cpp with Homebrew on macOS; on Linux, HyperFrames can build it when local transcription is first used. It requires Python 3.11 and Node.js 22.12 or newer. OpenAI Whisper, whisper.cpp, Kokoro, and MusicGen model weights are fetched on first use, not bundled with the skill. Other operating systems can install the same pinned dependencies from `runtime/requirements.txt` and `runtime/package.json` using their package managers.

Docker Desktop is separate from the skill installer because it is a system application with its own setup and license prompts. It is optional for normal local rendering; HyperFrames only needs a running Docker engine for `render --docker`. On macOS, install it from the [official Docker Desktop instructions](https://docs.docker.com/desktop/setup/install/mac-install/) and start Docker Desktop when you need container rendering.

## Use

Invoke `$video-edit` when asking Codex to prepare or revise a short-form edit. Read `references/production-toolchain.md` for tool selection, safe media intake, and command examples. The dependencies are optional helpers; the skill does not need every tool for every edit.

## Licensing

The skill text and installer are licensed under MIT. FFmpeg, Whisper, yt-dlp, OpenCV, Puppeteer, HyperFrames, and downloaded footage keep their own upstream licenses and usage terms. Check those terms for the way you use and distribute a finished project.
