# scroll-zoom-thing — Gemini Agent Guide

CSS 3D perspective parallax for MkDocs Material. No JavaScript. Pure CSS.

## How the parallax works

`perspective` on the scroll container creates a 3D context. Each layer uses `translateZ` to sit at a different depth — layers pushed further back appear to scroll slower. `scale()` compensates for the size reduction caused by depth, so all layers fill the viewport.

## Key files

| File | Role |
|---|---|
| `docs/overrides/home.html` | Jinja2 layer template — add/remove `<picture>` groups here |
| `docs/assets/stylesheets/home.css` | All parallax CSS with inline comments |
| `docs/assets/hero/` | Drop AVIF layer images here |
| `mkdocs.yml` | MkDocs configuration |
| `skills/` | Agent skill definitions |

## Layer CSS variables

```css
/* Per layer, set inline on the <picture> element */
--md-parallax-depth: 5;      /* higher = further back = slower scroll */
--md-image-position: 50%;    /* object-position horizontal % */
```

## Do not

- Add JavaScript to implement scroll behavior
- Change the theme from MkDocs Material
- Use image formats other than AVIF for layers

