---
title: Examples
description: Sites built with the scroll-zoom-thing parallax MkDocs template.
---

# Examples

This page collects sites built with scroll-zoom-thing in production. The template is young, so the list is short. If you have shipped a site using it, open a pull request adding an entry.

## Production reference

### docs.pai.direct

The canonical production reference is **[docs.pai.direct](https://docs.pai.direct)**, the documentation site for the PAI Linux distribution. It is the most complete example of how to build a real product documentation site on top of the template, and it is the site the template was originally extracted from.

See the full [case study](docs-pai-direct.md) for layer choices, deployment topology, and pointers to the public source.

## What makes a useful example

The point of this list is not to gather screenshots. The point is to give people considering the template a concrete answer to "what does it look like when someone actually uses this for real?" Useful entries on this page therefore tend to share a few traits:

- The site is publicly reachable.
- The repository is public, so readers can inspect the `mkdocs.yml`, the layer images, and any custom partials.
- The site has been deployed for at least a month, so the maintenance picture is honest.
- The owner is willing to answer questions in an issue thread.

If your site has those four traits, please add it.

## Suggested categories

The template suits several use cases. As more examples appear, this page will probably split by category. Categories that the template is a good fit for:

### Product documentation

Long-form technical documentation for a product or library. The parallax hero gives the landing page some weight without forcing you to maintain a separate marketing site. docs.pai.direct is the reference here.

### Personal sites and digital gardens

A single-author site with a handful of evergreen pages. The template's pure-CSS hero performs well even on cheap shared hosting, and the lack of analytics or trackers fits the spirit of most digital gardens.

### Internal handbooks

Company or project handbooks where you want a presentable landing page without bringing in a heavyweight marketing-site stack. The template runs comfortably behind an SSO proxy because all assets are static.

### Conference or event microsites

Single-event sites where you want a memorable landing page and a small set of inner pages (schedule, code of conduct, venue). The template builds in seconds and deploys to any static host.

## Sites looking for a slot here

If you are using the template and want to be listed:

1. Confirm your site builds with the current template version.
2. Open an issue on [GitHub](https://github.com/nirholas/scroll-zoom-thing/issues) titled "Example: yourdomain.tld" with a one-paragraph description and a link to the public repository.
3. If accepted, a maintainer will open a PR adding your entry to this page (or you can open the PR yourself).

## Why we keep the list short

This page exists to be useful, not to be impressive. A short curated list of well-documented production sites is more helpful than a long list of demos. We will rotate stale entries off and prefer entries with public repositories.

## Anti-examples

It is also useful to know when the template is the wrong choice. Do not use it for:

- Sites that need a complex JavaScript-driven hero (video backgrounds with synchronised text, full-bleed canvas animations). The template's pure-CSS approach will fight you.
- Sites where the hero must work in IE11 or other engines without `transform: translateZ` support.
- Sites that want a different documentation framework. The template is tightly coupled to MkDocs Material; porting it to Docusaurus or VitePress would mean rewriting most of the partials.

## Next steps

If you want to study a real deployment, start with the [docs.pai.direct case study](docs-pai-direct.md). If you want to start your own site, the [Getting Started](../getting-started/index.md) section walks through the first build. If you want to understand the deployment options, see the [Deploy](../deploy/index.md) landing page.
