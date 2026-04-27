# AGENTS.md — Operator's manual for AI agents working in this repo

> **You are an AI coding agent (Claude, Gemini, GPT, Cursor, Copilot, Codex, Cody, Aider, etc.).**
> This file is your single source of truth for working in `scroll-zoom-thing` and the docs sites built from it. Read the **30-second orientation** below, then jump to the section that matches your task.
> Tool-neutral. No tool-specific magic is required to use this repo, but Claude Code users get extra acceleration via `skills/` and `.claude/commands/`.

---

## Table of contents

1. [30-second orientation](#30-second-orientation)
2. [What this repo is, and what it isn't](#what-this-repo-is)
3. [The mental model in one diagram](#mental-model)
4. [Files: edit / configure / never touch](#file-classification)
5. [Decision tree: pick your task](#decision-tree)
6. [Workflow A — clone for a new project](#workflow-a)
7. [Workflow B — change hero copy and CTAs](#workflow-b)
8. [Workflow C — swap the hero artwork](#workflow-c)
9. [Workflow D — tune the depth effect](#workflow-d)
10. [Workflow E — add or remove a content section](#workflow-e)
11. [Workflow F — add a new docs page](#workflow-f)
12. [Workflow G — restructure the navigation](#workflow-g)
13. [Workflow H — change the brand palette](#workflow-h)
14. [Workflow I — deploy to production](#workflow-i)
15. [The ten variables you customize per project](#ten-variables)
16. [`# AGENT:` markers — what they mean](#agent-markers)
17. [Skills and slash commands (Claude Code)](#skills-slash-commands)
18. [Templates: scaffolding new sites](#templates)
19. [Verification: how to know you're done](#verification)
20. [Common mistakes and their fixes](#common-mistakes)
21. [The CSS depth math, in detail](#depth-math)
22. [Browser quirks (Safari, Firefox)](#browser-quirks)
23. [Performance budget](#performance-budget)
24. [Accessibility checklist](#accessibility)
25. [Security notes (CSP, headers, secrets)](#security)
26. [What you must never do](#never-do)
27. [Glossary](#glossary)
28. [Pointers to deeper docs](#pointers)

---

<a id="30-second-orientation"></a>
## 1. 30-second orientation

You are inside `scroll-zoom-thing`, a **template repository** for building documentation/marketing sites with a pure-CSS 3D parallax hero. There is no JavaScript framework. There is no build pipeline beyond `mkdocs build`. The site renders with [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) and a custom Jinja override that injects four layered AVIF images, displaced in 3D space using `perspective`, `translateZ`, and `scale`.

**The hot path you will touch 90% of the time:**

| File | What it is |
|---|---|
| `mkdocs.yml` | Site config: name, URL, palette, navigation tree |
| `overrides/home.html` | Hero template: H1 text, CTAs, four `<picture>` layers, optional pillar/intro sections |
| `src/assets/stylesheets/home.css` | The parallax engine. Read it. Don't modify the transform formula. |
| `src/assets/hero/*.avif` | The four artwork layers |
| `src/**/*.md` | Markdown content for every nav entry |

**The cold path you should rarely touch:**

| File | Why |
|---|---|
| `requirements.txt` | Python deps for MkDocs. Bump only if you have a reason. |
| `vercel.json`, `netlify.toml`, `wrangler.toml`, `nixpacks.toml` | Zero-config deploy targets. They Just Work. |
| `runtime.txt` | Python version pin for some hosts. |
| `_site/` | Build output. Never commit. Never edit. |

**The "do not touch unless explicitly asked" path:**

| File | Why |
|---|---|
| The transform formula in `home.css` (lines using `translateZ` and `scale`) | This is the depth math. Changing it breaks the parallax in non-obvious ways. |
| `<div class="mdx-parallax__layer mdx-parallax__blend"></div>` | This blend layer is required to be the last layer. Order matters. |
| `transform-style: preserve-3d` on `.mdx-parallax__group` | Required for the parallax to render. Removing it visually flattens everything. |
| `position: sticky; margin-bottom: -100vh` on `.mdx-hero__scrollwrap` | The hero text trick. Remove either property and the text scrolls with the layers. |

**If you only remember three things:**

1. **No JavaScript for the parallax.** It's CSS perspective + transforms. There is one tiny browser-quirk script (Safari/Firefox); that's it.
2. **The depth ladder is `8, 5, 2, 1`** for the four layers (back-to-front). These numbers are battle-tested. Tune within ±2 of each before considering structural changes.
3. **`mkdocs build --strict` must pass before you ship.** Strict mode is the test suite. If it fails, you have broken nav links.

---

<a id="what-this-repo-is"></a>
## 2. What this repo is, and what it isn't

### It is

- **A reusable template** for marketing-flavored documentation sites. Fork it, swap the artwork, rewrite the nav, ship.
- **A reference implementation** of the [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) parallax hero, ported to standalone form. The original is buried in the upstream theme; this repo extracts it into something readable end-to-end.
- **An agent-friendly project**, by deliberate design. `AGENTS.md` (this file), `CLAUDE.md`, `GEMINI.md`, `llms.txt`, `llms-full.txt`, `skills/`, and `.claude/commands/` all exist so a fresh agent can drive the repo without human handholding.
- **Currently shaped as the PAI documentation site.** The default `src/` content is the live `docs.pai.direct` content. Treat it as the worked example, not as immutable structure.

### It is not

- **A static-site generator.** It uses MkDocs. If you want Astro/Next/11ty, this is the wrong repo.
- **A theme.** The theme is upstream Material. This repo overrides exactly one Jinja block (`tabs`) and adds two stylesheets.
- **A JavaScript framework.** There is no React, Vue, Svelte, or web-components anywhere in the parallax. The Material theme ships some JS for navigation/search; that is theirs, not ours.
- **A library you install.** You don't `pip install scroll-zoom-thing`. You clone or fork and edit in place.
- **Something to bend.** When you find yourself "fighting" this template, you are usually doing it wrong. Re-read the relevant workflow below before improvising.

### It is *also*

- **A worked example of agent-friendly repo conventions.** `# AGENT:` markers. Per-skill SKILL.md files. Templates with their own READMEs. If you are designing your own template repo for agents to consume, study the structure of *this* repo as much as the content.

---

<a id="mental-model"></a>
## 3. The mental model in one diagram

```
┌───────────────────────────────── viewport ─────────────────────────────────┐
│                                                                            │
│   <body>                                                                   │
│     ┌────────────────── .mdx-parallax (scroll container) ──────────────┐   │
│     │  perspective: 2.5rem   overflow: hidden auto   height: 100vh     │   │
│     │                                                                  │   │
│     │   ┌─────────── .mdx-parallax__group:first-child ─────────────┐   │   │
│     │   │   transform-style: preserve-3d    height: 140vh          │   │   │
│     │   │                                                          │   │   │
│     │   │   ┌─ <picture> --md-parallax-depth: 8 ─┐ (back, slow)    │   │   │
│     │   │   │  translateZ(-20rem) scale(9)        │                 │   │   │
│     │   │   └─────────────────────────────────────┘                 │   │   │
│     │   │   ┌─ <picture> --md-parallax-depth: 5 ─┐                  │   │   │
│     │   │   │  translateZ(-12.5rem) scale(6)      │                 │   │   │
│     │   │   └─────────────────────────────────────┘                 │   │   │
│     │   │   ┌─ <picture> --md-parallax-depth: 2 ─┐                  │   │   │
│     │   │   │  translateZ(-5rem) scale(3)         │                 │   │   │
│     │   │   └─────────────────────────────────────┘                 │   │   │
│     │   │   ┌─ <picture> --md-parallax-depth: 1 ─┐ (front, fast)    │   │   │
│     │   │   │  translateZ(-2.5rem) scale(2)       │                 │   │   │
│     │   │   └─────────────────────────────────────┘                 │   │   │
│     │   │   ┌─ .mdx-parallax__blend (gradient) ──┐                  │   │   │
│     │   │   └─────────────────────────────────────┘                 │   │   │
│     │   │   ┌─ .mdx-hero (sticky text) ───────────┐ (pinned to vp)  │   │   │
│     │   │   │   <h1>Headline</h1>                 │                 │   │   │
│     │   │   │   <p>Subhead</p>  [CTA] [CTA]       │                 │   │   │
│     │   │   └─────────────────────────────────────┘                 │   │   │
│     │   └──────────────────────────────────────────────────────────┘   │   │
│     │                                                                  │   │
│     │   ┌─── .mdx-parallax__group (pillars or content) ────────────┐   │   │
│     │   └──────────────────────────────────────────────────────────┘   │   │
│     │   ┌─── .mdx-parallax__group (intro cards or content) ────────┐   │   │
│     │   └──────────────────────────────────────────────────────────┘   │   │
│     └──────────────────────────────────────────────────────────────────┘   │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

The browser does the work. When the user scrolls `.mdx-parallax`, the inner 3D-positioned elements project differently because they sit at different `translateZ` distances from the camera. There is no `requestAnimationFrame` loop, no `scroll` event handler, no `window.scrollY`-based interpolation.

**Why depth produces parallax:** project a point in 3D space onto the viewport. Move the camera (the user's view, via scroll) by some amount Δ. A point close to the camera moves by ≈Δ on screen. A point far from the camera moves by less than Δ on screen — that's perspective foreshortening. Different layers at different depths produce different on-screen velocities. The browser already implements this for any `transform: translateZ(...)` element under a `perspective` ancestor.

**Why `scale(depth + 1)`:** when you push something back with `translateZ`, it shrinks (because it's farther from the camera). To keep it filling the viewport, scale it up by exactly enough. The `+ 1` is empirical: at `perspective: 2.5rem` and depth 8, `scale(9)` happens to keep the layer at full viewport size. The relationship between perspective, depth, and required scale is governed by the 3D projection formula `apparent_size = real_size × perspective / (perspective + depth × perspective)`, which simplifies to `apparent_size = real_size / (1 + depth)`. Inverse that and you get `scale = depth + 1`.

---

<a id="file-classification"></a>
## 4. Files: edit / configure / never touch

### Edit freely

| Path | Purpose |
|---|---|
| `src/index.md` | Home page markdown. Mostly shadowed by the parallax hero, but indexed by search. |
| `src/**/*.md` | All other content pages. |
| `src/assets/hero/*.avif` | Hero artwork. Replace freely. Keep naming convention. |
| `src/assets/pai-theme.css` | Brand styles (colors, button shapes, pillar/intro layouts). Rename to your brand. |
| `mkdocs.yml` (most keys) | Site name, URL, repo, palette tokens, nav. |

### Configure carefully (template internals; touch with intent)

| Path | Purpose |
|---|---|
| `overrides/home.html` | Hero structure. Edit copy, CTA hrefs, layer filenames, depth values. Don't change the structural classnames. |
| `mkdocs.yml` `theme.features` | Material theme features. Each one has consequences; read [Material docs](https://squidfunk.github.io/mkdocs-material/setup/setting-up-navigation/) before flipping. |
| `mkdocs.yml` `markdown_extensions` | Markdown plugins. Adding one is fine; removing one breaks pages that use it. |
| `requirements.txt` | Pin floors. Don't pin to a single version unless reproducing a bug. |

### Almost never touch

| Path | Reason |
|---|---|
| `src/assets/stylesheets/home.css` (transform formula and structural rules) | The parallax engine. Tweaking it breaks the effect in subtle ways. Tune via the CSS custom properties on each layer instead. |
| The Jinja `{% extends "base.html" %}` and `{% block tabs %}` declarations in `overrides/home.html` | These hook into Material's template tree. Wrong block = no parallax. |
| `_site/` | Generated. Never commit. Never edit. Add to `.gitignore` if missing. |
| `vercel.json`, `netlify.toml`, `wrangler.toml`, `nixpacks.toml` | Tested deploy configs. Don't break Vercel because you wanted to "clean up" the JSON. |

### Forbidden

| Path | Reason |
|---|---|
| Anything that adds JavaScript to the scroll path | Defeats the whole point. The Safari/Firefox UA scripts are the only allowed exceptions, and they only run on first paint. |
| Inline `<script>` tags inside `home.html` outside `{% block extrahead %}` | CSP-unfriendly and breaks Material's layout assumptions. |
| `assets/hero/` files larger than ~600 KB each | LCP killer. Re-encode at higher CRF or smaller dimensions. |

---

<a id="decision-tree"></a>
## 5. Decision tree: pick your task

A user (or a higher-level agent) just gave you a task. Use this tree to find the right workflow.

```
Was the task "build a new site / docs / landing page for project X"?
  └─ YES → Workflow A (clone for a new project)

Was the task to change the headline, subhead, button text, or button URLs?
  └─ YES → Workflow B (change hero copy and CTAs)

Was the task to swap the hero images / illustration / artwork?
  └─ YES → Workflow C (swap the hero artwork)

Was the task "the parallax is too subtle / too strong / too slow / off"?
  └─ YES → Workflow D (tune the depth effect)

Was the task to add/remove a section under the hero (pillars, intro, FAQ, etc.)?
  └─ YES → Workflow E (add or remove a content section)

Was the task to add a new page to the docs?
  └─ YES → Workflow F (add a new docs page)

Was the task to restructure the navigation / sidebar / tabs?
  └─ YES → Workflow G (restructure the navigation)

Was the task about colors, fonts, accent, brand palette?
  └─ YES → Workflow H (change the brand palette)

Was the task to ship / deploy / publish / push live?
  └─ YES → Workflow I (deploy to production)

Was the task something else?
  └─ Read sections 14–28, then ask the user a clarifying question.
     Do not improvise on the parallax engine.
```

---

<a id="workflow-a"></a>
## 6. Workflow A — clone for a new project

**Trigger:** "Build me docs for project X" / "I want a landing page for X" / "Make a new site like the PAI docs but for X."

**Goal:** A fresh working tree, branded for X, deployable in <10 minutes.

### Steps

1. **Clone or fork the repo.**
   ```bash
   gh repo clone nirholas/scroll-zoom-thing my-project
   cd my-project
   git remote remove origin
   git remote add origin git@github.com:USER/my-project.git
   ```
   If the user has a scaffolding script, prefer it: `./scripts/new-site.sh my-project minimal`.

2. **Replace the ten variables.** See [section 15](#ten-variables). The minimum set:
   - `site_name`, `site_description`, `site_url` in `mkdocs.yml`
   - `repo_url`, `repo_name`, `edit_uri` in `mkdocs.yml`
   - Hero `<h1>`, hero `<p>`, two CTA labels and hrefs in `overrides/home.html`
   - Replace four AVIF files in `src/assets/hero/`
   - Replace `src/assets/pai-logo-white.png` and the `.svg` with your logo
   - Update brand colors in `src/assets/pai-theme.css`
   - Replace pillar copy and intro card copy in `overrides/home.html` (or remove those sections — see Workflow E)
   - Decide your nav tree (Workflow G)

3. **Stub out content.** For each entry in your nav, create a markdown file. Empty stubs are fine for v1; `mkdocs build --strict` only fails if a *link target* is missing.

4. **Run locally.**
   ```bash
   pip install -r requirements.txt
   mkdocs serve
   ```
   Open http://localhost:8000. Verify: parallax scrolls smoothly, hero copy is yours, CTAs land on real pages, nav reflects your tree.

5. **Verify with strict build.**
   ```bash
   mkdocs build --strict
   ```
   Fix any warnings. Strict mode treats warnings as errors.

6. **Commit and push.**
   ```bash
   git add .
   git commit -m "init: scaffold $PROJECT site from scroll-zoom-thing"
   git push -u origin main
   ```

7. **Configure deployment.** See [Workflow I](#workflow-i).

### Time budget

Experienced agent: 5–10 minutes including AVIF generation. From-scratch (no AVIFs ready): 30–60 minutes for the imagery, 10 minutes for the rest.

### Pitfalls

- **Don't forget `site_url`.** Material uses it to compute canonical URLs and sitemaps. Wrong `site_url` = wrong sitemap.
- **Don't keep the upstream `repo_url`.** It points the "Edit this page" button at `nirholas/scroll-zoom-thing`. Update it or remove `edit_uri`.
- **Don't ship without replacing the AVIFs.** The default landscape is recognizable as PAI. Shipping a "new product" site with PAI's hero is a brand mistake.

---

<a id="workflow-b"></a>
## 7. Workflow B — change hero copy and CTAs

**Trigger:** "Change the headline" / "Update the buttons" / "Make the hero text say X."

**File:** `overrides/home.html`. Look near line 35 (`<h1>` inside `<div class="mdx-hero__teaser md-typeset">`).

### What to edit

```html
<h1><!-- AGENT: hero headline -->Your AI. Your keys. Your OS.</h1>
<p><!-- AGENT: hero subhead -->PAI is a full Linux desktop on a USB drive...</p>
<a href="{{ 'quickstart/' | url }}"
   class="md-button md-button--primary"><!-- AGENT: primary CTA label -->Quickstart</a>
<a href="{{ 'general/how-pai-works/' | url }}"
   class="md-button"><!-- AGENT: secondary CTA label -->Learn more</a>
```

The `{{ '...' | url }}` filter resolves the link relative to `site_url`. Don't replace it with raw `href="quickstart/"` — that breaks on subpath deployments.

### Copy guidance

- **Headline ≤ 8 words.** PAI's "Your AI. Your keys. Your OS." is 6 words. The hero is the brand; treat the headline as a tagline.
- **Subhead 25–60 words.** Long enough to add detail, short enough to scan in 3 seconds.
- **Primary CTA = action.** "Quickstart", "Get started", "Try it free", "Read the docs". One verb.
- **Secondary CTA = orientation.** "Learn more", "How it works", "Why X". Lower commitment.
- **Both CTAs must point at real pages.** A 404 from the hero is the worst-possible first impression.

### Verify

```bash
mkdocs serve
```
Refresh, confirm copy renders. Click both CTAs; confirm they navigate to existing pages.

---

<a id="workflow-c"></a>
## 8. Workflow C — swap the hero artwork

**Trigger:** "Change the hero images" / "I generated new artwork" / "The plants don't fit my brand."

**Files:**
- `overrides/home.html` (filenames inline on each `<picture>`)
- `src/assets/hero/*.avif` (the actual files)

### Steps

1. **Decide your scene.** You need 4 layers, depth-sortable. See [`agents/image-agent.md`](agents/image-agent.md) for the detailed prompt strategy.

2. **Generate or source the layers.** Each layer is a 4096×2304 (or wider 16:5 panoramic) PNG. Layer 1 is opaque (the background). Layers 2–4 have transparent backgrounds.

3. **Convert to AVIF.** Use the `convert-images` skill or run `avifenc` directly:
   ```bash
   avifenc --min 28 --max 36 --speed 4 input.png output.avif
   ```
   Aim for: layer 1 (full landscape) ≤ 600 KB, layers 2–4 (transparent) ≤ 150 KB each.

4. **Place in `src/assets/hero/`.** Use the naming pattern `N-name@4x.avif` where `N` is the depth-sort order (1 = deepest, ascending toward foreground).

5. **Update `overrides/home.html`.** For each `<picture>`:
   ```html
   <picture class="mdx-parallax__layer"
            style="--md-parallax-depth: 8; --md-image-position: 70%">
     <source type="image/avif" srcset="{{ 'assets/hero/1-NAME@4x.avif' | url }}">
     <img src="{{ 'assets/hero/1-NAME@4x.avif' | url }}" alt="" class="mdx-parallax__image" draggable="false">
   </picture>
   ```
   Change the filename in both `srcset` and `src` (they should match for `<picture>` fallback).

6. **Tune `--md-image-position` per layer.** This is the horizontal `object-position`. A landscape with the horizon high wants 70% (showing bottom-of-image). A foreground with subjects on the left wants 25%.

7. **Reload and judge.** Scroll the hero. The closest layer should drift fastest, the farthest should barely move.

### Pitfalls

- **All layers same size = wrong.** They must be the same *aspect ratio* (typically 16:5 panoramic) but should depict different depth planes.
- **Foreground without transparency = layered cardboard.** Run `rembg` or generate with explicit `transparent PNG` prompts.
- **Filename mismatch = broken layer.** Check the Network tab. `404` means the filename in `home.html` doesn't match what's on disk. Linux is case-sensitive; `1-Landscape@4x.avif` ≠ `1-landscape@4x.avif`.

---

<a id="workflow-d"></a>
## 9. Workflow D — tune the depth effect

**Trigger:** "The parallax is too subtle" / "Layers feel glued together" / "It's too dramatic" / "It looks wrong on my ultrawide."

**File:** `overrides/home.html`. The two inline custom properties on each `<picture>`:
- `--md-parallax-depth` — back-distance; higher = slower scroll
- `--md-image-position` — `object-position` X percent

Plus, optionally, `:root { --md-parallax-perspective: 2.5rem }` in `home.css`.

### Diagnosis table

| Symptom | Likely cause | Fix |
|---|---|---|
| "Far background barely moves" | Background depth too high relative to scene | Lower from 8 → 5 |
| "Layers feel glued" | Depths too close (e.g. 4, 3, 2, 1) | Spread to 8, 5, 2, 1 |
| "Effect is invisible on ultrawide" | Perspective too small for viewport | `--md-parallax-perspective: clamp(1.5rem, 2.5vw, 3rem)` |
| "Subject of an image is cropped wrong" | `--md-image-position` mis-aligned | Adjust in 10% increments |
| "Hero scrolls past in one swipe" | First group not tall enough | Bump `.mdx-parallax__group:first-child { height: 160vh }` |
| "Foreground feels too aggressive" | Front depth too low | Raise from 1 → 2 |
| "Layers wobble or shimmer" | GPU compositing thrash | Check Chrome DevTools → Layers; reduce layer count if >4 |
| "First-paint flash on Firefox" | Containment bug | The `.ff-hack` script handles this; check it's loaded |

### Tuning strategy

1. **Change one variable at a time.** If you change three things and the effect improves, you don't know which one mattered.
2. **Start with depths.** They are the dominant lever. Try 8/5/2/1 first; 10/6/3/1.5 for ultrawide; 6/4/2/1 for narrow viewports.
3. **Keep adjacent layers ≥ 2 apart.** Layers within 1 of each other visually merge.
4. **Tune perspective last.** Smaller perspective (e.g. 1.5rem) = more dramatic depth. Larger (3rem+) = more subtle. The default 2.5rem is a good middle.
5. **Hero height affects feel, not depth.** A taller `:first-child` gives layers more time to travel; the parallax feels slower-paced. The default 140vh is the sweet spot.

### Use the slash command

If you are Claude Code, the [tune-layers skill](skills/tune-layers/SKILL.md) automates this:

```
/tune-layers
> Problem: "the front plants feel too fast"
> Suggested change: --md-parallax-depth on layer 4 from 1 → 2
> Expected effect: foreground will scroll ~33% slower
> Apply? [Y/n]
```

---

<a id="workflow-e"></a>
## 10. Workflow E — add or remove a content section

**Trigger:** "Add an FAQ under the hero" / "Remove the pillars" / "Add a third section between the pillars and intro cards."

**File:** `overrides/home.html`.

### The structure

A `mdx-parallax` div contains N `mdx-parallax__group` sections in order:

1. **First group** — the hero. Has `<picture>` layers, the blend layer, and the sticky hero text. Must be taller than 100vh (140vh by default).
2. **Subsequent groups** — content panels. Each is a normal-height section. They can have `data-md-color-scheme="slate"` or `"default"` to switch palette as the user scrolls.

### Add a new section

```html
<section class="mdx-parallax__group mdx-faq" data-md-color-scheme="default">
  <div class="mdx-faq__inner">
    <h2>Frequently asked</h2>
    <details>
      <summary>Does it work offline?</summary>
      <p>Yes — the entire site runs from disk after first load.</p>
    </details>
    <details>
      <summary>What about mobile?</summary>
      <p>The parallax respects <code>prefers-reduced-motion</code>.</p>
    </details>
  </div>
</section>
```

Then add the matching layout CSS to `src/assets/pai-theme.css`:

```css
.mdx-faq__inner {
  max-width: 48rem;
  margin: 0 auto;
  padding: 6rem 1.5rem;
}
.mdx-faq summary {
  cursor: pointer;
  font-weight: 600;
  padding: .75rem 0;
}
```

### Remove a section

Delete the entire `<section class="mdx-parallax__group ...">` block from `home.html`. The orphan CSS in `pai-theme.css` is harmless but should be removed for hygiene.

### Order matters

The visual flow assumes: hero → bridge sections (pillars/intro/etc.) → footer. Reorder by moving entire `<section>` blocks. Don't try to reorder content within a section by floating elements — let the natural document order win.

### Color scheme transitions

Each `<section>` can set its own `data-md-color-scheme`. Material picks up the attribute and recomputes CSS variables for the subtree. The cleanest pattern: hero in slate, pillars in slate (consistent dark), intro cards in default (light contrast bridge into the docs body).

---

<a id="workflow-f"></a>
## 11. Workflow F — add a new docs page

**Trigger:** "Add a Tutorial page" / "I need a new doc under Guides."

**Files:** `src/<section>/<page>.md` and `mkdocs.yml`.

### Steps

1. **Create the markdown file.**
   ```bash
   touch src/guides/my-new-page.md
   ```

2. **Write the content.** Material extensions are enabled by default:
   - **Admonitions:** `!!! note "Title"` then indented body
   - **Tabs:** `=== "macOS"` / `=== "Linux"` blocks
   - **Code blocks:** triple-backtick with language, line numbers via `{ .python linenums="1" }`
   - **Mermaid:** triple-backtick with `mermaid` language
   - **Tables:** standard GFM
   - **Footnotes:** `[^1]` and `[^1]: text`
   - **Task lists:** `- [x] done`
   - **Anchors:** auto-generated from headings; permalink `#` per heading

3. **Add to `mkdocs.yml` nav.**
   ```yaml
   nav:
     - Guides:
         - Existing page: guides/existing.md
         - My new page: guides/my-new-page.md
   ```

4. **Run strict build.**
   ```bash
   mkdocs build --strict
   ```
   Strict catches: orphan files (in `docs_dir` but not in `nav`), broken internal links, missing anchors.

5. **Cross-link.** Add at least one link from a related page to the new one. Pages without inbound links are findable by search but invisible to navigation.

### Conventions

- **Filenames:** lowercase-kebab-case, no underscores, no trailing slashes.
- **Title:** the H1 in the markdown becomes the nav label *if* the YAML omits the label. Set the label explicitly in `mkdocs.yml` for control.
- **Length:** there's no minimum, but pages under 100 words feel like stubs. Stub pages should explicitly say "Coming soon — see [related](related.md)."
- **Frontmatter:** optional. Use `---\ntitle: ...\ndescription: ...\n---` if you need explicit `<title>` and meta description override.

---

<a id="workflow-g"></a>
## 12. Workflow G — restructure the navigation

**Trigger:** "Reorganize the sidebar" / "Move FAQ to the top" / "Group these pages under a new section."

**File:** `mkdocs.yml`, the `nav:` block.

### Mental model

The `nav:` tree is **the user's table of contents**. It does not need to mirror the directory structure. Two rules:

1. **Top-level entries become tabs** when `theme.features` includes `navigation.tabs`.
2. **Nested entries become sidebar sections** when `navigation.sections` is enabled.

### Patterns

**Flat (small site, ≤ 8 pages):**
```yaml
nav:
  - Home: index.md
  - Quickstart: quickstart.md
  - Reference: reference.md
  - About: about.md
```

**Tabbed (medium site, marketing + docs):**
```yaml
nav:
  - Home: index.md
  - Get started:
      - Quickstart: quickstart.md
      - Install: install.md
  - Guides:
      - Basic: guides/basic.md
      - Advanced: guides/advanced.md
  - Reference:
      - API: reference/api.md
      - CLI: reference/cli.md
```

**Deep (PAI-style, full product docs):** see the existing `mkdocs.yml` for an 11-section tree with nested sub-sections.

### Rules of thumb

- **3–7 top-level tabs.** Fewer = wasted hierarchy; more = users miss tabs past the fold on narrow screens.
- **2–3 levels of nesting maximum.** Material renders 4+ levels but they become unscannable.
- **Group by user task, not by file type.** "Getting started" / "Guides" / "Reference" beats "Tutorials" / "How-tos" / "Explanations" / "Reference" (the Diataxis split feels right but in practice users don't read the labels).
- **Put `Home: index.md` first.** Material highlights it correctly.
- **Aliases:** if a page has multiple natural homes, point to the same file from multiple nav entries — Material handles it.

### Strict mode catches errors

```bash
mkdocs build --strict
```
- Orphan files: in `docs_dir` but not in `nav` → warn (strict: error).
- Missing files: in `nav` but not on disk → error (always).
- Wrong indentation: silent; the section just doesn't render. **Eyeball your YAML carefully.**

---

<a id="workflow-h"></a>
## 13. Workflow H — change the brand palette

**Trigger:** "Make it green" / "Match our brand colors" / "Switch from indigo to slate."

**Files:** `src/assets/pai-theme.css` (override variables) and `mkdocs.yml` (theme palette declaration).

### How Material's palette works

Material defines CSS custom properties for theme colors. The base palette is set in `mkdocs.yml`:

```yaml
theme:
  palette:
    - scheme: slate
      primary: custom
      accent: custom
```

`primary: custom` and `accent: custom` say "I will define these myself." Then in `src/assets/pai-theme.css`:

```css
:root {
  --md-primary-fg-color:        #0e7c66;
  --md-primary-fg-color--light: #14a484;
  --md-primary-fg-color--dark:  #094f41;
  --md-accent-fg-color:         #14a484;
}

[data-md-color-scheme="slate"] {
  --md-default-bg-color:    #0a0d10;
  --md-default-fg-color:    #e6e9ec;
  --md-typeset-color:        #d8dde2;
  --md-typeset-a-color:      #14a484;
}
```

### Steps

1. **Pick your brand color.** One primary, one accent, one background, one foreground. That's enough.
2. **Find the variables.** Material has hundreds; you only need 4–8. Search the [Material CSS variables reference](https://squidfunk.github.io/mkdocs-material/setup/changing-the-colors/) for `--md-`.
3. **Override in `pai-theme.css`.** Wrap the slate-specific overrides in `[data-md-color-scheme="slate"] { ... }`.
4. **Test contrast.** Both light text on dark bg and dark text on light bg. Run an accessibility checker (axe, Lighthouse).
5. **Update the `<meta name="theme-color">`** to your primary color via Material's setting:
   ```yaml
   extra:
     theme_color: "#0e7c66"
   ```

### Hero text overrides

The hero text uses `--md-primary-bg-color` for color and a fixed `text-shadow` for legibility against landscape backgrounds. If your hero artwork is light, you may need:

```css
.mdx-hero__teaser :not(.md-button) {
  text-shadow: 0 0 .2rem rgba(0, 0, 0, .8);
}
```

---

<a id="workflow-i"></a>
## 14. Workflow I — deploy to production

**Trigger:** "Deploy this" / "Push to prod" / "How do I host it?"

The repo ships **zero-config support for five deploy targets.** Pick one. They are not mutually exclusive but you only need one for production.

### A. GitHub Pages (recommended for simple cases)

1. Push to `main` of a repo named `<user>/<repo>`.
2. In repo Settings → Pages, set Source to "GitHub Actions".
3. The repo includes a workflow that runs `mkdocs build --strict` and uploads `_site/` as the Pages artifact.
4. Custom domain: drop a `CNAME` file in `src/` containing your domain, point a DNS CNAME to `<user>.github.io`, enable HTTPS in Pages settings.

### B. Vercel (best for previews)

1. `vercel link` (or import the repo from the Vercel dashboard).
2. `vercel.json` is already configured: `pip install -r requirements.txt && python3 -m mkdocs build`, output `_site`.
3. Every PR gets a preview URL. Production deploys on push to `main`.

### C. Netlify

1. Connect the repo in the Netlify dashboard.
2. `netlify.toml` is already configured.
3. Build command and output dir auto-detected.

### D. Cloudflare Pages / Workers

1. `wrangler.toml` is configured for Workers Sites.
2. Run `wrangler pages deploy _site` after a local `mkdocs build`, or connect via the Cloudflare Pages dashboard.

### E. Railway / Render / Fly / any Nix host

1. `nixpacks.toml` declares the Python version and build command.
2. Push to the connected branch; the platform builds and serves `_site/`.

### After deploy

- **Set `site_url` in `mkdocs.yml`** to the production URL. Material uses it for canonical URLs and the sitemap.
- **Verify HTTPS works.** Browser address bar shows the lock; `curl -sI https://your.domain` returns `200`.
- **Verify Content-Security-Policy.** The Vercel config sets a strict CSP; if you change it, test that fonts, images, and search still work.
- **Verify the sitemap.** Visit `/sitemap.xml`. It should contain every page in the nav.
- **Submit to search consoles.** Google Search Console, Bing Webmaster Tools.

---

<a id="ten-variables"></a>
## 15. The ten variables you customize per project

Most projects only differ from the template along these ten axes. Find them with `grep -rn "AGENT:" .` — every one is annotated.

| # | Variable | File | Default | Purpose |
|---|---|---|---|---|
| 1 | `site_name` | `mkdocs.yml` | "PAI Documentation" | Browser tab title, site header |
| 2 | `site_description` | `mkdocs.yml` | one-liner | `<meta name="description">` and OG tags |
| 3 | `site_url` | `mkdocs.yml` | https://docs.pai.direct | Canonical URL, sitemap base |
| 4 | `repo_url` | `mkdocs.yml` | github.com/nirholas/pai | "View on GitHub" link |
| 5 | Hero `<h1>` text | `overrides/home.html` | "Your AI. Your keys. Your OS." | The tagline |
| 6 | Hero `<p>` text | `overrides/home.html` | PAI subhead | Hero supporting copy |
| 7 | Two CTA labels and hrefs | `overrides/home.html` | "Quickstart" / "Learn more" | Buttons |
| 8 | Four AVIF filenames | `overrides/home.html` + disk | 1-landscape, 2-plateau, 5-plants-1, 6-plants-2 | Hero artwork |
| 9 | Brand colors | `src/assets/pai-theme.css` | PAI green palette | Theme accent and primary |
| 10 | Logo files | `src/assets/pai-logo-white.{png,svg}` | PAI mark | Header logo |

**Optional but common:**
- Pillar copy (3 × title + body) in `overrides/home.html`
- Intro card copy (2 × heading + body) in `overrides/home.html`
- Nav tree in `mkdocs.yml`

If you can answer those ten questions for the user, you can build their site.

---

<a id="agent-markers"></a>
## 16. `# AGENT:` markers — what they mean

Files that an agent customizes per-project carry inline `# AGENT:` (Python/YAML), `<!-- AGENT: -->` (HTML/Markdown), or `/* AGENT: */` (CSS) comments next to the line you usually edit.

```yaml
# AGENT: site name — change to "$YOUR_PROJECT_NAME Documentation"
site_name: PAI Documentation
```

```html
<!-- AGENT: hero headline (≤8 words, brand tagline) -->
<h1>Your AI. Your keys. Your OS.</h1>
```

```css
/* AGENT: primary brand color */
--md-primary-fg-color: #0e7c66;
```

### Conventions

- **`AGENT:` is the canonical prefix.** Comment-style adapts to the file.
- **One marker per logical unit.** A pillar block has one marker covering all three pillars, not three markers.
- **Markers describe the slot, not the value.** `<!-- AGENT: hero headline -->` is correct; `<!-- AGENT: change "PAI" to your name -->` is wrong (it ages badly).
- **Find them all:** `grep -rn "AGENT:" .`

### When to add or remove markers

- **Add** when introducing a new variable that future agents will customize per project.
- **Remove** when a marker is no longer accurate, the slot has been deleted, or the variable became internal.
- **Don't add** for things agents shouldn't change (the parallax transform formula, the structural classnames, the Jinja block declarations).

### When to ignore markers

A marker is a hint, not a directive. If the user explicitly says "leave the headline alone, just change the buttons," ignore the headline marker. The markers exist for the common case; the user's instruction wins.

---

<a id="skills-slash-commands"></a>
## 17. Skills and slash commands (Claude Code)

This repo ships four agent skills under `skills/` and five slash commands under `.claude/commands/`. They are Claude Code-specific but the SKILL.md files double as runbooks for any agent.

### Skills

| Skill | Path | When to invoke |
|---|---|---|
| `setup-parallax` | `skills/setup-parallax/SKILL.md` | First time scaffolding the parallax. Asks for headline, subhead, button labels; writes `home.html`, `home.css`, updates `mkdocs.yml`. |
| `tune-layers` | `skills/tune-layers/SKILL.md` | User reports a visual problem. Diagnoses depth/position; proposes a one-variable change with expected effect. |
| `convert-images` | `skills/convert-images/SKILL.md` | You have PNG/WebP source artwork and need AVIF outputs. Wraps `avifenc`/`ffmpeg` with sensible defaults. |
| `generate-prompts` | `skills/generate-prompts/SKILL.md` | You need to create new artwork. Outputs four AI image prompts (one per depth layer) with shared style anchor. |

### Slash commands

| Command | Path | What it does |
|---|---|---|
| `/setup-parallax` | `.claude/commands/setup-parallax.md` | Front-end for the `setup-parallax` skill. |
| `/tune-layers` | `.claude/commands/tune-layers.md` | Front-end for `tune-layers`. |
| `/convert-images` | `.claude/commands/convert-images.md` | Front-end for `convert-images`. |
| `/generate-prompts` | `.claude/commands/generate-prompts.md` | Front-end for `generate-prompts`. |
| `/deploy` | `.claude/commands/deploy.md` | Walks through Workflow I (deploy targets, DNS, HTTPS). |

### How to invoke (Claude Code)

```
/setup-parallax
/tune-layers
/convert-images path/to/png-folder
```

Each command reads the matching SKILL.md as its runbook. Reading the SKILL.md directly is fine if you're not Claude Code — it's the same instructions in a different envelope.

### Adding a new skill

1. `mkdir skills/my-skill && touch skills/my-skill/SKILL.md`
2. Use the existing SKILLs as templates: frontmatter (`name`, `description`, `version`, `triggers`, `inputs`, `outputs`, `constraints`), then sections for purpose, instructions, guardrails, example session, changelog.
3. Add it to `skills/SKILL.md` (the index).
4. Add a slash-command shim under `.claude/commands/my-skill.md` that points at the skill.

---

<a id="templates"></a>
## 18. Templates: scaffolding new sites

The repo ships with `templates/` containing pre-built starter directories. Use one as the base for a new site.

```
templates/
├── README.md                    # how the templates system works
├── minimal/                     # hero only — no pillars, no intro cards
│   ├── mkdocs.yml
│   ├── overrides/home.html
│   ├── src/index.md
│   └── README.md                # "use when: you want a simple landing"
├── marketing-hero/              # hero + 3 pillars + 2 intro cards (PAI-style)
│   ├── ... (clone of canonical layout)
│   └── README.md
└── product-docs/                # hero + deep nav, no pillars
    ├── ...
    └── README.md
```

### Scaffolding a new site from a template

```bash
./scripts/new-site.sh my-project minimal
cd ../my-project
mkdocs serve
```

The script:
1. Copies `templates/<name>/` to `../<my-project>/`.
2. Replaces `# AGENT: ${VAR}` placeholders by prompting the user for each value.
3. Initializes a fresh git repo.
4. Prints next-step instructions.

### Choosing a template

| Template | Use when... | Avoid when... |
|---|---|---|
| `minimal` | Single-page landing, simple project, ≤ 5 docs pages | You need pillars or intro cards (add them later from `marketing-hero`) |
| `marketing-hero` | Product/SaaS docs with marketing-flavored home page | You want a "docs first" feel without the marketing |
| `product-docs` | Deep technical docs (dozens of pages), hero is a tagline only | You don't need a hero at all (use upstream Material directly) |

### Don't use templates as god-files

Each template's content is a starting point, not a contract. Delete sections, add sections, restructure as needed for the project. The template's `README.md` documents the *original* shape; once you scaffold, the new project owns its shape.

---

<a id="verification"></a>
## 19. Verification: how to know you're done

A site is "done" (for a v1 ship) when every checkbox passes:

### Build

- [ ] `mkdocs build --strict` exits 0 with no warnings.
- [ ] `pip install -r requirements.txt` works on a fresh Python venv (no missing deps).
- [ ] CI workflow (if present) is green on the main branch.

### Local

- [ ] `mkdocs serve` runs without errors.
- [ ] Home page loads in <1s on localhost.
- [ ] Parallax scrolls smoothly: closest layer drifts fast, farthest barely moves.
- [ ] Hero CTAs land on existing pages (no 404s).
- [ ] All four AVIF layers return 200 in DevTools Network panel.
- [ ] Search bar finds at least one keyword from each top-level section.

### Browsers

- [ ] Chrome/Edge: parallax smooth, no flicker.
- [ ] Safari: hero renders without clipping (`.safari` class applied? check inspector on `<html>`).
- [ ] Firefox: no first-paint flash (`.ff-hack` class applied during initial scroll? check on `<body>`).
- [ ] Mobile (responsive mode): hero readable, layers scale, text reachable.

### Performance

- [ ] Lighthouse Performance ≥ 90 (mobile).
- [ ] LCP < 2.0s on Slow 4G.
- [ ] CLS < 0.05 (effectively zero).
- [ ] Total transfer < 800 KB on home (4 AVIFs ≈ 600 KB + theme ≈ 150 KB).

### Accessibility

- [ ] Lighthouse Accessibility = 100.
- [ ] Tab order: page-load → hero CTA1 → CTA2 → nav (no traps).
- [ ] All images have `alt` (decorative ones with `alt=""`).
- [ ] `prefers-reduced-motion: reduce` flattens the parallax (test by toggling OS setting).
- [ ] Color contrast: ≥ 4.5:1 for body text, ≥ 3:1 for large text and UI elements.

### SEO

- [ ] `<title>`, `<meta description>`, OG tags present (Material auto-generates from `mkdocs.yml`).
- [ ] `sitemap.xml` exists and contains every page.
- [ ] `robots.txt` allows indexing (or explicitly disallows if you want).
- [ ] Canonical URL matches `site_url`.
- [ ] Custom 404 page renders (Material ships one).

### Production

- [ ] HTTPS enforced; cert valid.
- [ ] DNS CNAME / A record correct; `dig` resolves.
- [ ] No mixed content (DevTools Console clean).
- [ ] CSP headers don't break fonts/images/search (test in incognito).
- [ ] OG image renders correctly on Twitter/Slack/Discord (use [opengraph.xyz](https://opengraph.xyz)).

A green checklist means the site is ready. A red checkbox means stop and fix; don't ship around it.

---

<a id="common-mistakes"></a>
## 20. Common mistakes and their fixes

### "Hero is invisible — I see only white/black."

- **Cause 1:** AVIF paths wrong. Open Network tab; if all four layers return 404, your `srcset` paths don't match disk. Linux is case-sensitive.
- **Cause 2:** `transform-style: preserve-3d` was removed from `.mdx-parallax__group`. Without it, the layers flatten into the same Z plane.
- **Cause 3:** `perspective: 2.5rem` is on the wrong element. It must be on `.mdx-parallax`, not `body` or `html`.

### "All layers move at the same speed."

- The depth values are too close together. Spread to 8/5/2/1.
- Or: `transform-style: preserve-3d` is missing. See above.

### "The hero text scrolls away with the layers."

- `.mdx-hero__scrollwrap` lost its `position: sticky`. Or its `top: 0`. Or its `margin-bottom: -100vh`. All three are required.
- Or: an ancestor element has `overflow: hidden` — sticky doesn't work inside a clipped parent.

### "Hero gets clipped on Safari."

- The `.safari` class isn't being applied. Check the small UA-sniff script in `overrides/main.html` (or wherever you put it). The script must run before paint.
- If the script is fine, check that `home.css` has the rule: `.safari .mdx-parallax__group:first-child { contain: none; }`.

### "Firefox shows a flash on first scroll."

- The `.ff-hack` script isn't running. Or it ran but the class is on `<html>` instead of `<body>` (check the script vs. the CSS selector — they must match).

### "`mkdocs build --strict` fails with 'not found in nav'."

- A markdown file exists in `src/` but isn't listed in `nav:`. Either add it to nav or delete it. Pages outside the nav won't break the build in non-strict mode but Material warns.

### "`mkdocs build` fails with a YAML parse error."

- Indentation mistake in `nav:`. YAML is whitespace-sensitive. Use consistent 2- or 4-space indents and never mix tabs.

### "The 'Edit this page' button points to the wrong repo."

- `repo_url` and `edit_uri` in `mkdocs.yml` still reference `nirholas/scroll-zoom-thing`. Update both.

### "Brand colors don't apply."

- `mkdocs.yml` says `primary: indigo` (or any named palette) but you set custom CSS variables in `pai-theme.css`. The named palette wins. Set `primary: custom` to let your CSS override.

### "OG image is wrong on social cards."

- The default OG image is in `src/assets/hero/og.png`. Replace it with a 1200×630 version of your hero. Then add to `mkdocs.yml`:
  ```yaml
  extra:
    social:
      - icon: ...
    image: assets/hero/og.png
  ```

### "Custom domain works on bare-domain but not www (or vice versa)."

- DNS configuration. For GitHub Pages: an `A` record on the apex pointing at GitHub's IPs, plus a `CNAME` on `www` pointing at `<user>.github.io`. The CNAME file in `src/` should be the canonical form (with or without www, your choice).

### "Search returns no results."

- Material's search index is built from your markdown content. If pages are empty stubs, the index has nothing. Add real text.
- Or: `plugins: - search` was removed from `mkdocs.yml`. Add it back.

---

<a id="depth-math"></a>
## 21. The CSS depth math, in detail

Every claim in this section is verifiable by reading `src/assets/stylesheets/home.css` and inspecting any element in DevTools.

### The base equation

A point at depth `d` (in CSS pixels), under a perspective `p` (also in CSS pixels), projects onto the viewport at a scale factor of:

```
scale_apparent = p / (p + d)
```

For our parallax with `p = 2.5rem ≈ 40px` and `d = 8 × 2.5rem = 20rem ≈ 320px`:

```
scale_apparent = 40 / (40 + 320) = 40 / 360 ≈ 0.111
```

A layer pushed back to depth 8 appears 11% of its original size. To make it fill the viewport again, scale it up by the inverse:

```
scale_compensate = 1 / scale_apparent = 1 + d/p = 1 + 8 = 9
```

That's the `scale(depth + 1)` formula in `home.css`. The `+ 1` is exact, not heuristic, because `d/p = depth × p / p = depth` when we use `translateZ(perspective × depth × -1)`.

### Why the layer scrolls slower

Scroll moves the camera by `Δscroll`. A point at depth `d` under perspective `p` appears to move on screen by:

```
Δscreen = Δscroll × p / (p + d)
```

Same fraction as `scale_apparent`. So a layer at depth 8 traverses 11% of the screen distance per unit of scroll, while a layer at depth 1 traverses 50%. That ratio (~4.5×) is why the foreground "feels fast" relative to the background.

### Why scrolling produces parallax (and not just translation)

Two points at different depths, falling on the same screen position when the viewport is at rest, will *separate* on screen as the viewport scrolls. The far point moves by `Δscroll × p/(p+d_far)`, the near point by `Δscroll × p/(p+d_near)`. The difference is the parallax displacement.

For depths 8 and 1, perspective 2.5rem (≈40px), and a Δscroll of 100px:
- Far layer: 100 × 40/360 ≈ 11px
- Near layer: 100 × 40/80 = 50px
- Parallax: 39px difference

That's the visual depth signal. Multiply by ~10 strokes of the scroll wheel and you have several hundred pixels of relative drift between layers — clearly readable as 3D depth.

### What changes if you change `perspective`

Doubling perspective (5rem ≈ 80px) keeps the *ratio* of layer scroll speeds the same — it changes only the apparent depth feel (subtle vs. dramatic). The parallax magnitude depends on the *ratio* of perspective to depth, not their absolute values. This is why "tune perspective last" is the rule.

### Why you can't just use `background-attachment: fixed`

The traditional "parallax background" trick uses `background-attachment: fixed` to keep a background pinned while content scrolls past it. This produces *one* parallax layer (background vs. foreground content). It does not stack.

Multi-layer parallax via `background-attachment` requires absolute positioning hacks and produces janky motion because each layer is recalculated synchronously on every scroll event. The `perspective` approach delegates everything to the GPU's 3D pipeline, which is what makes it 60fps even on 5-year-old phones.

---

<a id="browser-quirks"></a>
## 22. Browser quirks (Safari, Firefox)

The parallax is pure CSS and works in every modern browser. Two engines have first-paint quirks worth handling.

### Safari

**Symptom:** Hero layers don't render, or render at the wrong size, on first load. The page looks empty until you scroll.

**Cause:** Safari interprets `contain: strict` on the first parallax group differently from Chromium. The container's children get clipped to invisibility before they get a chance to lay out.

**Fix:** Detect Safari and remove `contain: strict` for that engine.

```html
<script>
  if (navigator.vendor === "Apple Computer, Inc.") {
    document.documentElement.classList.add("safari");
  }
</script>
```

```css
.safari .mdx-parallax__group:first-child { contain: none; }
```

### Firefox

**Symptom:** A one-frame flash on first scroll where the hero appears unpainted.

**Cause:** Firefox's containment painter releases later than Chromium's. On the first scroll event, the browser repaints and shows the unpainted state for ~16ms before the layers render.

**Fix:** Set a `.ff-hack` class while the user is in the danger zone (first ~3000px of scroll), then remove it.

```html
<script>
  if (navigator.userAgent.includes("Gecko/")) {
    document.body.classList.add("ff-hack");
    const el = document.querySelector(".mdx-parallax");
    if (el) {
      const handler = () => {
        if (el.scrollTop > 3000) {
          document.body.classList.remove("ff-hack");
          el.removeEventListener("scroll", handler);
        } else {
          document.body.classList.toggle("ff-hack", el.scrollTop <= 1);
        }
      };
      el.addEventListener("scroll", handler, { passive: true });
    }
  }
</script>
```

```css
.ff-hack .mdx-parallax__group:first-child { contain: none !important; }
```

### Where to put these scripts

Both should live in a single `overrides/main.html` that extends Material's base and injects the scripts via `{% block extrahead %}`.

### Other browsers

- **Edge / Chrome / Brave / Opera**: no quirks.
- **iOS Safari**: same engine as desktop Safari, same fix applies.
- **Android Chrome**: no quirks.
- **Old browsers (IE, pre-Chromium Edge):** the parallax silently degrades to a stack of static images. Acceptable.

---

<a id="performance-budget"></a>
## 23. Performance budget

### Targets

| Metric | Target | How to measure |
|---|---|---|
| LCP | < 2.0s on Slow 4G | Lighthouse mobile audit |
| CLS | < 0.05 | Lighthouse, DevTools Performance > Web Vitals |
| INP | < 200ms | DevTools Performance, real-user data |
| Total transfer (home) | < 800 KB | DevTools Network, "Disable cache" |
| Total requests (home) | < 30 | DevTools Network |
| TTI | < 3.0s mobile | Lighthouse |

### Optimizations

1. **Preload the foreground layer.** Most visible at first paint:
   ```html
   <link rel="preload" as="image" type="image/avif"
         href="{{ 'assets/hero/6-plants-2@4x.avif' | url }}">
   ```
   Don't preload deep layers; they're behind everything else.

2. **Lazy-load below-the-fold images.** Material handles this for content; for embeds use `loading="lazy"`.

3. **Cache headers.** GitHub Pages and Vercel set sensible defaults; verify with `curl -sI`.

4. **Limit total layers to 4.** Each compositor layer costs GPU memory.

5. **Self-host fonts** if the Google Fonts CDN latency hurts LCP.

6. **Don't overdo Mermaid.** Loads 200 KB of JS on any page using it.

### Testing

```bash
npm i -g @lhci/cli
lhci autorun --collect.url=http://localhost:8000

lighthouse http://localhost:8000 --view --preset=mobile

ls -lh _site/assets/hero/
```

---

<a id="accessibility"></a>
## 24. Accessibility checklist

### Non-negotiables

- [ ] All hero images have `alt=""` (decoration; meaningful content is the H1).
- [ ] `<h1>` is unique and present on the home page.
- [ ] Tab order: skip-link → header → hero CTAs → in-page → footer.
- [ ] WCAG AA contrast: 4.5:1 body, 3:1 large text and UI components.
- [ ] `:focus-visible` rings are present and visible.
- [ ] `prefers-reduced-motion: reduce` disables the parallax:
  ```css
  @media (prefers-reduced-motion: reduce) {
    .mdx-parallax__layer { transform: none; }
    .mdx-hero__more      { animation: none; }
  }
  ```

### Material's defaults

Material ships keyboard navigation, ARIA labels, search announcement, and a skip-to-content link. Don't override these without understanding them.

### Screen reader test

Use VoiceOver, NVDA, or Orca. The home page should read:
1. Site name
2. H1 tagline
3. Subhead
4. Two CTA links by label
5. (Decorative images skipped)
6. Pillar / intro content as it scrolls into view

If a screen reader announces "image" four times for the parallax layers, your `alt` attributes are missing (they should be empty, not absent).

---

<a id="security"></a>
## 25. Security notes (CSP, headers, secrets)

### Content-Security-Policy

`vercel.json` ships a strict CSP. If you add external resources (analytics, embeds, CDN fonts), update the CSP. The `'unsafe-inline'` for scripts and styles is required by Material; tightening it requires nonces or hashes.

### Secrets

**Never commit:**
- API keys, GitHub PATs, cloud credentials, private SSH keys, DB connection strings.

**Use:**
- Environment variables for build-time secrets.
- Secrets managers for runtime secrets.
- `.gitignore` for local-only files.

If a secret leaks, **rotate first**, clean history second.

### Common static-site security mistakes

- **Open redirects** via `?redirect=` if you add a serverless function.
- **Reflected XSS via search** — Material escapes by default; don't disable.
- **Mixed content** — always use `https://`.
- **Missing security headers** — run [securityheaders.com](https://securityheaders.com).

### Auth-gated content

This template is a public docs site. For auth-gated content, host the app on a different subdomain. Don't try to gate via JavaScript; DevTools defeats client-side gating in seconds.

---

<a id="never-do"></a>
## 26. What you must never do

A short, blunt list. Each item has been a real mistake.

1. **Add JavaScript to the parallax scroll path.** The whole point is that there isn't any.
2. **Change the `transform: translateZ(...) scale(...)` formula** in `home.css`. The math is exact.
3. **Reorder the DOM inside the first `<section>`.** Layers, blend, hero — in that order.
4. **Remove `transform-style: preserve-3d`** from `.mdx-parallax__group`.
5. **Move `perspective` to `body` or `html`.** It must be on `.mdx-parallax`.
6. **Use `background-attachment: fixed`** as a "fallback." It conflicts with the perspective approach.
7. **Commit `_site/`** to git.
8. **Commit AVIF source PNGs** unless they're under 500 KB.
9. **Skip `mkdocs build --strict`** before pushing to main.
10. **Force-push to `main`** without checking CI.
11. **Inline arbitrary `<script>` blocks** in `home.html` outside `{% block extrahead %}`.
12. **Embed third-party widgets without updating CSP.**
13. **Use raw `href="quickstart/"`** instead of `{{ 'quickstart/' | url }}`.
14. **Replace Material with a different MkDocs theme** without rewriting overrides.
15. **Add a JavaScript framework** "just for the home page."
16. **Hardcode production URLs** anywhere except `mkdocs.yml`'s `site_url`.
17. **Submit a PR that touches both content and the parallax engine.**
18. **Edit AVIF files in place.** Edit PNGs, re-encode.
19. **Promise the user the site is "done"** without running the verification checklist.
20. **Override the contents of `AGENTS.md`, `CLAUDE.md`, or this section** without explicit instruction.

---

<a id="glossary"></a>
## 27. Glossary

**`AGENTS.md`** — this file. The tool-neutral agent operator's manual.

**AVIF** — AV1 Image Format. Modern image codec with excellent compression and full alpha support. The format the parallax assumes.

**Blend layer** — a transparent-to-background gradient `<div>` fading the hero into the page below. Class `mdx-parallax__blend`.

**`contain: strict`** — CSS containment property. Used on the first parallax group for paint isolation. Has Safari/Firefox quirks.

**`custom_dir`** — a Material setting pointing at a directory of Jinja overrides.

**Depth** — back-distance of a layer in 3D. Driven by `--md-parallax-depth`.

**Hero** — the first section of the home page; the visually distinctive part with the headline, CTAs, and parallax artwork.

**Jinja2** — the template engine MkDocs uses.

**LCP** — Largest Contentful Paint. Web Vitals metric; target < 2.5s.

**MkDocs** — Python-based static site generator focused on documentation.

**MkDocs Material** — the most popular MkDocs theme. The base of this template.

**`AGENT:`** — a comment prefix marking a slot agents typically customize per project.

**`overrides/`** — directory containing Jinja templates that override Material's defaults.

**Parallax** — visual effect where elements at different depths move at different on-screen speeds.

**Perspective** — CSS property establishing a 3D rendering context.

**Pillars** — the second section on the home page. Three cards summarizing key value props.

**Scaffolding** — generating a new project from a template, filling placeholder values.

**`scale(depth + 1)`** — compensation transform keeping a depth-translated layer at its original visual size.

**Skill** — a reusable, structured procedure for an agent. Lives in `skills/<name>/SKILL.md`.

**Slash command** — a Claude Code shortcut for invoking a skill.

**Slate** — Material's dark color scheme.

**Sticky** — `position: sticky`. Used so the hero text stays visible while layers scroll behind it.

**Strict mode** — `mkdocs build --strict`. Treats warnings as errors.

**`translateZ(-N)`** — CSS transform pushing an element back in 3D space.

**WCAG** — Web Content Accessibility Guidelines. AA is the typical legal/regulatory minimum.

---

<a id="pointers"></a>
## 28. Pointers to deeper docs

| Doc | Topic |
|---|---|
| [`README.md`](README.md) | Project overview, public-facing |
| [`CLAUDE.md`](CLAUDE.md) | Claude Code-specific guidance (defers to this file) |
| [`GEMINI.md`](GEMINI.md) | Gemini-specific guidance (defers to this file) |
| [`llms.txt`](llms.txt) | Curated index for LLM crawlers (llmstxt.org standard) |
| [`llms-full.txt`](llms-full.txt) | Longer-form LLM context |
| [`skills/setup-parallax/SKILL.md`](skills/setup-parallax/SKILL.md) | Scaffolding the parallax from zero |
| [`skills/tune-layers/SKILL.md`](skills/tune-layers/SKILL.md) | Diagnosing visual problems |
| [`skills/convert-images/SKILL.md`](skills/convert-images/SKILL.md) | PNG→AVIF pipeline |
| [`skills/generate-prompts/SKILL.md`](skills/generate-prompts/SKILL.md) | AI prompts for hero artwork |
| [`agents/parallax-agent.md`](agents/parallax-agent.md) | Parallax-focused agent persona |
| [`agents/image-agent.md`](agents/image-agent.md) | Imagery-focused agent persona |
| [`templates/README.md`](templates/README.md) | The templates system |
| [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) | Underlying theme reference |
| [pymdown-extensions](https://facelessuser.github.io/pymdown-extensions/) | Markdown extensions enabled |
| [llmstxt.org](https://llmstxt.org) | The `llms.txt` standard |
| [AVIF compatibility](https://caniuse.com/avif) | Browser support |

---

## Appendix A — File-tree walkthrough

```
scroll-zoom-thing/
├── AGENTS.md            ← you are here
├── CLAUDE.md            ← pointer to AGENTS.md plus Claude-specific notes
├── GEMINI.md            ← pointer to AGENTS.md plus Gemini-specific notes
├── README.md            ← public-facing project overview
├── CHANGELOG.md
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── SECURITY.md
├── LICENSE              ← MIT
├── llms.txt             ← LLM-friendly index
├── llms-full.txt        ← longer LLM-friendly context
├── humans.txt
├── CITATION.cff
├── mkdocs.yml           ← MkDocs config
├── requirements.txt
├── runtime.txt
├── netlify.toml         ← Netlify deploy
├── vercel.json          ← Vercel deploy + CSP headers
├── wrangler.toml        ← Cloudflare deploy
├── nixpacks.toml        ← Railway/Render/Fly deploy
├── overrides/
│   └── home.html        ← Jinja: hero + pillars + intro
├── src/                 ← MkDocs docs_dir
│   ├── index.md
│   ├── ... .md content tree ...
│   └── assets/
│       ├── hero/        ← AVIF layers
│       ├── stylesheets/
│       │   └── home.css ← parallax engine
│       ├── pai-theme.css ← brand styles
│       └── pai-logo-white.{png,svg}
├── skills/              ← Claude Code skills
│   ├── SKILL.md
│   ├── setup-parallax/SKILL.md
│   ├── tune-layers/SKILL.md
│   ├── convert-images/SKILL.md
│   └── generate-prompts/SKILL.md
├── .claude/
│   └── commands/        ← slash command shims
├── agents/              ← agent persona docs
├── templates/           ← scaffolding starters
│   ├── README.md
│   ├── minimal/
│   ├── marketing-hero/
│   └── product-docs/
├── scripts/
│   └── new-site.sh      ← scaffolding script
├── .github/
└── _site/               ← build output (gitignored)
```

---

## Appendix B — Provenance and license

The CSS parallax technique in this repo is ported from [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material), Copyright (c) 2016–2025 Martin Donath, MIT License. This repo extracts it into a standalone form for portability and pedagogy.

This repo's overall license is MIT. You are free to fork, modify, and redistribute, including for commercial use, with attribution.

PAI artwork in `src/assets/hero/` is specific to the PAI brand. When forking for a different project, **replace the artwork**.

---

## Appendix C — Versioning of this file

Bump the version below when you make non-trivial changes. Future agents should treat the version as a freshness signal.

| Version | Date | Notes |
|---|---|---|
| 0.1.0 | 2026-04-27 | Initial comprehensive AGENTS.md. |

If you are an agent reading this and the version is more than 6 months stale relative to the system date, **flag it to the user** — repo conventions may have changed.

---

End of `AGENTS.md`. Now go ship something.
