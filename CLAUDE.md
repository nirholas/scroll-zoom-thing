# scroll-zoom-thing

CSS 3D perspective parallax for MkDocs Material — no JS, pure CSS.

## Project structure

```
docs/
├── overrides/home.html          # Jinja2 template — layer <picture> elements
├── assets/stylesheets/home.css  # All parallax CSS, heavily commented
└── assets/hero/                 # Drop AVIF layers here
skills/                          # Claude agent skills
.claude/commands/                # Claude slash commands
agents/                          # Agent documentation
mkdocs.yml
```

## Running locally

```bash
pip install mkdocs-material
mkdocs serve
```

## CSS variables per layer

| Variable | Effect |
|---|---|
| `--md-parallax-depth` | Depth — higher = slower. Suggested: `8`, `5`, `2`, `1` |
| `--md-image-position` | `object-position` horizontal % |

## Conventions

- No JavaScript in parallax — CSS only
- Images must be AVIF, `@4x` suffix, named `N-description@4x.avif`
- Skills live in `skills/`, commands in `.claude/commands/`
- Do not change the MkDocs theme

## Credits

Parallax technique ported from [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) — MIT License, Martin Donath.
