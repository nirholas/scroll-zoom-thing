---
title: Credits
description: Attribution for the people and projects scroll-zoom-thing builds on.
---

# Credits

scroll-zoom-thing exists because of prior work by other people. This page records who did what.

## The original CSS parallax

**[squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material)** by **Martin Donath** ([@squidfunk](https://github.com/squidfunk)).

The CSS technique at the core of this template - perspective on a scroll container, `translateZ` per layer, corrective `scale` to keep layers at intended size - was developed for Material for MkDocs and has been used on the Material documentation site for years. Martin published it under the MIT License, which is what makes this extraction possible.

If you find scroll-zoom-thing useful, the right thing to do is also support Material for MkDocs:

- The project: [github.com/squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material)
- Sponsor link: [github.com/sponsors/squidfunk](https://github.com/sponsors/squidfunk)

The Insiders edition of Material for MkDocs is excellent and funds the maintenance of the open-source version.

## The production reference

**[PAI (Personal AI Infrastructure)](https://github.com/danielmiessler/PAI)** by **Daniel Miessler** ([@danielmiessler](https://github.com/danielmiessler)).

PAI uses this template (or a close ancestor of it) on its documentation site. Working through that integration shaped a number of decisions in scroll-zoom-thing:

- The four-layer composition at depths 8, 5, 2, 1 was tuned for PAI's hero artwork and remains the default here.
- The legacy filename `src/assets/pai-theme.css` is a holdover from the PAI integration. It is not PAI-specific in the standalone template and can be renamed.
- The deploy configurations (Vercel, Netlify, Cloudflare, GitHub Pages) were debugged on PAI's infrastructure first.

PAI is not a dependency of scroll-zoom-thing - the template stands alone - but it is the reason the template is packaged the way it is.

## MkDocs

**[MkDocs](https://www.mkdocs.org)** by **Tom Christie** ([@tomchristie](https://github.com/tomchristie)) and contributors.

MkDocs is the static site generator scroll-zoom-thing builds on. Its design choices - Markdown source, YAML configuration, template overrides, plugin architecture - are what make it possible to ship a parallax hero as a one-file integration rather than a fork.

## Image assets

The default hero artwork (`src/assets/hero/layer-1.avif` through `layer-4.avif`) is sample art included with the template for demonstration. Replace it with your own art for production use - the included images are not licensed for redistribution as part of derivative works without checking the repository's `LICENSE` and `NOTICE` files for current terms.

## Claude Code workflow contributions

The repository ships with development tooling for [Claude Code](https://claude.com/claude-code):

- `skills/` - reusable instruction packs for the Claude Code agent (adding layers, debugging perspective, regenerating deploy configs)
- `.claude/commands/` - project-scoped slash commands
- `AGENTS.md` (when present) - cross-tool agent instructions

These were assembled iteratively while building the template. They are not required to use scroll-zoom-thing - if you do not use Claude Code, ignore them. They are checked in because the agent-assisted workflow is part of how the template is maintained, and exposing the prompts and skills lets contributors reproduce that workflow.

Claude Code itself is by Anthropic.

## Browsers

The technique relies on years of work by browser engineers at Google (Blink), Mozilla (Gecko), and Apple (WebKit) to make CSS 3D transforms and AVIF decoding fast and correct. None of this is taken for granted. The pure-CSS approach in scroll-zoom-thing is only viable because those engines are now reliable enough to depend on for visual effects this prominent.

## Documentation tooling

The site itself uses:

- [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) for the theme
- [Pygments](https://pygments.org/) (via Material) for code highlighting
- [Mermaid](https://mermaid.js.org/) (via Material) where diagrams appear

## Contributors

Issues, pull requests, and discussions are welcome at [github.com/nirholas/scroll-zoom-thing](https://github.com/nirholas/scroll-zoom-thing). Contributors will be listed here as they appear.

## See also

- [License](license.md) for legal terms covering the inherited and original work
- [How it works](../overview/how-it-works.md) for the technical mechanics
