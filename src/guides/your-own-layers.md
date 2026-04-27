---
title: Using Your Own Layers
description: A complete guide to designing, exporting, and wiring up your own parallax layers — image formats, dimensions, transparency, depth assignment, object-position tuning, and the picture element structure.
---

# Using Your Own Layers

This page is the practical handbook for replacing the default layers with your own art. It covers image format choices, the dimensions to target, transparency rules, how to pick depth values, the `object-position` cropping system, the `<picture>` markup, and the common mistakes that break the effect.

If you have already read [How It Works](../overview/how-it-works.md), you know that the parallax effect comes from layers at different `translateZ` distances inside a perspective scroll container. This page is about the layers themselves — what they should contain, how big they should be, and how to wire them into the template.

---

## Why four layers

Four is the practical sweet spot. Here is why.

Below four layers, the depth effect is subtle. Two layers feel like a tilt, three feel like a shallow scene, four feel like real depth. Above four, the eye stops resolving the additional planes — a fifth layer at depth 6 sits between depth 5 and depth 8 in a way most viewers cannot distinguish from a slight wobble in either neighbor. You pay the file size cost for depth nobody perceives.

The four-plane mental model also matches the way scenes naturally decompose:

| Plane | Role |
|---|---|
| Far | Sky, horizon, distant geometry. Sets atmosphere. |
| Mid | Architecture, terrain, water. Establishes the world. |
| Near | Foreground elements close enough to feel approachable. |
| Front | Framing objects (plants, edges) — give the viewer a sense of being inside the scene. |

A photographer composing a single-frame image instinctively places subject matter at three or four perceptual depths. The parallax just literalizes that mental model into separate layers.

---

## Image format comparison

The template uses AVIF for layer assets, with PNG and WebP available as fallbacks. Here is the trade-off:

| Format | Compression | Alpha (transparency) | Browser support | Recommended use |
|---|---|---|---|---|
| **AVIF** | Best — typically 30–50% smaller than WebP at equivalent quality | Yes, AV1-compressed | Universal in modern browsers (2023+) | Primary format for layers |
| **WebP** | Good — typically 25% smaller than PNG at equivalent quality | Yes, separate alpha channel | Universal | Fallback for older browsers |
| **PNG** | Lossless | Yes, native | Universal | Last-resort fallback or for hand-painted assets |
| **JPEG** | Good for photos but no alpha | No | Universal | Only for the far layer (no transparency needed) |

For a 4-layer setup at 2400×800 each:

| Format | Approximate file size per layer |
|---|---|
| PNG with alpha | 800 KB – 2 MB |
| WebP with alpha | 200 – 500 KB |
| AVIF with alpha | 80 – 200 KB |

AVIF is the right default. The savings compound — a 4-layer hero in AVIF totals ~600 KB, the same hero in PNG totals 4–8 MB. On mobile networks, that difference is noticeable on first load.

---

## Dimensions and aspect ratio

The minimum width depends on the depth value. A layer at depth 8 is scaled by `9×`, so the source image needs to be at least 1/9 the rendered viewport width — but it also needs to be wide enough to cover the viewport horizontally without showing edges. For a 1920px-wide viewport:

- Depth 8: source width ≥ 1920 / 9 ≈ 215px... but the layer at depth 8 takes up `100vw` after scaling, so the source still needs to fill that scaled box. Practically, source width ≥ 1920px is the safe floor, with 2400–3000px being ideal for high-DPI displays.

The reasoning generalizes: target a panoramic source at least 1920–2400px wide. The aspect ratio should be wide — 16:5 or wider. Tall images do not work well because the parallax travels primarily on the Y axis, but the layer scaling pushes the image wider in the viewport, not taller. A square or portrait source ends up cropped strangely as the user scrolls.

| Layer | Ideal dimensions | Aspect ratio |
|---|---|---|
| Far | 2400×800 | 3:1 |
| Mid | 2400×900 | ~2.7:1 |
| Near | 2400×1000 | ~2.4:1 |
| Front | 2400×1100 | ~2.2:1 |

The numbers shift slightly per layer because deeper layers need more horizontal coverage (their scale factor pushes more pixels off-screen), and front layers benefit from extra vertical padding to prevent crop on tall viewports.

