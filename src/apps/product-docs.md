---
title: Product documentation sites
description: Using scroll-zoom-thing as a documentation site that doubles as a marketing landing.
---

# Product docs

Product documentation has a split personality. The landing page is a
sales surface: a visitor arrives without context and decides in a few
seconds whether the product is for them. Every page after that is a
working surface: a logged-in or evaluating user looking up a specific
answer. Most documentation tools optimize for one and treat the other
as an afterthought. scroll-zoom-thing's pattern, a parallax hero
followed by an unmodified MkDocs Material body, is a deliberate way
to serve both without compromising either.

## The split-surface pattern

The landing page (`index.md`) renders the four-layer parallax hero with
short marketing copy underneath. Below the fold, the page becomes
ordinary documentation: a "Get started" call to action, a feature
summary, links into the reference. Every page beyond `index.md` is
plain MkDocs Material with the standard navigation, search, and
table of contents.

The visitor experience flows like this:

1. Land, see the hero, read the pitch.
2. Click "Get started" or scroll into the body.
3. Land in the docs section relevant to them.
4. Use search and the navigation tree to find a specific answer.

The hero never reappears once the visitor is in the docs body, which
is correct. Marketing imagery on every page is friction for someone
who is trying to look up a parameter name.

## Information architecture

A workable top-level structure for a product docs site:

```yaml
nav:
  - Home: index.md
  - Getting started:
      - getting-started/index.md
      - Installation: getting-started/install.md
      - Quickstart: getting-started/quickstart.md
  - Guides:
      - guides/index.md
      - Common tasks: guides/tasks.md
      - Recipes: guides/recipes.md
  - Reference:
      - reference/index.md
      - API: reference/api.md
      - CLI: reference/cli.md
      - Configuration: reference/config.md
  - Changelog: changelog.md
```

The four sections (Getting started, Guides, Reference, Changelog) cover
the standard Diátaxis-adjacent split. The hero lives only on `Home`.

## Hero copy that does work

The hero has limited vertical real estate. Three pieces of text earn
their place:

- A one-line product description (what it is, who it is for).
- A two-line value proposition (what changes for the user).
- One primary action (link to Getting started) and one secondary
  action (link to a quickstart, demo, or repo).

Anything else belongs below the fold. Resist the urge to put feature
grids inside the hero; they fight the parallax for attention and
rarely render well at the depths the template expects.

## Two flavors: API reference vs end-user

The template is happy hosting either, but they want different
defaults.

### API references

API reference sites lean heavily on:

- Long pages with deep tables of contents.
- Code blocks in multiple languages, ideally with tabs.
- Stable anchor links so other docs can deep-link to a method.

Useful MkDocs Material features:

- `pymdownx.tabbed` for language tabs.
- `pymdownx.snippets` for shared code samples.
- `mkdocstrings` if you generate from source (Python, etc.).

For an API site, the hero often does double duty as the project's
README replacement. Keep it sober. Developers evaluating an API are
allergic to marketing.

### End-user guides

End-user docs lean on:

- Screenshots and short walkthroughs.
- Task-oriented headings ("How to invite a teammate") rather than
  feature-oriented headings ("Team management").
- A prominent search field and a flat-ish navigation tree.

For an end-user site, the hero can carry more emotional weight. The
audience is making a purchase decision, not an integration decision.

## Tips for product-doc workflows

A few patterns that hold up over time:

**Version your docs early.** MkDocs Material supports versioning via
`mike`. Even if you have one version today, set up the structure now.
Migrating later is more work than starting versioned.

**Keep the changelog in the repo.** A `changelog.md` rendered as a doc
page is read more than a GitHub Releases page, especially by users who
arrived via search.

**Write the quickstart first.** The single most-read page on any
product docs site is the quickstart. Write it, then write the hero
copy that points at it. Doing it in the other order produces
quickstarts that try to sell.

**Treat the hero as part of the release.** When you ship a major
version or a renamed product, the hero copy and probably the layers
need updating. Add it to your release checklist.

**Do not nest deeply.** Three navigation levels is enough. Four feels
hidden. Search picks up the slack for anything that does not fit the
top three levels.

**Run Lighthouse on the landing.** The hero is image-heavy, and an
unoptimized AVIF stack can cost you a usable Largest Contentful Paint
score. See [Performance](../advanced/performance.md) for targets.

## When the template is the wrong fit

If your product docs site has dozens of long-form marketing pages, a
configurator, or interactive demos, MkDocs Material will fight you.
In that case, host the marketing on a different stack and use
scroll-zoom-thing only for the docs subdomain, with a quieter hero.
