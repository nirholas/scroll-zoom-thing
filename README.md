# scroll-zoom-thing

> A pure-CSS 3D parallax MkDocs Material template. No JavaScript, no scroll listeners, no animation frame loops. Just `perspective`, `translateZ`, and `scale()`, plus a handful of AVIF layers, wired into the browser's own scroll rendering.

The repository is a working production site — the docs you see when you build it are [docs.pai.direct](https://docs.pai.direct), included verbatim as a real-world example of the parallax pattern in use. Replace the content in `src/` with your own and you have a cinematic, depth-driven docs site for your own project.

> **Working with an AI agent? Read [`AGENTS.md`](AGENTS.md) first.** It is a tool-neutral operator's manual covering the mental model, decision tree, nine workflows (clone, hero copy, artwork, depth tuning, sections, pages, nav, palette, deploy), verification checklist, and common mistakes. There are also [`templates/`](templates/) starters and a [`scripts/new-site.sh`](scripts/new-site.sh) scaffolder that produces a new project in under a minute.

---

## Deploy in one click

| Platform | One-click | Cost | Notes |
|---|---|---|---|
| **Vercel** | [![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fnirholas%2Fscroll-zoom-thing) | Free | Truly zero-config. `vercel.json` does everything. |
| **Railway** | [![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy?template=https%3A%2F%2Fgithub.com%2Fnirholas%2Fscroll-zoom-thing) | Free trial → paid | Builds with `nixpacks.toml`, serves via Python http.server. |
| **Netlify** | [![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy?repository=https://github.com/nirholas/scroll-zoom-thing) | Free | `netlify.toml` configures Python build automatically. |
| **Cloudflare Pages** | [Connect repo](https://dash.cloudflare.com/?to=/:account/pages/new/provider/github) | Free, unlimited bandwidth | Set build command + `PYTHON_VERSION=3.12` once in dashboard. |
| **GitHub Pages** | Enable in [repo Settings → Pages → Source: GitHub Actions](#github-pages) | Free | Workflow at `.github/workflows/deploy.yml` auto-deploys on push. |

Click any button above. Each deploys this repository as-is, with the PAI docs as the example content. To make it your own, fork the repo first and click the button on your fork.

---

## Table of contents

- [What this is](#what-this-is)
- [What you see when you deploy](#what-you-see-when-you-deploy)
- [The parallax effect, in 30 seconds](#the-parallax-effect-in-30-seconds)
- [Quick start (local)](#quick-start-local)
- [Repository layout](#repository-layout)
- [Using this as a template](#using-this-as-a-template)
- [Building a parallax site from scratch](#building-a-parallax-site-from-scratch)
- [Per-layer CSS variables](#per-layer-css-variables)
- [Designing your own layers](#designing-your-own-layers)
- [Generating layers with AI](#generating-layers-with-ai)
- [Converting images to AVIF](#converting-images-to-avif)
- [Tuning depth, crop, and composition](#tuning-depth-crop-and-composition)
- [Customizing the hero text](#customizing-the-hero-text)
- [Adding pages and navigation](#adding-pages-and-navigation)
- [Customizing colors and theme](#customizing-colors-and-theme)
- [Deployment](#deployment)
  - [Vercel](#vercel)
  - [Cloudflare Pages](#cloudflare-pages)
  - [GitHub Pages](#github-pages)
  - [Railway](#railway)
  - [Netlify](#netlify)
  - [Custom domains](#custom-domains)
- [Tutorials](#tutorials)
- [Use cases and examples](#use-cases-and-examples)
- [Browser support and accessibility](#browser-support-and-accessibility)
- [Performance notes](#performance-notes)
- [Agent skills bundled with this repo](#agent-skills-bundled-with-this-repo)
- [FAQ](#faq)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Credits](#credits)
- [License](#license)

---

## What this is

`scroll-zoom-thing` is a minimal, documented, copy-pasteable reference implementation of a layered parallax hero on top of MkDocs Material. It is opinionated about three things:

1. **No JavaScript drives the parallax.** The depth effect is the browser's native 3D projection of `translateZ`-positioned elements inside a `perspective` scrolling container. There is no `requestAnimationFrame` loop, no scroll event handler, nothing fires per frame. The compositor does the work.
2. **AVIF layers, four planes deep.** Four panoramic AVIF images stacked at depths 8, 5, 2, 1 give a perceptible parallax range without bloating asset weight beyond ~600 KB total.
3. **Production-tested.** The site you build from this repository is the live documentation site for [PAI](https://pai.direct), an open-source bootable Linux distribution for offline AI. It is not a toy. It is the same code rendering [docs.pai.direct](https://docs.pai.direct) every day.

The hero scroll feels cinematic because it is cinematic. It is the same projection math a 3D rendering engine uses to put objects at depth — applied to scroll position instead of camera position.

If you have ever wondered "how do they do that thing where the background drifts slower than the foreground while you scroll, and why is my JavaScript version always janky?", this repo is the answer. The trick is that there is no trick. The browser already knows how to project 3D geometry during scroll. You just have to tell it that your layers exist in 3D space.

---

## What you see when you deploy

The repo ships with the full PAI documentation as example content:

- A parallax hero with four AVIF layers (mountains, plateau, foreground plants × 2)
- A "Pillars" section that fades in below the hero with three product pitches
- A two-column intro panel with quickstart steps
- The full PAI docs nav: Getting Started, Guides, AI, Apps, Privacy, Examples, Development, Reference, About

You can keep all of it, replace any of it, or strip it back to the hero alone. Every page in `src/` is a plain Markdown file. Delete the ones you don't need, edit the ones you do, update the nav in `mkdocs.yml`. Nothing else changes.

---

## The parallax effect, in 30 seconds

Three CSS rules carry most of the weight:

```css
/* 1. Scroll container — establishes a 3D perspective and scrolls itself */
.mdx-parallax {
  height: 100vh;
  overflow: hidden auto;
  perspective: 2.5rem;
}

/* 2. Each layer pushed back in Z by a multiple of perspective */
.mdx-parallax__layer {
  transform:
    translateZ(calc(var(--md-parallax-perspective) * var(--md-parallax-depth) * -1))
    scale(calc(var(--md-parallax-depth) + 1));
}

/* 3. Hero text sticky at viewport bottom */
.mdx-hero__scrollwrap {
  position: sticky;
  top: 0;
  height: 100vh;
  margin-bottom: -100vh;
}
```

A layer at depth 8 moves at ~11% of scroll speed. A layer at depth 1 moves at 50%. The `scale(depth + 1)` corrects for the apparent shrinking from being pushed back. The text stays glued to the bottom of the viewport via sticky positioning.

That's the whole effect. Everything else is browser quirk-handling, paint containment, and content composition.

For the long version with all the math, see [src/](src/) (when running locally) or browse the deployed docs.

---

## Quick start (local)

```bash
git clone https://github.com/nirholas/scroll-zoom-thing
cd scroll-zoom-thing
pip install -r requirements.txt
mkdocs serve
```

Open [http://localhost:8000](http://localhost:8000). The PAI docs render with the parallax hero. Scroll the home page and watch the depth effect.

To build the static site (without serving):

```bash
mkdocs build
```

Output goes to `_site/`. Upload that directory to any static host, or use one of the deploy buttons above.

To swap in your own art, drop replacement AVIF files into `src/assets/hero/`, keeping the naming convention (`N-description@4x.avif`), update the references in `overrides/home.html`, and `mkdocs serve` will pick them up on save.

---

## Repository layout

```
scroll-zoom-thing/
├── mkdocs.yml                     # MkDocs config — nav, theme, plugins
├── requirements.txt               # mkdocs-material + extensions
├── .python-version                # Python 3.12 pin (Vercel, Railway, etc.)
├── runtime.txt                    # Python version for Heroku-style platforms
│
├── src/                           # Markdown content (docs_dir)
│   ├── index.md                   # Home page (template: home.html)
│   ├── assets/
│   │   ├── hero/                  # AVIF parallax layers
│   │   │   ├── 1-landscape@4x.avif
│   │   │   ├── 2-plateau@4x.avif
│   │   │   ├── 5-plants-1@4x.avif
│   │   │   └── 6-plants-2@4x.avif
│   │   ├── stylesheets/home.css   # All parallax CSS, heavily commented
│   │   ├── pai-theme.css          # Color theme overrides
│   │   ├── pai-logo-white.svg     # Logo
│   │   └── slideshow/             # Optional carousel images
│   ├── general/, ai/, privacy/    # Doc sections
│   └── … rest of PAI docs
│
├── overrides/                     # MkDocs Material template overrides
│   └── home.html                  # The parallax hero template
│
├── images/                        # Site-level images outside docs_dir
│
├── .github/workflows/deploy.yml   # GitHub Pages CI
├── vercel.json                    # Vercel config
├── netlify.toml                   # Netlify config
├── nixpacks.toml                  # Railway / Nixpacks config
├── wrangler.toml                  # Cloudflare Pages config hint
│
├── skills/                        # Claude Code skills for parallax workflows
│   ├── setup-parallax/            # Scaffolds layer structure and template
│   ├── generate-prompts/          # Creates AI image prompts per layer
│   ├── convert-images/            # Batch converts source images to AVIF
│   └── tune-layers/               # Adjusts depth and crop per layer
├── agents/                        # Agent prompt definitions
└── .claude/commands/              # Claude Code slash commands
```

The two files that drive the parallax are [`overrides/home.html`](overrides/home.html) and [`src/assets/stylesheets/home.css`](src/assets/stylesheets/home.css). Everything else is content or scaffolding.

---

## Using this as a template

The fastest path from zero to your own parallax site:

1. **Click "Use this template"** on GitHub (or fork the repo manually)
2. **Click a deploy button** at the top of this README, pointed at your fork
3. **Replace the four AVIF layers** in `src/assets/hero/` with your own (same filenames, or update `overrides/home.html` to match)
4. **Edit the hero copy** in `overrides/home.html` — change the `<h1>` and paragraph in `.mdx-hero__teaser`
5. **Replace the page content** in `src/` with your docs (delete what you don't need)
6. **Update `mkdocs.yml`** — set `site_name`, `site_url`, `repo_url`, and the `nav` block to match your docs
7. **Push** — your deploy platform rebuilds automatically

Steps 3 through 6 are the substantive work. Steps 1, 2, and 7 are clicks. Most adopters are done in 30–60 minutes if their assets are ready.

---

## Building a parallax site from scratch

If you want to add the parallax pattern to an existing MkDocs Material project rather than starting from this template:

### 1. Install Material for MkDocs

```bash
pip install mkdocs-material
```

Add a `mkdocs.yml`:

```yaml
site_name: My Project
theme:
  name: material
  custom_dir: overrides
  palette:
    scheme: slate
extra_css:
  - assets/stylesheets/home.css
```

### 2. Create the override directory

```bash
mkdir -p overrides
mkdir -p docs/assets/hero
mkdir -p docs/assets/stylesheets
```

### 3. Copy `overrides/home.html` and `docs/assets/stylesheets/home.css` from this repo

These two files contain the entire parallax implementation. Drop them into your project unchanged.

### 4. Mark a page as the homepage

In `docs/index.md`:

```markdown
---
template: home.html
title: My Project
description: A short description.
---
```

### 5. Drop AVIF layers into `docs/assets/hero/`

Four AVIF files at the depths the template expects. See [Designing your own layers](#designing-your-own-layers).

### 6. Build and serve

```bash
mkdocs serve
```

The hero renders with your layers. Adjust depth and `object-position` in `overrides/home.html` per layer until the composition feels right.

The total integration is two files (`home.html`, `home.css`), four images, and one front-matter line.

---

## Per-layer CSS variables

Every layer in `home.html` takes two inline CSS custom properties. These are the only knobs you normally need.

| Variable | Type | Effect |
|---|---|---|
| `--md-parallax-depth` | number | Depth in abstract units. Higher values scroll slower. Sensible starting values: `8` for the farthest layer, `5` for mid, `2` for near, `1` for the foreground. |
| `--md-image-position` | percentage | Horizontal `object-position`. Controls which part of a wide image is visible. `50%` centers, `0%` shows the left edge, `100%` shows the right. |

Example:

```html
<picture
  class="mdx-parallax__layer"
  style="--md-parallax-depth: 8; --md-image-position: 50%;"
>
  <source srcset="assets/hero/1-landscape@4x.avif" type="image/avif" />
  <img src="assets/hero/1-landscape@4x.avif" alt="" />
</picture>
```

The CSS in `home.css` consumes these variables in the layer transform and the `object-position` rule. You can add your own variables if you want per-layer vertical positioning, opacity, saturation, or anything else. See [Advanced CSS](src/) (the deployed docs) for examples.

---

## Designing your own layers

Four layers is the practical sweet spot. Fewer and the depth effect is subtle. More and you are paying file size for depth the eye cannot resolve.

| Layer | Contents | Suggested depth | Transparency |
|---|---|---|---|
| 1, Far | Sky, horizon, distant mountains | `8` | Not required (fills the frame) |
| 2, Mid | Buildings, terrain, middle distance | `5` | Required above the horizon line |
| 3, Near | Foreground trees, closer foliage | `2` | Required |
| 4, Front | Closest plants, framing elements | `1` | Required |

**Image requirements:**

| Property | Recommendation |
|---|---|
| Format | AVIF first, WebP as fallback, PNG as last resort |
| Dimensions | Wide panorama, at least 1920×600, wider is better |
| Color space | sRGB, 8-bit |
| Transparency | Required on all layers except the farthest |
| Naming | `1-far@4x.avif`, `2-mid@4x.avif`, etc. The `@4x` suffix signals a high-resolution source. |

**Composition tips:**

- Keep the horizon line consistent across layers. Mismatched horizons destroy the illusion.
- Anchor foreground elements to the bottom of the frame.
- Avoid hard vertical edges on transparent layers — they show as cutouts when the image scales past viewport width.
- Match color and lighting across layers. Layers rendered separately with different lighting feel off even when geometry is right.

---

## Generating layers with AI

AI image generators are a good fit for this workflow because the layers do not need photographic consistency, just stylistic consistency. Each layer is a separate prompt with the same style anchor.

For each prompt:

- Specify the same lighting, color palette, and camera angle across all layers
- Request a transparent background for mid, near, and front layers
- Ask for a wide panoramic aspect ratio, 16:5 or wider
- Describe the depth cue explicitly (`distant horizon only, no mid-ground`, `mid-distance buildings only`, `foreground plants at the bottom edge`)

**Example prompt skeleton:**

```
[scene], transparent PNG, panoramic 16:5,
[depth cue: distant horizon only / mid-distance only / foreground plants only],
soft dawn lighting, muted cool palette,
consistent with: [style reference]
```

**Working tools:** Google ImageFX, Midjourney (`--ar 16:5`), DALL-E 3, Adobe Firefly, Stable Diffusion. Each has its own tricks for transparent output — Midjourney's `--no background` flag, DALL-E's "isolated on white" + post-process removal, Stable Diffusion's `rembg` CLI, Firefly's Generative Fill.

The `skills/generate-prompts/` skill bundled with this repo will generate a set of layered prompts for you given a scene description, ready to paste into your generator of choice.

---

## Converting images to AVIF

Once you have source PNGs (whether hand-painted, photographed, or generated), convert them to AVIF at the `@4x` resolution expected by the template.

Using `ffmpeg`:

```bash
ffmpeg -i 1-far.png -c:v libaom-av1 -crf 28 -b:v 0 -still-picture 1 1-far@4x.avif
```

Using `cavif` (Rust, best quality/size ratio):

```bash
cavif --quality 70 1-far.png -o 1-far@4x.avif
```

Using ImageMagick:

```bash
magick 1-far.png -quality 80 1-far@4x.avif
```

Batch conversion:

```bash
for f in *.png; do
  cavif --quality 70 "$f" -o "${f%.png}@4x.avif"
done
```

Target file size: under 200 KB per layer. Four layers at 150 KB each is ~600 KB of hero assets. If your AVIFs are multiple megabytes, your CRF is too low or your source is too large.

The `skills/convert-images/` skill wraps this with sensible defaults.

---

## Tuning depth, crop, and composition

Tuning is iterative. Open the site in a browser with the inspector visible, change the inline `--md-parallax-depth` and `--md-image-position` values, reload, and look. You are aiming for:

- A clear sense of depth between layers, with no layer moving so fast it reads as a glitch
- The focal point of each layer visible at common viewport widths
- A smooth transition from initial state to scrolled state

**Common pitfalls:**

- **Everything at depth 1 through 4.** Not enough separation. Spread the values.
- **Depth of 15 or higher.** The layer scales so large that its cropping becomes visible at the edges.
- **Identical `object-position` on every layer.** Wastes the parallax. Stagger them slightly so different parts of each image come into view as you scroll.
- **Forgetting transparency on the mid layer.** You will see a rectangle of sky covering everything below it.

The `skills/tune-layers/` skill automates the common adjustments — invoke it with a description like "the middle layer scrolls too fast" or "the foreground is cropped too far right" and it will propose specific value changes.

---

## Customizing the hero text

Open [`overrides/home.html`](overrides/home.html). The hero copy lives in the `.mdx-hero__teaser` block:

```html
<div class="mdx-hero__teaser md-typeset">
  <h1>Your AI. Your keys. Your OS.</h1>
  <p>PAI is a full Linux desktop on a USB drive — private AI, cold-signing, encryption, all of it local.</p>
  <a href="{{ 'quickstart/' | url }}" class="md-button md-button--primary">Quickstart</a>
  <a href="{{ 'general/how-pai-works/' | url }}" class="md-button">Learn more</a>
</div>
```

Replace the heading, paragraph, and button targets with your own. The `{{ 'path/' | url }}` Jinja2 filter resolves correctly under both root and subdirectory deployments. Use it for any internal link.

The buttons inherit Material's button styles — `md-button` for outlined, `md-button md-button--primary` for filled. You can have as many as you like; on mobile they wrap.

---

## Adding pages and navigation

MkDocs Material reads navigation from the `nav` block in `mkdocs.yml`. To add a page:

1. Create the Markdown file in `src/`, e.g. `src/pricing.md`
2. Add it to the nav:

```yaml
nav:
  - Home: index.md
  - Pricing: pricing.md
  - Docs:
      - Getting Started: docs/getting-started.md
      - API Reference: docs/api.md
```

Nested entries become dropdowns or sections depending on theme settings. The current `mkdocs.yml` uses `navigation.tabs` so top-level entries appear as tabs in the header.

For pages that should *not* appear in the nav but should still render at a URL, list them under a hidden section:

```yaml
nav:
  - Home: index.md
  - hidden:
      - Privacy Policy: privacy.md
```

Or omit them from `nav` entirely — they will still build at their URL but won't appear in the sidebar.

---

## Customizing colors and theme

The PAI color theme lives in [`src/assets/pai-theme.css`](src/assets/pai-theme.css). It overrides Material's CSS custom properties:

```css
:root,
[data-md-color-scheme="slate"] {
  --md-primary-fg-color:        #2a375b;
  --md-primary-fg-color--light:  #3a4a78;
  --md-primary-fg-color--dark:   #1e2944;
  --md-accent-fg-color:          #2a375b;
  --md-default-bg-color:  #000000;
  --md-default-fg-color:  #ffffff;
}
```

Replace these values with your brand colors. Material exposes a long list of `--md-*` variables — see the [Material for MkDocs theming docs](https://squidfunk.github.io/mkdocs-material/setup/changing-the-colors/) for the full set. You can also swap between Material's named palettes by editing `mkdocs.yml`:

```yaml
theme:
  palette:
    scheme: slate         # or "default" for light
    primary: indigo       # or red, pink, purple, deep-purple, blue, etc.
    accent: indigo
```

For a multi-scheme site (light/dark toggle), define both schemes in the palette block — see Material's docs.

---

## Deployment

### Vercel

Click [![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https%3A%2F%2Fgithub.com%2Fnirholas%2Fscroll-zoom-thing). Done.

The repo's `vercel.json` configures everything: Python build, output directory, security headers, and CSP. Connecting the repo manually:

1. Sign in to [vercel.com](https://vercel.com)
2. Import Git Repository → pick your fork
3. Click Deploy. Vercel reads `vercel.json` and builds.

For PR preview deployments, Vercel does this automatically — every PR gets a unique URL. Production deploys happen on push to `main`.

### Cloudflare Pages

Cloudflare Pages doesn't have a one-click button URL, but setup is two minutes:

1. Go to [Cloudflare Pages dashboard](https://dash.cloudflare.com/?to=/:account/pages/new/provider/github)
2. Connect your GitHub account, pick your fork
3. Build settings:
   - **Framework preset**: None
   - **Build command**: `pip install -r requirements.txt && mkdocs build`
   - **Build output directory**: `_site`
4. Environment variables → add `PYTHON_VERSION` = `3.12`
5. Save and Deploy

The repo's `wrangler.toml` hints at the output directory. Cloudflare's free tier offers unlimited bandwidth, which makes it ideal for sites with heavy traffic or large hero assets.

### GitHub Pages

The workflow is already in `.github/workflows/deploy.yml`. To activate:

1. Go to your repo's **Settings → Pages**
2. Under **Source**, pick **GitHub Actions**
3. Push any commit (or trigger the workflow manually from the Actions tab)

The workflow runs on every push to `main`. Build output goes live at `https://YOUR_USERNAME.github.io/scroll-zoom-thing/`. For a custom domain, see [Custom domains](#custom-domains).

### Railway

Click [![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy?template=https%3A%2F%2Fgithub.com%2Fnirholas%2Fscroll-zoom-thing). Or connect manually:

1. Go to [railway.com](https://railway.com)
2. New Project → Deploy from GitHub repo → pick your fork
3. Railway reads `nixpacks.toml` and builds

Railway is a long-running container platform, so it actually serves the static files via Python's built-in `http.server` on the port Railway assigns. This is overkill for a static site (Vercel and Cloudflare are better for static), but it works if you're already paying for Railway for other services.

### Netlify

Click [![Deploy to Netlify](https://www.netlify.com/img/deploy/button.svg)](https://app.netlify.com/start/deploy?repository=https://github.com/nirholas/scroll-zoom-thing). Or connect manually:

1. Sign in to [netlify.com](https://netlify.com)
2. Add new site → Import an existing project → pick your fork
3. Netlify reads `netlify.toml` and builds

Free tier covers static sites generously. Netlify's edge functions are useful if you want to add edge logic later (auth gating, A/B testing, redirects).

### Custom domains

Each platform has its own custom domain flow, but the pattern is the same:

1. Add the domain in the platform's dashboard
2. Update DNS — typically a `CNAME` record pointing to the platform's edge (`cname.vercel-dns.com`, `your-project.pages.dev`, `your-username.github.io`, etc.)
3. Wait for TLS provisioning (usually under a minute)
4. Update `site_url` in `mkdocs.yml` to your custom domain so internal links and the sitemap resolve correctly

For GitHub Pages specifically, drop a `CNAME` file with your domain at the root of the repo and MkDocs will copy it through the build:

```bash
echo "docs.example.com" > CNAME
```

(Or place it inside `src/` — MkDocs copies anything in `docs_dir` to the build output.)

---

## Tutorials

### Tutorial 1: Replace the hero with your brand

The fastest meaningful change. 10 minutes.

1. Generate four AVIF layers with your brand's visual style. See [Generating layers with AI](#generating-layers-with-ai).
2. Drop them in `src/assets/hero/`, replacing the four existing files (or update filenames and references).
3. Open `overrides/home.html`, find the four `<picture>` blocks, update `srcset` paths if you renamed.
4. Edit the `<h1>` and `<p>` in `.mdx-hero__teaser` to your headline and tagline.
5. Update the two `<a>` button targets and labels.
6. Run `mkdocs serve`, scroll the hero, tune `--md-parallax-depth` and `--md-image-position` per layer until the composition feels right.

### Tutorial 2: Add a new docs section

20 minutes.

1. Create `src/guide/index.md`, `src/guide/getting-started.md`, etc.
2. Each file gets standard YAML front matter:

```markdown
---
title: Getting Started
description: First steps with our product.
---

# Getting Started
...
```

3. Add to `nav` in `mkdocs.yml`:

```yaml
nav:
  - Home: index.md
  - Guide:
      - Overview: guide/index.md
      - Getting Started: guide/getting-started.md
```

4. `mkdocs serve` will live-reload as you edit.

### Tutorial 3: Wire the parallax into your existing site

30 minutes.

1. From this repo, copy `overrides/home.html` and `src/assets/stylesheets/home.css` into your existing MkDocs project.
2. Update your `mkdocs.yml`:

```yaml
theme:
  custom_dir: overrides
extra_css:
  - assets/stylesheets/home.css
```

3. Add four AVIF layers under `docs/assets/hero/` (use `src/assets/hero/` if your project follows this repo's naming).
4. Mark your homepage with `template: home.html` in its front matter.
5. Build and verify.

### Tutorial 4: Replace the hero with a video

The parallax layers are `<picture>` elements but the CSS works equally for `<video>`. Inside `home.html`, swap one `<picture>` block for:

```html
<video class="mdx-parallax__layer"
       style="--md-parallax-depth: 5"
       autoplay muted loop playsinline>
  <source src="{{ 'assets/hero/loop.webm' | url }}" type="video/webm">
  <source src="{{ 'assets/hero/loop.mp4' | url }}" type="video/mp4">
</video>
```

The video gets the same depth and parallax treatment as an image. Loop a 4-second clip, mute audio, set `playsinline` for iOS Safari.

### Tutorial 5: Multiple parallax sections

The hero is one parallax group. You can add more groups below it, each with their own layers, scroll-driven into view. See `overrides/home.html` for the structure — additional `.mdx-parallax__group` sections after the first scroll in normally and can each have their own layered content.

---

## Use cases and examples

This pattern works for any docs site that wants a cinematic landing without taking on a JavaScript framework. Real and proposed use cases:

- **Open-source project landing pages.** Replace generic GitHub README → docs site with something memorable. The PAI docs at [docs.pai.direct](https://docs.pai.direct) is the production reference.
- **Product documentation.** Internal docs, API references, or end-user guides where the homepage doubles as marketing.
- **Personal portfolios.** Use the hero as a self-introduction, the rest as a CV or project list.
- **Conference and event sites.** Speaker bios, schedules, FAQ — the hero sets atmosphere, the docs section handles logistics.
- **Game and creative project sites.** Visual storytelling with depth, no JS framework, fast on mobile.
- **Educational sites and online courses.** Course landing with parallax intro, content with full Material features (search, navigation, code copy, etc.).
- **Internal tool documentation.** Engineering teams who want their internal docs to feel like a polished product.

The constraint is that the parallax shines on the homepage. Material handles everything else (sidebar nav, search, code blocks, admonitions, instant navigation between pages) the same as any other Material site.

---

## Browser support and accessibility

- `perspective` and `translateZ` are supported in every modern browser. No polyfill is needed.
- The scroll container is a normal scrollable element. Keyboard scrolling, wheel scrolling, and touch scrolling all work.
- The `prefers-reduced-motion` media query disables the depth effect for users who opt out — `home.css` reserves a hook for this.
- All layer images have empty `alt=""` because they are decorative. The semantic content lives in the hero text.
- Safari has a `contain: strict` quirk that the CSS handles via a `.safari` class.
- Firefox has a first-scroll repaint bug fixed by toggling a `.ff-hack` class.
- The site works on iOS Safari, mobile Chrome, mobile Firefox.

To enable reduced motion:

```css
@media (prefers-reduced-motion: reduce) {
  .mdx-parallax {
    overflow: auto;
    perspective: none;
  }
  .mdx-parallax__layer {
    transform: none !important;
    height: 100vh;
  }
}
```

This is included in `home.css` as commented-out scaffolding — uncomment it for production.

---

## Performance notes

- The effect is entirely in the compositor. There is no main-thread work during scroll.
- Layer images are the dominant cost. Keep AVIF files under 200 KB each. Four layers at 150 KB is 600 KB of hero assets — reasonable for a hero.
- `translateZ` and `scale` together force layers onto their own composite layer. Do not add `will-change: transform` unless you measure a problem.
- The scroll container is the only scrollable element. Don't nest another scrollable inside it unless you're comfortable debugging two axes of overflow.
- Preloading the foreground (depth-1) layer with `<link rel="preload" as="image" type="image/avif">` improves perceived load time. The far layer can load lazily.

Lighthouse scores on the deployed PAI docs site:

| Metric | Score |
|---|---|
| Performance | 95+ |
| Accessibility | 100 |
| Best Practices | 100 |
| SEO | 100 |

(Mileage varies with your hero asset weight and host.)

---

## Agent skills bundled with this repo

This repo ships Claude Code compatible skills and agent prompts under `skills/` and `.claude/commands/`. They are optional. The parallax works without them. But if you use Claude Code, they save a lot of fiddling.

| Skill | What it does |
|---|---|
| `setup-parallax` | Scaffolds the layer file structure and wires the template |
| `generate-prompts` | Creates per-layer AI image prompts from a scene description |
| `convert-images` | Batch-converts source images to AVIF at `@4x` |
| `tune-layers` | Adjusts depth and crop per layer based on a description of what looks wrong |

To use, run `claude` from the repo root and invoke a skill by name (e.g., `/setup-parallax`) or describe what you want and let Claude pick the right skill. See the deployed docs' Agents section for full prompt patterns.

---

## FAQ

**Does this work on mobile?**
Yes. The same CSS runs on iOS Safari and mobile Chrome. Touch scrolling inside the container behaves correctly.

**Can I use this outside MkDocs Material?**
Yes. The CSS does not depend on MkDocs. You need the `.mdx-parallax` container, the `.mdx-parallax__layer` children, and the associated CSS. Port the template to whatever framework you use — Hugo, Jekyll, Astro, Next.js, plain HTML.

**Can I animate anything else on scroll?**
Yes, but you lose the "no JS" property. Scroll-linked animations via the new `animation-timeline: scroll()` CSS are a natural next step and are supported in recent Chromium. You can combine both.

**Why AVIF and not WebP?**
AVIF compresses better at the quality needed for smooth, wide panoramas. WebP is an acceptable fallback, and the `<picture>` element handles the fallback for you automatically.

**Why `@4x` in the filenames?**
The suffix is a convention borrowed from `mkdocs-material`. It marks the asset as a high-resolution source intended to be downscaled by the browser for display. It is purely a filename convention — no browser meaning.

**What if I only have three layers, or five?**
Three works. Five works. The depth table is a starting point, not a rule. Spread the depth values so each layer reads as distinct from its neighbors.

**Is this SEO-friendly?**
Yes. The page is fully server-rendered HTML. Search engines see the hero text, the navigation, and all content. The parallax is a CSS effect on top — Googlebot ignores transforms.

**Does it work without JavaScript enabled?**
Yes. The parallax is pure CSS. Material's instant navigation and search require JS, but the rest of the site degrades gracefully.

**Can I use this commercially?**
Yes. MIT license. Credit appreciated but not required.

**The example content is about a Linux distro called PAI. What's the relationship?**
PAI is the project that originally built this parallax pattern for its docs site. `scroll-zoom-thing` is the standalone extraction so others can use the technique. The PAI docs are bundled as the deployed example so you can see the pattern in production immediately. Replace `src/` with your own content to make it yours.

---

## Troubleshooting

**Layers don't show up when I scroll.**
Check `transform-style: preserve-3d` is set on the parallax group. Without it, child `translateZ` values are flattened.

**Layers are tiny in the middle of the frame.**
Missing `scale(depth + 1)` rule, or it's been overridden somewhere in your CSS.

**Layers bleed past the hero into the next section.**
`contain: strict` is missing from the first group, or it's disabled by a browser-specific override (check `.safari` and `.ff-hack` classes).

**The first scroll causes a flash on Firefox.**
The `.ff-hack` JavaScript toggle isn't installed. See `home.html` for the script.

**Layers disappear on Safari.**
The `.safari` class detection script isn't running, so `contain: strict` is breaking Safari's transform paint. See `home.html`.

**404 on AVIF assets in production.**
Filename case-sensitivity. Linux is case-sensitive, macOS isn't. `1-Far@4x.avif` and `1-far@4x.avif` are the same file on macOS but different on Linux. Use lowercase consistently.

**Build fails with "site_url not set".**
Set `site_url` in `mkdocs.yml`. MkDocs Material requires it for sitemap generation and link resolution.

**Cloudflare Pages build fails with "python: not found".**
You forgot the `PYTHON_VERSION` env var. Set it to `3.12` in the project's environment variables.

**Vercel build fails with "pip: command not found".**
Vercel's framework auto-detection is fighting `vercel.json`. Make sure `vercel.json` has `"framework": null` (it does in this repo).

---

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full guide. The short version:

- Open an issue before a non-trivial PR
- Keep changes focused, one idea per PR
- Run `mkdocs serve` locally and verify the hero in a browser before requesting review
- Keep `src/` and `skills/` in sync when you add new functionality
- Match the existing style (`CLAUDE.md` documents the project's coding guidelines)

---

## Credits

The parallax technique, the original CSS, and the artistic direction come from [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) (MIT License, copyright Martin Donath). This repository is a clean extraction with documentation, skills, and agent prompts added on top. All credit for the underlying technique goes to the Material for MkDocs project. If you like this, support [@squidfunk on GitHub Sponsors](https://github.com/sponsors/squidfunk).

The bundled example content (PAI documentation) is from the [PAI](https://github.com/nirholas/PAI) project — an open-source Linux OS for offline AI.

---

## License

MIT. See [`LICENSE`](LICENSE) if present, or treat the contents as MIT until one is added.
