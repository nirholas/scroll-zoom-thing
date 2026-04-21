---
title: Generating Parallax Layers with AI
description: How to use AI image generators — Google ImageFX, Midjourney, DALL-E, Stable Diffusion — to create transparent layered AVIF images for CSS 3D parallax scrolling.
---

# Generating Parallax Layers with AI

AI image generators are the fastest way to produce layered assets for parallax — no Photoshop, no manual masking. This page covers prompting strategy, tool-specific tips, and export settings.

## The layering mental model

Before prompting, decide what your scene contains at each depth:

```
Layer 1 (depth 8) — far background   : sky, mountains, city skyline, horizon
Layer 2 (depth 5) — mid background   : buildings, terrain, water, architecture
Layer 3 (depth 2) — near midground   : trees, plants, structures, people
Layer 4 (depth 1) — foreground       : window frame, plants, desk edge, closest objects
```

Each layer needs a **transparent background** except the far background (layer 1), which fills the entire frame.

---

## Prompt structure

Use a consistent style anchor across all layers so they composite cleanly:

```
[subject for this layer], [transparent PNG / no background],
panoramic wide-angle, [lighting description],
[color palette], [camera angle],
isolated from background, studio cut-out style
```

Example set for a rooftop scene:

| Layer | Prompt |
|---|---|
| Far | `City skyline at blue hour, soft gradient sky, no foreground, panoramic 16:5` |
| Mid | `Mid-distance rooftop buildings at dusk, transparent background, same blue-hour lighting` |
| Near | `Rooftop plants and railing, foreground only, transparent PNG, blue-hour lighting` |
| Front | `Indoor plants in foreground, window frame edge, transparent background, blue-hour ambient` |

---

## Tool-specific tips

### Google ImageFX

- Generates 4 images per prompt — run each layer separately
- Request `transparent background` explicitly; download as PNG
- Use "Edit" to regenerate weak layers without changing style
- Convert to AVIF after download (see below)

### Midjourney

- Add `--ar 16:5` for panoramic aspect ratio
- Add `--no background` or use `/describe` on a reference image to lock style
- Use `--style raw` for cleaner cut-outs on foreground layers
- Remove background with [remove.bg](https://www.remove.bg) or Photoshop generative fill

### DALL-E 3 (ChatGPT)

- Specify `"transparent PNG"` and `"isolated on white"` — remove white in post
- Consistent style: paste the same style description verbatim across all 4 prompts
- Use `"same scene, same lighting, different depth plane"` as a thread anchor

### Stable Diffusion (local)

- Use inpainting to isolate layers from a single scene render
- `rembg` CLI removes backgrounds automatically: `rembg i input.png output.png`
- ControlNet depth maps help maintain consistent perspective across layers

---

## Exporting to AVIF

AVIF gives the best compression for photographic layers. From PNG:

```bash
# Using ffmpeg (available on most systems)
ffmpeg -i layer1.png -c:v libavc -crf 30 1-landscape@4x.avif

# Using ImageMagick
magick layer1.png -quality 80 1-landscape@4x.avif

# Using cavif (Rust, best quality/size ratio)
cavif --quality 70 layer1.png -o 1-landscape@4x.avif
```

For a quick web-ready pipeline:

```bash
for f in *.png; do
  cavif --quality 70 "$f" -o "${f%.png}@4x.avif"
done
```

---

## Naming convention

Match the filenames expected in `home.html`:

```
docs/assets/hero/
├── 1-landscape@4x.avif   ← depth 8, far background
├── 2-plateau@4x.avif     ← depth 5, mid background
├── 5-plants-1@4x.avif    ← depth 2, near midground
└── 6-plants-2@4x.avif    ← depth 1, foreground
```

Rename freely — just update the `srcset` paths in `home.html` to match.

---

## Checking compositing before building

Open all 4 PNGs in layers in any image editor (Figma, Photoshop, GIMP) with the far background at the bottom. If the scene reads as a coherent 3D space, it will look right in the parallax.

Common issues:

| Problem | Fix |
|---|---|
| Layers have mismatched lighting | Re-generate with the same lighting description anchored in every prompt |
| Foreground objects are too large | Use `--ar 16:5` and keep subjects in the lower third |
| Background bleeds into foreground layers | Re-run background removal with a higher tolerance |
