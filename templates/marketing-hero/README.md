# Template: marketing-hero

The full PAI-style home page: hero with four parallax layers, a three-pillar value-prop section, and a two-card intro section. Behind the home, a complete docs nav.

## Use when

- You're building a product/SaaS docs site that doubles as a marketing page.
- The home should have value-prop pillars summarizing the product.
- You want an "Overview + Quickstart" intro card layout.
- You expect 20–100 docs pages organized into sections.

## Avoid when

- You want a clean docs-only site without marketing flavor (use `product-docs`).
- You only have ≤ 5 docs pages (use `minimal`).

## What's included

This template currently mirrors the root `scroll-zoom-thing` repo as the canonical PAI-style site. To use it as a template:

1. Run the scaffolding script: `./scripts/new-site.sh my-project marketing-hero`.
2. The script copies the *root* repo into your new project and applies placeholder substitution.
3. Replace the AVIFs in `src/assets/hero/`, the logo in `src/assets/`, and the brand colors in `src/assets/pai-theme.css`.
4. Rewrite the pillar copy and intro card copy in `overrides/home.html` (keep the structure, change the words).
5. Restructure the nav in `mkdocs.yml` for your project's docs.

## Why no separate template files yet

Maintaining two parallel copies of the same site (root + template) drifts. The marketing-hero template uses the root files directly; the scaffolding script does the work of copying and templating. If you find yourself wanting this template to diverge from the root, that's the signal to give it its own files.

## After scaffolding

See [`AGENTS.md` § 6 (Workflow A)](../../AGENTS.md#workflow-a) for the full new-project checklist.
