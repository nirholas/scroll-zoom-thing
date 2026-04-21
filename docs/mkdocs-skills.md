---
title: MkDocs Material Skills for Custom Homepages
description: Practical MkDocs Material skills — custom_dir overrides, Jinja2 template blocks, extra_css, extra_javascript, and hooks — for building custom landing pages.
---

# MkDocs Material Skills for Custom Homepages

The parallax hero is one pattern. This page covers the MkDocs Material skills that make custom homepages possible — template overrides, CSS injection, JS hooks, and page metadata.

---

## 1. The override system

MkDocs Material's `custom_dir` lets you replace or extend any built-in template:

```yaml
# mkdocs.yml
theme:
  name: material
  custom_dir: docs/overrides
```

Files in `docs/overrides/` shadow the theme's own templates. You only need to include what you're changing — everything else falls back to the theme.

Key files you can override:

| File | What it controls |
|---|---|
| `overrides/home.html` | The homepage — any page with `template: home.html` |
| `overrides/base.html` | Global layout (header, footer, sidebar) |
| `overrides/main.html` | Content area |
| `overrides/partials/header.html` | Just the header |
| `overrides/404.html` | Error page |

---

## 2. Jinja2 template blocks

Material's templates are composed of named blocks. Your override can replace or extend any block:

```html
{% extends "base.html" %}

{% block tabs %}
  {{ super() }}   {# keeps the original nav tabs #}
  <!-- your custom HTML here -->
{% endblock %}

{% block content %}{% endblock %}   {# suppress default content area #}
{% block footer %}{% endblock %}    {# suppress footer on homepage #}
```

Common blocks to know:

| Block | Location |
|---|---|
| `tabs` | Top navigation tabs — inject hero here |
| `content` | Main page content |
| `footer` | Site footer |
| `scripts` | End of `<body>` — inject custom JS |
| `styles` | Inside `<head>` — inject critical CSS |
| `extrahead` | Additional `<head>` tags |

---

## 3. Marking a page as the homepage

In your markdown front matter:

```yaml
---
template: home.html
title: My Site
description: SEO description here
---
```

The `template: home.html` key tells MkDocs to render this page with your override instead of the default `main.html`.

---

## 4. Injecting CSS and JS

```yaml
# mkdocs.yml
extra_css:
  - assets/stylesheets/home.css
  - assets/stylesheets/custom.css

extra_javascript:
  - assets/javascripts/home.js
```

Files under `docs/assets/` are copied to `_site/assets/` verbatim. Reference them from `mkdocs.yml` with paths relative to `docs/`.

For JavaScript that must run after the DOM is ready:

```javascript
document.addEventListener("DOMContentLoaded", () => {
  // your code
});
```

---

## 5. MkDocs hooks

Hooks are Python scripts that run at build time. They can modify pages, inject content, or transform output:

```yaml
# mkdocs.yml
hooks:
  - hooks/inject_meta.py
```

```python
# hooks/inject_meta.py
def on_page_markdown(markdown, page, config, files):
    if page.file.src_path == "index.md":
        return markdown + "\n\n<!-- injected by hook -->"
    return markdown
```

Available hook events: `on_config`, `on_files`, `on_nav`, `on_page_markdown`, `on_page_content`, `on_post_build`.

---

## 6. Useful Material features for landing pages

```yaml
theme:
  features:
    - navigation.instant          # SPA-style navigation (no full reload)
    - navigation.tabs             # Top-level nav as tabs
    - navigation.tabs.sticky      # Tabs stay visible on scroll
    - announce.dismiss            # Dismissible announcement bar
    - content.code.copy           # Copy button on code blocks
```

For the parallax hero specifically, `navigation.instant` is important — it preserves scroll position and prevents the hero from re-rendering on every navigation.

---

## 7. Color scheme variables

Material exposes CSS custom properties you can use in your override styles:

```css
var(--md-default-bg-color)       /* page background */
var(--md-default-fg-color)       /* primary text */
var(--md-primary-fg-color)       /* primary brand color */
var(--md-primary-bg-color)       /* text on primary color */
var(--md-accent-fg-color)        /* accent color */
var(--md-typeset-color)          /* typeset text color */
var(--md-shadow-z1)              /* elevation shadow */
```

Override them per color scheme:

```css
[data-md-color-scheme="slate"] {
  --md-default-bg-color: #0d1117;
}
```
