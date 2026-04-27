---
title: Quickstart
description: Deploy scroll-zoom-thing in under ten minutes - pick a host, fork the repo, edit the hero copy, replace the four AVIF layers.
---

# Quickstart

This walkthrough takes you from zero to a deployed site. It assumes you have
a GitHub account and a browser. You will not need a local Python environment
to complete it.

## Step 1: Pick a deploy target

scroll-zoom-thing builds with `mkdocs build`, which produces a static `site/`
directory. Any host that can serve static files will work. The README links
deploy buttons for the three most common targets:

- **Vercel** - the fastest path to a preview URL. Vercel detects the MkDocs
  build automatically and provisions a `*.vercel.app` subdomain. See
  [vercel.com/docs/git/vercel-for-github](https://vercel.com/docs/git/vercel-for-github).
- **Cloudflare Pages** - free tier with generous bandwidth and a global CDN.
  Build command: `mkdocs build`. Output directory: `site`. See
  [developers.cloudflare.com/pages](https://developers.cloudflare.com/pages/).
- **GitHub Pages** - zero additional accounts required. The repo ships with
  a GitHub Actions workflow that runs `mkdocs build` on push to `main` and
  publishes to the `gh-pages` branch. See
  [docs.github.com/pages](https://docs.github.com/en/pages).

If you do not have a preference, start with Vercel. The signup is fastest
and the preview URL is provisioned within a minute of the first push.

## Step 2: Fork the repository

Open [github.com/nirholas/scroll-zoom-thing](https://github.com/nirholas/scroll-zoom-thing)
and click **Fork** in the top right. GitHub will create a copy under your
account at `github.com/<you>/scroll-zoom-thing`. The fork preserves the
default branch (`main`) and the GitHub Actions workflow, but it is your
copy - you can push to it, rename it, and edit anything.

If you would rather start a clean repo with no fork relationship, see
[Use as a template](use-as-template.md). For a quickstart, the fork is fine.

## Step 3: Click deploy

From your forked repository, follow the deploy button that matches your host.

For Vercel:

1. Visit [vercel.com/new](https://vercel.com/new) and pick **Import Git Repository**.
2. Select your fork from the list.
3. Vercel will detect MkDocs and prefill the build command. Confirm and click
   **Deploy**.
4. Within roughly sixty seconds you will have a `*.vercel.app` URL.

For Cloudflare Pages:

1. Visit the [Pages dashboard](https://dash.cloudflare.com/?to=/:account/pages).
2. **Connect to Git**, pick your fork.
3. Set the build command to `mkdocs build` and the output directory to `site`.
4. Set the Python version environment variable: `PYTHON_VERSION=3.11`.
5. **Save and Deploy**.

For GitHub Pages:

1. In your fork, open **Settings -> Pages**.
2. Under **Source**, pick **GitHub Actions**.
3. Push any change to `main` to trigger the included workflow.
4. The site will be live at `https://<you>.github.io/scroll-zoom-thing/`.

## Step 4: Edit the hero copy

The hero text lives in `overrides/home.html`. You can edit it directly on
GitHub - click the file in the web UI, then click the pencil icon. The
elements you will likely want to change are the H1, the subheading, and the
two call-to-action buttons:

```html
<h1 class="md-parallax__title">Your headline here</h1>
<p class="md-parallax__subtitle">Your supporting copy here.</p>

<div class="md-parallax__buttons">
  <a href="{{ 'getting-started/' | url }}" class="md-button md-button--primary">
    Get started
  </a>
  <a href="{{ 'overview/' | url }}" class="md-button">
    Learn more
  </a>
</div>
```

The `{{ '...' | url }}` filter is Jinja2 syntax that MkDocs uses to resolve
URLs relative to the site root. Always wrap internal links in this filter so
they continue to work if the site is hosted under a subpath.

For a deeper guide on hero copy, including button styling and how the buttons
interact with Material's palette, see [Hero copy](../guides/hero-copy.md).

## Step 5: Replace the four AVIF layers

The hero is composed from four AVIF images that live in `src/assets/`. Each
layer sits at a depth that controls how far it translates as the user scrolls.
The default depths are `8`, `5`, `2`, and `1`, where `8` is farthest from the
camera and `1` is closest.

To swap in your own art:

1. Export each layer as AVIF. Aim for roughly 2400 pixels wide for the
   farthest layer and 3200 for the closest, since closer layers scale up
   more visibly.
2. Replace the four files in `src/assets/`. Keep the filenames - the
   template references them by name.
3. If you need to reposition a layer, edit the `--md-image-position` CSS
   variable on the matching `<div>` in `overrides/home.html`. The variable
   accepts any valid `background-position` value.

```html
<div class="md-parallax__layer"
     style="--md-parallax-depth: 5;
            --md-image-position: 50% 30%;
            background-image: url('{{ 'assets/layer-2.avif' | url }}')">
</div>
```

Commit the changes. Your host will rebuild and your new hero will be live
within a minute or two. From here, follow [Use as a template](use-as-template.md)
if you want to repoint the repo at a clean history, or
[Local development](local-development.md) if you want to iterate faster
than a deploy cycle allows.
