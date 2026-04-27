# Template: product-docs

A docs-first site: same parallax hero engine as the other templates, but a hero with only a tagline and one CTA, no pillars, no intro cards. The hero is a brand mark; the docs are the product.

## Use when

- You're building deep technical documentation (dozens to hundreds of pages).
- The home is a tagline-and-jump-into-docs experience.
- You don't need marketing flavor — users come to read, not to be sold.
- Your nav has 5+ top-level sections with multiple sub-pages each.

## Avoid when

- You need pillars or marketing intro cards on the home (use `marketing-hero`).
- You have a small docs surface (use `minimal`).

## Status

This template is a stub. The current implementation falls through to the same scaffolding logic as `marketing-hero` but with the pillars and intro sections deleted from the generated `overrides/home.html`. To produce its dedicated form, build three product-docs sites from `marketing-hero` first, observe the changes you make every time, then promote those into a real template.

## After scaffolding

The scaffolder, when given `product-docs`, will:
1. Copy the root repo.
2. Apply placeholder substitution.
3. Strip the `mdx-pillars` and `mdx-intro` `<section>` blocks from `overrides/home.html`.
4. Strip the matching CSS from `src/assets/pai-theme.css`.
5. Leave the nav tree intact (you'll restructure it for your project).

See [`AGENTS.md` § 6 (Workflow A)](../../AGENTS.md#workflow-a) for next steps.
