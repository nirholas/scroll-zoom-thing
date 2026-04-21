---
title: Deploying to GitHub Pages
description: Deploy a MkDocs Material parallax site to GitHub Pages using GitHub Actions — automatic builds on push, artifact upload, and Pages configuration.
---

# Deploying to GitHub Pages

Deploy your MkDocs Material parallax site automatically on every push using GitHub Actions.

---

## Prerequisites

- Repository on GitHub
- `mkdocs-material` in `requirements.txt`
- GitHub Pages enabled in repo Settings → Pages → Source: GitHub Actions

---

## `requirements.txt`

```
mkdocs-material>=9.0
```

---

## GitHub Actions workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy MkDocs to GitHub Pages

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.x"
          cache: pip

      - run: pip install -r requirements.txt

      - uses: actions/configure-pages@v4

      - run: mkdocs build --strict

      - uses: actions/upload-pages-artifact@v3
        with:
          path: _site

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/deploy-pages@v4
        id: deployment
```

---

## `site_url` in `mkdocs.yml`

Set this to your Pages URL so internal links resolve correctly:

```yaml
site_url: https://YOUR_USERNAME.github.io/YOUR_REPO/
```

---

## AVIF files in git

AVIF files are binary — git tracks them fine but they inflate repo size. For large layer files (>2MB each), consider:

- **Git LFS**: `git lfs track "*.avif"` — stores binaries in LFS, keeps repo fast
- **External CDN**: host layers on Cloudflare R2 or S3, reference by URL in `home.html`
- **Cloudflare Images**: upload once, get responsive AVIF URLs automatically

For a tutorial repo where files are <5MB each, plain git is fine.

---

## Custom domain

Add a `docs/CNAME` file with your domain:

```
parallax.yourdomain.com
```

MkDocs copies it to `_site/CNAME` at build time. Then configure your DNS CNAME to point to `YOUR_USERNAME.github.io`.

---

## Checking the deployed site

After the first deploy, open DevTools → Network → filter by `avif`. Confirm all 4 layers return 200 and load within 1-2 seconds. If layers are missing, check that file paths in `home.html` match exactly what's in `docs/assets/hero/` (case-sensitive on Linux).
