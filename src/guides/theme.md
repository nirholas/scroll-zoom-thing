---
title: Theme
description: Customize colors via Material's named palettes, override CSS custom properties for fine control, and configure dark and light mode.
---

# Theme

scroll-zoom-thing exposes color customization at two levels. The high-level
knob is MkDocs Material's named palettes, which you change in
`mkdocs.yml`. The low-level knob is the CSS custom properties exposed in
`src/assets/pai-theme.css`, which you edit directly. This guide covers
both, plus how dark and light mode interact with the parallax hero.

## The named palettes

MkDocs Material ships with a fixed set of color names you can pick from.
The full list - `red`, `pink`, `purple`, `deep purple`, `indigo`, `blue`,
`light blue`, `cyan`, `teal`, `green`, `light green`, `lime`, `yellow`,
`amber`, `orange`, `deep orange`, `brown`, `grey`, `blue grey`, `black`,
and `white` - is documented in
[Material's color reference](https://squidfunk.github.io/mkdocs-material/setup/changing-the-colors/).

Pick one and set it in `mkdocs.yml`:

```yaml
theme:
  name: material
  custom_dir: overrides
  palette:
    - scheme: default
      primary: indigo
      accent: pink
```

`primary` is the color used for the header, the navigation, and the
filled button. `accent` is used for links, hover states, and emphasis. The
parallax hero picks up both - the primary color tints the header that sits
above the hero, and the accent color drives the primary button background.

After changing `mkdocs.yml`, restart `mkdocs serve` (changes to the config
require a restart, unlike content changes which hot-reload).

## Dark and light mode

Material supports a palette-toggle pattern with two entries:

```yaml
theme:
  palette:
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: indigo
      accent: pink
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      primary: indigo
      accent: pink
      toggle:
        icon: material/brightness-4
        name: Switch to light mode
```

The `media` key tells Material which entry to default to based on the
user's OS preference. The `toggle` block adds a button to the header that
flips between the entries. `scheme: default` is light; `scheme: slate` is
dark.

The parallax hero respects the active scheme. The text color on the hero
content block is bound to `var(--md-default-fg-color)`, which Material
swaps automatically when the scheme changes. If your hero AVIFs are
photographic and look bad over a dark background, consider whether you
want to ship two sets of layers (see "Per-scheme assets" below).

## Custom properties in `pai-theme.css`

For finer control than the named palettes give you, edit
`src/assets/pai-theme.css`. This file is loaded after Material's stylesheet
and overrides the relevant custom properties:

```css
:root {
  --md-primary-fg-color: #4f46e5;
  --md-primary-fg-color--light: #818cf8;
  --md-primary-fg-color--dark: #3730a3;
  --md-accent-fg-color: #ec4899;

  /* Parallax-specific */
  --md-parallax-bg: #0b0d10;
  --md-parallax-fg: #ffffff;
  --md-parallax-button-bg: var(--md-accent-fg-color);
  --md-parallax-button-fg: #ffffff;
}

[data-md-color-scheme="slate"] {
  --md-parallax-bg: #050608;
  --md-parallax-fg: #f3f4f6;
}
```

The `--md-*` properties prefixed without `parallax` are Material's. The
`--md-parallax-*` properties are scroll-zoom-thing's own. The split lets
you change the global theme without affecting the hero, or change the hero
without affecting the rest of the site.

To find the property that controls a specific element, inspect it in
browser DevTools. The "Computed" panel shows which custom property feeds
each color, and you can trace the cascade from there.

## Tinting the parallax layers

Sometimes the hero art is close in tone to the background and you want to
push it forward visually. The CSS supports a tint overlay:

```css
.md-parallax__layer::after {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(
    180deg,
    rgba(0, 0, 0, 0) 0%,
    var(--md-parallax-bg) 100%
  );
  pointer-events: none;
}
```

The default stylesheet ships a similar gradient tuned for the bundled
artwork. If you replace the AVIFs and the gradient no longer reads well,
adjust the stops or change the blend.

## Per-scheme assets

If your hero needs different artwork for light and dark modes, you can
swap the AVIF source via CSS rather than rendering both sets of `<div>`s:

```css
[data-md-color-scheme="default"] .md-parallax__layer--1 {
  background-image: url("../layer-1-light.avif");
}

[data-md-color-scheme="slate"] .md-parallax__layer--1 {
  background-image: url("../layer-1-dark.avif");
}
```

Add a per-layer modifier class to each `<div>` in `overrides/home.html`
(`md-parallax__layer--1`, `md-parallax__layer--2`, and so on) so the
selectors above can target them. The `background-image` declared inline
in the template will need to be removed, otherwise it will win the
specificity battle.

## A note on contrast

The parallax hero is large and visually busy. Text contrast over the
combined layers should be checked against
[WCAG AA](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html)
at minimum. The default styling pairs a 700-weight headline with a tinted
gradient overlay, which clears AA on the bundled artwork. If you replace
the layers, re-check.

## Verifying changes

After editing palette settings or `pai-theme.css`:

1. Restart `mkdocs serve` if you edited `mkdocs.yml`. CSS changes
   hot-reload without a restart.
2. Open the home page and toggle dark and light mode using the header
   button.
3. Open a content page (for example, the Overview) and confirm the
   primary and accent colors flow through.
4. Run Lighthouse in DevTools and check the contrast warnings.

For navigation and content structure changes, continue to
[Pages and nav](pages-and-nav.md).
