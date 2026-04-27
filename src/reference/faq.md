---
title: FAQ
description: Frequently asked questions about using scroll-zoom-thing - mobile support, accessibility, browser support, performance, and customization.
---

# Frequently asked questions

Practical answers to questions that come up when adopting scroll-zoom-thing. For deeper background see [philosophy](../about/philosophy.md); for definitions see the [glossary](glossary.md).

## Compatibility

### Does it work on mobile?

Yes. The parallax effect works on iOS Safari, Chrome on Android, and other mobile browsers that support CSS 3D transforms (which is all current browsers). Performance is good because the entire animation runs on the compositor thread.

That said, the default template scales the perspective effect down on small screens via media queries. Very small viewports get a less aggressive 3D treatment to keep the hero readable. You can tune the breakpoints in `src/assets/stylesheets/home.css`.

iOS in particular handles `transform-style: preserve-3d` reliably. Older Android WebView builds (Android 7 and earlier) had bugs in 3D rendering, but those are below most projects' support thresholds today.

### Does it work on touch devices?

The parallax responds to scroll position, not pointer position, so touch scrolling works exactly the same as desktop wheel scrolling. There is no hover state involved in the effect.

### Can I use it without MkDocs?

Yes, with adaptation. The CSS technique is independent of MkDocs - you only need three things:

1. A scroll container with `perspective`
2. A nested element with `transform-style: preserve-3d`
3. Layered images with per-layer `translateZ` and `scale`

Copy `src/assets/stylesheets/home.css` and the hero markup pattern from `overrides/home.html` into any HTML page. You will lose the navigation, search, and theme integration that Material provides, but the parallax will function.

If you want a non-MkDocs version, the [overview](../overview/how-it-works.md) page documents the technique standalone.

### What browsers are supported?

Tested and known-good:

| Browser | Minimum version |
|---|---|
| Chrome / Edge | 90+ |
| Firefox | 93+ |
| Safari (macOS) | 16+ |
| Safari (iOS) | 16+ |
| Samsung Internet | 15+ |

The two features that gate support are CSS 3D transforms (universal since ~2015) and AVIF decoding (Chrome 85, Firefox 93, Safari 16). If you need to support older Safari, provide JPEG or WebP fallbacks via `<picture>` elements.

## Accessibility

### What about `prefers-reduced-motion`?

The default stylesheet includes a media query that disables the parallax transform when the user has set their OS to reduce motion:

```css
@media (prefers-reduced-motion: reduce) {
  .md-parallax__layer {
    transform: none;
  }
}
```

Layers stack flat and scroll normally. You should keep this rule in any customization.

### Is the hero readable for users with low vision?

The hero text overlay (`.md-parallax__content`) is layered above the images and uses Material's color tokens for contrast. The default theme includes a translucent gradient overlay (`--md-hero-overlay-color`) to ensure WCAG AA contrast against busy artwork. If you customize the layer images, re-check contrast with the overlay enabled.

### Are images announced to screen readers?

The layer `<img>` elements use empty `alt=""` because they are decorative - the hero's meaning is conveyed by the headline and tagline beneath, which are real text. Do not add descriptive `alt` text to layers; it would be redundant and noisy for screen reader users.

### Does keyboard navigation work?

Yes. The parallax hero is purely visual - keyboard focus moves through the page normally and into Material's standard navigation, search, and content. No focus traps are introduced.

## Images and layers

### Why AVIF?

AVIF was chosen for two reasons:

1. **File size.** Four layered hero images at desktop resolution would be several megabytes as PNGs. As AVIF, the four layers together are typically under 400 KB. That keeps the hero within an acceptable initial-load budget.
2. **Alpha channel.** Layers must have transparent regions so layers behind them show through. JPEG cannot store transparency. WebP can, but its alpha compression is weaker than AVIF's.

If your audience includes browsers without AVIF support (mostly older Safari), wrap each layer in a `<picture>` element with WebP and PNG fallbacks.

### How many layers can I use?

The default template uses four. The technique scales to any number, with practical tradeoffs:

- More layers = more render and decode work on first load
- More layers = more visual depth
- Beyond ~6 layers the marginal effect of each additional layer is small

A reasonable upper bound for a documentation hero is 6-8 layers. If you need more, consider whether some can be combined into a single layer with the parallax illusion preserved.

### Can I use video instead of images?

Yes. Replace the `<img>` tags with `<video>` elements. The CSS transform applies identically. Video layers cost more bandwidth and CPU, so be conservative with autoplay loops. Use `playsinline muted loop autoplay` for the iOS background-video pattern.

### Can I animate the layer images?

The parallax is driven by scroll, not time. If you want time-based animation (e.g. a layer drifting independently), add a CSS `@keyframes` animation on `transform` or a child element. Avoid animating the same `transform` property the parallax uses on the layer itself - compose with a wrapper element instead.

### Do the layer images need to be the same dimensions?

Yes, ideally. All four default layers are the same canvas size with their content positioned within. This makes them stack predictably regardless of scaling. If sizes differ, you will need to set per-layer `width` and `height` to match.

## Performance

### Will it slow down my site?

On the home page only. Other pages render with Material's default layout and have zero parallax overhead. On the home page itself, the cost is:

- Initial decode of four AVIF layers (typically <100 ms total)
- Continuous compositor work while scrolling, which is GPU-accelerated and does not block the main thread

Lighthouse Performance scores in the high 90s are typical with the default template.

### Does it cause layout shift?

No. The hero reserves its viewport space before images load via the `aspect-ratio` declaration on `.md-parallax__layer`. Cumulative Layout Shift stays at 0.

## Customization

### Can I use custom fonts?

Yes. Use Material's `theme.font.text` and `theme.font.code` settings in `mkdocs.yml` for Google Fonts, or self-host with `@font-face` and override `--md-text-font-family`. See [CSS variables](css-variables.md#typography) for details.

### Does it support multilingual sites?

Yes. scroll-zoom-thing has no opinion about language. Use Material's `i18n` plugin to serve translated content. The hero headline pulls from `config.site_name` (or you can hardcode it per-language in the override). RTL languages work because the parallax does not depend on text direction.

### Can I have different heroes on different pages?

The template renders the parallax only on pages that opt in via `template: home.html` frontmatter. To create variations, copy `overrides/home.html` to a new name (e.g. `overrides/hero-blue.html`) with different layer images, then opt that page in via frontmatter:

```markdown
---
template: hero-blue.html
---
```

### Can I disable the parallax entirely and keep the rest of the template?

Yes. Remove the `extra_css` entry for `home.css` in `mkdocs.yml`, or comment out the parallax block in `overrides/home.html`. Material will render its default home page.

## Project

### Is it actively maintained?

The repository is at [github.com/nirholas/scroll-zoom-thing](https://github.com/nirholas/scroll-zoom-thing). Issues and pull requests are welcome.

### Where did the technique come from?

From [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) by Martin Donath. The CSS approach is MIT-licensed; scroll-zoom-thing extracts and packages it as a standalone template. See [credits](../about/credits.md) for full attribution.

### Why is the theme file called `pai-theme.css`?

Legacy from the production reference. The PAI project ([Personal AI Infrastructure](https://github.com/danielmiessler/PAI)) uses this template in production, and the filename was inherited. It is not PAI-specific in usage - rename it to anything you like and update `mkdocs.yml` accordingly.
