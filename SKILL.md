---
name: video-edit
description: Create and revise editable DaVinci Resolve short-form videos and motion graphics, especially the user's Persian café accounting reels. Use optional FFmpeg, Whisper, Persian Piper TTS, yt-dlp, OpenCV, Puppeteer, or HyperFrames workflows when they fit; preserve existing edits unless asked to change them.
---

# Video Edit

Use this skill for the user's DaVinci Resolve café-accounting video series and closely related edits. Keep deliverables editable in Resolve so the user can adjust motion, timing, colors, and content.

## Optional production tools

Resolve remains the editable project master. Use the supporting tools only when they solve a real part of the current edit; do not force every tool into every job. Before using them, check what is installed and read the relevant usage notes in [references/production-toolchain.md](references/production-toolchain.md). Do not install or upgrade a tool just because it is listed there.

Follow the user's workspace instruction: inspect prerequisites before any build, restart, or migration, and do only the specific step needed to apply the requested change. Do not run Graphify updates unless the user asks.

## Preserve the edit

- Use only the user's supplied footage and audio by default. Do not add downloaded/stock/AI-generated clips, synthetic narration, or generated music unless the user asks for them.
- Keep the user's original voice recording in sync and on its own audio track. Do not replace or alter it; denoise, process, or rebalance it only when requested.
- Treat the user's existing cuts, clip order, timing, and crops as intentional. Keep them intact unless the user asks for a layout or timing change.
- Keep source footage on its own lower video track and motion graphics on a separate upper track. Keep reusable backgrounds such as the dotted pattern on their own transparent track, long enough to cover the requested sequence.
- Put synchronized sound effects on a separate audio track so the user can adjust or mute them independently.
- Save a separate reusable Fusion composition or template when the user wants to reuse an element; keep its editable controls and provide a concise guide when useful.
- When revising an established edit, create a new versioned timeline/project and output folder. Keep earlier versions and their deliverables available; do not overwrite them as part of normal iteration.

## Editable titles and charts

- If the user wants to edit subtitles in Resolve, place each timed caption as an individually selectable native Fusion Title/Text+ clip on a dedicated, clearly named track. Put the actual Persian wording in the Text+ `Styled Text` input, preserve RTL and intentional line breaks, and match the supplied speech timing. A clip label or a nested timeline containing a baked subtitle is not an editable caption.
- When exposing an existing chart, reuse its original Fusion composition on a dedicated timeline track instead of flattening it into a movie. Preserve its slice, label, ratio, and reveal controls, and give the track/timeline names enough detail that the user can find and edit them without searching through nested timelines.
- Verify every caption's actual Text+ value against the approved transcript/timing source, confirm that the chart remains a Fusion composition, and preview the rendered timeline. Include the editable project, a short Persian guide naming the relevant tracks/nodes, and any reusable title/chart templates in the versioned output folder.

## Visual style for the café-accounting series

- Follow the user's red and black brand direction, using restrained dark red / bright red accents and neutral supporting tones. Preserve any supplied visual reference's structure while adapting it to the user's palette.
- Set Persian text right-to-left, use readable type size and contrast for vertical mobile video, and keep chart labels distinct from the data marks.
- When a chart or explanatory visual is on screen, use the requested second layout: show the presenter smaller and lower while the visual sits above. When the full presenter view is needed, return to full frame and use only a gentle zoom.
- Keep chart slices and labels independently editable and animate the fill or reveal so the audience can follow the values.
- Never present invented café costs, margins, or profit as measured results. If the user has not supplied real data, label illustrative chart values clearly as a demo and distinguish them from the real result to be measured after the 30-day observation period.

## Motion continuity and the presenter

