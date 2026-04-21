---
title: How CSS 3D Parallax Works
description: Technical deep-dive into CSS perspective, translateZ, and scale — how a scroll container with a perspective value creates a parallax depth effect without JavaScript.
---

# How CSS 3D Parallax Works

## The core idea

A CSS `perspective` value on a scroll container creates a 3D vanishing point. Any child element with a `translateZ` transform is rendered at a perceived depth — and because it is visually further away, it appears to move slower as the container scrolls.

This is not simulated. It is the browser's real 3D projection math applied to normal scroll rendering.

## Step by step

### 1. The scroll container

```css
.mdx-parallax {
  height: 100vh;
  overflow: hidden auto;    /* this element scrolls, not html/body */
  perspective: 2.5rem;      /* establishes the 3D context */
}
```

The entire page lives inside `.mdx-parallax`. When the user scrolls, this element scrolls — not the document root.

### 2. Pushing layers back in Z

```css
.mdx-parallax__layer {
  transform:
    translateZ(calc(2.5rem * var(--md-parallax-depth) * -1))
    scale(calc(var(--md-parallax-depth) + 1));
}
```

`translateZ` pushes the element away from the viewer. A layer at `depth: 8` is pushed back `8 × 2.5rem = 20rem` in 3D space. Because it is further from the vanishing point, it appears to move a shorter distance per scroll unit — the parallax effect.

`scale(depth + 1)` compensates for the apparent size reduction from moving the layer back. Without it, deeper layers would appear smaller.

### 3. Hero text — sticky, not parallax

```css
.mdx-hero__scrollwrap {
  position: sticky;
  height: 100vh;
  margin-bottom: -100vh;
  top: 0;
}
```

The hero text sits in a sticky container so it stays fixed at the bottom of the viewport while the layers scroll behind it. `margin-bottom: -100vh` collapses the sticky wrapper so it doesn't push content down.

### 4. Paint containment

```css
.mdx-parallax__group:first-child {
  contain: strict;
  height: 140vh;
}
```

`contain: strict` clips anything that overflows the group box. Without it, scaled-up deep layers would bleed outside the hero section. The height is set taller than `100vh` because deep layers travel further during scroll.

## Why not `animation-timeline: scroll()`?

The scroll-timeline API (`@keyframes` driven by scroll position) is simpler to write but has limited browser support and worse performance characteristics on some engines. The `perspective` approach works in every modern browser and has no JS dependency.

## Browser quirks

- **Safari**: handles `contain: strict` differently — the `.safari` class disables it.
- **Firefox**: has a `contain` bug on the first scroll — the `.ff-hack` class (toggled by a tiny JS observer) forces a repaint.
