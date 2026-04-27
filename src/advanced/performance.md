---
title: Performance
description: AVIF size targets, preload hints, compositor layers, and Lighthouse benchmarks for the parallax hero.
---

# Performance

The parallax hero is the most expensive thing on the page. Four AVIF
layers, a `perspective` transform, and a scroll-driven scale across
each layer add up quickly if you are not careful. This guide covers
the specific things that move the numbers on a scroll-zoom-thing
site, in rough order of impact.

## What you are optimizing for

The targets that matter on a hero-driven landing:

- **Largest Contentful Paint (LCP):** under 2.5 s on a mid-tier mobile
  device, ideally under 1.8 s. The LCP element is almost always one
  of the hero layers, usually the foreground at depth 1 or 2.
- **Cumulative Layout Shift (CLS):** under 0.05. The hero's fixed
  aspect ratio makes this easy if you set dimensions correctly.
- **Interaction to Next Paint (INP):** under 200 ms. The template is
  CSS-only, so this is rarely a problem unless you have added
  scripted interactions on top.
- **Total transferred bytes for the hero:** under 400 KB across all
  four layers, ideally under 250 KB. This is the single biggest lever.

A well-tuned site lands at Lighthouse Performance 95+ on desktop and
90+ on mid-tier mobile. Below those numbers, look at the layers first.

## AVIF size targets

The four layers have different size budgets because they cover
different amounts of the viewport:

| Depth | Typical role         | Target size | Hard ceiling |
|-------|----------------------|-------------|--------------|
| 8     | Background           | 60–100 KB   | 150 KB       |
| 5     | Mid-ground           | 40–80 KB    | 120 KB       |
| 2     | Foreground subject   | 30–60 KB    | 100 KB       |
| 1     | Near-camera detail   | 15–40 KB    | 60 KB        |

These are AVIF sizes, not PNG. If you are exporting from a tool that
defaults to PNG, expect PNG sizes 5x to 15x larger. Convert to AVIF
before measuring.

A reasonable encoder command:

```bash
avifenc --min 20 --max 32 --speed 4 input.png output.avif
```

`--min` and `--max` set the quantizer range (lower is higher quality);
`20`–`32` is a good default for hero imagery. `--speed 4` is the
quality/speed tradeoff for the encoder itself, not the output. Run
once at `--speed 0` for the production export.

## Resolution

Layers should be exported at **2x the largest viewport you target**,
not larger. For most sites:

- Desktop hero rendered at 1920 px wide → export layers at ~2560 px
  wide. Going to 3840 px doubles file size for a barely visible
  improvement on 4K screens, which are a small fraction of traffic.
- If your hero is constrained to a max-width of 1440 px, export at
  1920 px and stop.

The depth-1 layer can be smaller in pixel dimensions than the others
if it does not cover the full width. Crop it tightly before exporting.

## Preload hints

The hero layers are render-blocking for LCP whether you mark them so
or not. Tell the browser explicitly:

```html
<link rel="preload" as="image" href="/assets/hero/depth-1.avif" type="image/avif" fetchpriority="high">
<link rel="preload" as="image" href="/assets/hero/depth-2.avif" type="image/avif" fetchpriority="high">
```

Preload only the two foreground layers (depths 1 and 2). The
background layers (5 and 8) are larger and visually less important
in the first paint; preloading all four can crowd the connection
and delay the layer that actually wins LCP.

`fetchpriority="high"` is supported in Chromium and Safari and
ignored elsewhere. It is a small, free win.

If you serve responsive variants via `<picture>`, preload the
variant that matches the most common viewport. Preloading every
variant is worse than preloading none.

## Compositor layers

The parallax effect uses `transform: translateZ()` on each layer.
This implicitly promotes each layer to a compositor layer, which is
what you want: the browser composites them on the GPU instead of
repainting them on every scroll frame.

Two things break this:

1. Setting `overflow: hidden` on an ancestor that also has a
   transform. The browser may decide to flatten the stack. Check in
   DevTools (Layers panel) that each depth is a separate layer.
2. Animating properties other than `transform` and `opacity`. If you
   animate `top`, `width`, or `filter`, the browser repaints rather
   than recomposites. Stick to `transform` and `opacity` for hero
   animations.

For very large layers, hint explicitly:

```css
.hero-layer {
  will-change: transform;
}
```

Use `will-change` sparingly. Setting it on every element costs more
than it saves; setting it on the four hero layers is fine.

## Avoiding layout shift

The hero must reserve its space before the layers load. Two ways:

```css
.hero {
  aspect-ratio: 16 / 9;
}
```

Or, for older browsers, set explicit `width` and `height` on the
container and let the layers fill it absolutely.

Each `<img>` inside the hero should also have `width` and `height`
attributes set to its intrinsic dimensions, even though CSS overrides
them. This lets the browser compute the layout before the image
decodes.

## Lazy-loading the rest

Anything below the hero that is not in the initial viewport should
be lazy-loaded:

```html
<img src="..." loading="lazy" decoding="async" width="..." height="...">
```

MkDocs Material does this for content images already. The thing to
watch is custom partials you have added. Audit them for images
without `loading="lazy"`.

## Fonts

The Material theme loads Roboto and Roboto Mono by default. If you
swap them, self-host rather than fetching from Google Fonts. Add
`font-display: swap` and preload the WOFF2 files used in the hero
copy:

```html
<link rel="preload" as="font" href="/assets/fonts/your-font.woff2" type="font/woff2" crossorigin>
```

Font CLS is rare on this template because the hero copy is short, but
it is worth the one line of HTML.

## Lighthouse benchmarks

A reference run on a clean site with the defaults:

| Metric                | Mobile | Desktop |
|-----------------------|--------|---------|
| Performance score     | 92     | 99      |
| LCP                   | 1.6 s  | 0.7 s   |
| CLS                   | 0.00   | 0.00    |
| Total Blocking Time   | 0 ms   | 0 ms    |
| Hero transferred      | 240 KB | 240 KB  |

If your numbers are meaningfully worse, the usual suspects are: PNG
layers instead of AVIF, layers larger than 2x viewport, no preload
hints, or a custom partial dragging in render-blocking JavaScript.

## When to stop

The hero will never be free. A page with four image layers is more
expensive than a page with none. The goal is to make it cheap, not
free. Once you are at 95+ Performance and under 250 KB of hero
transfer, the remaining wins are not worth the effort.
