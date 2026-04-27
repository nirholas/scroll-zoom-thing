# MkDocs Material Skills for Custom Homepages

This guide is a deep reference for every MkDocs Material feature relevant to building a custom parallax homepage. It covers the override system, Jinja2 templating, CSS custom properties, plugins, navigation, and build tooling — everything you need to understand before touching `docs/overrides/home.html` or `docs/assets/stylesheets/home.css`.

---

## The Override System: What `custom_dir` Does

MkDocs Material ships its own set of Jinja2 templates inside the installed Python package. When you set `custom_dir` in `mkdocs.yml`, you give MkDocs a second place to look for templates before falling back to the built-in ones:

```yaml
# mkdocs.yml
theme:
  name: material
  custom_dir: docs/overrides
```

MkDocs resolves templates by checking `custom_dir` first. If `docs/overrides/home.html` exists, it is used instead of Material's built-in `home.html`. If it does not exist, Material's bundled version is used. This layered lookup means you only need to create files for the templates you actually want to override — everything else continues to work from the package.

The `custom_dir` path is relative to the project root (the directory containing `mkdocs.yml`), not relative to `docs_dir`. Keep that distinction in mind when structuring the repo.

The override directory mirrors the internal directory layout of the Material theme package. You can find the canonical layout by inspecting the installed package:

```bash
python -c "import material; import os; print(os.path.dirname(material.__file__))"
# e.g. /usr/local/lib/python3.11/site-packages/material
ls /usr/local/lib/python3.11/site-packages/material/templates/
```

Any file placed at the same relative path inside `custom_dir` will shadow the built-in version.

---

## Overridable Template Files

The following are the most important template files in Material's template tree. Each controls a distinct portion of the rendered page.

### `home.html`

The custom homepage template. This file is **not** present in Material's built-in set by default — it is a convention you create. A page uses it when its front matter declares `template: home.html`. It typically extends `main.html` and replaces the `content` block entirely:

```html
{% extends "main.html" %}

{% block content %}
<section class="parallax-hero">
  <!-- layer markup here -->
</section>
{% endblock %}
```

### `base.html`

The root template that all other templates extend. It defines the top-level HTML structure, the `<head>` element, the favicon link, and every major Jinja2 block. If you need to inject something into `<head>` globally (a font preconnect, a preload hint), this is where to do it. Override it sparingly.

### `main.html`

Extends `base.html` and wraps the page content with the sidebar, TOC, and `article` element. Most page-level overrides target `main.html` rather than `base.html`. The `content` block lives here and is what `home.html` replaces.

### `partials/header.html`

The navigation header bar. Override this to change the logo, nav links, or color scheme toggle behavior. The parallax homepage sometimes hides the header on scroll by patching this partial.

### `partials/footer.html`

The page footer with links and copyright. Override this to change the legal text, remove the "Made with Material for MkDocs" line, or add social icons.

### `404.html`

The error page. MkDocs will use this when serving locally (`mkdocs serve`) and GitHub Pages will use it if configured. Override it to match the parallax design — a minimal version that still loads the hero CSS and shows a "page not found" message over the same background:

```html
{% extends "main.html" %}

{% block content %}
<div class="not-found">
  <h1>404</h1>
  <p>This page does not exist. <a href="{{ config.site_url }}">Go home.</a></p>
</div>
{% endblock %}
```

---

## Jinja2 Template Blocks

Material defines a large set of named `{% block %}` regions. The complete list of blocks you are most likely to interact with:

| Block name | Where it lives | What it controls |
|---|---|---|
| `htmltitle` | `base.html` | The `<title>` tag |
| `site_meta` | `base.html` | Meta description, OG tags |
| `fonts` | `base.html` | Google Fonts `<link>` tags |
| `styles` | `base.html` | All stylesheet `<link>` tags |
| `scripts` | `base.html` | JavaScript `<script>` tags at end of `<body>` |
| `header` | `base.html` | The entire `<header>` element |
| `hero` | `main.html` | Optional hero section above content |
| `content` | `main.html` | The main article content |
| `footer` | `base.html` | The `<footer>` element |
| `announce` | `base.html` | Dismissible announcement banner |
| `tabs` | `base.html` | Navigation tab bar |
| `outdated` | `base.html` | "Outdated version" warning (used with mike) |

