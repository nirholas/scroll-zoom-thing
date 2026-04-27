---
title: File structure
description: Annotated tree of the scroll-zoom-thing repository - every top-level file and directory explained.
---

# File structure

Annotated layout of the scroll-zoom-thing repository. Use this when you need to know where something lives.

```
scroll-zoom-thing/
├── .claude/
│   └── commands/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── overrides/
│   └── home.html
├── skills/
├── src/
│   ├── assets/
│   │   ├── hero/
│   │   │   ├── layer-1.avif
│   │   │   ├── layer-2.avif
│   │   │   ├── layer-3.avif
│   │   │   └── layer-4.avif
│   │   ├── stylesheets/
│   │   │   └── home.css
│   │   └── pai-theme.css
│   ├── about/
│   ├── advanced/
│   ├── ai/
│   ├── apps/
│   ├── deploy/
│   ├── getting-started/
│   ├── guides/
│   ├── images/
│   ├── overview/
│   ├── reference/
│   ├── favicon.ico
│   ├── index.md
│   └── logo.png
├── mkdocs.yml
├── netlify.toml
├── nixpacks.toml
├── requirements.txt
├── vercel.json
└── wrangler.toml
```

## Top-level files

### `mkdocs.yml`

The MkDocs configuration. Declares:

- `site_name`, `site_url`, `repo_url` - metadata
- `theme.name: material` and `theme.custom_dir: overrides` - tells MkDocs to load Material and the override at `overrides/home.html`
- `theme.palette` - light and dark color schemes
- `extra_css` - lists `assets/stylesheets/home.css` and `assets/pai-theme.css` so they load on every page
- `nav` - the documentation navigation tree (Overview, Getting Started, Guides, Reference, Deploy, About)
- `markdown_extensions` - admonitions, code highlighting, content tabs, etc.
- `plugins` - search and any Material plugins enabled

Edit this file to change site metadata, navigation, or to enable plugins.

### `requirements.txt`

Python dependencies. The minimum is:

```
mkdocs-material
```

Pin to a specific version in production:

```
mkdocs-material==9.5.*
```

### `vercel.json`

Vercel deploy configuration. Tells Vercel to install Python, run `mkdocs build`, and serve `site/` as static output.

### `netlify.toml`

Netlify deploy configuration. Equivalent to `vercel.json` for Netlify - sets the build command and publish directory.

### `nixpacks.toml`

Nixpacks build configuration. Used by Railway and other platforms that build from Nixpacks. Declares Python and the build steps.

### `wrangler.toml`

Cloudflare Workers / Pages configuration. Defines the project name and points at the `site/` output directory.

### `.github/workflows/deploy.yml`

GitHub Actions workflow that builds the site and deploys to GitHub Pages on push to `main`. Uses `actions/checkout`, sets up Python, installs requirements, runs `mkdocs gh-deploy`.

## `overrides/`

Material for MkDocs supports template overrides. Files in `overrides/` shadow files of the same name in the Material theme.

### `overrides/home.html`

The Jinja2 template for the home page. Extends Material's `main.html` and replaces the `tabs` and `content` blocks with the parallax hero markup. Structure:

```jinja
{% extends "main.html" %}

{% block tabs %}
  {{ super() }}
  <section class="md-parallax">
    <div class="md-parallax__group">
      <img class="md-parallax__layer" style="--md-parallax-depth: 8" ...>
      <img class="md-parallax__layer" style="--md-parallax-depth: 5" ...>
      <img class="md-parallax__layer" style="--md-parallax-depth: 2" ...>
      <img class="md-parallax__layer" style="--md-parallax-depth: 1" ...>
    </div>
    <div class="md-parallax__content">
      <h1>{{ config.site_name }}</h1>
      <p>{{ config.site_description }}</p>
    </div>
  </section>
{% endblock %}
```

The hero only renders on the home page; other pages use Material's default layout.

## `src/`

Markdown source for the documentation site. MkDocs reads from `src/` (configured via `docs_dir: src` in `mkdocs.yml`) and writes built HTML to `site/`.

### `src/index.md`

The home page. Frontmatter sets `template: home.html`, which activates the override at `overrides/home.html` and renders the parallax hero. Body content appears below the hero.

### `src/favicon.ico` and `src/logo.png`

Browser favicon and the logo shown in Material's header. Both are referenced from `mkdocs.yml`:

```yaml
theme:
  favicon: favicon.ico
  logo: logo.png
```

### `src/assets/`

Static assets bundled with the site.

#### `src/assets/hero/`

The four AVIF layer images for the parallax hero.

- `layer-1.avif` - depth 8, sky / furthest background
- `layer-2.avif` - depth 5, mid-background
- `layer-3.avif` - depth 2, mid-foreground
- `layer-4.avif` - depth 1, foreground / closest

Each is roughly 2400px wide. AVIF compresses the layered art to a fraction of equivalent PNG size while preserving the alpha channel needed for transparency between layers.

#### `src/assets/stylesheets/home.css`

All parallax CSS. Contains:

- `.md-parallax` - the scroll container with `perspective` and `overflow-y: auto`
- `.md-parallax__group` - sets `transform-style: preserve-3d`
- `.md-parallax__layer` - the per-layer transform combining `translateZ` and `scale`
- `.md-parallax__content` - the headline and tagline overlay
- Media queries for mobile breakpoints
- A `prefers-reduced-motion` block that disables the 3D transform

#### `src/assets/pai-theme.css`

Color theme. The filename is legacy from the production reference (PAI) and is not specific to PAI in usage. Declares `--md-hero-*` tokens, gradient overlays, and adjustments to Material color tokens for a cohesive hero treatment. Rename freely if it bothers you - just update `extra_css` in `mkdocs.yml`.

### `src/about/`, `src/advanced/`, `src/ai/`, `src/apps/`, `src/deploy/`, `src/getting-started/`, `src/guides/`, `src/overview/`, `src/reference/`

Markdown content directories, one per top-level navigation section. Each contains an `index.md` and topic pages.

### `src/images/`

Inline images referenced from documentation pages (screenshots, diagrams). Distinct from `src/assets/hero/` which is reserved for the parallax layers.

## `.claude/commands/`

Custom Claude Code slash commands scoped to this repository. Each `.md` file defines a command that the Claude Code agent can run while developing the template.

## `skills/`

Claude Code agent skills. Skills are reusable instruction packs the agent loads when relevant. They cover tasks like adding a new layer, debugging perspective math, and rebuilding deploy configs.

## `site/`

The build output directory, created by `mkdocs build`. Not checked into git (listed in `.gitignore`). Contains the static HTML, CSS, JS, and copied assets that you deploy.

## What you usually edit

For most customization tasks:

- Color and theme: `src/assets/pai-theme.css`
- Hero math (perspective, depths): `src/assets/stylesheets/home.css`
- Hero layout (markup, headline): `overrides/home.html`
- Layer images: `src/assets/hero/*.avif`
- Site config and navigation: `mkdocs.yml`
- Documentation content: anything under `src/`

## See also

- [CSS variables](css-variables.md) for the variables declared in the stylesheets
- [How it works](../overview/how-it-works.md) for what each file does at runtime
