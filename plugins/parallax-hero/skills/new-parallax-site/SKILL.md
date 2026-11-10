---
name: new-parallax-site
description: Scaffold a new MkDocs Material site with the CSS 3D perspective parallax hero from the scroll-zoom-thing repo, using its new-site.sh script and templates. Use when asked for a cinematic docs or landing site with layered parallax art.
---

# Scaffold a parallax hero site

The `nirholas/scroll-zoom-thing` repo is a working MkDocs Material site whose home page uses a pure-CSS parallax: `perspective` on the scroll container, each layer pushed back with `translateZ` and scaled to compensate. No JavaScript and no scroll listeners.

## Steps

1. Clone and install (Python with pip):

   ```bash
   git clone https://github.com/nirholas/scroll-zoom-thing
   cd scroll-zoom-thing
   pip install -r requirements.txt     # mkdocs, mkdocs-material, pymdown-extensions, pygments
   ```

2. Create a site as a sibling directory with `scripts/new-site.sh <project-name> <template>`. Templates: `minimal` (bare hero), `marketing-hero` (hero, pillars, intro cards), `product-docs` (hero plus deep nav, no pillars). The script refuses to overwrite an existing destination and prompts for site name, description, URL, repo, hero headline and subhead, CTA labels and links, and brand colors. To skip prompts, export the variables it reads first: `SITE_NAME`, `SITE_DESCRIPTION`, `SITE_URL`, `REPO_URL`, `REPO_NAME`, `HERO_HEADLINE`, `HERO_SUBHEAD`, `PRIMARY_CTA_LABEL`, `PRIMARY_CTA_HREF`, `SECONDARY_CTA_LABEL`, `SECONDARY_CTA_HREF`, `PRIMARY_COLOR`, `ACCENT_COLOR`.

   ```bash
   HERO_HEADLINE="Ship faster" ./scripts/new-site.sh my-app minimal
   ```

3. Build and preview from the new project:

   ```bash
   cd ../my-app
   mkdocs build      # static site
   mkdocs serve      # live preview
   ```

## Where things live

- `mkdocs.yml`: `docs_dir: src`, theme `custom_dir: overrides`, `extra_css` including the parallax stylesheet.
- `overrides/home.html`: the hero markup, one `<picture class="mdx-parallax__layer">` per layer, back to front.
- `src/assets/stylesheets/home.css`: the parallax CSS (`--md-parallax-perspective` is `2.5rem`).
- `src/assets/hero/`: layer images named `N-description@4x.avif`.

## Swapping in your own art

Put replacement AVIF files in `src/assets/hero/`, update the filenames in `overrides/home.html`, then `mkdocs build`. Convert PNG sources with an AVIF encoder you have installed (for example `magick input.png -quality 70 layer@4x.avif`); check with `command -v` first and do not overwrite existing files without asking.

Keep the CSS approach as is: do not switch to `animation-timeline: scroll()`, keep the `.mdx-parallax__blend` div as the last layer before `.mdx-hero`, and keep `contain: strict` on the first group. Always run `mkdocs build` and confirm it succeeds before reporting done.