- When the user provides exact narration or on-screen wording, use the latest explicit wording from the current task verbatim and align it to the matching speech. Do not let stale ASR or wording from another task override it, and do not ask the user to reconfirm words they already supplied. Do not replace it with a looser summary. Keep machine-transcribed sections marked for listening review when the audio is unclear; do not change the original voice track unless requested.
- Keep the presenter anchored consistently across shots. When their size or position needs to change, animate Transform/Zoom and position with keyframes; do not create the change through a sudden crop or an unanimated resize. Match the start and end framing across cuts so the presenter does not jump unexpectedly to the center.
- If removing the background, refine and preview the matte against the actual intended background. Keep the subject cutout aligned to its source frame and prevent holes, edge spill, flicker, or another clip showing through the presenter. Use the full source shot when the matte is not clean.
- Text placed behind the presenter should remain fully readable while the subject occludes only the intended part. Use deliberate depth, extrusion, shadow, or bevel for a 3D look, and inspect the face, hair, and text edges at the beginning and end of the effect.
- Give each visual a motion that supports its content: chart slices fill, labels enter and leave cleanly, and presenter zooms ease between sizes. Keep the layout stable while those elements animate.
- Preserve the animated pie/donut chart in the edit when requested. Keep its slices, labels, and reveal controls editable. When the real figures are unknown, use labels such as «هزینه‌ها» and «سود؟» plus a clear «نمونهٔ نمایشی / سهم واقعی پس از ۳۰ روز» disclosure; never imply that a demo ratio is measured.
- For this café reel, the opening hook is «از هر ۱۰۰ هزار تومان فروش کافه چقدرش سوده؟». The user describes the ending as «تمام داده‌ها رو وارد سیستم می‌کنم تا ببینم بعد از ۳۰ روز…» and wants the video to end there so it loops into the hook. Match the closing line and final frame to the opening question without adding an unrelated outro or extra tail.

## Reusable motion assets and story beats

- Distinguish rendered stock clips from editable motion-graphics components. Mixkit and Pixabay provide ready-made video assets; use them as footage, backgrounds, or overlays, but do not present them as editable Fusion titles, charts, or animation components.
- For editable components, look for DaVinci Resolve/Fusion templates or macros such as `.drfx` and `.setting` files. A public Fusion macro/template collection is available at [mrJohnHolt's DaVinci Resolve Fusion Expressions repository](https://github.com/mrJohnHolt/davinci-resolve-fusion-expressions); it lists installable packages for titles, animated backgrounds, counters, layouts, and transitions. Reactor is another community source for Fusion tools and macros. Check each package's license, Resolve compatibility, and exposed controls before using it; a downloaded template may still need styling and adjustment.
- Use a rendered `.mov` with alpha or a transparent PNG sequence only when a flattened overlay is sufficient. For this reel's pie chart, titles, and recurring brand graphics, prefer native editable Fusion compositions and keep their controls exposed rather than substituting a pre-rendered clip.
- For the narration about building the accounting software and first implementing it at the user's company, animate the software screenshot as a framed panel that eases to the right; bring in the company/product footage from the opposite side to take its place, showing the software in use when source footage supports it. Move the narration text into a clear area that does not cover the interface or products. Keep the presenter anchored and align the handoff to the spoken sentence.
- For «فقط یه مشکلی دارم، من هیچ تجربه‌ای از مدیریت کافه ندارم», use a brief, candid beat: give the presenter room, introduce a restrained question mark or «مدیریت کافه؟» cue, then let a few small labels or icons for فروش، انبار، پرتی، تولید، and نیروی انسانی appear one at a time. Keep the layout uncluttered and let this uncertainty lead into the 30-day learning process; do not portray it as a measured result or make the presenter seem incompetent.

## Finish and verify

- Check that overlays are transparent where intended, cover the requested duration, and remain on independent tracks.
- Preview representative points in the timeline, including transitions into and out of the graphic layout; confirm Persian labels are legible and sound effects line up with their animations.
- Preview every presenter scale/layout transition and the chart-to-presenter handoff. Check that the intended loop closes on «بعد از ۳۰ روز» and restarts naturally at the opening hook.
- Preserve the original project and user-edited timeline. Save a new project version or backup before consequential timeline restructuring.
- Report what was saved and what was actually previewed or verified. Do not claim a render, export, or verification that did not happen.
