---
title: Advanced CSS Parallax Techniques
description: Advanced CSS parallax patterns — multiple scroll groups, color scheme transitions, responsive depth tuning, Safari and Firefox browser fixes, and performance optimization.
---

# Advanced CSS Parallax Techniques

Beyond the basic 4-layer setup — multiple content sections, color scheme transitions between groups, responsive depth tuning, and browser-specific fixes.

---

## Multiple parallax groups

Add more `mdx-parallax__group` sections after the first to create content panels that scroll in after the hero:

```html
<div class="mdx-parallax" data-mdx-component="parallax">

  <!-- Hero group (layers + sticky text) -->
  <section class="mdx-parallax__group" data-md-color-scheme="slate">
    <!-- layers -->
    <!-- hero text -->
  </section>

  <!-- First content panel -->
  <section class="mdx-parallax__group" data-md-color-scheme="slate" data-md-color-primary="indigo">
    <div class="md-content md-grid">
      <div class="md-content__inner md-typeset">
        <!-- your content -->
      </div>
    </div>
  </section>

  <!-- Second content panel — different scheme -->
  <section class="mdx-parallax__group" data-md-color-scheme="default">
    <!-- light-mode panel -->
  </section>

</div>
```

Each group can set its own `data-md-color-scheme` for automatic light/dark transitions as the user scrolls.

---

## Responsive depth scaling

On very wide monitors, the default depth values can make the effect too subtle. Scale the perspective with viewport width:

```css
:root {
  --md-parallax-perspective: clamp(1.5rem, 2.5vw, 3rem);
}
```

Or adjust depth per breakpoint:

```css
@media (min-width: 120em) {
  /* Ultra-wide: increase depth to keep effect visible */
  .mdx-parallax__layer:nth-child(1) { --md-parallax-depth: 10; }
  .mdx-parallax__layer:nth-child(2) { --md-parallax-depth: 7; }
}
```

---

## Tuning the hero height for wide viewports

The first group's height determines how far the layers travel before content appears. The built-in media queries handle common cases, but you can extend them:

```css
/* Default: 140vh */
.mdx-parallax__group:first-child { height: 140vh; }

/* As viewport gets wider relative to height, switch to vw-based height */
@media (min-width: 125vh)  { .mdx-parallax__group:first-child { height: 120vw; } }
@media (min-width: 150vh)  { .mdx-parallax__group:first-child { height: 130vw; } }
@media (min-width: 200vh)  { .mdx-parallax__group:first-child { height: 150vw; } }

/* Ultrawide (21:9+) */
@media (min-width: 250vh)  { .mdx-parallax__group:first-child { height: 160vw; } }
```

---

## Browser quirks and fixes

### Safari

Safari handles `contain: strict` paint containment differently — it clips transformed children correctly without it. Adding `contain: strict` in Safari causes layers to disappear:

```css
.safari .mdx-parallax__group:first-child {
  contain: none;
}
```

The `.safari` class is set by this script (include in your `home.html` or base template):

```html
<script>
  if ("AppleComputer,Inc." === navigator.vendor)
    document.documentElement.classList.add("safari")
</script>
```

### Firefox

Firefox has a bug where `contain: strict` on the first scroll causes a repaint that shows the unpainted state briefly. The fix: remove `contain` after the first few pixels of scroll:

```javascript
// Toggle ff-hack class to remove contain:strict after initial scroll
if (navigator.userAgent.includes("Gecko/")) {
  const el = document.querySelector(".mdx-parallax")
  el.addEventListener("scroll", function handler() {
    if (el.scrollTop > 3000) {
      document.body.classList.remove("ff-hack")
      el.removeEventListener("scroll", handler)
    } else {
      document.body.classList.toggle("ff-hack", el.scrollTop <= 1)
    }
  }, { passive: true })
}
```

```css
.ff-hack .mdx-parallax__group:first-child {
  contain: none !important;
}
```

---

## Performance optimization

### Reduce paint area

Large AVIF files still decode on the main thread. Preload the visible layers:

```html
<link rel="preload" as="image" type="image/avif"
      href="assets/hero/6-plants-2@4x.avif">
```

Only preload the foreground (depth 1) — it's the first layer the user sees. The far background is rendered behind it and can load async.

### Limit layer count

Each additional layer adds a composited layer to the GPU render tree. 4 layers is safe; 8+ can cause jank on lower-end devices. Test with Chrome DevTools → Layers panel.

### `will-change` on layers

The CSS already has `transform-style: preserve-3d` on the group, which promotes layers to their own compositor context. You don't need `will-change: transform` — it's already implied.

---

## Accessible fallback

Users who prefer reduced motion should get a static hero:

```css
@media (prefers-reduced-motion: reduce) {
  .mdx-parallax {
    overflow: auto;
    perspective: none;
  }

  .mdx-parallax__layer {
    transform: none !important;
    height: 100vh;
  }
}
```

This disables the 3D scroll effect and treats the hero as a normal stacked layout.
