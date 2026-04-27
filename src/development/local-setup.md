---
title: Local setup
description: Detailed instructions for running scroll-zoom-thing locally during development.
---

# Local setup

This page walks through getting a working development environment for scroll-zoom-thing on your machine. It assumes you have Git and Python 3.10 or newer installed. If you only want to use the template, this is more setup than you need; head to [Getting Started](../getting-started/index.md) instead.

## Prerequisites

You need:

- **Python 3.10+.** Earlier versions may work but are not tested. Verify with `python --version`.
- **pip.** Bundled with Python. Verify with `pip --version`.
- **Git.** For cloning the repo and pushing changes.

Optional:

- **pyenv** or **uv** for managing multiple Python versions.
- **direnv** for automatic virtualenv activation when you `cd` into the repo.

## Clone the repository

```bash
git clone https://github.com/nirholas/scroll-zoom-thing
cd scroll-zoom-thing
```

If you plan to contribute, fork first and clone your fork. Add the upstream as a second remote so you can pull updates:

```bash
git remote add upstream https://github.com/nirholas/scroll-zoom-thing
```

## Create a virtual environment

Always use a virtualenv. The Python community has standardised on this pattern; there is no good reason to install MkDocs into your system Python.

```bash
python -m venv .venv
source .venv/bin/activate    # macOS / Linux
.venv\Scripts\activate       # Windows PowerShell
```

You should see `(.venv)` prepended to your shell prompt. From now on, every `pip` and `mkdocs` command runs inside the virtualenv.

To leave the virtualenv: `deactivate`.

## Install dependencies

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

`requirements.txt` pins MkDocs, MkDocs Material, and any plugins the project uses. The pinning is intentional: theme upgrades have a habit of moving things around and breaking the parallax overrides.

If `pip install` fails on a specific package, the most common cause is a Python version mismatch. Confirm `python --version` is 3.10 or newer, then re-run.

## Run the development server

```bash
mkdocs serve
```

This starts a local server at `http://127.0.0.1:8000` with livereload enabled. Edit any file under `src/`, and the browser refreshes automatically. The server prints any build warnings or errors to the terminal as you save.

A few useful flags:

- `mkdocs serve --strict` treats warnings as errors. Use this before opening a PR.
- `mkdocs serve --dirty` skips rebuilding unchanged pages, which is faster on large sites. Not needed for this project.
- `mkdocs serve -a 0.0.0.0:8000` binds to all interfaces, useful when testing from another device on your LAN.

## Build for production

```bash
mkdocs build --strict
```

This produces a `site/` directory containing the built static site. The `--strict` flag is mandatory in CI; you should run it locally before pushing. It catches broken internal links, missing image references, and duplicate slugs.

To preview the production build:

```bash
python -m http.server --directory site 8000
```

That serves `site/` exactly the way Railway will. It is the closest local approximation to the deployed environment. The serve command is the same one used by [the Railway deployment guide](../deploy/railway.md).

## Livereload behaviour

`mkdocs serve` watches:

- `src/` (markdown content)
- `mkdocs.yml`
- `overrides/` (theme partial overrides)
- Any path listed under `watch:` in `mkdocs.yml`

It does **not** watch the theme package inside your virtualenv. If you are debugging a theme issue by editing files in `.venv/lib/python3.x/site-packages/material/`, you will need to manually reload the browser, and the changes will be lost the next time you reinstall.

The livereload script is injected only by `mkdocs serve`; it is not present in the production build.

## Debugging templates

When you override a partial in `overrides/partials/`, MkDocs Material picks up the override automatically. If your override does not seem to apply:

1. Confirm the directory name matches the original (`partials/`, not `partial/`).
2. Confirm the filename matches exactly (case-sensitive on Linux).
3. Restart `mkdocs serve` (livereload does not always pick up new files in `overrides/`).
4. Check the rendered HTML in the browser; sometimes the override is loading but a CSS rule is hiding it.

For Jinja2 errors, the traceback in the terminal is usually clear. The most common mistake is referencing a variable that does not exist in the template's context. The MkDocs Material docs list the variables available in each partial.

## IDE recommendations

The project is small enough that any editor works. Recommended setups:

- **VS Code** with the Python extension and the Even Better TOML extension. The Python extension picks up the virtualenv automatically if `.venv` is at the repo root.
- **Neovim** with `pyright` for Python type-checking and `prettier` for Markdown formatting (optional).
- **PyCharm Community** if you prefer a heavier IDE; configure the project interpreter to point at `.venv/bin/python`.

For writing prose, any editor with soft-wrap and live preview works. VS Code's built-in Markdown preview is sufficient for checking that your headings nest correctly.

## Troubleshooting

**`mkdocs: command not found`**: the virtualenv is not activated, or you skipped `pip install -r requirements.txt`. Re-run both steps.

**Port 8000 already in use**: pass `mkdocs serve -a 127.0.0.1:8001` (or any free port).

**Browser does not livereload**: a content blocker may be stripping the websocket connection that livereload uses. Whitelist `127.0.0.1` and reload.

**Parallax hero looks flat in your local build**: confirm your browser is not in reduced-motion mode (see [accessibility.md](../privacy/accessibility.md) for how to toggle it).

**Build error on a Material partial after upgrading**: pin MkDocs Material in `requirements.txt` to the version the project was last tested against, then upgrade in a separate PR.

## Next steps

Once you have a working local environment, read [contributing.md](contributing.md) for the contribution workflow, or browse the [development landing page](index.md) for the broader project values.
