---
title: Deploy to Railway
description: Deploying a scroll-zoom-thing site to Railway using nixpacks.toml and Python http.server.
---

# Deploy to Railway

Railway is an application platform: it deploys long-running processes from a Git repository, manages environment variables, and bills based on usage. It is not a static-site host in the dedicated sense (Netlify, Vercel, Cloudflare Pages, GitHub Pages all are), but it can serve a static site through Python's bundled `http.server` perfectly well. Railway is the right choice when you want your documentation to live in the same project as a backend, a database, or a scheduled job. For a docs-only site, prefer one of the dedicated hosts. See the [deployment landing page](index.md) for the comparison.

## Prerequisites

You need:

- A Railway account.
- The site source pushed to a Git remote (GitHub is the smoothest integration).
- A working local build (`mkdocs build --strict` passes).

## How Railway builds

Railway uses [Nixpacks](https://nixpacks.com) by default to detect your project type and produce a build. Nixpacks reads `nixpacks.toml` (when present) and falls back to auto-detection. The repo ships a `nixpacks.toml` configured for MkDocs:

```toml
providers = ["python"]

[phases.setup]
nixPkgs = ["python311", "pip"]

[phases.install]
cmds = ["pip install -r requirements.txt"]

[phases.build]
cmds = ["mkdocs build"]

[start]
cmd = "python -m http.server --directory site $PORT"
```

The four phases:

- **setup** declares the system packages Nixpacks installs into the build image. Pinning `python311` prevents Railway from silently moving to a newer interpreter when Nixpacks updates.
- **install** runs `pip install -r requirements.txt`. The pip cache is preserved between deploys, so subsequent builds reuse downloaded wheels.
- **build** runs `mkdocs build`, producing the `site/` directory.
- **start** runs the long-lived process. `python -m http.server` is the simplest static server in the standard library; it is good enough for docs traffic and adds no dependencies.

## Creating the project

1. Open the Railway dashboard and click **New Project**.
2. Choose **Deploy from GitHub repo**.
3. Authorise Railway to read your GitHub account, then pick the repo.
4. Railway reads `nixpacks.toml` and starts the first build automatically. It takes about 30 seconds.
5. Once the build succeeds, Railway assigns a `*.up.railway.app` subdomain and starts the `http.server` process.

The first deploy is now live at the assigned subdomain.

## The PORT environment variable

Railway injects a `$PORT` environment variable into the runtime container and routes its public ingress to that port. Your start command **must** bind to `$PORT`; binding to a hard-coded `8000` will appear to work in the build logs but produce a 502 at the public URL.

The `nixpacks.toml` start command above passes `$PORT` to `http.server` as the port argument. If you customise the start command, preserve that pattern:

```bash
python -m http.server --directory site $PORT
```

`http.server`'s `--directory` flag was added in Python 3.7, so the 3.11 version pinned in `nixpacks.toml` supports it. If you somehow end up on an older Python, change to `cd site && python -m http.server $PORT`.

## Custom domains

To add a custom domain:

1. In the Railway dashboard, open the service then the **Settings** tab.
2. Under **Networking**, click **Custom Domain** and enter your domain.
3. Railway returns a CNAME target. Add the CNAME at your registrar.
4. Once propagation completes, Railway provisions a Let's Encrypt certificate.

Apex domains are supported via ALIAS or ANAME records if your DNS provider offers them. If your provider does not (Cloudflare and DNSimple do; many registrars do not), use a `www` subdomain and a 301 redirect from the apex.

## Environment variables

Railway exposes environment variables to the build phases (the `nixpacks.toml` `cmds`) and to the runtime process. Set them in the **Variables** tab:

- `MKDOCS_SITE_URL` if you want to override the canonical site URL at build time.
- `PYTHON_VERSION` is set by Nixpacks; do not override it. Change `nixpacks.toml` instead.

Avoid putting secrets in build-time variables unless you have to; build logs are readable to anyone with project access.

## Quirks and tradeoffs

A handful of Railway behaviours surprise people coming from Netlify or Vercel.

### Cold starts

Railway services sleep after a period of inactivity on the trial plan. The first request after sleep wakes the container, which takes a few seconds. On the paid plans this does not happen, but it is worth confirming your plan if response time matters.

### No global CDN

`http.server` runs in a single Railway region. Visitors far from that region see higher latency than they would on Cloudflare Pages or Vercel. For a docs site with an international audience, prefer one of the CDN-backed hosts. If you must use Railway, front it with Cloudflare's free CDN: point your domain at Cloudflare, set Cloudflare to proxy, and origin-pull from the Railway URL. This recovers most of the latency advantage.

### Build minutes are billed

Railway bills for build CPU time. The build for this project takes roughly 30 seconds and uses negligible resources, so the cost is in the cents-per-month range. Still, if you push frequently to multiple branches, the billed build time accumulates. Disable preview environments for branches that do not need them.

### Logs are useful

Railway streams stdout from `http.server` directly to the dashboard. Each request produces a log line. This makes Railway one of the easiest places to do log-based analytics: pipe the log drain to GoAccess and you have visitor analytics with no browser-side tracking. See [analytics.md](../privacy/analytics.md) for the broader analytics options.

### `http.server` is not production-grade

Python's `http.server` is fine for low-to-moderate documentation traffic. It is single-threaded and has no caching headers beyond defaults. For high-traffic deployments, replace it with a more capable server. A small Caddyfile and the `caddy` binary works well:

```toml
[start]
cmd = "caddy file-server --root site --listen :$PORT"
```

This requires adding `caddy` to the `nixPkgs` list in the setup phase. Caddy serves static files efficiently and sets sensible cache headers automatically.

## Pricing notes

Railway's pricing as of writing:

- $5/month trial credit on signup, which is enough to run a small docs service for several months.
- After the trial, the **Hobby** plan is $5/month and includes $5 of usage; usage above that is billed per minute of compute and per GB of network egress.
- Static-site usage on Railway is dominated by network egress, since CPU is near-zero when serving cached files. The exact cost depends on your traffic.

Before committing a high-traffic site to Railway, model the cost: estimated monthly bandwidth times the per-GB rate, plus the base plan, plus the build time. For a docs site under 50 GB/month of traffic, the cost is typically under $10/month. For a docs site over 500 GB/month, Cloudflare Pages becomes much cheaper. See [the deployment landing page](index.md) for the comparison.

## Migrating away

If you decide to move off Railway, the `site/` directory is portable. The Railway-specific files are `nixpacks.toml` (which other platforms ignore) and any environment variables you set in the dashboard. There is no lock-in beyond those.

## See also

- [Cloudflare Pages](cloudflare.md) and [Netlify](netlify.md) for dedicated static hosts with global CDNs.
- [GitHub Pages](github-pages.md) for a free, no-platform option.
- [Privacy landing page](../privacy/index.md) for the project's broader privacy posture, including log-based analytics that pair well with Railway.
