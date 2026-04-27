# Generating Parallax Layers with AI

This guide walks through every step of creating the four AVIF image layers that power the CSS 3D parallax hero in [nirholas/scroll-zoom-thing](https://github.com/nirholas/scroll-zoom-thing). You will learn how to think about depth before you open any tool, how to prompt AI image generators effectively for each plane, how to remove backgrounds, and how to convert and quality-check your final assets. Shell scripts and prompt templates are included throughout.

---

## The Mental Model: Thinking in Depth Planes First

Before you touch an AI generator, spend five minutes with a pencil sketch or a rough Figma artboard. The parallax system uses CSS `perspective: 2.5rem` and `translateZ` values to push layers away from the viewer. The math works out so that a layer at `translateZ(-8rem)` moves much more slowly as you scroll than a layer at `translateZ(-1rem)`. This is the same parallax that photographers call "foreground-background separation" — except you are building it synthetically.

The four layers in the project correspond to these approximate real-world distances:

| Layer file | `translateZ` equivalent | Perceived distance | Moves on scroll |
|---|---|---|---|
| `layer-far.avif` | −8 rem (depth 8) | Horizon / sky | Very slowly |
| `layer-mid.avif` | −5 rem (depth 5) | Distant terrain / treeline | Slowly |
| `layer-near.avif` | −2 rem (depth 2) | Closer objects, structures | Moderately |
| `layer-front.avif` | −1 rem (depth 1) | Foreground elements, foliage | Fast |

The CSS variables `--md-parallax-depth` and `--md-image-position` let you tweak these values without touching HTML. But the visual plausibility of the parallax depends entirely on you having designed the images to match these distance roles. A tree trunk that belongs on the front layer will look bizarre if you put it in the far layer and it crawls slowly across the screen while the sky races ahead.

The key mental rule: **each layer should be incomplete on its own.** The far layer can have no foreground elements. The front layer should have no sky. Each plane is a slice through a scene, not a scene by itself. If you can print one layer alone and it looks like a finished illustration, it probably has too much detail at too many depths and will break the illusion.

---

## Why AI Generators Are Ideal for This Workflow

Conventional photography and stock art are poorly suited to depth-layer extraction. A photograph has continuous depth of field — separating a tree from its background requires masking every pixel of bark and leaf, a labor-intensive process that still produces fringe artifacts. Illustrations from stock libraries rarely match each other stylistically unless they come from the same artist and series.

AI generators solve both problems:

- **Stylistic consistency.** You can anchor a style in a prompt ("oil painting, muted palette, golden hour") and reuse that exact anchor across all four prompts. The model will produce images that share the same color temperature, texture grain, and visual language — something very difficult to guarantee with stock photography.
- **Generative simplicity.** You can ask the generator for a sky with no terrain, or terrain with no sky, or foreground plants with no background. This separation is unnatural for a photograph but completely natural for a generated image. The model will comply with "only clouds, no ground" in a way that no photographer can.
- **Transparent PNG output.** Several generators can export images with alpha channel transparency, which is exactly what the front and near layers need. When there is no background to remove, you skip an entire post-processing step.
- **Rapid iteration.** A weak layer can be regenerated in 30 seconds. Redoing a stock photo composite takes hours.

---

## Prompt Structure: The Four-Part Formula

Every prompt for a parallax layer should contain four components:

```
[Style anchor] + [Depth cue] + [Compositional constraint] + [Technical request]
```

**Style anchor** — lock the visual language once and reuse it verbatim across all four prompts. Examples:
- `digital matte painting, cinematic, warm dusk palette, desaturated shadows`
- `ukiyo-e woodblock print, flat color areas, indigo and ochre`
- `photorealistic aerial photograph, Sony A7R, golden hour`

**Depth cue** — explicitly tell the model where in the scene this plane lives:
- Far: `distant horizon, atmospheric haze, low contrast, pale sky`
- Mid: `rolling hills in the middle distance, treeline silhouette, slight haze`
- Near: `closer rocky outcroppings, partial structures, medium contrast`
- Front: `close foreground foliage and rocks, sharp edges, high contrast, no sky visible`

**Compositional constraint** — restrict what appears on the layer:
- Far: `only sky and horizon, no foreground elements, no figures`
- Mid: `no sky, no close-up elements, terrain only`
- Near: `no sky, no tiny background elements, medium-ground only`
- Front: `isolated foreground objects only, transparent or white background, no background scenery`

**Technical request** — tell the model what you need for post-processing:
- `transparent PNG`, `white background for easy removal`, `16:5 aspect ratio`, `ultrawide crop`

### Example: Full Prompt for the Far Layer

```
Digital matte painting, cinematic wide shot, warm dusk palette,
desaturated shadows, golden-pink sky with volumetric clouds,
distant mountain silhouette at the horizon, strong atmospheric haze,
no foreground elements, no figures, no trees close to camera,
16:5 aspect ratio, horizontal panorama
```

### Example: Full Prompt for the Front Layer

```
Digital matte painting, cinematic, warm dusk palette, desaturated shadows,
close foreground — large fern fronds and mossy boulders in sharp focus,
high contrast, dark silhouette at bottom of frame, no sky visible,
no mid-ground terrain, transparent PNG background, isolated elements only
```

---

## The Four Depth Planes: What Each Should Contain

### Layer 1 — Far (depth 8, moves slowest)

This is the foundation of your scene. It should contain sky, clouds, a sun or moon, and the most distant horizon elements — mountain ranges, ocean horizon, desert plateaus. Everything here should be low-contrast and desaturated relative to the foreground. On Earth, atmosphere scatters light and makes distant objects bluer and paler. Simulate this even in fantastical scenes.

**What to include:** clouds, sky gradient, horizon line, distant mountains or water, mist.  
**What to exclude:** any object that has recognizable size or texture at normal viewing distance.

### Layer 2 — Mid (depth 5)

This is the scene's "establishing" plane — the element that tells the viewer where they are. For a forest scene, this is the treeline. For a city, this is the skyline. For a fantasy scene, this might be floating islands or castle spires.

**What to include:** treelines, building silhouettes, rolling terrain, mid-distance structures.  
**What to exclude:** sky, close-up foliage, foreground objects, figures.

### Layer 3 — Near (depth 2)

Objects in this plane have visible texture and form. This is where your scene gains specificity — individual trees, boulders, architectural columns, cliff faces. The depth separation from the mid layer is noticeable as the user scrolls.

**What to include:** specific terrain features, structures, individual large plants.  
**What to exclude:** sky, tiny background details, foreground small elements.

### Layer 4 — Front (depth 1, moves fastest)

This layer sits closest to the viewer and moves most aggressively with scroll. It should frame the hero content visually — think of it as the "vignette" layer. Large foreground silhouettes (tree branches, leaves, rock faces) work well. This layer must have a transparent background because the layers behind it need to show through.

**What to include:** large foreground elements with clear silhouettes, dark or shadowed subjects.  
**What to exclude:** sky, mid-ground elements, anything that should appear "far away."

---

## Google ImageFX

[Google ImageFX](https://aitestkitchen.withgoogle.com/tools/image-fx) uses Imagen and is freely accessible with a Google account. It produces high-quality matte painting style images with excellent prompt adherence.

**Workflow:**

1. Navigate to ImageFX and sign in.
2. Paste your style anchor plus the layer-specific depth cue and compositional constraint.
3. Request `white background` rather than transparent PNG — ImageFX does not export alpha channels.
4. Download the PNG.
5. Remove the background with `rembg` or remove.bg (see Background Removal section below).
6. Convert to AVIF with `ffmpeg` or `cavif`.

**Iterating weak layers:** If a generated layer has the wrong depth cue — for example, the mid layer has a sky bleed — add a negative prompt phrase: `no sky, no clouds, no horizon visible`. ImageFX allows you to click individual generated images and use them as seeds for variations. Use this to nudge a near-correct image toward the target without starting over.

**Converting to AVIF after download:**

```bash
ffmpeg -i layer-far.png -c:v libaom-av1 -crf 30 -b:v 0 \
  -still-picture 1 layer-far.avif
```

---

## Midjourney

Midjourney is well-suited to stylistic consistency because you can reuse the same `--style` code or `--sref` (style reference) URL across all four prompts.

**Key flags for this workflow:**

```
--ar 16:5          # Match the ultrawide hero aspect ratio
--no background    # Encourage isolated subject (not true transparency)
--style raw        # Reduces Midjourney's aesthetic "polish" for more neutral matte paintings
--q 2              # Full quality
```

**Example command for the far layer:**

```
/imagine prompt: digital matte painting, cinematic wide shot, 
warm dusk palette, golden-pink sky, volumetric clouds, 
distant mountain silhouette, atmospheric haze, 
no foreground elements, no figures --ar 16:5 --style raw --q 2
```

**Using Vary Region to isolate layers:** If a generated image has a beautiful sky but unwanted foreground elements, use the "Vary Region" button in the Midjourney UI. Select the foreground region and reprompt it with `empty, transparent, faded to white` to remove the intrusion without regenerating the whole image.

**Consistency between layers:** Start with the far layer. Once you have a result you like, copy the Job ID from that image and reference it with `--sref [image URL]` in subsequent layer prompts. This maintains color grading and stylistic details across all four planes.

---

## DALL-E 3 via ChatGPT

DALL-E 3, accessed through ChatGPT, has a notable advantage for consistency: it maintains conversational context. You can anchor your style in a single message and build all four layers in the same thread.

**Consistency technique:**

Start the thread with a reference message:

```
I'm creating a 4-layer parallax illustration in this style:
[describe or attach a reference image]
For each layer, I'll describe what should appear in it.
Please keep the color palette, lighting direction, and artistic style
identical across all layers.
```

Then generate each layer in subsequent messages:

```
Layer 1 (far): Only the sky and distant horizon. Warm dusk. No ground, no foreground.
Aspect ratio approximately 3:1 (wide). PNG if possible.
```

**Transparent PNG workaround:** DALL-E 3 does not natively export transparent PNGs. Always request a `white background` or `solid light grey background` so that background removal tools work cleanly. Avoid requesting gradients or complex backgrounds that match the foreground subject — this makes automated removal unreliable.

**White background removal:** After downloading, use `rembg` or Adobe Firefly's Remove Background tool (see below). DALL-E 3 images often have clean subject edges, making automated removal highly accurate.

---

## Adobe Firefly

Adobe Firefly has two significant advantages for this workflow:

1. **Commercial licensing.** Firefly is trained on licensed Adobe Stock images, making outputs safe for commercial use without additional rights clearance.
2. **Generative Fill for background removal.** You can select any region of an existing image and fill it with transparency or a solid color directly in Photoshop's AI-powered Generative Fill.

**Workflow for consistent layers:**

1. Generate the far layer using Firefly's text-to-image.
2. Download and note your prompt.
3. Open the downloaded image in Photoshop.
4. Use "Generative Fill" to remove any foreground intrusions: select the region, type `empty sky, atmospheric haze` as the fill prompt.
5. For the front layer, use Firefly's "Remove Background" button in Express or Firefly.adobe.com to get a clean alpha mask.

**Consistency between layers:** Firefly supports "Style Reference" — upload your far layer image as a style reference when generating mid, near, and front layers. The color temperature and texture grain will carry over reliably.

---

## Stable Diffusion (Local)

Running Stable Diffusion locally with [AUTOMATIC1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui) gives you the most control over the generation pipeline.

### img2img for Layer Isolation

If you have one strong layer image and want to derive a second layer from it (maintaining visual consistency), use img2img:

1. Load your far layer image as the input.
2. Write a new prompt for the mid layer: `[same style anchor], rolling hills treeline, no sky, no foreground`.
3. Set denoising strength to `0.55–0.70`. Lower values preserve more of the original (useful for color grading), higher values allow more compositional change.

### ControlNet Depth Maps for Consistent Perspective

Install [ControlNet](https://github.com/Mikubill/sd-webui-controlnet) and use the `depth` preprocessor to enforce consistent perspective across layers:

1. Generate the far layer without ControlNet.
2. Extract its depth map using the ControlNet preprocessor (set to `depth_midas`).
3. Use that depth map as a ControlNet condition when generating mid, near, and front layers. This ensures that the implied perspective — the horizon line, the vanishing point — is consistent between planes.

### rembg CLI for Background Removal

[rembg](https://github.com/danielgatis/rembg) is a Python CLI tool that removes backgrounds using the U2-Net model:

```bash
pip install rembg[cli]

# Remove background from a single image
rembg i layer-front-raw.png layer-front.png

# Batch remove backgrounds from all raw layer files
for f in layer-*-raw.png; do
  rembg i "$f" "${f/-raw/}"
done
```

rembg produces an RGBA PNG with the background replaced by transparency. Quality is excellent for subjects with clear silhouettes (foliage, rocks, architecture) and adequate for complex edge cases.

---

## Background Removal Tools

| Tool | Best for | Cost | Output |
|---|---|---|---|
| [remove.bg](https://www.remove.bg) | Clean subjects with clear edges | Freemium (50 free/mo) | RGBA PNG |
| `rembg` (Python CLI) | Batch processing, local privacy | Free, open source | RGBA PNG |
| Photoshop Generative Fill | Complex edges, manual refinement | Adobe subscription | RGBA PNG/PSD |
| GIMP Fuzzy Select | Simple backgrounds, manual | Free, open source | RGBA PNG |

**GIMP Fuzzy Select workflow for simple backgrounds:**

1. Open the image in GIMP.
2. Select "Fuzzy Select" (the magic wand tool, shortcut: `U`).
3. Click the background area. Adjust threshold until only background is selected.
4. `Select > Grow` by 1px to catch edge fringing.
5. `Select > Feather` by 1px for a softer edge.
6. Delete the selection to create transparency.
7. Export as PNG with "Save background color" unchecked.

---

## Post-Processing: Resizing, Transparency, and Edge Cleanup

### Resizing to correct dimensions

The hero images should match the viewport breakpoints. The recommended baseline is `2560 × 800 px` (a 16:5 ratio), which serves ultrawide monitors well and downscales cleanly for smaller viewports.

```bash
# Resize using ImageMagick, maintaining aspect ratio with white fill for portrait images
convert layer-far-raw.png -resize 2560x800^ \
  -gravity center -extent 2560x800 layer-far-resized.png
```

### Checking transparency

After background removal, verify the alpha channel is correct before converting to AVIF. A quick check in the terminal:

```bash
# Check if the PNG has an alpha channel
python3 -c "
from PIL import Image
img = Image.open('layer-front.png')
print(img.mode)  # Should be 'RGBA' for transparency
print('Alpha range:', img.split()[3].getextrema())
"
```

### Edge cleanup

Hard mask edges are the most common artifact from automated background removal. They appear as a thin halo of the original background color around the subject. To fix:

1. Open in Photoshop. Select the layer mask.
2. `Properties > Refine Mask`. Use "Smart Radius" and paint over hair/foliage edges.
3. In GIMP: `Filters > Enhance > Unsharp Mask` on the alpha channel alone can help sharpen soft, blurry edges.
4. For programmatic cleanup: `rembg` with the `--alpha-matting` flag produces better edges on complex subjects:

```bash
rembg i --alpha-matting layer-front-raw.png layer-front.png
```

---

## AVIF Conversion

AVIF (AV1 Image File Format) offers significantly better compression than PNG or WebP at equivalent quality, which matters when you are loading four hero images on page load.

### ffmpeg

```bash
# Single file conversion, CRF 30 (good quality/size balance for hero images)
ffmpeg -i layer-far.png -c:v libaom-av1 -crf 30 -b:v 0 \
  -still-picture 1 layer-far.avif

# CRF 28 for layers with fine detail (near, front)
ffmpeg -i layer-front.png -c:v libaom-av1 -crf 28 -b:v 0 \
  -still-picture 1 -pix_fmt yuva420p layer-front.avif
```

Note: For layers with transparency (`layer-near.avif`, `layer-front.avif`), use `-pix_fmt yuva420p` to preserve the alpha channel in the AVIF output. `libaom-av1` supports AVIF with transparency; `libsvtav1` does not.

### cavif (Rust, faster encoding)

[cavif](https://github.com/kornelski/cavif-rs) is a Rust-based AVIF encoder that is significantly faster than `libaom-av1` for batch work:

```bash
cargo install cavif

cavif --quality 72 layer-far.png -o layer-far.avif
cavif --quality 75 layer-front.png -o layer-front.avif
```

Quality 72–78 in cavif corresponds roughly to CRF 28–32 in libaom-av1.

### ImageMagick

```bash
convert layer-far.png -quality 80 layer-far.avif
```

ImageMagick AVIF support requires a build with `libheif`. Check with `convert -list format | grep AVIF`. Quality 75–85 is appropriate for hero layers.

### Quality settings reference

| Layer | Recommended CRF (ffmpeg) | cavif quality | Target file size |
|---|---|---|---|
| Far | 32 | 68 | < 80 KB |
| Mid | 30 | 72 | < 120 KB |
| Near | 28 | 75 | < 150 KB |
| Front | 28 | 75 | < 200 KB |

---

## Batch Conversion Shell Script

Save this as `convert-layers.sh` in your project root. It handles all four layers, preserving transparency where needed:

```bash
#!/usr/bin/env bash
set -euo pipefail

LAYERS=(far mid near front)
# CRF values per layer: far gets more compression, front gets less
declare -A CRF=([far]=32 [mid]=30 [near]=28 [front]=28)
# Which layers need alpha channel preserved
declare -A ALPHA=([far]=0 [mid]=0 [near]=1 [front]=1)

INPUT_DIR="./layers-png"
OUTPUT_DIR="./docs/assets/parallax"
mkdir -p "$OUTPUT_DIR"

for layer in "${LAYERS[@]}"; do
  input="$INPUT_DIR/layer-${layer}.png"
  output="$OUTPUT_DIR/layer-${layer}.avif"

  if [[ ! -f "$input" ]]; then
    echo "SKIP: $input not found"
    continue
  fi

  crf="${CRF[$layer]}"
  alpha="${ALPHA[$layer]}"

  if [[ "$alpha" -eq 1 ]]; then
    pix_fmt="yuva420p"
  else
    pix_fmt="yuv420p"
  fi

  echo "Converting $layer (CRF $crf, pix_fmt $pix_fmt) ..."
  ffmpeg -y -i "$input" \
    -c:v libaom-av1 \
    -crf "$crf" \
    -b:v 0 \
    -still-picture 1 \
    -pix_fmt "$pix_fmt" \
    "$output"

  size=$(du -sh "$output" | cut -f1)
  echo "Done: $output ($size)"
done

echo ""
echo "All layers converted. File sizes:"
du -sh "$OUTPUT_DIR"/layer-*.avif
```

Make it executable and run it:

```bash
chmod +x convert-layers.sh
./convert-layers.sh
```

---

## Quality Checking

### File size targets

| Layer | Maximum recommended size |
|---|---|
| Far | 80 KB |
| Mid | 120 KB |
| Near | 150 KB |
| Front | 200 KB |

Check all four at once:

```bash
du -sh docs/assets/parallax/layer-*.avif
```

If any layer exceeds its target, re-encode with a higher CRF value. Increase by increments of 2 (CRF 30 → 32 → 34) and compare the result visually in the browser before committing.

### Visual checks in browser before building

Never judge parallax layer quality from an image editor alone. The parallax motion reveals compression artifacts and edge issues that are invisible in a static preview. Before running `mkdocs build`, open the layer images directly in a browser tab:

1. Drag each AVIF file onto a browser tab.
2. Look for:
   - Compression blocking on smooth gradients (especially in sky layers)
   - Fringing or halo artifacts around transparent edges
   - Color banding in atmospheric haze areas
3. For transparency layers, view against a dark background (right-click the image, "Inspect", set `background: #000` on the `body`).

---

## Common Issues and Fixes

### Mismatched lighting between layers

**Symptom:** The sun is on the left in the far layer and on the right in the front layer. The composite looks physically impossible.

**Fix:** Establish lighting direction in your style anchor prompt and state it explicitly: `light source from the upper left, shadows falling right`. Include this phrase verbatim in all four prompts.

### Hard edges on transparent layers

**Symptom:** The near or front layer has a visible rectangular border, or a hard pixelated edge around foreground objects.

**Fix:** Re-run `rembg` with `--alpha-matting`. If using Photoshop, use Refine Edge with a 2px feather. For edges that remain problematic, apply a thin `box-shadow: inset 0 0 20px rgba(0,0,0,0.5)` in CSS to blend the edges into the dark scene background.

### Foreground objects too large

**Symptom:** The front layer's foreground elements dominate the screen and obscure the hero text.

**Fix:** In your prompt, add `partial crop, only the bottom edge of foreground elements visible, maximum 25% of frame height`. Then use CSS `object-position: bottom` on the `<img>` element to anchor the crop to the bottom of the layer.

### Horizon mismatch

**Symptom:** The horizon line in the far layer is at 40% of the image height but the treeline in the mid layer implies a horizon at 60%.

**Fix:** Before generating, sketch the intended horizon line percentage (typically 35–45% from the top for a landscape scene). Include it in each prompt: `horizon line at 40% from the top of the frame`.

---

## Claude Code Skills: Automating Prompt Generation

This repository includes a set of Claude Code skills in `skills/generate-prompts/` that automate the process of generating all four layer prompts from a single scene description. Run the skill from your project root:

```bash
# From the project root, in a Claude Code session
/generate-prompts "misty Japanese cedar forest at dawn, watercolor style"
```

The skill outputs four ready-to-paste prompts, one for each depth plane, with the style anchor locked and depth cues automatically inserted. It also outputs a suggested `--sref` Midjourney workflow and an estimated file size budget for the scene complexity.

The skill source lives at `skills/generate-prompts/index.md` and is straightforward to customize — edit the `DEPTH_PLANES` array to adjust what compositional constraints are applied to each layer.

---

## Testing the Composite Before Building

Before running `mkdocs serve` or `mkdocs build`, stack your four PNG layers in any image editor to verify that the composite reads correctly as a scene. This reveals horizon mismatches, lighting inconsistencies, and foreground scale problems without needing to run the full site.

### Figma workflow

1. Create a frame at `2560 × 800 px`.
2. Import all four PNG layers.
3. Stack them: far at the bottom, front at the top.
4. Set each layer's blending mode to `Normal`, opacity to `100%`.
5. Toggle layers on and off to check that each plane contributes meaningfully without the others.
6. Add a text layer at the hero text position to verify the foreground layer does not obscure the headline.

### Command-line composite check

```bash
# Flatten all four layers into a composite PNG using ImageMagick
convert \
  docs/assets/parallax/layer-far.avif \
  docs/assets/parallax/layer-mid.avif \
  docs/assets/parallax/layer-near.avif \
  docs/assets/parallax/layer-front.avif \
  -flatten composite-preview.png

open composite-preview.png   # macOS
xdg-open composite-preview.png  # Linux
```

If the composite looks good as a flat image, the parallax will look good in motion. The CSS animation only adds depth — it does not fix compositional problems in the source images.

---

## Summary Checklist

Before committing your layer assets:

- [ ] All four layers share the same style anchor (color palette, lighting direction, artistic style)
- [ ] Far layer: sky only, no foreground, atmospheric haze
- [ ] Mid layer: terrain/treeline only, no sky, no foreground
- [ ] Near layer: specific terrain features, transparent background
- [ ] Front layer: isolated foreground elements, transparent background (`yuva420p` AVIF)
- [ ] All AVIF files are under their size targets (80 / 120 / 150 / 200 KB)
- [ ] No hard edges on transparent layers (test against dark background)
- [ ] Horizon line is consistent across all layers
- [ ] Composite preview in Figma or ImageMagick looks like a single coherent scene
- [ ] Layers visually tested in browser as AVIFs (not just PNG intermediates)
