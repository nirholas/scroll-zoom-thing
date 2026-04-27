---
title: Personal sites and portfolios
description: Stripping scroll-zoom-thing down to a single-page personal site, portfolio, or CV.
---

# Personal sites

The template's defaults assume a documentation site. For a personal
site, those defaults are too heavy. A personal site usually wants one
strong hero, a short list of projects, maybe a CV, and a place to
write. This page describes how to peel the template back to that
shape without fighting MkDocs Material.

## The minimum viable shape

A workable personal site needs four pages:

```
src/
  index.md          # hero plus short intro
  projects.md       # links to project pages or external work
  writing/          # blog index + posts
    index.md
    posts/
  cv.md             # CV / about
```

That is enough to feel complete. Anything more is optional. Anything
less starts to feel like a placeholder.

## Stripping the navigation

MkDocs Material renders a sidebar by default. On a personal site with
four pages, the sidebar is mostly empty space. Two adjustments make
the layout feel right:

```yaml
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.tabs.sticky
    - navigation.top
    - toc.integrate
```

`navigation.tabs` moves the top-level entries into a horizontal bar,
which suits a flat site. `toc.integrate` folds the per-page table of
contents into the sidebar, freeing the right column. On pages that do
not need a TOC at all, hide it via frontmatter:

```yaml
---
title: Home
hide:
  - navigation
  - toc
---
```

The home page in particular benefits from `hide: [navigation, toc]`
so the hero gets the full width.

## Hero choices for a personal site

The four-layer parallax stack has more visual weight than most
personal sites need. Two patterns work well:

**Identity hero.** A stylized portrait or scene rendered as four
layers. Depths `8, 5, 2, 1` translate to "background environment,
mid-ground props, foreground subject, near-camera detail." A face at
depth 2 with a small accessory at depth 1 reads well.

**Logotype hero.** Skip the portrait. Use the layers to stack a
typographic mark with a backdrop, mid-ground decorative elements, and
a small foreground accent. This ages better than a portrait if you
are uncomfortable updating the site every haircut.

Whichever you pick, keep the hero copy short. A name, a one-line
description, and a single primary link. The links to `projects.md`,
`writing/`, and `cv.md` belong in the navigation, not the hero.

## A projects page that holds up

Project pages tend to rot. The maintainable pattern is a single
`projects.md` with one entry per project, each entry small enough to
keep current:

```markdown
## Project name

One-sentence description. [Link](https://example.com)

Stack: list of technologies. Year.
```

Resist the urge to give every project its own page until the project
itself warrants long-form writing. When that happens, promote it to
`projects/project-name.md` and link to it from the entry above.

## Integrating a blog

MkDocs Material has a first-class blog plugin. For a personal site
this is enough; you do not need a separate blog engine. The minimum
configuration:

```yaml
plugins:
  - blog:
      blog_dir: writing
      post_url_format: "{slug}"
      archive: false
      categories: false
```

Posts live in `src/writing/posts/`, each with frontmatter:

```yaml
---
date: 2026-04-12
authors:
  - you
---
```

The plugin generates an index automatically. If you want to keep the
blog feel handmade, set `archive: false` and `categories: false` and
let the index page act as the only listing.

The hero on the blog index can either inherit the home hero (recognizable,
slightly redundant) or be replaced with a quieter banner (cleaner,
costs an extra layer set). For a small blog, inheriting is fine.

## CV and about

A CV page is a good test of the template's typography. MkDocs Material
handles long bullet lists and section headings well, but a few
conventions help:

- Use `##` for sections (Education, Experience, Talks) and `###` for
  individual entries.
- Keep dates consistent: `2024 — present` or `2024–2026`, not a
  mix.
- Provide a printable version. Add a small `print.css` or use
  `@media print` rules to hide the navigation and the hero, keeping
  only the content.

If you want a downloadable PDF, generate it out of band rather than
asking MkDocs to do it. A separate `cv.pdf` in `src/assets/` linked
from the page is the path of least resistance.

## Hosting and domains

Personal sites are the easiest case for the template's hosting story.
GitHub Pages with a custom domain covers it. The build is a single
`mkdocs build` step in CI; the output is static; the bandwidth bill
is zero.

A few hardening steps:

- Set up a `CNAME` file in `src/` pointing to your domain.
- Add a `404.md` so the fallback page also looks like your site.
- Pin the MkDocs Material version in your CI so a theme update does
  not silently change your site between commits.

## When to outgrow the template

A personal site that grows into a heavily structured archive (years
of writing, dozens of projects, talks, photography) eventually wants
something with more native blog ergonomics. Until then, the template's
"hero plus four pages" shape is hard to beat for the time it costs to
maintain.
