---
title: Accessibility
description: Accessibility considerations for the parallax hero and the rest of a scroll-zoom-thing site.
---

# Accessibility

Parallax effects have a deserved reputation for being hostile to readers with vestibular conditions, screen reader users, and anyone navigating by keyboard. The template tries to avoid those failure modes by default, but accessibility is something you keep working at, not something you check off. This page documents the choices the template makes and the responsibilities that remain with you.

## Reduced motion

The single most important accessibility feature for a parallax hero is honouring `prefers-reduced-motion`. The template's hero stylesheet wraps the parallax transforms in a media query:

```css
@media (prefers-reduced-motion: no-preference) {
  .parallax-layer {
    transform: translateZ(var(--depth)) scale(var(--counter-scale));
  }
}

@media (prefers-reduced-motion: reduce) {
  .parallax-layer {
    transform: none;
  }
  .parallax-container {
    perspective: none;
    overflow: visible;
  }
}
```

When the operating system reports a reduced-motion preference, the layered transforms collapse to a flat composition. Scrolling no longer translates the layers at different rates. The hero remains visually present (so the page does not look broken) but the motion that triggers vestibular symptoms is removed.

Test this by setting your OS to reduce motion (System Settings on macOS, Settings → Ease of Access on Windows, or `gsettings` on GNOME) and reloading. The hero should display as a static composition.

## Alt text for parallax layers

Each layer in the parallax hero is a decorative image stacked into a single composition. Treat the composition, not the individual layers, as the meaningful image:

- Mark the individual layer `<img>` elements with `alt=""` and `role="presentation"`. They are decorative components of a larger image.
- Provide a single descriptive alt text on the wrapping element, or include a visually hidden caption near the hero.

The template's hero partial already sets empty alts on the layer images. If you replace the partial, preserve that behaviour. A screen reader walking the hero should hear one description, not five.

If your hero contains text rendered as part of an image layer (a logo or a slogan), the alt text on the wrapping element must include that text. Image-rendered text is invisible to screen readers and to anyone running a translation tool.

## Keyboard navigation

The hero contains no interactive elements by default, so there is nothing to tab to. If you add a call-to-action button overlaid on the hero, verify:

1. The button receives a visible focus ring. MkDocs Material's default focus ring is preserved by the template; do not override it without replacement.
2. The focus ring has at least 3:1 contrast against the layer immediately behind it. On a busy hero this often fails. The fix is usually a solid background plate behind the button, not a thicker focus ring.
3. Tab order matches reading order. If you use `position: absolute` to place the button, the DOM order should still be sensible.

The skip-link added by MkDocs Material continues to work with the template. Test it by pressing Tab as the first action after page load; the "Skip to content" link should appear.

## Screen reader compatibility

Run a quick screen reader pass before publishing. The cheap version of this test:

- macOS: enable VoiceOver (Cmd+F5), navigate to the page, press Ctrl+Option+A to read everything.
- Windows: install NVDA (free), navigate to the page, press Insert+Down to read everything.

You are listening for three things. First, the hero should announce as a single image (or be silent if it is purely decorative and has no overlaid text). Second, the page heading should be announced once, with the correct level. Third, the navigation should be announced as a navigation landmark.

If the screen reader announces every layer image separately, the alt text is wrong. If it announces the heading twice, you probably have an `<h1>` both in the hero overlay and in the page content; remove one.

## Colour contrast

Parallax heroes love to put thin white text over a busy gradient. This usually fails WCAG AA. Two fixes that work well:

- Add a semi-opaque solid plate behind the hero text (a `rgba(0,0,0,0.45)` panel, for example) so the text contrast is measured against a known colour.
- Use a heavy text weight and a text-shadow only as a secondary accent; do not rely on the shadow for contrast.

Check the contrast with the WebAIM contrast checker or the Accessibility panel in Chrome DevTools. The threshold is 4.5:1 for body text and 3:1 for text 18pt or larger (24px regular, 18.66px bold).

## Heading structure

The template's homepage uses a single `<h1>` for the site title and `<h2>` for section breaks. If you customise the hero partial, do not introduce a second `<h1>`. Screen reader users navigate by heading level, and a duplicate top-level heading makes the document outline misleading.

## Forms and embedded widgets

The template does not include forms. If you add an embedded form (a newsletter signup, a feedback widget), the form must:

- Have visible, persistent labels for each input. Placeholder-only labels fail WCAG.
- Associate error messages with their inputs via `aria-describedby`.
- Be reachable and submittable using only the keyboard.
- Honour `prefers-reduced-motion` for any animation it adds.

## Auditing

A short audit checklist before each release:

1. Run [axe DevTools](https://www.deque.com/axe/devtools/) on the homepage and one inner page.
2. Run Lighthouse's Accessibility audit; aim for a score of 100, but treat any score below 95 as a regression to investigate.
3. Test with reduced motion enabled.
4. Test with JavaScript disabled. The hero should still render; the navigation should still work.
5. Test at 200% browser zoom. The hero should not produce horizontal scrollbars.

Accessibility is not a feature you ship once. The template gives you a defensible starting point, but every change you make to the hero or the layout deserves the same five-step pass. See [analytics.md](analytics.md) for related privacy considerations and [index.md](index.md) for the broader privacy posture.
