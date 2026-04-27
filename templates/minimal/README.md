# Template: minimal

A bare hero with no pillars, no intro cards. Just the four parallax layers, a headline, a subhead, and two CTAs.

## Use when

- You want a simple project landing page.
- The hero should dominate the viewport; everything else lives in the docs nav.
- You have ≤ 5 markdown content pages.
- You don't need to summarize the product on the home page (the headline and subhead are enough).

## Avoid when

- You need value-prop pillars (use `marketing-hero` instead).
- You need an "Overview" or "Quickstart" intro card on the home (use `marketing-hero`).
- You have dozens of docs pages and the marketing feel is wrong (use `product-docs`).

## What's included

```
templates/minimal/
├── README.md            # this file
├── mkdocs.yml           # site config with placeholders
├── overrides/
│   └── home.html        # hero only — no pillars, no intro
└── src/
    ├── index.md         # home page (shadowed by hero)
    ├── about.md         # placeholder content page
    └── assets/
        ├── hero/        # placeholder AVIFs (replace these)
        ├── stylesheets/
        │   └── home.css # parallax engine, verbatim
        └── theme.css    # brand stylesheet
```

## After scaffolding

1. **Replace the AVIF layers** in `src/assets/hero/`. The placeholders are zero-byte files; the build will fail until you replace them. Use the `convert-images` skill or `avifenc` directly.
2. **Edit the headline and subhead** in `overrides/home.html`.
3. **Wire CTA targets** to real pages. Both buttons currently point to `getting-started/` — create that file or change the hrefs.
4. **Update brand colors** in `src/assets/theme.css`.
5. **Run** `mkdocs serve` and verify the parallax scrolls.

## Time to ship

10–15 minutes if you have AVIFs ready. 30–60 minutes from scratch (most of that is generating artwork).
