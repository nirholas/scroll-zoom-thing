---
title: Hero copy
description: Edit the headline, subheading, and call-to-action buttons in overrides/home.html, and use the Jinja2 url filter for internal links.
---

# Hero copy

The text and buttons in the parallax hero live in `overrides/home.html`.
This guide walks through each editable element and explains the Jinja2
template syntax you will encounter.

## Where the copy lives

Open `overrides/home.html`. The hero markup looks roughly like this
(simplified):

```html
{% extends "main.html" %}

{% block tabs %}
  <section class="md-parallax">
    <div class="md-parallax__layer"
         style="--md-parallax-depth: 8;
                --md-image-position: 50% 50%;
                background-image: url('{{ 'assets/layer-4.avif' | url }}')">
    </div>
    {# ...three more layers... #}

    <div class="md-parallax__content">
      <h1 class="md-parallax__title">Your headline here</h1>
      <p class="md-parallax__subtitle">
        A short paragraph that supports the headline.
      </p>

      <div class="md-parallax__buttons">
        <a href="{{ 'getting-started/' | url }}"
           class="md-button md-button--primary">
          Get started
        </a>
        <a href="{{ 'overview/' | url }}" class="md-button">
          Learn more
        </a>
      </div>
    </div>
  </section>
{% endblock %}
```

The four `<div class="md-parallax__layer">` elements are the parallax
layers. The `<div class="md-parallax__content">` block holds the copy.
You will edit elements inside the content block.

## The headline

Replace the contents of the `<h1>`:

```html
<h1 class="md-parallax__title">A pure-CSS 3D parallax landing page.</h1>
```

A few rules of thumb:

- Keep it under roughly 60 characters. Above that, the headline wraps to
  three lines on most viewports and the visual rhythm of the hero breaks.
- Avoid HTML inside the `<h1>`. The default styling assumes flat text.
- If you need an emphasized word, the existing CSS supports a
  `<span class="md-parallax__title-accent">` wrapper, which picks up the
  accent color from your palette.

```html
<h1 class="md-parallax__title">
  A pure-CSS <span class="md-parallax__title-accent">3D parallax</span> hero.
</h1>
```

## The subheading

Replace the contents of the `<p>`:

```html
<p class="md-parallax__subtitle">
  Built on MkDocs Material. No JavaScript. AVIF layers. Ships with a working
  GitHub Actions deploy.
</p>
```

The subheading is for context that the headline does not have room for.
Keep it to one or two sentences. Like the headline, plain text is the
safe choice; the styling assumes a single block of text rather than rich
markup.

## The buttons

There are two buttons by default - a primary call-to-action and a
secondary. Their structure:

```html
<a href="{{ 'getting-started/' | url }}"
   class="md-button md-button--primary">
  Get started
</a>
<a href="{{ 'overview/' | url }}" class="md-button">
  Learn more
</a>
```

The class `md-button` is provided by MkDocs Material. Adding
`md-button--primary` gives the button a filled appearance using your
accent color. Without it, the button is outlined.

To change a button's destination, edit the `href`. To change the label,
edit the text between the `<a>` tags. To add a third button, copy one of
the existing `<a>` blocks and adjust.

### The `{{ '...' | url }}` filter

This is Jinja2 syntax. MkDocs registers a `url` filter on the template
environment that resolves a path relative to the site root. You should
wrap every internal link in it:

```html
<a href="{{ 'getting-started/' | url }}">Get started</a>
```

This produces `/getting-started/` when the site is hosted at the domain
root, and `/my-project/getting-started/` when it is hosted under a
subpath (for example, GitHub Pages project sites). Without the filter,
hard-coded paths break in subpath deployments.

Two practical points:

- The filter takes a string relative to the docs root. `'overview/'`
  resolves to the overview index. `'overview/index.md'` works too -
  MkDocs strips the `.md` and resolves it the same way.
- For external links (`https://...`), do not use the filter. Use the URL
  directly:

```html
<a href="https://github.com/nirholas/scroll-zoom-thing">View on GitHub</a>
```

### Linking to anchors within a page

If you want a button to scroll to a specific section of a page, append the
anchor:

```html
<a href="{{ 'overview/#what-you-get' | url }}" class="md-button">
  See what you get
</a>
```

The anchor is the slugified version of the heading text. MkDocs generates
anchors for every heading by default, so `## What you get when you deploy`
becomes `#what-you-get-when-you-deploy`.

## A worked example

Here is a complete content block for a fictional product:

```html
<div class="md-parallax__content">
  <h1 class="md-parallax__title">
    Documentation that <span class="md-parallax__title-accent">looks like a product</span>.
  </h1>
  <p class="md-parallax__subtitle">
    A pure-CSS parallax hero on top of MkDocs Material. Deploy in ten minutes,
    customize in fifteen.
  </p>

  <div class="md-parallax__buttons">
    <a href="{{ 'getting-started/quickstart/' | url }}"
       class="md-button md-button--primary">
      Deploy now
    </a>
    <a href="https://github.com/nirholas/scroll-zoom-thing"
       class="md-button">
      View on GitHub
    </a>
  </div>
</div>
```

Save the file. If you have `mkdocs serve` running, the browser will
reload and your new copy will appear. From here, the next thing most
people customize is colors - see [Theme](theme.md).