---

## Transparency rules

Three of the four layers require transparency. The far background does not.

| Layer | Transparency required? | Why |
|---|---|---|
| Far | No | Fills the entire frame as the deepest plane |
| Mid | Yes | Must show the far layer behind it |
| Near | Yes | Must show the mid and far layers behind it |
| Front | Yes | Must show everything behind it |

If a layer that should be transparent has a solid background, you get a rectangular cutout effect — the solid rectangle paints over everything behind it where the actual subject does not extend. The eye reads this as a flat shape pasted over the scene, not a depth plane.

AVIF supports alpha as a separately compressed AV1 channel. Modern AVIF encoders preserve transparency cleanly. WebP supports alpha as an extra channel as well. PNG supports alpha natively (RGBA mode).

When exporting from a tool that doesn't natively output AVIF with alpha (some image editors flatten on export), check the output:

```bash
# Verify AVIF has alpha — should print "yuva" or "rgba"
ffprobe -v quiet -select_streams v:0 -show_entries stream=pix_fmt 1-far@4x.avif
```

If the format reports `yuv420p` (no alpha), re-export with the alpha channel preserved.

---

## The `@4x` naming convention

The filenames use a `@4x` suffix:

```
1-landscape@4x.avif
2-plateau@4x.avif
5-plants-1@4x.avif
6-plants-2@4x.avif
```

This convention comes from iOS asset catalogs, where `@2x` and `@3x` mark high-DPI source images. It has no browser meaning — the browser does not change behavior based on the filename. The suffix exists to communicate to humans (and to tooling) that these are full-resolution sources intended to scale across display densities. It is purely documentation in the filename.

You can rename them to anything you want. Just update the `srcset` paths in `home.html`. The skill scripts (`skills/convert-images/`) follow the convention, so keeping it makes the automated pipelines just work.

---

## Selecting depth values

Each layer's `--md-parallax-depth` controls how far back it sits in 3D space, which controls how slowly it scrolls. Higher = slower.

The relationship is not linear. The scroll rate at depth `d` is approximately:

```
scroll_rate = 1 / (depth + 1)
```

So:

| Depth | Approximate scroll rate |
|---|---|
| 0 | 100% (no parallax) |
| 1 | 50% |
| 2 | 33% |
| 5 | 17% |
| 8 | 11% |
| 12 | 8% |

The default values (`8`, `5`, `2`, `1`) give a noticeable spread between layers — the far background drifts at 11%, the foreground at 50%. Each layer feels distinct from its neighbors.

A common mistake is clustering depth values too closely:

| Bad: depth values too close | Better: spread the values |
|---|---|
| `4`, `3`, `2`, `1` | `8`, `5`, `2`, `1` |

In the bad case, the layers at depths 4, 3, 2, 1 all scroll at fairly similar rates (20%, 25%, 33%, 50%) — the eye has trouble separating them. In the better case, the gap between rates is large enough to read as distinct depth.

For wider viewports, you can push the far layer to depth 10 or 12 to make the parallax more pronounced. For mobile, depth 6 or 7 on the far layer often feels better because the smaller viewport makes high-depth parallax read as too slow.

---

## `object-position` as crop control

The `--md-image-position` variable maps to `object-position` on the layer image:

```css
.mdx-parallax__image {
  object-fit: cover;
  object-position: var(--md-image-position, 50%);
}
```

`object-fit: cover` scales the image to fill the layer box, cropping whatever does not fit. `object-position` controls which part of the cropped image is shown:

| Value | Shows |
|---|---|
| `0%` | Left edge of the source image |
| `50%` (default) | Horizontal center |
| `100%` | Right edge |
| `25%` | Roughly the left third |
| `70%` | Roughly the right third |

For a wide panoramic source, the layer box is narrower than the source, so `object-position` chooses which horizontal slice is visible.

You set this independently per layer in the `<picture>` style attribute:

```html
<picture
  class="mdx-parallax__layer"
  style="--md-parallax-depth: 8; --md-image-position: 70%;"
>
  ...
</picture>
```

A typical tuning loop:

