---
title: CSS variables
description: Complete reference for every CSS custom property used in scroll-zoom-thing - parallax variables, Material color tokens, and typography.
---

# CSS variables

Every CSS custom property the template reads or sets, grouped by purpose. Override these in your own stylesheet to customize the look without forking the template.

To override a variable, declare it on `:root` (global) or on `.md-parallax` (scoped to the hero):

```css
:root {
  --md-parallax-perspective: 3rem;
}
```

Then load your stylesheet after the template's stylesheets in `mkdocs.yml`:

```yaml
extra_css:
  - assets/stylesheets/home.css
  - assets/pai-theme.css
  - assets/your-overrides.css
```

## Parallax variables

These variables control the 3D effect itself. They live in `src/assets/stylesheets/home.css`.

| Variable | Type | Default | Effect |
|---|---|---|---|
| `--md-parallax-perspective` | length | `2.5rem` | Distance from the viewer to the projection plane. Smaller values exaggerate the 3D effect; larger values flatten it. Set on `.md-parallax`. |
| `--md-parallax-depth` | integer | per-layer (`8`, `5`, `2`, `1`) | The Z-depth of an individual layer, set per `.md-parallax__layer`. Higher values move the layer further back, which under perspective makes it appear smaller and parallax slower. |
| `--md-image-position` | percentage | `50%` | Horizontal focal point of the hero image, applied as `object-position`. `50%` centers; `25%` shifts the focus left; `75%` shifts right. Useful for art with off-center subjects. |

### How depth becomes scale

Each layer is transformed with:

```css
transform:
  translateZ(calc(var(--md-parallax-depth) * -1rem))
  scale(calc(var(--md-parallax-depth) + 1));
```

The `scale` factor cancels the perspective shrink so all layers render at the original size, while parallax speed varies with depth. Layer 1 (closest) moves nearly with the scroll; layer 8 (furthest) moves slowest.

### Layer depths in the default hero

| Layer | Depth | File |
|---|---|---|
| 1 (sky / background) | `8` | `src/assets/hero/layer-1.avif` |
| 2 (mid-back) | `5` | `src/assets/hero/layer-2.avif` |
| 3 (mid-front) | `2` | `src/assets/hero/layer-3.avif` |
| 4 (foreground) | `1` | `src/assets/hero/layer-4.avif` |

Lower depth equals closer to the viewer. The foreground layer at depth `1` parallaxes most aggressively as you scroll.

## Material color tokens

scroll-zoom-thing inherits the Material for MkDocs color system. These tokens are read by Material's own CSS and by `src/assets/pai-theme.css` for the hero color treatment. Override them in your theme override file.

### Background and surface

| Variable | Type | Default | Effect |
|---|---|---|---|
| `--md-default-bg-color` | color | white / dark slate | Page background. The hero section sits on top of this; transparent areas in layer images reveal it. |
| `--md-default-bg-color--light` | color | derived | Lightened variant for cards and surface elevation. |
| `--md-default-bg-color--lighter` | color | derived | Even lighter variant for hover states. |
| `--md-default-bg-color--lightest` | color | derived | Lightest variant, used sparingly. |
| `--md-code-bg-color` | color | gray | Background of inline and block code. |

### Foreground and text

| Variable | Type | Default | Effect |
|---|---|---|---|
| `--md-default-fg-color` | color | near-black | Primary body text color. |
| `--md-default-fg-color--light` | color | derived | Secondary text - captions, metadata. |
| `--md-default-fg-color--lighter` | color | derived | Tertiary text - hints, placeholders. |
| `--md-default-fg-color--lightest` | color | derived | Rarely used, mostly for borders. |
| `--md-typeset-color` | color | inherits `--md-default-fg-color` | Color of body content rendered by Material's typeset module. |

### Brand and accent

| Variable | Type | Default | Effect |
|---|---|---|---|
| `--md-primary-fg-color` | color | theme palette | Header background, primary buttons, hero accent overlay. |
| `--md-primary-fg-color--light` | color | derived | Lighter variant for hover. |
| `--md-primary-fg-color--dark` | color | derived | Darker variant for active states. |
| `--md-primary-bg-color` | color | white | Text color on primary backgrounds (header text). |
| `--md-primary-bg-color--light` | color | derived | Secondary text on primary backgrounds. |
| `--md-accent-fg-color` | color | theme palette | Links, focus rings, callout accents. |
| `--md-accent-fg-color--transparent` | color | derived | Translucent variant for hover backgrounds. |
| `--md-accent-bg-color` | color | white | Text on accent backgrounds. |

### Hero-specific color tokens

`src/assets/pai-theme.css` declares the color treatment for the hero. Override these to retheme without touching layout.

| Variable | Type | Default | Effect |
|---|---|---|---|
| `--md-hero-bg-color` | color | dark navy | Solid color shown behind the parallax layers if any AVIF fails to load. |
| `--md-hero-fg-color` | color | white | Color of headline and tagline text overlaid on the hero. |
| `--md-hero-overlay-color` | color | semi-transparent black | Gradient overlay improving text contrast against busy art. |

### Code and syntax highlighting

Material exposes a long list of `--md-code-hl-*` tokens (keyword, string, number, comment, operator, etc.). These are inherited from the chosen palette and rarely need overriding for a parallax template. See [Material's color reference](https://squidfunk.github.io/mkdocs-material/setup/changing-the-colors/) for the full list.

## Typography

The template does not impose a custom font stack. It inherits Material's defaults, which can be overridden through `mkdocs.yml`:

```yaml
theme:
  name: material
  font:
    text: Inter
    code: JetBrains Mono
```

| Variable | Type | Default | Effect |
|---|---|---|---|
| `--md-text-font-family` | string | `-apple-system, BlinkMacSystemFont, Helvetica, Arial, sans-serif` | Body text stack. Set indirectly via `theme.font.text` in `mkdocs.yml`. |
| `--md-code-font-family` | string | system monospace | Code text stack. Set via `theme.font.code`. |
| `--md-typeset-font-size` | length | `0.8rem` (Material default) | Base font size for body content. Inherited from Material; override with caution. |
| `--md-hero-font-size` | length | `clamp(2rem, 6vw, 4rem)` | Headline size in the hero. Defined in `pai-theme.css`. Uses `clamp` to scale fluidly. |
| `--md-hero-line-height` | number | `1.1` | Tight line-height for large hero headings. |

### Setting custom fonts

To use a self-hosted font, add it via `extra_css`:

```css
@font-face {
  font-family: "MyFont";
  src: url("/assets/fonts/myfont.woff2") format("woff2");
  font-display: swap;
}

:root {
  --md-text-font-family: "MyFont", sans-serif;
}
```

## Variables you should not override

- `--md-parallax-depth` on the `.md-parallax__layer` element - this is set per layer in the template; changing it globally breaks the depth ordering.
- Internal Material variables prefixed with `--md-` and not listed above. They may change between Material releases.

## See also

- [How it works](../overview/how-it-works.md) for the math behind perspective and depth
- [Theme guide](../guides/theme.md) for a step-by-step retheme
- [File structure](file-structure.md) for where these declarations live
