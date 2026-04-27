---
title: Glossary
description: Definitions for terms used throughout the scroll-zoom-thing documentation.
---

# Glossary

Definitions for terms used in the scroll-zoom-thing documentation. Entries are alphabetized within thematic groups.

## CSS 3D and transforms

### Parallax

A visual effect where elements at different apparent distances move at different speeds relative to the viewer. In scroll-zoom-thing, parallax emerges naturally from `perspective` plus `translateZ` - layers further from the viewer appear smaller and move less per unit of scroll, creating the illusion of depth.

### Perspective

The CSS property that establishes a 3D viewing frustum on an element. Set on the parent of any element being transformed in Z. The numeric value is the distance from the viewer to the projection plane in CSS units. Smaller perspective exaggerates the 3D effect; larger perspective approaches an orthographic projection. scroll-zoom-thing uses `perspective: 2.5rem` on `.md-parallax`.

### translateZ

A CSS transform function that moves an element along the Z axis (toward or away from the viewer). Negative values push the element away; positive values bring it closer. Has no visual effect unless an ancestor has `perspective` set. The default template applies `translateZ(calc(var(--md-parallax-depth) * -1rem))` to each layer.

### Vanishing point

The point on the projection plane toward which parallel lines recede under perspective. By default it is the center of the perspective origin. CSS exposes this via the `perspective-origin` property. Shifting the origin shifts where the 3D scene appears to converge - useful when the hero subject is off-center.

### Transform-style

The `transform-style` CSS property determines whether children of a transformed element are flattened into the parent's plane (`flat`, the default) or preserved as a 3D scene (`preserve-3d`). scroll-zoom-thing sets `transform-style: preserve-3d` on `.md-parallax__group` so layers retain their Z positions.

### preserve-3d

The value of `transform-style` that keeps child elements positioned in 3D space relative to the transformed parent rather than flattening them. Required for any nested 3D transform to render correctly.

### Depth

In scroll-zoom-thing, the integer value passed to a layer via `--md-parallax-depth` that determines how far back the layer sits. Depth `1` is closest; depth `8` is furthest. Depth feeds both the `translateZ` distance and the corrective `scale` factor that keeps each layer at its visually intended size.

### Layer

One of the AVIF images stacked inside `.md-parallax__group` to form the hero. Each layer is a positioned `<img>` with its own depth. The default template uses four layers at depths 8, 5, 2, and 1; you can use more or fewer.

### Blend layer

A layer that uses CSS blend modes (e.g. `mix-blend-mode: multiply`) or a translucent gradient overlay to interact visually with the layers beneath it. Useful for atmospheric effects like fog or color washes without adding another full image.

## Scrolling and layout

### Scroll container

An element with `overflow: auto` or `overflow: scroll` that creates its own scrolling context. The parallax hero uses a scroll container so the 3D scene scrolls independently of the rest of the page when configured that way. The scroll position drives the parallax via the natural Z displacement of layers under perspective.

### Sticky positioning

CSS `position: sticky` pins an element to a scroll boundary while it remains within its containing block. Not used by the default template, but a common adaptation for headlines that should stay visible while the hero scrolls past.

### Scroll-snap

CSS Scroll Snap (`scroll-snap-type` and `scroll-snap-align`) lets a scroll container snap to defined points. Useful if you want the hero to snap fully into or out of view rather than allowing free scrolling. Not enabled by default.

## Browser performance

### Compositor thread

The browser thread responsible for assembling rendered layers into the final on-screen image. Properties that can be handled entirely on the compositor (`transform`, `opacity`) animate smoothly even under main-thread contention. scroll-zoom-thing relies on `transform` for all motion specifically to stay on the compositor.

### Paint containment

The CSS `contain: paint` declaration tells the browser that an element's painting cannot affect anything outside its bounds. This lets the browser skip work and allocate a dedicated compositing layer. The parallax container uses containment hints to stabilize performance on lower-end devices.

## Image formats

### AVIF

AV1 Image File Format. A modern image format derived from the AV1 video codec. Offers significantly better compression than JPEG or PNG at equivalent quality, supports an alpha channel (transparency), and has wide browser support as of 2024. scroll-zoom-thing uses AVIF for hero layers because the per-layer file size is small enough to load all four layers within the initial viewport budget.

## MkDocs and Material

### MkDocs

A Python-based static site generator focused on project documentation. Reads Markdown from a source directory, applies a theme, and writes static HTML to a build directory. See [mkdocs.org](https://www.mkdocs.org).

### Material

[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) by squidfunk (Martin Donath). The theme scroll-zoom-thing extends. Provides the navigation, search, color palette system, content tabs, admonitions, and the plugin architecture used.

### Override

A file in the `overrides/` directory that shadows a same-named file in Material's theme. Overrides let you replace specific Jinja2 template blocks (or whole templates) without forking Material. scroll-zoom-thing overrides `home.html` to inject the parallax hero.

### Hook

A Python module loaded via the `hooks` key in `mkdocs.yml`. Hooks let you intercept events during the build (page rendering, asset copying) to modify content programmatically. Not used by the default template, but available if you need build-time logic.

### Jinja2

The templating language MkDocs and Material use for HTML templates. Jinja2 supports variables (`{{ var }}`), control flow (`{% if %}`, `{% for %}`), inheritance (`{% extends %}`), and blocks (`{% block name %}`). `overrides/home.html` is a Jinja2 template.

### Frontmatter

The YAML block at the top of a Markdown file, delimited by `---` lines above and below. MkDocs reads frontmatter for per-page metadata: title, description, and crucially `template: home.html` to opt a page into a custom template.

## See also

- [How it works](../overview/how-it-works.md) for these concepts in motion
- [CSS variables](css-variables.md) for the names of the actual properties
- [FAQ](faq.md) for browser support and other practical questions