### When to Use `{{ super() }}`

Call `{{ super() }}` when you want to **add** to a block rather than replace it. For example, to append an extra stylesheet without removing Material's built-in stylesheets:

```html
{% block styles %}
  {{ super() }}
  <link rel="stylesheet" href="{{ 'assets/stylesheets/home.css' | url }}">
{% endblock %}
```

If you omit `{{ super() }}`, you replace the entire block. For the `content` block in `home.html`, that is exactly what you want — there is no Material content to preserve. For blocks like `styles` or `scripts`, omitting `{{ super() }}` will silently break the entire theme.

---

## `template: home.html` Front Matter

MkDocs routes a page to a custom template via the `template` key in the page's YAML front matter:

```markdown
---
template: home.html
title: CSS 3D Parallax Scrolling
description: A pure-CSS depth effect with AVIF layered images.
---
```

The value is the template filename, resolved relative to `custom_dir`. When MkDocs renders this page, it looks for `docs/overrides/home.html` (given the `custom_dir` above) instead of the default `main.html`. The rest of the page's Markdown content is still available inside the template as `{{ page.content }}`, but for a full-screen parallax hero you typically discard it.

This mechanism works for any page, not just `index.md`. You can create a dedicated `docs/landing.md` with `template: home.html` and link to it from the nav.

---

## `extra_css` and `extra_javascript` in `mkdocs.yml`

```yaml
extra_css:
  - assets/stylesheets/home.css

extra_javascript:
  - assets/javascripts/parallax-init.js
```

Paths in `extra_css` and `extra_javascript` are resolved relative to `docs_dir` (default: `docs/`). The file `docs/assets/stylesheets/home.css` is referenced as `assets/stylesheets/home.css`.

These resources are injected into the `styles` and `scripts` blocks in `base.html` **after** Material's own assets. That means:

- Your CSS loads after Material's CSS, so you can safely override Material variables and rules.
- Your JavaScript loads after Material's JavaScript, so Material's DOM setup is complete when your script runs.

For the parallax homepage, loading order matters. The hero CSS should be as early as possible to avoid a flash of unstyled content. If your custom stylesheet is large, consider splitting it: keep the hero critical path styles in the `{% block styles %}` override inside `home.html` itself (as an inline `<style>` tag), and load non-critical styles via `extra_css`.

```html
<!-- docs/overrides/home.html -->
{% block styles %}
  {{ super() }}
  <style>
    /* Critical: hero dimensions and perspective */
    .parallax-hero { perspective: 1000px; height: 100vh; }
  </style>
  <link rel="stylesheet" href="{{ 'assets/stylesheets/home.css' | url }}">
{% endblock %}
```

---

## CSS Custom Properties: The `--md-*` Variable System

Material exposes its entire design system as CSS custom properties on `:root`. You can override any of them in your `home.css` to tune the appearance without forking the theme.

Key variables:

```css
:root {
  /* Type scale */
  --md-text-font: "Roboto", sans-serif;
  --md-code-font: "Roboto Mono", monospace;

  /* Primary color (hue-based) */
  --md-primary-fg-color: hsla(231, 48%, 48%, 1);
  --md-primary-fg-color--light: hsla(231, 44%, 56%, 1);
  --md-primary-fg-color--dark: hsla(231, 48%, 48%, 1);
  --md-primary-bg-color: hsla(0, 0%, 100%, 1);

  /* Accent color */
  --md-accent-fg-color: hsla(231, 99%, 66%, 1);

  /* Default text */
  --md-default-fg-color: hsla(0, 0%, 0%, 0.87);
  --md-default-bg-color: hsla(0, 0%, 100%, 1);

  /* Typeset (content area) */
  --md-typeset-color: var(--md-default-fg-color);

  /* Shadow */
  --md-shadow-z1: 0 0.2rem 0.5rem hsla(0, 0%, 0%, 0.05);

  /* Border radius */
  --md-border-radius: 0.1rem;
}
```

