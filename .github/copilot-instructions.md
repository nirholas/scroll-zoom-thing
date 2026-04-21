# scroll-zoom-thing

CSS 3D Perspective Parallax — a pure-CSS parallax technique for MkDocs Material.

## Project overview

`perspective` on the scroll container pushes each layer back with `translateZ`. Layers farther from the vanishing point move slower. `scale()` compensates so layers fill the viewport. No JS, no scroll events — just the browser's natural 3D projection during scroll.

## Key files

- `docs/overrides/home.html` — Jinja2 template with layer `<picture>` elements
- `docs/assets/stylesheets/home.css` — All parallax CSS
- `docs/assets/hero/` — Drop AVIF layer images here
- `mkdocs.yml` — MkDocs Material configuration

## CSS variables per layer

| Variable | Effect |
|---|---|
| `--md-parallax-depth` | Depth — higher = slower scroll. Suggested: `8`, `5`, `2`, `1` |
| `--md-image-position` | `object-position` horizontal %. Controls visible crop |

## Agent skills

Skills live in `skills/` and Claude commands in `.claude/commands/`. When modifying skills, keep the SKILL.md interface contract in sync.

## Conventions

- No JavaScript in the parallax implementation — CSS only
- Images must be AVIF format, `@4x` suffix
- MkDocs Material theme only
