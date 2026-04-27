---
title: Philosophy
description: The design rationale behind scroll-zoom-thing - why pure CSS, why MkDocs, why AVIF, why extraction.
---

# Philosophy

This page explains why scroll-zoom-thing is built the way it is. If you only want to use the template, [getting started](../getting-started/index.md) is sufficient. This page is for people deciding whether to adopt it or extend it.

## No JavaScript drives the parallax

The single most important design decision: the parallax animation is driven entirely by CSS and the browser's native scroll. There is no `requestAnimationFrame` loop, no scroll event listener, no IntersectionObserver, no library.

This matters for several reasons:

### Performance

CSS `transform` is one of the few properties browsers can animate entirely on the compositor thread. Once the layout and paint are done, scrolling moves the layers without touching the main thread. The frame rate is whatever the browser can refresh - typically 60 fps and capable of higher on devices that support it.

A JavaScript-driven parallax that listens to scroll events and updates `transform` from JS will be slower in steady state and far slower under main-thread contention (heavy SPA, third-party tags, devtools open, low-power CPU). It will also flicker on iOS when the rubber-band overscroll engages, because event-driven JS cannot keep up with the system's gesture animation.

CSS-driven parallax does not have these failure modes. The browser handles it.

### Bundle size

Zero. The animation adds no JavaScript bytes to the page. Material for MkDocs ships some JS for navigation and search, but none of it is needed for the hero.

### Maintenance

There is no API to drift. The template will continue to work with every browser update for the foreseeable future because `perspective`, `translateZ`, and `scale` are stable, well-supported CSS features that have not changed in years and will not change.

### Accessibility

Reducing motion is a one-line CSS rule:

```css
@media (prefers-reduced-motion: reduce) {
  .md-parallax__layer { transform: none; }
}
```

A JavaScript implementation has to wire this up explicitly, often forgets to, and adds a code path. The CSS version cannot forget.

## Why MkDocs

The template targets MkDocs (specifically Material for MkDocs) for three reasons:

1. **Static output.** MkDocs builds to plain HTML, CSS, and assets. Anything that runs the resulting `site/` directory can host the template - Vercel, Netlify, Cloudflare Pages, GitHub Pages, an S3 bucket, an nginx server. There is no Node runtime, no SSR step, no dynamic content negotiation.

2. **Override system.** Material's theme override mechanism is small, well-documented, and stable. You shadow `home.html` with your own Jinja2 template and you are done. There is no plugin to write, no build hook to install. The whole integration is one file.

3. **Documentation focus.** The template is for documentation sites. MkDocs is for documentation sites. Aligning the two means the rest of the docs site (navigation, search, content tabs, admonitions, code highlighting) is already solved by Material - we only have to ship the hero.

This does mean the template is unsuitable for sites that need a non-MkDocs framework. The CSS technique itself is portable to any HTML page; the integration is what is MkDocs-specific.

## Why AVIF

The hero is composed of four layered images. With four layers at desktop resolution, file format matters.

**JPEG** is out: no alpha channel.

**PNG** has alpha but compresses photographic content poorly. Four layered PNGs at 2400px wide can easily exceed 5 MB.

**WebP** has alpha and better compression than PNG. Four WebP layers might be 1-2 MB total - acceptable but not great.

**AVIF** has alpha and significantly better compression than WebP, particularly for content with large smooth gradients (skies, soft lighting). Four AVIF layers fit in roughly 300-400 KB. Browser support is universal as of Safari 16.

The choice trades off support for older Safari (15 and below) for a better-than-good experience on every modern browser. For sites that need to support older Safari, you can wrap each layer in a `<picture>` element with WebP and PNG sources - the structure of the parallax is unaffected.

## Why extracted from a larger project

The CSS parallax technique was originally part of [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material). It serves as the hero on the Material for MkDocs documentation site. Martin Donath wrote it, MIT-licensed it, and demonstrated it in production for years.

Why extract it?

### Discoverability

The technique is buried in the Material codebase, mixed with the rest of the theme. Someone wanting "a parallax hero for my docs site" would have to identify what to copy, sort it from the surrounding theme code, and figure out how to integrate it. Most people will not bother.

A standalone repository with the parallax as the entire point is easier to find, easier to evaluate, and easier to adopt.

### Documentation

This site documents the technique on its own terms. The Material docs reasonably focus on Material; this site can spend a whole page on perspective math, another on AVIF tradeoffs, another on layer authoring. The depth would be out of scope for the parent project.

### Modification

Once the technique is its own template, modifications to it (different layer counts, different perspective values, different artwork) are first-class concerns. In the parent project they would be one detail among many.

### Attribution

Extraction makes the lineage explicit. The template credits the original at [credits](credits.md) and links to it. People building on top can see exactly what they are inheriting.

## What scroll-zoom-thing is not trying to be

To keep the design coherent, the template explicitly is not:

- **A general 3D library.** If you need rotating objects, multiple cameras, or interactive 3D, use Three.js or similar. CSS perspective is sufficient for fake parallax depth, not for real 3D scenes.
- **A scroll-driven animation framework.** The parallax is the only scroll-driven animation. If you want elaborate scroll choreography, look at [GSAP ScrollTrigger](https://gsap.com/docs/v3/Plugins/ScrollTrigger/) or the new [scroll-driven animations CSS](https://developer.mozilla.org/en-US/docs/Web/CSS/animation-timeline) once it is widely supported.
- **A site builder.** It is a template for one section of an MkDocs site. The rest of the site uses Material as-is.

Saying no to these adjacent possibilities keeps the codebase small enough that a single person can understand the whole thing in an afternoon.

## See also

- [How it works](../overview/how-it-works.md) for the technical mechanics
- [Credits](credits.md) for attribution
- [License](license.md) for legal terms