### Overriding Per Color Scheme

Material applies color schemes via the `data-md-color-scheme` attribute on `<body>`. Override variables inside the appropriate selector:

```css
/* Light scheme overrides */
[data-md-color-scheme="default"] {
  --md-primary-fg-color: #2b4acb;
  --md-default-bg-color: #ffffff;
}

/* Dark scheme overrides */
[data-md-color-scheme="slate"] {
  --md-primary-fg-color: #7986cb;
  --md-default-bg-color: #0d1117;
  /* Hero overlay opacity for dark mode */
  --hero-overlay-opacity: 0.6;
}
```

The parallax hero often uses a custom CSS variable to control the depth of the background dim:

```css
.parallax-hero::after {
  background: rgba(0, 0, 0, var(--hero-overlay-opacity, 0.4));
}
```

---

## The `data-md-color-scheme` Attribute System

Material sets `data-md-color-scheme` on the `<body>` tag based on the user's current theme selection. The two built-in schemes are `default` (light) and `slate` (dark).

The JavaScript toggle (the sun/moon icon in the header) reads and writes `localStorage` under the key `data-md-color-scheme`, then sets the attribute on `<body>`. You can hook into this in your own scripts:

```javascript
// Listen for scheme changes to update hero video/image sources
const observer = new MutationObserver(() => {
  const scheme = document.body.getAttribute('data-md-color-scheme');
  document.querySelector('.parallax-hero').dataset.scheme = scheme;
});
observer.observe(document.body, { attributes: true, attributeFilter: ['data-md-color-scheme'] });
```

### Custom Schemes

You can define entirely new color schemes in `mkdocs.yml`:

```yaml
theme:
  palette:
    - scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
```

A custom scheme requires a corresponding CSS file that sets all `--md-*` variables under the correct attribute selector. Register it as a stylesheet in `extra_css`.

---

## MkDocs Plugins Useful for Parallax Sites

### search

The built-in search plugin is enabled by default. For a parallax homepage, configure it to exclude the hero page from the index (it has no meaningful searchable text):

```yaml
plugins:
  - search:
      exclude:
        - index.md
```

### social (OG Images)

The `social` plugin generates Open Graph preview images automatically. When someone shares your parallax site on social media, they get a branded card instead of a blank preview:

```yaml
plugins:
  - social:
      cards_layout_options:
        background_color: "#2b4acb"
        color: "#ffffff"
        font_family: Roboto
```

Social cards require `cairosvg` and `pillow`:

```bash
pip install mkdocs-material[imaging]
```

### minify

Reduces HTML, CSS, and JS output size. Important for a parallax site because the AVIF layers are already large — you want the HTML shell to be as lean as possible:

```yaml
plugins:
  - minify:
      minify_html: true
      minify_css: true
      minify_js: true
      htmlmin_opts:
        remove_comments: true
```

### redirects

Useful when you rename pages or change the URL structure:

```yaml
plugins:
  - redirects:
      redirect_maps:
        old-page.md: new-page.md
```

---

## Social Cards Plugin: OG Images in Depth

The social plugin renders each page's title, description, and site name into a 1200x630px card. The card template is a Jinja2 SVG file. You can override it by placing a custom template at `docs/overrides/.icons/social/` and referencing it in the plugin config.

The canonical workflow:

1. Install imaging extras: `pip install mkdocs-material[imaging]`
2. Enable the plugin in `mkdocs.yml`
3. Run `mkdocs build` — cards are generated into `site/.cache/plugin/social/`
4. Verify by inspecting the `<meta property="og:image">` tag in built HTML

