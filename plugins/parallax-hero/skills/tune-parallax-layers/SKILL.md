---
name: tune-parallax-layers
description: Adjust the depth and crop of each layer in a scroll-zoom-thing parallax hero by editing the CSS variables in overrides/home.html. Use when the parallax feels flat, glued together, too strong or crops the wrong part of an image.
---

# Tune parallax layers

Each layer in `overrides/home.html` is a `<picture class="mdx-parallax__layer">` with two inline custom properties:

- `--md-parallax-depth: N` is how far back the layer sits. Higher N moves the layer further back, so it scrolls slower and shows more parallax. The CSS applies `translateZ(perspective * depth * -1)` and `scale(depth + 1)`. Keep adjacent layers at least 2 apart for visible separation.
- `--md-image-position: X%` maps to `object-position` on the horizontal axis (0% left edge, 50% center, 100% right edge).

The default ladder, back to front, is depth 8, 5, 2, 1 with positions 70%, 25%, 40%, 50%. The global `--md-parallax-perspective` (default `2.5rem`) is set in `src/assets/stylesheets/home.css`.

## Diagnosis

| Report | Likely cause | Change |
|---|---|---|
| Far background barely moves | depth too low or too uniform | raise the far layer depth (up to 8) |
| Layers look glued together | depths too close, for example 2, 3, 4, 5 | spread them, for example 1, 3, 6, 9 |
| Effect weak on ultrawide screens | perspective too small | raise `--md-parallax-perspective`, for example to `3rem` |
| Wrong part of an image shows | `--md-image-position` off | move it in 10% steps until the subject is visible |
| Foreground cut off at the bottom | crop anchored to center | check image dimensions and position |

## Workflow

1. Read `overrides/home.html` and list each layer's filename, depth and position.
2. If the complaint does not name a layer, ask which one, or infer it from the description.
3. Change only the values needed and say what you expect to change.
4. Run `mkdocs build` and confirm it succeeds; use `mkdocs serve` for the user to look at it.

Do not edit the parallax rules in `home.css` other than `--md-parallax-perspective`, unless the user asks.
