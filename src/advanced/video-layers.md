---
title: Video layers
description: Replacing a still parallax layer with an autoplaying video, including codecs, file sizes, and mobile autoplay rules.
---

# Video layers

Any of the four parallax layers can be a video instead of a still
image. The depth math is the same: the video sits at depth 8, 5, 2,
or 1 like any other layer. The hard part is everything around it:
codecs, file size, mobile autoplay, and the fact that a video layer
is always more expensive than a still.

This guide covers the mechanics of swapping one layer for video and
the constraints that come with it.

## When a video layer earns its place

A video layer is justified when:

- The motion is the point. A flickering candle, a rotating object, a
  subtle ambient loop. Things a still cannot communicate.
- The motion is small. A few percent of the frame. Large motion in a
  parallax stack fights the parallax for attention and looks chaotic.
- The loop is short. Two to six seconds. Longer loops bloat file size
  without adding value.

It is not justified when the motion is decorative noise (rain on a
window, drifting clouds across the whole frame). That kind of motion
is also a still image's job, and a still costs a fraction as much.

## Markup

The minimum markup that autoplays correctly across browsers:

```html
<video
  class="hero-layer"
  style="--depth: 2;"
  autoplay
  muted
  loop
  playsinline
  preload="auto"
  poster="/assets/hero/depth-2-poster.avif"
  width="2560"
  height="1440">
  <source src="/assets/hero/depth-2.av1.mp4" type="video/mp4; codecs=av01.0.05M.08">
  <source src="/assets/hero/depth-2.h264.mp4" type='video/mp4; codecs="avc1.42E01E"'>
</video>
```

Every attribute earns its place:

- `autoplay`: starts the video without user interaction.
- `muted`: required by browsers for `autoplay` to actually play.
  Without it, mobile and modern desktop browsers block playback.
- `loop`: replays without a gap.
- `playsinline`: required on iOS Safari. Without it, the video tries
  to enter fullscreen on play.
- `preload="auto"`: hints that the video is part of the initial
  view. Use `metadata` instead if the video is below the fold.
- `poster`: a still frame shown until the video decodes. Use the
  same AVIF you would have used if this layer were a still.

The `poster` attribute is more important than it looks. It is what
the user sees during the first second of the page load, before the
video stream has buffered enough to start. It is also what users on
data-saver mode see permanently.

## Codec choices

Three codecs are realistic in 2026:

| Codec | Container | Size (relative) | Browser support  | Encode time |
|-------|-----------|-----------------|------------------|-------------|
| H.264 | MP4       | 1.0x (baseline) | Universal        | Fast        |
| AV1   | MP4       | 0.4x            | Modern browsers  | Slow        |
| VP9   | WebM      | 0.6x            | Most browsers    | Medium      |

Recommended: ship AV1 first, H.264 as fallback. AV1 cuts file size
roughly in half versus H.264 at the same visual quality. WebM/VP9 is
not worth the extra build step if you already have AV1 and H.264.

Encoding AV1 with `ffmpeg`:

```bash
ffmpeg -i input.mov \
  -c:v libsvtav1 -preset 6 -crf 30 \
  -an \
  -movflags +faststart \
  depth-2.av1.mp4
```

Encoding H.264 fallback:

```bash
ffmpeg -i input.mov \
  -c:v libx264 -preset slow -crf 23 \
  -pix_fmt yuv420p \
  -an \
  -movflags +faststart \
  depth-2.h264.mp4
```

`-an` strips the audio track. A muted hero video does not need an
audio track at all, and removing it saves bytes. `+faststart` moves
the moov atom to the front of the file so the browser can begin
playback before the full file downloads.

## File size targets

Per video layer:

- Background (depth 8): under 800 KB AV1, under 1.5 MB H.264.
- Mid-ground (depth 5): under 600 KB AV1, under 1.2 MB H.264.
- Foreground (depth 2): under 400 KB AV1, under 800 KB H.264.
- Near-camera (depth 1): under 250 KB AV1, under 500 KB H.264.

If you are over budget, in order:

1. Shorten the loop. A two-second loop that is well-edited beats a
   ten-second loop at half the bitrate.
2. Crop tighter. A video that covers 30% of the frame can be 30% of
   the resolution.
3. Lower the resolution. Hero video at 1440p is rarely
   distinguishable from 2160p.
4. Raise the CRF. Try 32, 34. Hero video has a lot of motion blur
   tolerance.
5. Use the still-image fallback. Not every layer needs to be video.

Only one layer should be video. Two video layers is twice the cost
for diminishing returns; four is a guarantee of bad performance.

## Alpha channel

Most parallax stacks need transparent layers. Video with alpha is
possible but constrained:

- AV1 supports alpha but encoder tooling is uneven.
- H.264 in MP4 does not support alpha. You need HEVC in MP4 (Safari
  only) or VP9 in WebM (Chromium and Firefox).
- Result: shipping alpha video cross-browser requires both a WebM
  VP9 source and an HEVC MP4 source, plus a still-image fallback.

For most sites, the simpler answer is: only the background layer is
video, and it does not need alpha. The depth-1 and depth-2 layers
stay as still AVIFs with transparent backgrounds. The video sits
behind them.

## Mobile autoplay

iOS Safari and Chrome on Android both autoplay muted, inline videos.
The combination required is `autoplay muted playsinline`. Missing
any one of those will silently fail on mobile.

Two additional considerations:

- iOS Low Power Mode disables autoplay regardless of attributes. The
  poster image must therefore be good enough on its own.
- Data Saver mode in Chrome on Android may block video downloads.
  Same fallback: the poster carries the experience.

Test on a real phone, not just a desktop emulator. Desktop simulators
do not enforce all the autoplay rules.

## Reduced motion

Users with `prefers-reduced-motion: reduce` should not see autoplaying
video. Honor it:

```css
@media (prefers-reduced-motion: reduce) {
  .hero-layer[data-video] {
    display: none;
  }
  .hero-layer[data-video-poster] {
    display: block;
  }
}
```

Render both the video and its poster as separate elements; toggle
visibility based on the media query. The poster path is also the
fallback for browsers that fail to decode either codec.

## A working pattern

The configuration that holds up across most sites:

- Depth 8 (background): video, AV1 + H.264, no alpha, ~600 KB.
- Depths 5, 2, 1: still AVIFs with alpha.
- Hero stack as before; only the background layer markup changes.

This buys the motion where it matters (the establishing background)
without paying for video on every layer. If you cannot make this
configuration look good, more video layers will not help.
