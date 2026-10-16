# Short-form production toolchain

These tools support the edit around DaVinci Resolve. Keep the Resolve project and native Fusion titles/compositions as the main editable deliverable. Use the tools that help with the footage actually provided; using all of them is not a goal by itself.

## Before using a tool

- Check availability and version first (`command -v`, then the tool's `--version` or `--help`). Check the project's own dependencies before changing them.
- If a tool is missing, continue with available tools where practical and tell the user what could not run. Do not install or upgrade a stack of dependencies speculatively. Whisper needs FFmpeg; HyperFrames also needs FFmpeg and a compatible browser. Puppeteer may download a browser when installed, so do not install it as a side effect of an unrelated edit.
- To install this skill's toolchain on macOS or Debian/Ubuntu, use [`scripts/install-tools.sh`](../scripts/install-tools.sh). It installs FFmpeg through Homebrew or apt and keeps Python and Node dependencies under `runtime/`; inspect the script before running it on another host.
- The installer also provides HyperFrames' optional Kokoro ONNX and MusicGen dependencies; model weights are downloaded on first use. The available Kokoro voices/languages do not include Persian, so keep Persian narration in the user's own recording or use a Persian-capable voice workflow.
- Check the specific MusicGen checkpoint's model-weight license before generating audio. Meta's `facebook/musicgen-small` weights are CC-BY-NC 4.0, so do not use that checkpoint for commercial café or promotional videos unless the user has separate rights; use a commercially cleared music source instead.
- Preserve source media and existing cuts. Write analysis, proxies, and exports into the current version's organized output folder; never overwrite the source or the prior project version.
- Use `yt-dlp` only for footage the user owns or is allowed to download. Do not bypass DRM, paywalls, access controls, or platform restrictions. Do not use browser cookies, private session data, or credentials to fetch media.
- Keep private footage and transcripts local. Do not upload, publish, or send them to a hosted service unless the user asks for that destination.
- Treat tool output as evidence to review, not as creative approval: ASR text needs listening review, automated shot analysis needs visual review, and exports need playback review.

## Practical order

1. **Inspect media:** use `ffprobe` for streams, duration, frame rate, and audio layout. Use `yt-dlp` only when an authorized source URL is provided and a local copy is needed.
2. **Understand speech:** extract a working audio copy with FFmpeg, then use Whisper to make a timestamped draft transcript. Keep the approved script and the machine transcript separate.
3. **Map visuals:** use OpenCV for contact sheets, motion/scene-change candidates, or checking presenter framing. Confirm the selected moments by looking at the actual frames.
4. **Edit in Resolve:** make the requested cuts and native Fusion graphics in a versioned project. Use HyperFrames for self-contained HTML motion graphics or a quick browser-based composition when that fits; bring a transparent video or image sequence into Resolve only when a flattened graphic is acceptable. Rebuild any recurring or specifically editable title/chart natively in Fusion.
5. **Capture product screens:** use Puppeteer only for the user's own/local/public page where a controlled viewport screenshot or frame capture is useful. Keep browser automation isolated; do not read or reuse a logged-in browser profile.
6. **Inspect and deliver:** use FFmpeg for necessary proxy/transcode/audio extraction or a requested final encode. Preview the actual output and report what was checked.

## Tool notes and small recipes

### FFmpeg and ffprobe

Use `ffprobe` to inspect before choosing transcode settings. `ffmpeg` is useful for audio extraction, compatible proxies, format conversion, and metadata checks; it does not replace the editable Resolve timeline. Prefer stream copy (`-c copy`) when no filter or re-encode is required. Filtering requires decode/encode and can change quality, timing, or color, so keep the original and inspect the result.

```sh
ffprobe -v error -show_format -show_streams -of json INPUT
ffmpeg -i INPUT -map 0:a:0 -ac 1 -ar 16000 -c:a pcm_s16le WORK/audio.wav
```

Use the installed FFmpeg build's help and filters to confirm options; builds differ in codecs and hardware support. Avoid hard-coding machine-specific encoder assumptions.

### Whisper

Whisper is for a draft transcript, language check, and timing aid. For Persian speech, set the language explicitly and keep its output in a review folder. The model can miss colloquial words, names, numbers, and punctuation; listen to unclear spans. Never substitute ASR wording for text the user has explicitly approved.

```sh
runtime/.venv/bin/whisper WORK/audio.wav --language Persian --task transcribe --model small \
  --output_format all --output_dir ANALYSIS/transcript
```

Choose a model that fits the available hardware and the clip; compare a difficult passage by listening instead of assuming a larger model fixes it. Keep the approved transcript as the caption source and place each final timed Persian caption in its own editable Text+ clip when requested.

### yt-dlp

Use this only for an authorized URL when the user needs a local source copy. Inspect available formats first, avoid playlists unless requested, and preserve the URL/source and license note alongside the downloaded asset.

```sh
runtime/.venv/bin/yt-dlp --simulate --no-playlist -F "URL"
runtime/.venv/bin/yt-dlp --no-playlist -f "bv*+ba/b" --merge-output-format mp4 \
  -o "INPUTS/%(title)s [%(id)s].%(ext)s" "URL"
```

If download rights or site permission are unclear, use a user-provided local file or ask for a permitted source. Do not attempt authentication workarounds.

### OpenCV and opencv_contrib

Use OpenCV for frame sampling/contact sheets, candidate scene-change detection, movement checks, and simple framing measurements—not as a substitute for watching the footage. Threshold-based detections can miss fast cuts or flag camera motion; review candidate timestamps in context. Start with core OpenCV. `opencv_contrib` contains extra modules with varying maturity; use one only when a named module is needed. The Python wheel families share the `cv2` namespace: install one matching package variant, not both `opencv-python` and `opencv-contrib-python` in the same environment. Avoid compiling OpenCV from source for a routine reel task.

For a quick contact sheet, sample a frame every second, save the frames as images, and inspect them before using them to set edit points:

```python
import cv2
import sys
from pathlib import Path

source = cv2.VideoCapture(sys.argv[1])
fps = source.get(cv2.CAP_PROP_FPS)
frame_count = source.get(cv2.CAP_PROP_FRAME_COUNT)
duration = frame_count / fps if fps else 0
out = Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)
for second in range(int(duration) + 1):
    source.set(cv2.CAP_PROP_POS_MSEC, second * 1000)
    ok, frame = source.read()
    if ok:
        cv2.imwrite(str(out / f"{second:04d}.jpg"), frame)
source.release()
```

### Puppeteer

Use Puppeteer to automate an isolated Chrome/Firefox page and capture a controlled viewport image or a planned set of frames from the user's own page. It is useful for product/UI inserts, not for capturing private sessions or scraping arbitrary sites. Verify the viewport, page state, font loading, and captured frames before placing them in the edit. For authored frame-accurate HTML animation, prefer HyperFrames where its project workflow fits. This skill installs `puppeteer-core` and uses the browser resolved by `scripts/hyperframes.sh browser path`; pass that path as Puppeteer's `executablePath`.

From a small script saved under `scripts/`, resolve Puppeteer Core from the skill runtime and keep the browser session isolated:

```js
import { createRequire } from "node:module";
import { mkdir } from "node:fs/promises";

const require = createRequire(new URL("../runtime/package.json", import.meta.url));
const puppeteer = require("puppeteer-core");
const browserPath = process.env.HYPERFRAMES_BROWSER_PATH;
if (!browserPath) throw new Error("Set HYPERFRAMES_BROWSER_PATH first");

const browser = await puppeteer.launch({ executablePath: browserPath, headless: true });
try {
  const page = await browser.newPage();
  await page.setViewport({ width: 1080, height: 1920, deviceScaleFactor: 1 });
  await page.goto("http://localhost:5173", { waitUntil: "networkidle2" });
  await page.evaluate(() => document.fonts.ready.then(() => true));
  await mkdir("outputs", { recursive: true });
  await page.screenshot({ path: "outputs/product-screen.png" });
} finally {
  await browser.close();
}
```

Set the path without reusing the user's everyday browser profile:

```sh
export HYPERFRAMES_BROWSER_PATH="$(scripts/hyperframes.sh browser path)"
```

### HyperFrames

HyperFrames renders HTML/CSS and seekable animations to video and offers a preview/check workflow. Use it for short designed graphics, infographics, or browser-native scenes when the expected deliverable can include their source project plus a rendered overlay. From the skill root, run `scripts/hyperframes.sh doctor` to diagnose the installation, `scripts/hyperframes.sh check` to review a composition, and `scripts/hyperframes.sh render` when a rendered export is requested. The wrapper uses an installed browser or downloads HyperFrames' pinned browser if none is available. Docker is only needed for `render --docker`, not ordinary local rendering. Check the composition and preview key timestamps. For a transparent graphic, confirm the chosen output format carries alpha; a PNG sequence is a practical handoff to Fusion when transparency and frame control matter. Keep original HTML/CSS, media, and any data values with the versioned output.

HyperFrames video is a rendered asset, not a native Fusion composition. Do not replace a reusable Fusion chart/title with a flattened export when the user expects to edit its values, typography, slices, or animation in Resolve. Do not publish a composition or upload media as part of local editing unless the user asks.

## References

- [FFmpeg repository](https://github.com/FFmpeg/FFmpeg), [FFmpeg documentation](https://ffmpeg.org/documentation.html), and [ffprobe documentation](https://ffmpeg.org/ffprobe.html)
- [OpenAI Whisper repository and usage](https://github.com/openai/whisper)
- [yt-dlp usage and supported sites](https://github.com/yt-dlp/yt-dlp)
- [OpenCV documentation](https://docs.opencv.org/), [opencv_contrib modules](https://github.com/opencv/opencv_contrib), and [OpenCV Python packages](https://github.com/opencv/opencv-python)
- [Puppeteer documentation](https://pptr.dev/)
- [HyperFrames CLI and rendering documentation](https://hyperframes.heygen.com/packages/cli)

Check the installed version's own `--help` and the linked upstream docs when a command changes; these projects evolve independently.
