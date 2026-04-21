---
template: home.html
title: CSS 3D Parallax Scrolling for MkDocs Material
description: A minimal, copy-paste example of pure-CSS 3D perspective parallax scrolling in MkDocs Material — no JavaScript, no dependencies, just translateZ and scale.
---

## What this is

A minimal, working example of CSS 3D perspective parallax scrolling built on top of [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).

The effect uses no JavaScript, no scroll event listeners, and no `requestAnimationFrame`. It is a natural consequence of how the browser projects 3D-transformed elements inside a scrolling perspective container.

## Files you need

| File | Purpose |
|---|---|
| `docs/overrides/home.html` | Jinja2 template — wires up the layer `<picture>` elements |
| `docs/assets/stylesheets/home.css` | All parallax CSS |
| `mkdocs.yml` | `custom_dir: docs/overrides` + `extra_css` |
| `docs/assets/hero/*.avif` | Your layered images |

## Key CSS properties

```css
/* Scroll container — this replaces html/body as the scroller */
.mdx-parallax {
  height: 100vh;
  overflow: hidden auto;
  perspective: 2.5rem;
}

/* Each layer — depth set inline via --md-parallax-depth */
.mdx-parallax__layer {
  transform:
    translateZ(calc(var(--md-parallax-perspective) * var(--md-parallax-depth) * -1))
    scale(calc(var(--md-parallax-depth) + 1));
}
```

## Layer depth values

| Layer | Depth | Effect |
|---|---|---|
| Far background | `8` | Slowest scroll, most depth |
| Mid background | `5` | Medium depth |
| Near midground | `2` | Slight parallax |
| Foreground | `1` | Almost no parallax |

## Credits

CSS parallax technique ported from [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) — MIT License, copyright Martin Donath.

