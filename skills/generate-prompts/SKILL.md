---
name: generate-prompts
description: Generate consistent AI image prompts for each parallax depth layer from a scene description.
version: 0.1.0
triggers:
  - when the user describes a scene and wants layer prompts
  - when the user asks for AI image generation prompts for parallax
  - when the user wants to generate their hero images with an AI tool
inputs:
  - name: scene_description
    type: string
    required: true
    description: One-sentence description of the overall scene
  - name: style
    type: string
    required: false
    description: Visual style (e.g. "photorealistic", "flat illustration", "painterly")
  - name: lighting
    type: string
    required: false
    description: Lighting description (e.g. "blue hour dusk", "golden hour", "overcast midday")
  - name: layer_count
    type: integer
    required: false
    description: Number of layers to generate prompts for (default 4)
outputs:
  - one prompt per layer, formatted for copy-paste into ImageFX, Midjourney, or DALL-E 3
  - suggested depth value and --md-image-position for each layer
constraints:
  - every prompt must include the same style anchor (lighting + palette + camera angle)
  - mid/near/foreground prompts must request transparent background
  - prompts must specify panoramic wide-angle aspect ratio
---

# generate-prompts

Generate AI image prompts for parallax layers from a scene description.

## 1. Purpose

Consistent layer prompts are the hardest part of building a parallax — if
lighting or perspective changes between layers, the composite looks wrong.
This skill locks a style anchor and derives one prompt per depth layer.

## 2. Output format

For each layer, output:

```
Layer N — [depth name]
Depth: [value]
Image position: [value]%
---
[Full prompt text ready to paste]
---
```

## 3. Prompt construction rules

**Style anchor** (repeat verbatim in every prompt):
```
[lighting description], [color palette], [camera angle], [style]
```

**Per-layer additions:**

| Layer | Depth cue to add | Transparency |
|---|---|---|
| Far background | "distant [scene element] only, no midground or foreground" | No (solid fill) |
| Mid background | "mid-distance [elements] only, no foreground" | Yes: "transparent background, PNG with alpha" |
| Near midground | "[elements] in near-midground only, foreground cut off" | Yes |
| Foreground | "[elements] in immediate foreground only" | Yes |

**Aspect ratio:**
Always append: `panoramic wide-angle, 16:5 aspect ratio, landscape orientation`

## 4. Example output

Scene: *"Rooftop terrace in Tokyo at dusk with city skyline and indoor plants"*
Style: photorealistic, blue-hour lighting, slightly elevated camera

```
Layer 1 — Far background
Depth: 8
Image position: 65%
---
Tokyo city skyline at blue hour, warm amber street lights against deep blue 
sky, no buildings in foreground or midground, distant view only, photorealistic, 
panoramic wide-angle, 16:5 aspect ratio, landscape orientation
---

Layer 2 — Mid background
Depth: 5
Image position: 30%
---
Mid-distance Tokyo rooftop buildings and terraces at blue hour, warm amber 
and blue tones, no foreground elements, transparent background PNG with alpha, 
same blue-hour lighting as reference, photorealistic, panoramic wide-angle, 
16:5 aspect ratio
---

Layer 3 — Near midground
Depth: 2
Image position: 50%
---
Rooftop terrace railing and potted plants at blue hour, mid-shot, transparent 
background PNG with alpha, same warm amber and blue-hour lighting, cut off at 
foreground edge, photorealistic, panoramic wide-angle, 16:5 aspect ratio
---

Layer 4 — Foreground
Depth: 1
Image position: 50%
---
Large tropical indoor plants in immediate foreground, visible leaf detail, 
transparent background PNG with alpha, blue-hour ambient backlight, 
photorealistic, panoramic wide-angle, 16:5 aspect ratio
---
```

## 5. Tool-specific notes

| Tool | Notes |
|---|---|
| Google ImageFX | Generates 4 at once — run each layer as a separate prompt, download as PNG |
| Midjourney | Add `--ar 16:5 --style raw` — use `/describe` on a reference to lock style |
| DALL-E 3 | Say "transparent PNG" — remove white bg in post with rembg |
| Stable Diffusion | Use inpainting + ControlNet depth to isolate layers from one render |

## 6. Changelog

- `0.1.0` — Initial skill.
