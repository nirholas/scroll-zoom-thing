---
title: Guides
description: Task-focused guides for customizing scroll-zoom-thing - hero copy, theme, navigation, and more.
---

# Guides

The guides in this section are task-focused. Each one assumes you have a
working scroll-zoom-thing site (either deployed or running locally via
`mkdocs serve`) and walks you through one specific change.

If you have not yet got that far, start with
[Getting started](../getting-started/index.md) and come back here once your
site is rendering.

## Available guides

### [Hero copy](hero-copy.md)

Editing the H1, the subheading, and the call-to-action buttons in
`overrides/home.html`. Covers the Jinja2 `{{ '...' | url }}` filter for
internal links, how button targets work, and the difference between primary
and secondary buttons. Read this first if the only thing you want to change
is the words on the landing page.

### [Theme](theme.md)

Customizing colors. There are two layers of customization available - the
named palettes that MkDocs Material ships with (`indigo`, `pink`, `teal`,
and so on) which you swap via `mkdocs.yml`, and the lower-level CSS custom
properties exposed in `src/assets/pai-theme.css` for finer control. This
guide covers both, plus dark and light mode handling and how the parallax
respects palette changes.

### [Pages and nav](pages-and-nav.md)

Adding new pages, organizing them with the `nav:` block in `mkdocs.yml`,
nesting sections, hiding pages from navigation while keeping them
reachable, and the `template:` front matter key that lets specific pages
opt into the parallax hero (or other custom templates).

## How to read these guides

Each guide is self-contained. You do not need to read them in order, and
they do not assume you have read the others. They do assume you know:

- Where `overrides/home.html` lives and what it does.
- That `mkdocs.yml` is the site configuration.
- Roughly how `mkdocs serve` works.

If any of those are unfamiliar, the [Local development](../getting-started/local-development.md)
page covers them.

## What is not in this section

Two kinds of content live elsewhere.

**Conceptual explanations** of how the parallax works - the perspective
math, the `scale(depth + 1)` compensation, why AVIF was chosen - live in
the [Overview](../overview/index.md) section. The guides here assume you
know roughly what is happening; they tell you which knob to turn.

**Reference material** - the full list of CSS custom properties, the
Jinja2 blocks the override exposes, the GitHub Actions workflow inputs -
will live in a `Reference` section. If you are looking for a specific
variable name and cannot find it in a guide, check there.

## A note on Material's docs

scroll-zoom-thing extends MkDocs Material. Anything that is not specific
to the parallax hero - admonitions, code highlighting, search, the
table-of-contents sidebar, the social plugin - is documented at
[squidfunk.github.io/mkdocs-material](https://squidfunk.github.io/mkdocs-material/).

When you are looking for something and it is not in these guides, that is
the next place to look. The Material docs are excellent and the feature
surface area is large.
