---
title: Pages and nav
description: Add pages, structure them with the nav block in mkdocs.yml, nest sections, hide pages, and use template front matter.
---

# Pages and nav

Adding content to a scroll-zoom-thing site is the same as adding content
to any MkDocs Material site. This guide covers the pieces specific to how
the template is set up - the `nav:` block, nested sections, hiding pages,
and the `template:` front matter that lets a page opt into the parallax
hero.

## Adding a page

Create a Markdown file under `src/`. For example, a new "Pricing" page:

```markdown
---
title: Pricing
description: Plans and pricing for the project.
---

# Pricing

Content goes here.
```

The front matter at the top is YAML. `title` controls the browser tab and
the page heading in navigation; `description` is used for SEO and social
cards. Both are optional - MkDocs will fall back to the first H1 - but
setting them explicitly is the safe default.

By itself, the file will appear in the build output and be reachable by URL,
but it will not show up in the sidebar navigation until you add it to the
`nav:` block.

## The `nav:` block

`nav:` lives in `mkdocs.yml` and defines the order and labels of the
sidebar entries. A minimal example:

```yaml
nav:
  - Home: index.md
  - Overview: overview/index.md
  - Getting started: getting-started/index.md
  - Pricing: pricing.md
```

Each entry is `Label: path/to/file.md`. The label is what shows up in
the sidebar; the path is relative to the `src/` directory.

If you omit `nav:` entirely, MkDocs builds the navigation automatically
from the directory structure. This works for small sites but the order
becomes alphabetical, which is rarely what you want. Setting `nav:`
explicitly is recommended once you have more than a few pages.

## Nested sections

For deeper structures, nest entries:

```yaml
nav:
  - Home: index.md
  - Overview:
      - overview/index.md
      - How it works: overview/how-it-works.md
  - Getting started:
      - getting-started/index.md
      - Quickstart: getting-started/quickstart.md
      - Use as a template: getting-started/use-as-template.md
      - Local development: getting-started/local-development.md
  - Guides:
      - guides/index.md
      - Hero copy: guides/hero-copy.md
      - Theme: guides/theme.md
      - Pages and nav: guides/pages-and-nav.md
```

A few rules:

- The first entry inside a section that is a bare path (no label) becomes
  that section's index page. `overview/index.md` listed first under
  `Overview:` makes `/overview/` the section landing page.
- The label of the section comes from the parent key (`Overview:`), not
  from the index file's title.
- Nesting deeper than two levels works but tends to become hard to scan.
  Consider flattening if you find yourself at three or more levels.

## Hidden pages

Sometimes you want a page that exists, is reachable by URL, and is
indexed by search, but does not appear in the sidebar. The trick is to
omit it from `nav:` and add a small bit of front matter so MkDocs does
not warn about an orphaned page:

```yaml
---
title: Thank you
description: Confirmation page after signup.
search:
  exclude: false
---
```

Then in `mkdocs.yml`, configure the navigation plugin to allow the
omission. With recent MkDocs Material, the relevant setting is:

```yaml
plugins:
  - search
  - awesome-pages  # optional, for fine-grained nav control
```

Or, if you would rather not add a plugin, set:

```yaml
extra:
  nav:
    omit_warnings: true
```

The page will be reachable at `/thank-you/` (the URL is generated from the
file path) and will appear in search results, but the sidebar will not
show it.

## The `template:` front matter

This is the key that opts a page into a custom Jinja2 template. The home
page uses it to attach the parallax hero:

```yaml
---
title: Home
template: home.html
---
```

`template: home.html` tells MkDocs Material to render this page using
`overrides/home.html` instead of the default `overrides/main.html` (or
the theme's built-in `main.html` if you have not overridden it).

You can use the same mechanism to attach other custom templates. For
example, if you build a `landing.html` template for marketing pages:

```yaml
---
title: For teams
template: landing.html
---
```

Place the corresponding `landing.html` in `overrides/` and MkDocs will
pick it up.

Two practical points:

- A page that uses a custom template still parses its Markdown body, but
  whether the body appears depends on the template. The bundled
  `home.html` does render the Markdown content below the hero, so you can
  put copy in `src/index.md` and it will appear under the parallax.
- If you change a page's template, restart `mkdocs serve`. Template
  resolution happens at startup; hot-reload does not pick up new template
  attachments.

## Putting it together

A reasonable starting `nav:` for a small product site:

```yaml
nav:
  - Home: index.md
  - Overview: overview/index.md
  - Getting started:
      - getting-started/index.md
      - Quickstart: getting-started/quickstart.md
  - Guides:
      - guides/index.md
      - Hero copy: guides/hero-copy.md
      - Theme: guides/theme.md
      - Pages and nav: guides/pages-and-nav.md
  - Pricing: pricing.md
```

From here, the [Hero copy](hero-copy.md) and [Theme](theme.md) guides
cover the customization most people want next. If you need to deploy
what you have built, return to
[Quickstart](../getting-started/quickstart.md).
