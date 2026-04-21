---
name: tune-layers
description: Adjust --md-parallax-depth and --md-image-position values on existing parallax layers based on user description of visual problems.
version: 0.1.0
triggers:
  - when the user says the parallax effect is too subtle or too strong
  - when layers look misaligned or the wrong part of the image shows
  - when the user wants to adjust depth or image position values
  - when the hero scrolls too fast or too slow
inputs:
  - name: problem_description
    type: string
    required: true
    description: What the user sees — e.g. "far background barely moves", "plants are cut off"
outputs:
  - updated --md-parallax-depth and/or --md-image-position values in home.html
  - explanation of what each change does visually
constraints:
  - change one layer at a time unless the user explicitly asks for a full reset
  - always explain the expected visual effect before writing
  - run mkdocs build after changes
---

# tune-layers

Adjust layer depth and image position values in `docs/overrides/home.html`.

## 1. Purpose

The two inline CSS variables on each `<picture>` element control the
parallax effect. This skill diagnoses visual problems and adjusts the
values, one layer at a time.

## 2. Variables explained

```
--md-parallax-depth: N
```
Controls how far back the layer sits in 3D space.
- Higher N → layer pushed further back → scrolls slower → more parallax
- Lower N → layer closer → scrolls faster → less parallax
- Adjacent layers should differ by at least 2 for visible separation

```
--md-image-position: X%
```
Maps to CSS `object-position` (horizontal axis).
- `0%` shows the left edge of the image
- `50%` shows the center
- `100%` shows the right edge
- Adjust when the subject of the image is cropped out

## 3. Diagnosis map

| User reports | Likely cause | Fix |
|---|---|---|
| "Far background barely moves" | Depth too high (e.g. 8 on a shallow scene) | Lower far bg depth to 4–6 |
| "Layers look glued together" | Depths too close (e.g. 2, 3, 4, 5) | Spread to 1, 3, 6, 9 |
| "Effect disappears on ultrawide monitor" | Perspective too small | Increase `--md-parallax-perspective` to 3rem |
| "Wrong part of image shows" | `--md-image-position` off | Adjust in 10% increments until subject is centered |
| "Plants/fg layer cut off at bottom" | `object-position` anchors to center | Set `--md-image-position` to `50%` and check image dimensions |
| "Hero scrolls past too quickly" | First group not tall enough | Not a depth issue — see `advanced-css.md` group height |

## 4. Workflow

1. Read current `docs/overrides/home.html`.
2. Print a table of current layer filenames, depths, and positions.
3. Ask the user which layer(s) are problematic if not clear from the description.
4. Propose new values with a one-sentence explanation of the expected change.
5. Write the updated values.
6. Run `mkdocs build` and confirm success.

## 5. Changelog

- `0.1.0` — Initial skill.

