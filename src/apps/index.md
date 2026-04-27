---
title: Apps you can build with scroll-zoom-thing
description: A survey of site categories that fit the parallax-hero plus MkDocs Material pattern.
---

# Apps

scroll-zoom-thing is a template, not a framework. It gives you a parallax
hero on the landing page and a clean MkDocs Material body for everything
else. That combination turns out to suit a surprisingly wide range of
sites. This page surveys the categories that fit naturally and points
to deeper guides for the most common ones.

## What the template optimizes for

Before picking a category, it helps to be honest about what the template
is good at:

- A single, high-impact landing impression.
- Long-form, navigable, searchable content underneath.
- Static hosting on GitHub Pages, Cloudflare Pages, Netlify, or any
  bucket that serves files.
- Low ongoing maintenance: Markdown plus CSS, no runtime.

It is not optimized for:

- Heavy interactivity (dashboards, editors, configurators).
- Authenticated areas.
- Server-rendered personalization.

If you need any of those, the template can still host the marketing
front of the site, with the app itself living on a subdomain.

## Documentation sites

The most natural fit. MkDocs Material is already the default for a
large number of open-source projects, and the parallax hero replaces
the typical flat banner with something that signals more design care
without breaking the rest of the docs experience.

Common subtypes:

- API references with a hand-written narrative section.
- End-user product docs with onboarding, how-tos, and reference.
- Internal engineering handbooks.

See [Product docs](product-docs.md) for the full pattern.

## Product landings

If you have a small product and want a single page that explains it,
the template works as a one-page site with a deep landing and a thin
docs section. The hero handles the pitch; one or two doc pages handle
pricing, FAQ, and a getting-started guide.

The constraint here is content density. Marketing landing pages typically
want lots of horizontal sections, testimonials, and feature grids.
MkDocs Material is vertical and document-shaped. If you need a richer
marketing layout, treat the hero as the marketing surface and keep the
body short.

## Personal portfolios

A personal site is a natural single-page application of the template.
The hero carries identity; a short stack of doc pages carries projects,
writing, and contact. The depth-stacked layers are an easy way to make
a personal site look distinct without writing custom JavaScript.

See [Personal sites](personal-sites.md) for ways to strip the
template down and integrate a blog.

## Conferences and events

Conference sites have a predictable shape: a hero that sells the event,
a schedule, speaker bios, venue and travel info, and an FAQ. The
template fits this shape almost without modification. The hero is the
poster; the docs body is the program.

See [Conferences](conferences.md) for layout patterns specific to
multi-track schedules.

## Courses and curricula

A course site is structurally a documentation site with a different
information architecture: modules instead of sections, lessons instead
of pages. MkDocs Material's nested navigation handles this well, and
the parallax hero gives the course a recognizable identity that survives
across the lesson pages.

Useful patterns:

- One section per module, with `index.md` as the module overview.
- A top-level `progress.md` or similar that lists prerequisites.
- A consistent hero that doesn't change between lessons, so the
  branding stays stable as students click around.

## Internal tools and handbooks

Teams often need a small internal site: an onboarding handbook, an
incident runbook index, a design system reference. The template is
well-suited because it is fully static, self-hosts trivially, and
costs nothing to keep alive.

Considerations:

- Disable or restrict search if the content is sensitive.
- Serve from a private GitHub Pages repo or behind a VPN.
- Keep the hero understated; internal users do not need to be sold to.

## Picking a category

If you cannot decide, start with documentation. The template falls
back to a clean docs site if you remove the hero entirely, so nothing
about the structure forces a particular category. The categories above
are starting points, not constraints.

## Where to go next

- [Product docs](product-docs.md)
- [Personal sites](personal-sites.md)
- [Conferences](conferences.md)
