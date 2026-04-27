---
title: Development
description: How to contribute to scroll-zoom-thing, run tests, and set up a local environment.
---

# Development

scroll-zoom-thing is a small project. Most contributions are documentation fixes, layer-image adjustments, or small tweaks to the parallax CSS. This section describes how to get a local copy running, how to test changes, and how to submit them.

If you only want to use the template for your own site, you do not need anything in this section. Head to [Getting Started](../getting-started/index.md) instead. The pages here are for people working on the template itself or proposing changes upstream.

## What this section covers

There are two pages under Development:

- **[contributing.md](contributing.md)** explains the contribution workflow: opening issues, the pull request process, code style, and how the project's CLAUDE.md guidelines apply to AI-assisted contributions. Read this before opening a PR.
- **[local-setup.md](local-setup.md)** covers the mechanics of getting the template running on your machine: Python virtualenv, dependency installation, `mkdocs serve`, livereload behaviour, and IDE recommendations. Read this first if you have not yet built the site locally.

The two pages are independent; you can read them in either order. Most new contributors want local-setup first.

## At a glance

The fast path for an experienced MkDocs user:

```bash
git clone https://github.com/nirholas/scroll-zoom-thing
cd scroll-zoom-thing
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
mkdocs serve
```

That gets you a live-reloading site at `http://127.0.0.1:8000`. The full setup with debugging notes is in [local-setup.md](local-setup.md).

## Repository layout

A short tour, so you know where to look:

```
scroll-zoom-thing/
  src/                  # Markdown sources for the docs site
    index.md            # Homepage with the parallax hero
    assets/             # Images, fonts, CSS, JS
      parallax/         # Layer images for the hero
    overrides/          # MkDocs Material partial overrides
  mkdocs.yml            # MkDocs configuration
  requirements.txt      # Python dependencies
  netlify.toml          # Netlify deploy config
  nixpacks.toml         # Railway deploy config
  CLAUDE.md             # AI-assistant guidelines
```

The parallax effect is implemented in `src/assets/css/parallax.css` (the file name may have evolved; check the current source). It is small, pure CSS, and well under 100 lines. Most contributions touch one of three places: the parallax CSS, the hero partial in `overrides/`, or the markdown content under `src/`.

## How to test changes

The project does not yet have an automated test suite in the conventional sense. Testing happens through:

1. **Build verification.** `mkdocs build --strict` must succeed without warnings. The `--strict` flag turns broken links and other warnings into errors.
2. **Visual inspection.** Run `mkdocs serve` and load the site at the desktop and mobile viewport sizes you care about. The parallax hero is the main thing to eyeball.
3. **Reduced-motion check.** Toggle your OS reduced-motion preference and verify the hero collapses to a static composition.
4. **Lighthouse pass.** For changes that touch the homepage or the hero, run Lighthouse and confirm the four scores (Performance, Accessibility, Best Practices, SEO) have not regressed.

PRs that add behaviour rather than fix bugs should include a sentence or two in the PR description explaining how the reviewer can verify the change.

## Getting help

Open a GitHub issue if:

- You hit a build error you cannot diagnose.
- The parallax hero misbehaves on a specific browser or device.
- You want to propose a new feature before writing the code.

For ad-hoc questions, the issue tracker is the right venue. The project does not have a chat room.

## Project values

Two values shape the contribution review:

- **Static and small.** The template is deliberately a static-only, no-runtime-JS design. Contributions that add a JavaScript animation library, a build-time bundler, or a server-side component will usually be declined unless they replace something heavier.
- **Accessibility is not optional.** Any change that affects the hero must keep the reduced-motion fallback working and must not regress the Lighthouse Accessibility score.

Read [contributing.md](contributing.md) for the full PR checklist, and [local-setup.md](local-setup.md) for the environment setup.