Custom card template (placed at `docs/overrides/social/card.svg.jinja2`):

```xml
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630">
  <rect width="1200" height="630" fill="{{ layout.background_color }}"/>
  <text x="60" y="200" font-size="64" fill="{{ layout.color }}">
    {{ config.site_name }}
  </text>
  <text x="60" y="300" font-size="36" fill="{{ layout.color }}">
    {{ page.meta.get('description', page.title) }}
  </text>
</svg>
```

---

## The `hooks` System

Hooks are Python scripts that MkDocs executes at build time. They receive events from MkDocs's plugin event system. Unlike plugins, hooks do not require packaging — you just point to the file:

```yaml
hooks:
  - docs/hooks/inject_meta.py
```

A hook that injects a canonical `og:image` meta tag on every page:

```python
# docs/hooks/inject_meta.py
def on_page_context(context, page, config, **kwargs):
    page.meta['og_image'] = f"{config['site_url']}assets/og-image.png"
    return context
```

Common hook use cases for a parallax site:

- Automatically set `description` from the first paragraph of each page
- Inject `preload` link headers for AVIF layers
- Add `last_modified` timestamps from git history
- Transform image paths to point to a CDN

---

## MkDocs Navigation Features

### `navigation.tabs`

Renders the top-level nav sections as a horizontal tab bar below the header. For a parallax homepage, tabs are the recommended navigation pattern because they keep the header clean and let the hero fill the viewport:

```yaml
theme:
  features:
    - navigation.tabs
    - navigation.tabs.sticky
```

`navigation.tabs.sticky` keeps the tab bar visible as the user scrolls — important when the parallax hero is taller than the viewport.

### `navigation.instant`

Enables SPA-style navigation via XHR + the History API. Clicking a link fetches the new page's content and swaps it into the DOM without a full page reload:

```yaml
theme:
  features:
    - navigation.instant
```

For the parallax homepage this is critical. Without instant navigation, clicking any link and pressing Back triggers a full page reload, which re-renders the hero and causes a visible flash. With instant navigation enabled, the browser keeps the hero DOM in place while fetching the destination page, making the transition feel instantaneous.

### `navigation.instant` Deep Dive

When a user clicks an internal link:

1. Material intercepts the click event.
2. It issues an `XMLHttpRequest` (or `fetch`) for the target URL.
3. The response HTML is parsed, and only the content area and page metadata are extracted.
4. The current page's content area is replaced with the new content.
5. The browser's History API (`history.pushState`) updates the URL.
6. The page title, meta description, and canonical URL are updated in `<head>`.

The hero `<section>` in `home.html` lives outside the content area, so it is not replaced during instant navigation from `index.md`. Navigating away and then back does trigger a re-render, but the perceived cost is much lower because the hero CSS and AVIF images are cached.

One caveat: JavaScript that runs on `DOMContentLoaded` will not re-run after instant navigation. If your parallax requires JavaScript initialization (scroll event listeners, IntersectionObserver), register it via Material's `document$` observable instead:

```javascript
document$.subscribe(function() {
  // Runs after every instant navigation, including the initial load
  initParallax();
});
```

### `navigation.top`

Shows a "Back to top" button when the user scrolls down:

```yaml
theme:
  features:
    - navigation.top
```

For a parallax hero that occupies a full viewport height, the back-to-top button provides useful UX on content-heavy pages below the fold.

---

## Canonical URLs and `site_url`

```yaml
site_url: https://nirholas.github.io/scroll-zoom-thing/
```

Setting `site_url` correctly does several things:

- MkDocs injects `<link rel="canonical" href="...">` into every page, preventing duplicate content penalties when the site is mirrored.
- The social plugin uses `site_url` as the base for OG image URLs.
- The sitemap (`sitemap.xml`) uses it to build absolute URLs.
- The `{{ config.site_url }}` variable in templates resolves to this value.