1. Open the site, scroll the hero, identify the most important focal point in each layer image.
2. Note where that focal point sits horizontally — left, center, right.
3. Adjust `--md-image-position` to bring that focal point into view at the user's normal viewport width.
4. Test on multiple viewport widths — what looks centered at 1920px may be cropped differently at 1280px.

---

## Scene composition

Beyond format and dimensions, the layers need to compose as a coherent scene.

**Horizon alignment.** If your far layer has a horizon at 60% from the top, your mid layer should also place its mid-distance scenery roughly at 60% from the top. Mismatched horizons read as a glitch — the eye expects the perspective lines to converge.

**Foreground anchoring.** Front and near layers should anchor at the bottom of the frame. The hero text sits at the bottom of the viewport, and the front layer often acts as a frame around or below it. If your foreground objects float in the middle of the frame, they read as floating, not framing.

**Color consistency.** All four layers should share the same lighting direction, color temperature, and saturation. A dawn-lit far layer paired with a midday-lit foreground breaks the illusion. When generating layers with AI, anchor every prompt to the same lighting description (`"soft dawn light, cool blue-purple palette"`) and stick to that anchor across all four prompts.

**Atmospheric perspective.** Real scenes have less contrast and more blue-shift in distant elements (atmospheric haze). If your far layer is as crisp and saturated as your foreground, the brain reads them as the same distance. Reduce contrast and saturation on the far layer to mimic real-world atmospheric perspective.

---

## Edge handling on transparent layers

When a layer scales up (via `scale(depth + 1)`), any hard edge in the alpha channel becomes much larger and more visible. A clean cut-out at 100% may show jagged or rectangular edges at 9× scale.

Mitigations:

- **Feather the alpha by 2–4 pixels** before exporting. Soft edges scale gracefully; hard edges do not.
- **Avoid hard horizontal lines at the top or bottom** of transparent layers. They become visible bands when the layer scales beyond viewport bounds.
- **Avoid solid edge geometry** like a rectangular building wall touching the image edge. When scaled, the wall appears to extend off-canvas in a way the eye reads as wrong.

For Photoshop: Layer mask → blur the mask by 2–3px, or use Refine Edge with a small feather radius. For Figma: convert to a frame, blur the alpha with a Gaussian blur effect on the mask. For affine tools: most have an "expand selection" or "feather" option in the alpha channel toolset.

---

## Testing layers before AVIF conversion

