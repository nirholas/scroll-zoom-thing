---
title: Local development
description: Set up a Python virtual environment, run mkdocs serve with hot reload, build a production bundle, and debug the parallax hero.
---

# Local development

Local development is the right workflow when you want to iterate faster than
a deploy cycle allows, run plugins that need a Python environment, or debug
the parallax hero without pushing every change. This page covers the setup
and the day-to-day commands.

## Prerequisites

You need:

- Python 3.9 or later. Check with `python3 --version`.
- `pip`, which ships with modern Python installs.
- Git.

You do not need Node.js. There is no JavaScript bundle to compile.

## Setting up a virtual environment

A virtual environment isolates the Python packages for this project from
your system Python. Create one in the repo root:

```bash
git clone https://github.com/<you>/<your-repo>.git
cd <your-repo>

python3 -m venv .venv
source .venv/bin/activate
```

On Windows, the activation command is `.venv\Scripts\activate` instead.

Once the environment is active, your shell prompt will show `(.venv)`.
Install the dependencies:

```bash
pip install -r requirements.txt
```

The `requirements.txt` ships with the template and pins the versions of
`mkdocs`, `mkdocs-material`, and any additional plugins the template
relies on. If you add a plugin later, freeze the new version with
`pip freeze > requirements.txt` so collaborators and CI get the same setup.

## Running the dev server

The most common command:

```bash
mkdocs serve
```

This starts a local server at [http://127.0.0.1:8000](http://127.0.0.1:8000)
and watches the source tree for changes. When you save a file, MkDocs
rebuilds the affected page and the browser reloads automatically. Build
times for the parallax hero are typically under 200ms, so the feedback loop
is tight.

Useful flags:

- `mkdocs serve --dev-addr 0.0.0.0:8000` - bind to all interfaces, useful
  when previewing on a phone over the local network.
- `mkdocs serve --strict` - treat warnings as errors. Recommended before a
  production push, because broken internal links and orphaned pages will
  surface here rather than in production.
- `mkdocs serve --no-livereload` - disable the auto-reload script. Useful
  if you want to test without the live-reload websocket interfering with
  service worker debugging.

## Building for production

When you want to produce a static site you can ship:

```bash
mkdocs build
```

This writes the rendered site to `site/` in the repo root. The directory is
self-contained - copy it to any static host and it will work. CI hosts
(Vercel, Cloudflare Pages, the included GitHub Actions workflow) run this
command on every push and serve the result.

Add `--strict` for a final sanity check:

```bash
mkdocs build --strict
```

## Hot-reload and the parallax hero

The hero CSS lives in `src/assets/stylesheets/home.css`. When you edit the
file, `mkdocs serve` rebuilds and the browser refreshes. There is one
caveat: because the parallax depends on scroll position, a full reload
returns you to the top of the page. If you are tuning a layer that only
appears below the fold, scroll back to it after each save - or temporarily
move the layer's depth to a value that makes it visible at the top.

When you edit `overrides/home.html`, the live-reload script also fires a
full reload. Jinja2 errors in the template will appear in the terminal
running `mkdocs serve` rather than the browser - watch the terminal for
red text if a save did not produce the expected refresh.

## Debugging tips

A few things that go wrong often enough to be worth naming.

### The parallax looks flat

This usually means the scroll container does not have `perspective` set, or
a parent element has an opaque `transform` that is collapsing the 3D
context. Inspect the `.md-parallax` element in DevTools and confirm:

- It has `perspective: <something>` (typically `1px` or a small px value).
- It has `transform-style: preserve-3d` on itself or on the relevant
  ancestor.
- No ancestor has `overflow: hidden` blocking the layer that should extend
  beyond it.

### Layers look blurry

Each layer is scaled up by `scale(depth + 1)` to compensate for the fact
that `translateZ(-N)` makes content appear smaller. If your AVIF source is
not high enough resolution, the upscale will look soft. Re-export the
asset at a higher size - aim for the layer to be at least 2x its rendered
size at depth 1, more for deeper layers.

### The hero appears on every page

The hero template only attaches to pages that opt in via front matter:

```yaml
---
template: home.html
---
```

If the hero is appearing on a page you did not expect, check that page's
front matter. Conversely, if the home page is rendering as a normal
content page, confirm `src/index.md` has the `template: home.html` line.

### Plugins fail with a Python version error

If you upgrade your system Python and `mkdocs serve` starts failing, the
virtual environment may still be pinned to the old version. Recreate it:

```bash
deactivate
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Next steps

With a working dev loop, the [Guides](../guides/index.md) section is the
natural next read - it covers hero copy, theme customization, and
navigation in more depth than the getting-started flow.