If you deploy to a subdirectory (e.g., GitHub Pages project site), the trailing slash matters. Include it.

---

## The Announce Feature

Material supports a dismissible announcement banner at the top of every page:

```html
<!-- docs/overrides/partials/announce.html -->
<div class="md-announce">
  <div class="md-announce__inner">
    New: AVIF layer tutorial now live.
    <a href="/tutorial/avif-layers/">Read it.</a>
  </div>
</div>
```

To make it dismissible via localStorage, add a small script:

```javascript
// Dismiss on close button click, remember across sessions
const key = 'announce-dismissed-v1';
const bar = document.querySelector('.md-announce');
if (localStorage.getItem(key)) {
  bar?.remove();
} else {
  bar?.querySelector('.md-announce__close')?.addEventListener('click', () => {
    localStorage.setItem(key, '1');
    bar.remove();
  });
}
```

---

## Markdown Extensions

### Essential Extensions for Technical Docs

```yaml
markdown_extensions:
  # Code blocks with syntax highlighting
  - pymdownx.highlight:
      anchor_linenums: true
      line_spans: __span
      pygments_lang_class: true
  - pymdownx.inlinehilite
  - pymdownx.superfences:
      custom_fences:
        - name: mermaid
          class: mermaid
          format: !!python/name:pymdownx.superfences.fence_code_format

  # Admonitions (note, warning, tip boxes)
  - admonition
  - pymdownx.details

  # Table of contents with permalink icons
  - toc:
      permalink: true
      title: On this page

  # Tables
  - tables

  # Footnotes
  - footnotes

  # Attribute lists (add CSS classes to elements)
  - attr_list

  # Emoji support
  - pymdownx.emoji:
      emoji_index: !!python/name:material.extensions.emoji.twemoji
      emoji_generator: !!python/name:material.extensions.emoji.to_svg

  # Content tabs
  - pymdownx.tabbed:
      alternate_style: true

  # Task lists
  - pymdownx.tasklist:
      custom_checkbox: true
```

`pymdownx.superfences` with the `mermaid` fence lets you embed flowcharts and sequence diagrams directly in Markdown. For a parallax tutorial, this is useful for illustrating the CSS stacking context hierarchy.

`attr_list` lets you add HTML attributes to Markdown elements:

```markdown
![Hero layer 1](assets/hero/layer-1.avif){ loading=lazy width=1920 height=1080 }
```

---

## Search Plugin Configuration

```yaml
plugins:
  - search:
      lang: en
      separator: '[\s\-,:!=\[\]()"/]+|(?!\b)(?=[A-Z][a-z])|\.(?!\d)|&[lg]t;'
      suggestions: true
```

`suggestions` enables search-as-you-type completions in the search box. This requires Material's built-in JavaScript, which is always included.

For multilingual sites, set `lang` to a list:

```yaml
  - search:
      lang:
        - en
        - de
```

---

## Multi-Language Support with `i18n`

```yaml
plugins:
  - i18n:
      default_language: en
      languages:
        - locale: en
          name: English
          build: true
        - locale: de
          name: Deutsch
          build: true
          nav:
            - Home: index.de.md
```

With the `i18n` plugin, you maintain parallel Markdown files (e.g., `index.md` and `index.de.md`) and the plugin builds a separate site tree for each locale under `/de/`. The language switcher is added automatically to the header.

---

## Versioning with mike

`mike` is the standard tool for deploying multiple documentation versions to GitHub Pages:

```bash
pip install mike
mike deploy --push --update-aliases 1.0 latest
mike set-default --push latest
```

```yaml
extra:
  version:
    provider: mike
    default: latest
```

Material's version selector reads the `versions.json` file that `mike` maintains at the root of the `gh-pages` branch and renders a dropdown in the header. For a parallax site with infrequent version changes, the overhead of `mike` is low.

