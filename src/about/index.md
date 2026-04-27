---
title: About
description: About scroll-zoom-thing - a pure-CSS 3D parallax MkDocs Material template.
---

# About

scroll-zoom-thing is a pure-CSS 3D parallax template for [MkDocs Material](https://squidfunk.github.io/mkdocs-material/). The hero section composites four AVIF layers under a CSS perspective transform and animates them as the user scrolls. No JavaScript drives the effect.

The repository is at [github.com/nirholas/scroll-zoom-thing](https://github.com/nirholas/scroll-zoom-thing).

## Philosophy in one sentence

The browser is already a high-performance 3D compositor; the right amount of CSS is enough to ship a hero animation that is fast, accessible, and trivially maintainable.

## Background

The parallax technique was originally developed for [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) by Martin Donath. That project uses the effect on its own marketing site, where it serves as both a visual identity and a demonstration of what the theme can do.

scroll-zoom-thing extracts that technique into a standalone template you can drop into any MkDocs project. The CSS is the same approach - perspective, translateZ, and a corrective scale factor per layer - packaged with sample artwork, deploy configurations, and documentation.

The production reference for this template is [PAI (Personal AI Infrastructure)](https://github.com/danielmiessler/PAI), which uses it on its documentation site. The legacy filename `src/assets/pai-theme.css` is a holdover from that integration; it is not PAI-specific in the template you are looking at and can be renamed freely.

## What this site is

This documentation site explains:

- [How the parallax works](../overview/how-it-works.md) - the CSS math and DOM structure
- [How to install and configure it](../getting-started/index.md) - from a fresh clone to a running dev server
- [How to customize it](../guides/index.md) - swapping artwork, adjusting depths, retheming colors
- [How to deploy it](../deploy/index.md) - configurations for Vercel, Netlify, Cloudflare Pages, and GitHub Pages
- [Reference material](../reference/index.md) - CSS variables, file structure, glossary, FAQ

## What this site is not

- A general MkDocs tutorial. For that, see [mkdocs.org](https://www.mkdocs.org).
- A general Material for MkDocs reference. For that, see [squidfunk.github.io/mkdocs-material](https://squidfunk.github.io/mkdocs-material/).
- A JavaScript animation library. There is no runtime to learn, no API surface, and no plugin ecosystem - just CSS.

## Subsections

- [Philosophy](philosophy.md) - the rationale for the design decisions: pure CSS, MkDocs as host, AVIF for layers, extraction from a larger project
- [Credits](credits.md) - attribution to squidfunk/mkdocs-material, Martin Donath, the PAI production reference, and contributors
- [License](license.md) - MIT license text and notes on inherited licenses

## Contact

Issues and pull requests on [GitHub](https://github.com/nirholas/scroll-zoom-thing/issues) are the preferred channel. The project is small enough that there is no separate forum or chat.

## Status

The template is feature-complete for the use case it was extracted to serve. Future changes will focus on:

- Keeping deploy configurations current with platform changes
- Following Material for MkDocs releases when relevant
- Documentation improvements based on user feedback

It is not seeking new features outside that scope. If your use case needs more (e.g. interactive 3D scenes, scroll-driven storytelling), you will likely outgrow the template, which is fine - the CSS approach inside is portable.
