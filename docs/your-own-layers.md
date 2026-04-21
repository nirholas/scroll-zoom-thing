---
title: Using Your Own Layers
description: How to create and export layered AVIF images for CSS 3D parallax scrolling — image dimensions, transparency, depth assignments, and object-position tuning.
---

# Using Your Own Layers

## Image requirements

| Property | Recommendation |
|---|---|
| Format | AVIF (best compression), WebP fallback, PNG as last resort |
| Dimensions | Wide panorama — at least 1920×600, wider is better |
| Transparency | Required for mid and foreground layers |
| Naming | `1-far@4x.avif`, `2-mid@4x.avif`, etc. |

## How many layers?

Four is the practical sweet spot. Fewer and the effect is subtle; more and you're paying file size for imperceptible depth.

| Layer | What it contains | Depth |
|---|---|---|
| 1 — Far | Sky, horizon, distant scenery — no transparency needed | `8` |
| 2 — Mid | Buildings, terrain, mid-distance elements — transparent bg | `5` |
| 3 — Near | Foreground objects, close foliage — transparent bg | `2` |
| 4 — Front | Closest elements, frame, plants — transparent bg | `1` |

## Generating layers with AI

Ask an image generator for each layer separately with a consistent style anchor. For each prompt:

- Specify the same lighting, color palette, and camera angle
- Request a transparent background (for mid/near/front layers)
- Ask for a wide panorama aspect ratio (16:5 or wider)
- Keep the foreground elements at the bottom of the frame — `object-position` anchors images from the bottom up

Example prompt structure:

```
[Scene description], transparent PNG, panoramic 16:5, 
[depth cue: "distant horizon only" / "mid-distance only" / "foreground plants only"],
consistent with: [style reference]
```

## Wiring up your layers

In `home.html`, each `<picture>` gets two inline CSS variables:

```html
<picture class="mdx-parallax__layer"
         style="--md-parallax-depth: 8; --md-image-position: 70%">
  <source type="image/avif" srcset="assets/hero/1-far@4x.avif">
  <img src="assets/hero/1-far@4x.avif" alt="" class="mdx-parallax__image">
</picture>
```

- `--md-parallax-depth` — how far back the layer sits (higher = slower scroll)
- `--md-image-position` — maps to `object-position`; controls which vertical slice of the image is shown

## Tuning `--md-image-position`

`object-position` is a single `%` value here (horizontal axis only, vertical defaults to `50%`). Adjust it per layer to center the most important part of each image:

| Value | Shows |
|---|---|
| `0%` | Left edge of image |
| `50%` | Center (default) |
| `100%` | Right edge |

For landscapes, `70%` on a far layer often shows sky; `25%` on a plateau layer shifts to show terrain detail.

## File placement

```
docs/
└── assets/
    └── hero/
        ├── 1-far@4x.avif
        ├── 2-mid@4x.avif
        ├── 3-near@4x.avif
        └── 4-front@4x.avif
```

Reference them in `mkdocs.yml` via `extra_css` (already done) — MkDocs copies everything under `docs/assets/` to `_site/assets/` automatically.