---

## The `edit_uri` Setting

```yaml
edit_uri: edit/main/docs/
```

This adds an "Edit this page" pencil icon to every page that links directly to the GitHub web editor. The full URL is constructed as `{{ repo_url }}{{ edit_uri }}{{ page.file.src_path }}`. Set it to `""` to disable the edit icon entirely — useful for the homepage where the template is in `overrides/`, not in `docs/`.

---

## Favicon Configuration

```yaml
theme:
  favicon: assets/favicon.png
```

The favicon path is relative to `docs_dir`. Place your favicon at `docs/assets/favicon.png`. MkDocs copies it to `site/assets/favicon.png` during build and injects the appropriate `<link rel="icon">` into `<head>`.

For a complete favicon set (including Apple touch icons and the Web App Manifest), add them to `docs/assets/` and reference them manually inside the `{% block styles %}` override in `base.html` or `home.html`:

```html
<link rel="apple-touch-icon" sizes="180x180" href="{{ 'assets/apple-touch-icon.png' | url }}">
<link rel="manifest" href="{{ 'assets/site.webmanifest' | url }}">
```

---

## Custom 404 Page

```html
<!-- docs/overrides/404.html -->
{% extends "main.html" %}

{% block hero %}{% endblock %}

{% block content %}
<div class="md-content not-found" data-md-component="content">
  <article class="md-content__inner">
    <h1>404 &mdash; Page not found</h1>
    <p>The page you're looking for doesn't exist.</p>
    <a href="{{ config.site_url }}" class="md-button md-button--primary">
      Back to home
    </a>
  </article>
</div>
{% endblock %}
```

GitHub Pages automatically serves your `404.html` for missing paths. The MkDocs build places it at `site/404.html`.

---

## Build Validation: `mkdocs build --strict`

```bash
mkdocs build --strict
```

In strict mode, MkDocs treats every warning as an error and exits with a non-zero code. This catches:

- Broken internal links (links to pages that don't exist in the nav or `docs/`)
- Missing files referenced in `extra_css` or `extra_javascript`
- Jinja2 template errors
- Invalid front matter YAML

Run strict mode in CI to prevent broken builds from reaching production:

```yaml
# .github/workflows/docs.yml
- name: Build docs
  run: mkdocs build --strict

- name: Deploy to GitHub Pages
  run: mkdocs gh-deploy --force
```

A clean `mkdocs build --strict` with zero warnings is the acceptance criterion before merging any change to the docs source.

---

## Putting It All Together: Minimal `mkdocs.yml` for a Parallax Site

```yaml
site_name: CSS 3D Parallax Scrolling
site_url: https://nirholas.github.io/scroll-zoom-thing/
repo_url: https://github.com/nirholas/scroll-zoom-thing
repo_name: nirholas/scroll-zoom-thing
edit_uri: edit/main/docs/

theme:
  name: material
  custom_dir: docs/overrides
  favicon: assets/favicon.png
  palette:
    - scheme: default
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - scheme: slate
      primary: indigo
      accent: indigo
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
  features:
    - navigation.tabs
    - navigation.tabs.sticky
    - navigation.instant
    - navigation.top
    - search.suggest
    - search.highlight

extra_css:
  - assets/stylesheets/home.css

plugins:
  - search:
      lang: en
  - social
  - minify:
      minify_html: true

markdown_extensions:
  - admonition
  - pymdownx.details
  - pymdownx.superfences
  - pymdownx.highlight:
      anchor_linenums: true
  - attr_list
  - toc:
      permalink: true

nav:
  - Home: index.md
  - Guide:
    - Layers: guide/layers.md
    - Assets: guide/assets.md
  - Skills: mkdocs-skills.md
  - Agents: agents.md
```

This configuration gives you a fully functional parallax documentation site with instant navigation, dark mode, search, OG image generation, and HTML minification — without any unnecessary complexity.
