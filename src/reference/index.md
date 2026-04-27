---
title: Reference
description: Technical reference for scroll-zoom-thing - CSS variables, file structure, glossary, and FAQ.
---

# Reference

This section is the technical reference for scroll-zoom-thing. Use it to look up the names of CSS variables, locate files in the repository, decode terminology, and resolve common questions.

The reference is intentionally terse. For tutorials and walkthroughs, see [getting started](../getting-started/index.md) or [guides](../guides/index.md). For background and rationale, see [philosophy](../about/philosophy.md).

## What is scroll-zoom-thing

scroll-zoom-thing is a pure-CSS 3D parallax template for [MkDocs Material](https://squidfunk.github.io/mkdocs-material/). The hero section uses CSS `perspective`, `translateZ`, and `scale` to fake a multi-layer parallax effect as the user scrolls. No JavaScript drives the animation - the browser composites the transforms on the GPU.

The technique is extracted from [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) (MIT, Martin Donath) and packaged as a standalone template you can drop into any MkDocs project.

## Sections in this reference

### [CSS variables](css-variables.md)

Every CSS custom property used by the template, grouped into:

- Parallax variables - perspective distance, layer depth, image positioning
- Material color tokens - background, primary, accent, foreground colors
- Typography - font stacks and sizing scales

Each entry lists the variable name, expected type (length, color, integer), default value, and the visual effect of changing it.

### [File structure](file-structure.md)

An annotated tree of the repository. Every top-level file and directory is documented:

- `overrides/home.html` - the Jinja2 template that renders the parallax hero
- `src/assets/stylesheets/home.css` - all parallax CSS, including transforms and media queries
- `src/assets/pai-theme.css` - color theme (filename is legacy from the production reference)
- `src/assets/hero/*.avif` - the four AVIF layer images at depths 8, 5, 2, 1
- `mkdocs.yml` - MkDocs configuration with theme, plugins, and navigation
- `requirements.txt` - Python dependencies (mkdocs-material)
- Deploy configs for Vercel, Netlify, Nixpacks, Cloudflare Workers, and GitHub Pages
- `skills/` and `.claude/commands/` - Claude Code agent skills used during development

### [Glossary](glossary.md)

Definitions for terms used throughout the docs. Includes core CSS 3D concepts (perspective, translateZ, vanishing point, transform-style, preserve-3d), browser performance terms (compositor thread, paint containment), MkDocs concepts (override, hook, frontmatter), and image format terms (AVIF, blend layer).

### [FAQ](faq.md)

Frequently asked questions covering:

- Mobile and touch device support
- Use without MkDocs
- Why AVIF was chosen
- Number of layers and how to add more
- Video and animated layers
- Accessibility (`prefers-reduced-motion`)
- Browser support matrix
- Performance characteristics
- Custom fonts and multilingual sites

## How to read this reference

Reference pages assume you have already followed [local development setup](../getting-started/local-development.md) and have a running local dev server (`mkdocs serve`). Code blocks show CSS, HTML, or YAML exactly as it appears in the repository.

Cross-references use relative links from the current file. To jump between top-level sections, use links like `[overview](../overview/how-it-works.md)`.

If something in the reference is wrong or missing, open an issue at [github.com/nirholas/scroll-zoom-thing](https://github.com/nirholas/scroll-zoom-thing/issues).
