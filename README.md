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

The installer supports macOS with Homebrew and Debian/Ubuntu with apt. It installs FFmpeg/ffprobe at the OS level and keeps Whisper, OpenCV contrib, yt-dlp, HyperFrames, and Puppeteer Core under `runtime/`. It requires Python 3.11 and Node.js 22.12 or newer. Whisper model weights are fetched only when a transcription model is first used. Other operating systems can install the same pinned dependencies from `runtime/requirements.txt` and `runtime/package.json` using their package managers.

## Use

Invoke `$video-edit` when asking Codex to prepare or revise a short-form edit. Read `references/production-toolchain.md` for tool selection, safe media intake, and command examples. The dependencies are optional helpers; the skill does not need every tool for every edit.

## Licensing

The skill text and installer are licensed under MIT. FFmpeg, Whisper, yt-dlp, OpenCV, Puppeteer, HyperFrames, and downloaded footage keep their own upstream licenses and usage terms. Check those terms for the way you use and distribute a finished project.
