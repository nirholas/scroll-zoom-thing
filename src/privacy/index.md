---
title: Privacy
description: Privacy-conscious defaults and choices for parallax sites built with scroll-zoom-thing.
---

# Privacy

scroll-zoom-thing ships with privacy-respecting defaults. The template renders entirely from static HTML, CSS, and a small amount of JavaScript shipped by MkDocs Material itself. No analytics, no third-party fonts, and no tracking pixels are included out of the box. This page documents those defaults and the choices you should think about before publishing a site built on the template.

## What the template does not do

Out of the box the template makes zero third-party network requests beyond what MkDocs Material itself emits. Specifically:

- **No analytics.** There is no Google Analytics, no Plausible script, no Segment, no Hotjar, no Sentry. If you want analytics, you opt in. See [analytics.md](analytics.md) for privacy-first options.
- **No third-party fonts.** Fonts are either system fonts or self-hosted in `assets/fonts/`. No requests go to `fonts.googleapis.com` or `fonts.gstatic.com`.
- **No tracking pixels or beacons.** No Facebook pixel, no LinkedIn Insight tag, no marketing automation tags.
- **No cookies set by the template itself.** MkDocs Material has an optional cookie consent component, but this template does not enable it because there are no cookies to consent to.
- **No external CDNs for runtime assets.** All CSS and JavaScript that drives the parallax hero is bundled with the site.

The result: a visitor opening a page served by this template establishes connections only to your own origin. That makes the site cheap to audit, friendly to readers behind strict content blockers, and easy to deploy in regulated environments.

## Why this matters for a parallax site

The parallax hero is implemented in pure CSS using `transform: translateZ()` on a stack of layered images. There is no JavaScript animation loop, no IntersectionObserver, no scroll listener. This is a deliberate privacy choice as much as a performance one:

- A pure-CSS hero never needs to send telemetry about scroll position, dwell time, or pointer movement.
- There is no client-side state to persist, so there is nothing to write to `localStorage`, `sessionStorage`, or cookies.
- The hero degrades cleanly when JavaScript is disabled. Readers using Tor Browser at the "Safer" or "Safest" security level will see the full hero without any broken behaviour.

## Self-hosted assets

Every image, font, and script the template references is served from the same origin as the HTML. When you add a layer to the parallax hero, you place the file in `src/assets/parallax/` and reference it with a relative path. The build copies it into the output directory.

If you add a third-party dependency later (a video embed, a code playground, an embedded form), audit it before committing. A useful exercise is to load a built page with the browser's DevTools network panel filtered to "third party" and confirm the list is empty.

## Accessibility is a privacy concern

Accessibility and privacy overlap more than most sites acknowledge. A reader who relies on `prefers-reduced-motion` is signalling a system-level preference. A site that ignores that signal forces the reader to disclose their preference again, often via a toggle that may be tracked. The template honours `prefers-reduced-motion: reduce` and disables parallax translation when the media query matches. See [accessibility.md](accessibility.md) for the full list of accessibility considerations.

## Logs and server-side data

The template itself does not collect data, but the platform you deploy to will keep some access logs. The default deployment targets behave roughly as follows:

- **Cloudflare Pages** keeps aggregated request data and offers cookieless Web Analytics as an opt-in.
- **Netlify** keeps request logs scoped to your account and offers paid analytics.
- **Vercel** keeps request logs and offers analytics as a paid add-on.
- **GitHub Pages** does not expose logs to site owners.
- **Railway** keeps logs from the Python `http.server` process you run.

If your readers' privacy is a hard requirement, prefer GitHub Pages (no log access for the owner) or Cloudflare Pages with Web Analytics disabled.

## Content Security Policy

The template does not ship a Content Security Policy header by default because headers are platform-specific. If you serve from Cloudflare or Netlify, adding a strict CSP is straightforward:

```
Content-Security-Policy: default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self'
```

The `'unsafe-inline'` for styles is required by MkDocs Material's runtime theming; everything else can be locked to `'self'`.

## Checklist before publishing

1. Open DevTools, load a built page, and confirm the network tab shows only your origin.
2. Search the rendered HTML for `googleapis`, `gstatic`, `analytics`, and `cdn.` to catch accidentally introduced third-party assets.
3. Decide whether you need analytics. If yes, follow [analytics.md](analytics.md). If no, leave `extra_javascript` empty.
4. Review [accessibility.md](accessibility.md) and confirm the reduced-motion fallback works on your hero.
5. If you are deploying behind a custom domain, configure HTTPS and a CSP header at the platform level.
