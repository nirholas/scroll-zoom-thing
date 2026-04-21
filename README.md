# CSS 3D Perspective Parallax — MkDocs Material

> CSS 3D perspective scrolling — a pure-CSS parallax. `perspective` on the scroll container pushes each layer back with `translateZ`; layers farther from the vanishing point move slower. `scale()` compensates so they fill the viewport. No JS, no scroll events — just the browser's natural 3D projection during scroll.

## What's here

A minimal, copy-paste example of the parallax hero used on [squidfunk.github.io/mkdocs-material](https://squidfunk.github.io/mkdocs-material/), extracted and documented.

```
docs/
├── overrides/
│   └── home.html          # Jinja2 template with layer <picture> elements
├── assets/
│   ├── stylesheets/
│   │   └── home.css       # All parallax CSS, heavily commented
│   └── hero/              # Drop your AVIF layers here
│       ├── 1-landscape@4x.avif
│       ├── 2-plateau@4x.avif
│       ├── 5-plants-1@4x.avif
│       └── 6-plants-2@4x.avif
├── index.md
├── how-it-works.md
└── your-own-layers.md
mkdocs.yml
```

## Quick start

```bash
pip install mkdocs-material
# drop your AVIF layers into docs/assets/hero/
mkdocs serve
```

## Key variables

Each layer in `home.html` takes two inline CSS variables:

| Variable | Effect |
|---|---|
| `--md-parallax-depth` | Depth (higher = slower scroll). Suggested: `8`, `5`, `2`, `1` |
| `--md-image-position` | `object-position` horizontal %. Controls which part of the image shows |

