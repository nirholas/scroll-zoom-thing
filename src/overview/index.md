---
title: Overview
description: scroll-zoom-thing is a pure-CSS 3D parallax hero template built on MkDocs Material, with no JavaScript and AVIF image layers.
---

# Overview

scroll-zoom-thing is a documentation site template that renders a 3D parallax
hero entirely in CSS. It is built on top of [MkDocs Material](https://squidfunk.github.io/mkdocs-material/),
which means you keep every feature of the underlying theme - search, navigation,
admonitions, code highlighting, dark mode - while gaining a landing page that
feels like a product page rather than a documentation index.

The hero is the centerpiece. Four image layers sit at different depths inside
a CSS `perspective` container. As you scroll, the layers translate at
different rates because `translateZ` interacts with the perspective camera,
producing genuine parallax instead of a faked `background-attachment: fixed`
effect. There is no scroll listener, no `requestAnimationFrame` loop, and no
JavaScript bundle to ship.

## The three opinions

This template is opinionated. Three decisions shape everything else.

### No JavaScript for the parallax

The parallax effect uses `perspective` on a scroll container, `translateZ`
on each layer, and `scale(depth + 1)` to compensate for the perceived
shrinkage that `translateZ` introduces. The browser's compositor handles the
animation on the GPU. This means:

- No layout thrash from `scroll` event handlers.
- No frame drops on low-powered devices.
- No bundle weight for a feature that should be visual chrome.
- Graceful degradation in browsers that ignore `transform-style: preserve-3d`.

If you want to layer interactive behavior on top, you can - but the hero
itself has zero runtime cost.

### AVIF layers

Each of the four hero layers is encoded as AVIF. The format produces files
that are typically 30-50% smaller than the equivalent WebP at similar
quality, which matters because parallax layers are large and need to look
crisp when scaled up. AVIF is supported by every evergreen browser; if you
need to support older targets, you can swap in WebP or PNG by editing
`overrides/home.html`.

### MkDocs Material as the foundation

Rather than build a static site generator from scratch, scroll-zoom-thing
extends MkDocs Material through its `overrides/` directory. The hero is a
custom `home.html` template applied to the index page via front matter.
Every other page uses Material's defaults. This means you inherit:

- Material's navigation, table of contents, and search index.
- Plugin support (`mkdocs-material`, `pymdown-extensions`, and the rest).
- Theme palette switching, including `media: "(prefers-color-scheme)"`
  auto-detection.
- The community's accumulated knowledge of how to build documentation sites.

## What you get when you deploy

Deploying scroll-zoom-thing produces a static site you can host on any CDN.
Out of the box you get:

- A landing page (`/`) with the parallax hero and your call-to-action buttons.
- The full MkDocs Material chrome - header, sidebar, search, footer - on
  every other page.
- A four-layer hero composed from AVIF assets at depths `8`, `5`, `2`, and `1`.
  The depth value drives the `translateZ` distance for each layer, so the
  number eight sits farthest back and the number one sits closest to the
  camera.
- Inline CSS variables per layer (`--md-parallax-depth` and
  `--md-image-position`) so each layer can be repositioned without editing
  the stylesheet.
- A single CSS file (`src/assets/stylesheets/home.css`) where every parallax
  rule lives. If you want to retune the camera, change the easing, or adjust
  the layer scaling, this is the only file you need.
- A working build pipeline. `mkdocs build` produces a `site/` directory ready
  for static hosting; `mkdocs serve` runs a dev server with hot reload.

```yaml
# mkdocs.yml (excerpt)
theme:
  name: material
  custom_dir: overrides
  palette:
    - media: "(prefers-color-scheme: light)"
      scheme: default
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
extra_css:
  - assets/stylesheets/home.css
```

## Where to go next

If you want a deeper explanation of how the perspective math works - why
`scale(depth + 1)` is the right compensation factor, how the layers stay
sharp, and how the CSS variables flow from the template into the
stylesheet - read [How it works](how-it-works.md).

If you want to ship a site, jump to [Getting started](../getting-started/index.md)
and pick the path that matches your situation.
