# scroll-zoom-thing

> A pure-CSS 3D perspective parallax hero for MkDocs Material. No JavaScript, no scroll listeners, no animation frame loops. Just `perspective`, `translateZ`, and `scale()`, plus a handful of AVIF layers, wired into the browser's own scroll rendering.

This repository is a minimal, documented, copy-pasteable reference implementation of the layered parallax hero used on [squidfunk.github.io/mkdocs-material](https://squidfunk.github.io/mkdocs-material/). It extracts the technique into its own project so you can read it end to end, swap in your own artwork, and ship a MkDocs site that opens with a slow, cinematic depth effect that degrades gracefully on anything from a 2015 laptop to a modern phone.

If you have ever wondered "how do they do that thing where the background drifts slower than the foreground while you scroll, and why is my JavaScript version always janky?", this repo is the answer. The trick is that there is no trick. The browser already knows how to project 3D geometry during scroll. You just have to tell it that your layers exist in a 3D space.

## Table of contents

- [What this is](#what-this-is)
- [What it is not](#what-it-is-not)
- [How it works](#how-it-works)
- [Repository layout](#repository-layout)
- [Quick start](#quick-start)
- [Per-layer CSS variables](#per-layer-css-variables)
- [Designing your own layers](#designing-your-own-layers)
- [Generating layers with AI](#generating-layers-with-ai)
- [Converting images to AVIF](#converting-images-to-avif)
- [Tuning depth, crop, and composition](#tuning-depth-crop-and-composition)
- [Deploying to GitHub Pages](#deploying-to-github-pages)
- [Agent skills bundled with this repo](#agent-skills-bundled-with-this-repo)
- [Browser support and accessibility](#browser-support-and-accessibility)
- [Performance notes](#performance-notes)
- [FAQ](#faq)
- [Contributing](#contributing)
- [Credits](#credits)
- [License](#license)

## What this is

A small, self-contained MkDocs Material site that demonstrates a pure-CSS 3D perspective parallax, fully documented in plain HTML and CSS, with everything you need to adapt it to your own project:

- A single `home.html` Jinja2 template override that lays out the parallax layers
- A single `home.css` stylesheet, heavily commented, that implements the depth effect
- An `assets/hero/` directory where your AVIF layers live
- A set of documentation pages that explain the technique, the math, and the tuning
- Reusable skills and agent prompts for Claude Code and similar tools, so an AI assistant can scaffold layers, generate prompts, convert images, and tune the result for you

Everything is standard MkDocs Material. If you already know how to run `mkdocs serve`, you already know how to run this.

## What it is not

- It is not a JavaScript library. There is no bundler, no framework, no runtime. The parallax effect runs inside the browser's compositor.
- It is not a gimmick that breaks without JS. The layers are plain `<picture>` tags inside HTML. With CSS disabled you get a stack of images. With JS disabled you get the full effect.
- It is not a rebrand of squidfunk's work. The technique and original CSS come from the MkDocs Material project. This repository is a clean extraction, documented for reuse, with credit to the original author.
- It is not a generator or template engine. It does not produce layered images for you. It shows you where to put them and how to wire them up.

## How it works

The entire effect rests on three ideas.

**1. A perspective on the scroll container establishes a 3D context.** The scroll container is the element that actually scrolls. Its CSS sets `overflow: hidden auto` so it becomes scrollable, and `perspective: 2.5rem` so the browser treats its children as points in 3D space with a shared vanishing point.

**2. Each layer is pushed backwards in Z.** Every layer is a `<picture>` with `transform: translateZ(...)`. A layer at depth 1 is just barely behind the viewport. A layer at depth 8 is far away. The browser, when scrolling the container, applies its normal 3D projection math. Elements further from the camera appear to move less per unit of scroll. That is parallax.

**3. Each layer is scaled up to compensate for the depth.** Pushing a layer back in Z makes it visually smaller. A `scale(depth + 1)` transform scales it back up to fill the viewport. Without this, your far layer would end up tiny in the middle of the frame.

The result is a parallax that is not simulated, not interpolated, and not animated. It is the same 3D projection the browser applies to any element with a `transform: translateZ(...)`. The scroll position of the container feeds directly into that projection. There are no scroll event handlers. Nothing fires on every frame. The compositor does the work.

For the long version with code walkthrough, see [`docs/how-it-works.md`](docs/how-it-works.md).

## Repository layout

```
docs/
├── overrides/
│   └── home.html                    # Jinja2 template with layer <picture> elements
├── assets/
│   ├── stylesheets/
│   │   └── home.css                 # All parallax CSS, heavily commented
│   └── hero/                        # AVIF layers go here
│       ├── 1-landscape@4x.avif
│       ├── 2-plateau@4x.avif
│       ├── 5-plants-1@4x.avif
│       └── 6-plants-2@4x.avif
├── index.md                         # The home page that triggers the hero
├── how-it-works.md                  # Technical deep-dive
├── your-own-layers.md               # Layer design guide
├── advanced-css.md                  # Variations and edge cases
├── ai-image-generation.md           # Prompting tips for generated layers
├── github-pages.md                  # Deployment guide
├── agents.md                        # Agent usage notes
└── mkdocs-skills.md                 # Skill reference
mkdocs.yml
skills/
├── setup-parallax/                  # Scaffolds layer structure and template
├── generate-prompts/                # Creates AI image prompts per layer
├── convert-images/                  # Converts sources to AVIF @4x
└── tune-layers/                     # Adjusts depth and crop
.claude/
└── commands/                        # Claude Code slash commands
agents/                              # Agent prompts for parallax work
```

## Quick start

```bash
pip install mkdocs-material
git clone https://github.com/nirholas/scroll-zoom-thing
cd scroll-zoom-thing
mkdocs serve
```

Open [http://localhost:8000](http://localhost:8000). The existing layers will render. Scroll and watch the depth effect.

To swap in your own art, drop replacement AVIF files into `docs/assets/hero/`, keeping the naming convention (`N-description@4x.avif`), update the references in `docs/overrides/home.html`, and `mkdocs serve` will pick them up on save.

To build the static site, run `mkdocs build`. The result goes to `site/`, which you can upload to any static host.

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

The CSS in `home.css` consumes these variables in the layer transform and the `object-position` rule. You can add your own variables if you want per-layer vertical positioning, per-layer opacity, per-layer saturation, or anything else.

## Designing your own layers

Four layers is the practical sweet spot. Fewer and the depth effect is subtle. More and you are paying file size for depth the eye cannot resolve.

| Layer | Contents | Suggested depth | Transparency |
|---|---|---|---|
| 1, Far | Sky, horizon, distant mountains | `8` | Not required (fills the frame) |
| 2, Mid | Buildings, terrain, middle distance | `5` | Required above the horizon line |
| 3, Near | Foreground trees, closer foliage | `2` | Required |
| 4, Front | Closest plants, framing elements | `1` | Required |

Image requirements:

| Property | Recommendation |
|---|---|
| Format | AVIF first, WebP as fallback, PNG as last resort |
| Dimensions | Wide panorama, at least 1920x600, wider is better |
| Color space | sRGB, 8-bit is fine |
| Transparency | Required on all layers except the farthest |
| Naming | `1-far@4x.avif`, `2-mid@4x.avif`, etc. The `@4x` suffix signals a high-resolution source that scales cleanly across display densities. |

Composition tips:

- Keep the horizon line consistent across layers. Mismatched horizons destroy the illusion.
- Anchor foreground elements to the bottom of the frame. `object-position` defaults bottom-align, so hero content sits at the bottom of the viewport where the eye expects it.
- Avoid hard vertical edges on transparent layers. They will show as cutouts when the image scales past the viewport width.
- Think about color consistency. Layers that were rendered separately with different lighting will feel off even when the geometry is right.

## Generating layers with AI

AI image generators are a good fit for this workflow because the layers do not need photographic consistency, just stylistic consistency. Each layer is a separate prompt with the same style anchor.

For each prompt:

- Specify the same lighting, color palette, and camera angle across all layers
- Request a transparent background for mid, near, and front layers
- Ask for a wide panoramic aspect ratio, 16:5 or wider
- Describe the depth cue explicitly ("distant horizon only, no mid-ground", "mid-distance buildings only", "foreground plants at the bottom edge")

Example prompt skeleton:

```
[scene], transparent PNG, panoramic 16:5,
[depth cue: distant horizon only / mid-distance only / foreground plants only],
soft dawn lighting, muted cool palette,
consistent with: [style reference]
```

The `skills/generate-prompts/` skill in this repo will generate a set of layered prompts for you given a scene description. See [`docs/ai-image-generation.md`](docs/ai-image-generation.md) for the longer version.

## Converting images to AVIF

Once you have source PNGs (whether hand-painted, photographed, or generated), convert them to AVIF at the `@4x` resolution expected by the template. `ffmpeg` works well:

```bash
ffmpeg -i 1-far.png -c:v libaom-av1 -crf 28 -b:v 0 -still-picture 1 1-far@4x.avif
```

The `skills/convert-images/` skill wraps this with sensible defaults and batch processing. For comparison, the hero on `mkdocs-material` ships layers in the 50 to 200 KB range. If your outputs are multiple megabytes, your CRF is too low or your source is too large.

## Tuning depth, crop, and composition

Tuning is iterative. Open the site in a browser with the inspector visible, change the inline `--md-parallax-depth` and `--md-image-position` values, reload, and look. You are aiming for:

- A clear sense of depth between layers, but no layer moving so fast that it reads as a glitch
- The focal point of each layer visible through normal viewport sizes
- The transition from loaded state to scrolled state feeling smooth, not stepped

The `skills/tune-layers/` skill automates the common adjustments, for example "the middle layer scrolls too fast" or "the foreground is cropped too far right".

Common pitfalls:

- **Everything at depth 1 through 4.** Not enough separation. Spread the values.
- **Depth of 15 or higher.** The layer scales so large that its cropping becomes visible at the edges.
- **Identical `object-position` on every layer.** Wastes the parallax. Stagger them slightly so different parts of each image come into view as you scroll.
- **Forgetting transparency on the mid layer.** You will see a rectangle of sky covering everything below it.

## Deploying to GitHub Pages

A simple MkDocs Material deploy:

```bash
mkdocs gh-deploy --force
```

This builds the site and pushes it to the `gh-pages` branch. For CI-based deploys (recommended for real projects), see [`docs/github-pages.md`](docs/github-pages.md), which includes a ready-to-use GitHub Actions workflow.

If you deploy to a custom domain, drop a `CNAME` file in `docs/` and MkDocs will carry it through the build.

## Agent skills bundled with this repo

This repo ships Claude Code compatible skills and agent prompts. They are optional. The parallax works without them. But if you use Claude Code, they save a lot of fiddling.

| Skill | What it does |
|---|---|
| `setup-parallax` | Scaffolds the layer file structure and wires the template |
| `generate-prompts` | Creates per-layer AI image prompts from a scene description |
| `convert-images` | Batch-converts source images to AVIF at `@4x` |
| `tune-layers` | Adjusts depth and crop per layer based on a description of what looks wrong |

See [`docs/mkdocs-skills.md`](docs/mkdocs-skills.md) for usage and [`docs/agents.md`](docs/agents.md) for the raw agent prompts.

## Browser support and accessibility

- `perspective` and `translateZ` are supported in every modern browser. No polyfill is needed.
- The scroll container is a normal scrollable element. Keyboard scrolling, wheel scrolling, and touch scrolling all work.
- The `prefers-reduced-motion` media query can be wired in to disable the depth effect for users who opt out. The CSS already reserves a hook for this; see the comments in `home.css`.
- All layer images should have empty `alt=""` because they are decorative. The semantic content lives in the hero text, which is a sibling element, not a layer.

## Performance notes

- The effect is entirely in the compositor. There is no main-thread work during scroll.
- Layer images are the dominant cost. Keep AVIF files under 200 KB each. Four layers at 150 KB is 600 KB of hero assets, which is reasonable.
- `translateZ` and `scale` together force layers onto their own composite layer, which is what you want. Do not add `will-change` unless you have measured a problem.
- The scroll container is the only scrollable element. Do not nest another scrollable element inside it unless you are comfortable debugging two axes of overflow.

## FAQ

**Does this work on mobile?**
Yes. The same CSS runs on iOS Safari and mobile Chrome. Touch scrolling inside the container behaves correctly.

**Can I use this outside MkDocs Material?**
Yes. The CSS does not depend on MkDocs. You need the `.mdx-parallax` container, the `.mdx-parallax__layer` children, and the associated CSS. Port the template to whatever framework you use.

**Can I animate anything else on scroll?**
Yes, but you lose the "no JS" property. Scroll-linked animations via the new `animation-timeline: scroll()` CSS are a natural next step and are supported in recent Chromium. You can combine both.

**Why AVIF and not WebP?**
AVIF compresses better at the quality needed for smooth, wide panoramas. WebP is an acceptable fallback, and the `<picture>` element handles the fallback for you.

**Why `@4x` in the filenames?**
The suffix is a convention borrowed from `mkdocs-material`. It marks the asset as a high-resolution source intended to be downscaled by the browser for display. It is purely a filename convention.

**What if I only have three layers, or five?**
Three works. Five works. The depth table is a starting point, not a rule. Spread the depth values so each layer reads as distinct from its neighbors.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for the full guide. The short version:

- Open an issue before a non-trivial PR
- Keep changes focused, one idea per PR
- Run `mkdocs serve` locally and check the hero in a browser before requesting review
- Keep `docs/` and `skills/` in sync when you add new functionality

## Credits

The parallax technique, the original CSS, and the artistic direction come from [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) (MIT License, copyright Martin Donath). This repository is a clean extraction with documentation, skills, and agent prompts added on top. All credit for the underlying technique goes to the Material for MkDocs project.

If you like this, support squidfunk.

## License

MIT. See [`LICENSE`](LICENSE) if present, or treat the contents as MIT until one is added.
