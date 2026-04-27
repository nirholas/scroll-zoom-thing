---
title: Advanced topics
description: Deeper guides for performance, video layers, custom CSS, and MkDocs Material features in scroll-zoom-thing.
---

# Advanced

The basic setup of scroll-zoom-thing covers the common case: four AVIF
layers, CSS-only parallax, MkDocs Material defaults. Once a site moves
past that baseline, four areas tend to need deeper treatment. This
section collects them.

## What's in this section

The advanced guides are independent. Read whichever applies.

### CSS techniques

Custom layer counts, alternate easing, depth tweaks, masking, blend
modes, reduced-motion handling, and other modifications to the
`perspective` plus `translateZ` plus `scale(depth + 1)` core. Start
here if you want a hero that does not look like every other
scroll-zoom-thing site.

See [CSS techniques](css-techniques.md).

### MkDocs Material features

Plugins, theme extensions, navigation patterns, search tuning, and
the Material features that pair well with the parallax hero. Start
here if you have the hero working and want to make the rest of the
site do more.

See [MkDocs skills](mkdocs-skills.md).

### Performance

The hero is image-heavy by design. Without care, four AVIF layers
plus the rest of the page can blow a Largest Contentful Paint budget.
This guide covers AVIF size targets, preload hints, compositor layer
hygiene, and the Lighthouse numbers a well-tuned site should hit.

See [Performance](performance.md).

### Video layers

One of the four layers can be a video instead of a still image, which
changes the feel of the hero significantly. This guide covers the
mechanics: codecs, file size, mobile autoplay, and the markup changes
required.

See [Video layers](video-layers.md).

## Reading order

If you are tuning an existing site, read in this order:

1. [Performance](performance.md) first. Almost every site has wins
   here, and the changes are mechanical.
2. [CSS techniques](css-techniques.md) next, if the hero feels too
   close to the default.
3. [MkDocs skills](mkdocs-skills.md) third, when the body of the site
   needs more than the defaults provide.
4. [Video layers](video-layers.md) last. It is the riskiest change
   for performance and accessibility, so do it after the other three.

If you are starting a new site, ignore this section until the basic
template is working. The advanced guides are easier to apply against
a working baseline than against a half-built one.

## What is not in this section

Topics that belong elsewhere:

- AI-assisted layer generation: see [AI](../ai/index.md).
- Site categories and patterns: see [Apps](../apps/index.md).
- Initial setup, file layout, and `mkdocs.yml` structure: those
  remain in the introductory sections.

The advanced guides assume you have a working site and want to push
it further, not that you are still standing it up.

## A note on stability

The CSS in this template is intentionally small. The parallax effect
is roughly twenty lines of CSS plus the layer markup. That smallness
is deliberate; it keeps the template legible and easy to modify.

The advanced guides occasionally suggest changes that grow that
surface area. When they do, they are explicit about it. If you find
yourself adding hundreds of lines of CSS to achieve an effect, step
back and ask whether the effect is worth the cost. Usually it is
not, and a smaller approach exists.