Convert to AVIF only after the composition is right. AVIF conversion is irreversible (you can re-export from the source PNG, but you can't recover the original from the AVIF).

To preview the composite:

1. Open all 4 PNGs in Figma, Photoshop, GIMP, or Affinity Designer
2. Stack them with the far layer at the bottom, front on top
3. Crop the composite to a panoramic aspect ratio (16:9 or 21:9)
4. Verify the scene reads as coherent depth, not as four pasted shapes
5. Check that horizons align and lighting is consistent

If the composite looks right, convert to AVIF. If it looks wrong, fix the source files first.

---

## File placement

MkDocs copies everything under `docs/assets/` to the build output verbatim. Drop your layer files at:

```
docs/
└── assets/
    └── hero/
        ├── 1-far@4x.avif
        ├── 2-mid@4x.avif
        ├── 3-near@4x.avif
        └── 4-front@4x.avif
```

After build:

```
_site/
└── assets/
    └── hero/
        ├── 1-far@4x.avif
        └── ...
```

Reference them in `home.html` with paths relative to the site root:

```html
<source srcset="{{ 'assets/hero/1-far@4x.avif' | url }}" type="image/avif">
```

The `| url` Jinja2 filter resolves the path correctly regardless of whether the site is deployed at the root or in a subdirectory. Without it, paths break under custom domains or path-prefixed deployments.

**Linux is case-sensitive.** `1-Far@4x.avif` and `1-far@4x.avif` are different files. GitHub Pages and most production hosts run Linux. macOS is case-insensitive, so a typo on macOS can pass local testing and break in production. Use lowercase filenames and consistent capitalization to avoid the trap.

---

## The `<picture>` element

Each layer in `home.html` looks like this:

```html
<picture
  class="mdx-parallax__layer"
  style="--md-parallax-depth: 8; --md-image-position: 70%;"
>
  <source srcset="{{ 'assets/hero/1-far@4x.avif' | url }}" type="image/avif">
  <source srcset="{{ 'assets/hero/1-far@4x.webp' | url }}" type="image/webp">
  <img src="{{ 'assets/hero/1-far@4x.png' | url }}"
       alt=""
       class="mdx-parallax__image"
       draggable="false">
</picture>
```

The `<picture>` element gives you progressive enhancement:

- Browsers that support AVIF use the first `<source>`
- Browsers that support WebP but not AVIF use the second `<source>`
- Browsers that support neither (very rare) fall back to the `<img>` PNG

The `alt=""` is intentional. Layer images are decorative — the semantic content lives in the hero text, which is a sibling element. An empty alt tells assistive technology to skip the image. A non-empty alt would make screen readers announce four meaningless image descriptions before getting to the actual hero copy.

`draggable="false"` prevents the browser from initiating an image drag when the user accidentally clicks-and-drags on a layer. Without it, the user can grab a layer and pull it across the page, which breaks the parallax illusion.

---

## Adding a WebP fallback

If you need to support older browsers, encode WebP versions:

```bash
for f in docs/assets/hero/*.png; do
  cwebp -q 80 "$f" -o "${f%.png}.webp"
done
```

Add the WebP `<source>` between the AVIF source and the `<img>`:

```html
<source srcset="{{ 'assets/hero/1-far@4x.avif' | url }}" type="image/avif">
<source srcset="{{ 'assets/hero/1-far@4x.webp' | url }}" type="image/webp">
<img src="{{ 'assets/hero/1-far@4x.png' | url }}" ...>
```

Order matters. The browser uses the first source it can decode. AVIF first, WebP next, PNG fallback last.

---

## Common mistakes

| Mistake | What happens | Fix |
|---|---|---|
| Forgetting transparency on the mid layer | Solid rectangle paints over the far layer | Re-export with alpha channel |
| Depth values too close together | Layers feel like one plane | Spread to 8/5/2/1 or wider |
| Mismatched lighting between layers | Scene reads as pasted, not unified | Anchor lighting in every AI prompt |
| Hard edges on transparent layers | Visible cutouts at scale | Feather alpha by 2–4px |
| Square or portrait source images | Wrong horizontal coverage at scale | Use 16:5 or wider panoramas |
| Wrong file path in home.html | Layer fails to load (404) | Check Network tab, verify case |
| Non-`@4x` source resolution | Pixelation on retina displays | Source ≥ 2400px wide |
| No `<source type="image/avif">` | All browsers download the PNG | Add the AVIF source first |

---

## Swapping layers without breaking the site

A clean swap procedure:

1. Place new AVIF files in `docs/assets/hero/` alongside the old ones
2. Update the four `<source>` paths in `home.html` to point to new files
3. Update `--md-parallax-depth` and `--md-image-position` per layer
4. Run `mkdocs serve` and open in a browser
5. Scroll the hero and check each layer feels right
6. Build with `mkdocs build` and verify no errors
7. Once the new layers are confirmed, delete the old AVIF files
8. Commit the result

If a layer fails to load, open DevTools → Network and filter by `avif`. A 404 means the path in `home.html` doesn't match the file in `docs/assets/hero/` — most often a case-sensitivity issue or a typo.

---

## Quick reference

| Property | Where set | Default | Notes |
|---|---|---|---|
| Depth | `--md-parallax-depth` inline on `<picture>` | `8`, `5`, `2`, `1` | Higher = slower scroll |
| Crop | `--md-image-position` inline on `<picture>` | `50%` | Horizontal `object-position` |
| Source format | `<source type="...">` | AVIF first | WebP and PNG as fallbacks |
| File path | `srcset` and `src` attributes | `assets/hero/N-name@4x.avif` | Use `{{ ... | url }}` filter |
| Alt text | `<img alt="">` | empty | Layers are decorative |
| Drag behavior | `<img draggable="false">` | disabled | Prevents accidental drag |

The defaults work. Most projects only need to swap the four AVIF files and tune the two CSS variables per layer. Everything else is rarely worth touching.
