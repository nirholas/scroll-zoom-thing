---
title: "Case study: docs.pai.direct"
description: How docs.pai.direct uses scroll-zoom-thing as its parallax MkDocs template.
---

# Case study: docs.pai.direct

[docs.pai.direct](https://docs.pai.direct) is the production reference deployment of scroll-zoom-thing. The template was extracted from the docs site, generalised, and released as a standalone project. As a result, the live site is the most complete example of what a finished build looks like.

This page covers what PAI is, how the docs site uses the parallax hero, the specific layer choices the maintainers made, and how to inspect the setup.

## What PAI is

PAI is a Linux distribution focused on running AI models locally without an internet connection. It bundles a curated set of open-weight models, a launcher, and the supporting drivers needed to make GPU-accelerated inference work on consumer hardware. The project's positioning is "offline AI" - everything runs on the user's machine, no cloud round trips, no telemetry.

That positioning matters for the docs site choice. PAI's audience is privacy-sensitive by self-selection. A docs site that pulled in Google Fonts or shipped Google Analytics would contradict the product's pitch. The team needed a docs framework that could ship fast, look distinctive, and not introduce third-party requests. scroll-zoom-thing was built to be that framework.

## How the parallax hero is used

The PAI homepage hero is a layered illustration of a stylised desktop scene with floating UI elements. The layers move at different rates as the visitor scrolls, producing the depth effect without any JavaScript. Specifically:

- The back layer is a soft gradient and atmospheric glow, set deep in the perspective stack.
- A middle layer carries the main illustration: monitor, peripherals, ambient props.
- A foreground layer holds small UI fragments (buttons, badges, accent shapes) that drift past the camera most aggressively.
- An overlay layer carries the page title and the call-to-action. It does not translate; it is pinned at scale 1 so the type stays crisp.

The total weight of the hero is well under 200 KB because every layer is a static SVG or compressed PNG and there is no script. The hero meets the project's accessibility floor by collapsing to a static composition under `prefers-reduced-motion: reduce`.

## Layer choices

The docs.pai.direct hero uses four layers. The template supports up to six in the default partial; the team kept it to four for two reasons:

1. Each additional layer adds a paint cost on scroll. Four layers is the sweet spot where the depth effect reads clearly without the GPU cost climbing.
2. Each additional layer is one more illustration to maintain. Fewer layers means simpler updates when the brand evolves.

The depth values used by the site are roughly:

```css
.layer-back   { --depth: -800px; --counter-scale: 1.8;  }
.layer-mid    { --depth: -400px; --counter-scale: 1.4;  }
.layer-fore   { --depth: -150px; --counter-scale: 1.15; }
.layer-overlay{ --depth:    0px; --counter-scale: 1.0;  }
```

The `--counter-scale` values compensate for the perspective foreshortening so each layer fills the viewport. If you copy these values, expect to tweak them: they depend on the perspective distance set on the container and on the aspect ratio of your source images.

## Theme and typography choices

PAI's docs site uses MkDocs Material's dark palette with a custom accent. The fonts are self-hosted Inter for body and a self-hosted display face for the homepage hero. Both fonts live in `assets/fonts/` in the repo and are served as `woff2` from the same origin as the HTML. There are no requests to `fonts.googleapis.com`.

Code blocks use the `material` syntax highlighter with a custom palette tuned for the dark theme. The site does not use `mkdocs-jupyter` or any other plugin that ships JavaScript at runtime.

## Deployment topology

docs.pai.direct is deployed on Cloudflare Pages with the production branch wired to the repo's `main`. Every push to `main` triggers a fresh build. The site uses Cloudflare Web Analytics in the cookieless mode described in [analytics.md](../privacy/analytics.md), which keeps the analytics inside Cloudflare's own infrastructure and avoids adding third-party requests to the page. See [cloudflare.md](../deploy/cloudflare.md) for the deployment guide that the site follows.

The site has a single custom domain (`docs.pai.direct`) configured in Cloudflare with full TLS. There is no separate staging domain; preview branches receive Cloudflare Pages preview URLs.

## Performance posture

The PAI team optimises for two metrics:

- **Largest Contentful Paint** under 1.5 s on a throttled 4G connection. The pure-CSS hero helps here because there is no JavaScript blocking paint.
- **Total Blocking Time** under 50 ms. With no animation loop and no analytics script, this is mostly free.

The Lighthouse Performance score for the homepage typically sits at 99-100. The Accessibility score sits at 100, and the SEO score at 100. The Best Practices score is 100 because the site does not load any third-party content.

## How to view the setup

The docs.pai.direct repository is public. To inspect how the site is configured:

1. Clone the repository (linked from the site footer).
2. Look at `mkdocs.yml` to see the navigation and theme configuration.
3. Look at `src/index.md` to see the homepage front matter and the partial used for the hero.
4. Look at `src/assets/parallax/` for the layer images.
5. Look at `overrides/partials/` for any partials that override the template defaults.

If you want to clone the look directly, the safest path is to start a fresh project from scroll-zoom-thing's template and copy specific files (the hero partial, the parallax CSS) rather than forking the docs repo. That keeps your project independent of PAI's release cadence.

## What to take from this example

The lesson from docs.pai.direct is that a parallax hero does not need to be heavy. Four static layers, one container with `perspective`, and a media query for reduced motion is enough to produce a hero that holds attention without trading away performance, privacy, or accessibility. If your project shares those constraints, the template should fit comfortably.

For other potential examples and the criteria for being listed, see the [Examples landing page](index.md).
