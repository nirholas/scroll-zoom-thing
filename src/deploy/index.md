---
title: Deployment
description: Comparison of the five supported deployment platforms for scroll-zoom-thing sites.
---

# Deployment

scroll-zoom-thing builds to a static `site/` directory, which means it deploys to almost any host. The repo includes ready-to-use configuration for five platforms: Vercel, Netlify, Cloudflare Pages, GitHub Pages, and Railway. This page compares them so you can pick.

The five long-form guides:

- [GitHub Pages](github-pages.md)
- [Vercel](vercel.md)
- [Cloudflare Pages](cloudflare.md)
- [Netlify](netlify.md)
- [Railway](railway.md)

If you have not picked yet, read the comparison below first.

## At-a-glance comparison

| Platform | Free tier | Build time | Custom domain | Edge network | Best for |
|----------|-----------|------------|---------------|--------------|----------|
| GitHub Pages | Unlimited public repos | ~1 min | Yes (one per repo) | Fastly-backed CDN | Open-source docs, personal sites |
| Vercel | 100 GB bandwidth/mo | ~30 s | Yes | Vercel Edge | Teams already on Vercel |
| Cloudflare Pages | Unlimited bandwidth | ~45 s | Yes | Cloudflare global | Privacy-conscious, high-traffic |
| Netlify | 100 GB bandwidth/mo | ~45 s | Yes | Netlify Edge | Form handling, edge functions |
| Railway | $5/mo trial credit | ~30 s | Yes | Single region | When you also need a backend |

All five platforms support automatic deploys on push to `main`, preview builds for pull requests, and HTTPS with auto-renewing certificates.

## Picking by use case

### "I want it free, forever, no surprises"

**GitHub Pages.** It is free for public repositories, has no bandwidth cap that documentation sites realistically hit, and the deploy is a single GitHub Actions workflow. The downside is the build is slightly slower and the platform offers no built-in analytics. See [github-pages.md](github-pages.md).

### "I need the absolute fastest global performance"

**Cloudflare Pages.** Cloudflare's network is the largest of the five, and Web Analytics (cookieless, opt-in) is included free. Bandwidth is uncapped on the free tier. See [cloudflare.md](cloudflare.md).

### "We already deploy everything on Vercel"

**Vercel.** No friction, integrates with Vercel Analytics if you want it. The 100 GB bandwidth limit is generous for documentation but real if your site goes viral. See [vercel.md](vercel.md).

### "I want form handling without writing a backend"

**Netlify.** Netlify Forms turns any HTML form into a webhook target without server code. Edge Functions handle redirects, A/B tests, and auth checks at the edge. The free tier includes 100 form submissions per month. See [netlify.md](netlify.md).

### "I also need to run a small backend or scheduled job"

**Railway.** Railway lets you serve the static build via Python's `http.server` in the same project as a background worker, a database, or a cron job. The pricing is usage-based after the trial credit. For docs-only sites this is overkill; for docs that sit alongside an API, it is a reasonable choice. See [railway.md](railway.md).

## Build commands

Every platform runs the same build command. The repo's configuration files set this for you, but for reference:

```bash
pip install -r requirements.txt
mkdocs build
```

The output lives in `site/`. Each platform's deploy guide explains how to point its build pipeline at that directory.

## Branch and preview behaviour

The five platforms all support previews per branch or per pull request. The defaults differ:

- **GitHub Pages** does not produce previews automatically; you build them yourself or use a third-party preview action.
- **Vercel, Netlify, Cloudflare Pages, and Railway** all produce a unique preview URL for each PR by default.

If review-by-preview is important to your workflow, prefer the four platforms with built-in previews. GitHub Pages is fine if you do all review against `main`.

## Custom domains

All five platforms support custom domains with auto-renewing TLS. The differences:

- **GitHub Pages** allows one domain per repository. If you need multiple, deploy each to its own repo.
- **Cloudflare Pages** is the easiest if your domain is already managed by Cloudflare; the wiring is two clicks.
- **Vercel** and **Netlify** both walk you through the DNS records to add at your registrar.
- **Railway** issues a CNAME you point at; HTTPS is automatic once propagation completes.

## Environment variables

Static documentation sites generally need no environment variables. The exceptions are:

- An analytics token, if you wire analytics through a build-time replacement rather than a static script.
- A Sentry DSN, if you decide to add browser error reporting (the template does not by default).
- A search API key, if you swap the bundled search for Algolia DocSearch.

Each platform exposes environment variables to the build step in roughly the same way; see the per-platform guides for the syntax.

## Cost realism

The default deploy on any of the five platforms costs $0 for a typical documentation site. If you publish a popular post and burn through a free-tier bandwidth quota:

- GitHub Pages and Cloudflare Pages do not have a bandwidth cap to burn through.
- Vercel and Netlify charge per GB above 100 GB; the bills are real but rarely catastrophic.
- Railway is usage-based throughout; track your usage before relying on it for high-traffic deployments.

## What to read next

Pick a platform from the table above and follow the matching guide. If you are unsure, start with [GitHub Pages](github-pages.md) or [Cloudflare Pages](cloudflare.md). Both are free, both produce production-quality deployments, and both are easy to migrate away from later because the build artifact is just a static `site/` directory.
