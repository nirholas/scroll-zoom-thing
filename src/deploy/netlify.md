---
title: Deploy to Netlify
description: Deploying a scroll-zoom-thing site to Netlify, including netlify.toml, environment variables, custom domains, and edge functions.
---

# Deploy to Netlify

Netlify is one of the most full-featured static hosts: it deploys from a Git repository, produces preview URLs for every pull request, and offers form handling, edge functions, and identity as opt-in extras. This page walks through deploying a scroll-zoom-thing site to Netlify, covers the `netlify.toml` already in the repo, and notes the Netlify-specific quirks that come up.

Compare to [Vercel](vercel.md), [Cloudflare Pages](cloudflare.md), [GitHub Pages](github-pages.md), and [Railway](railway.md) for the other supported targets.

## Prerequisites

You need:

- A Netlify account (free).
- The site source pushed to a Git remote (GitHub, GitLab, or Bitbucket).
- A working local build. If `mkdocs build --strict` does not pass on your machine, it will not pass in Netlify either.

## The netlify.toml file

The repository ships a `netlify.toml` configured for MkDocs builds. Its core sections look like this:

```toml
[build]
  command = "pip install -r requirements.txt && mkdocs build"
  publish = "site"

[build.environment]
  PYTHON_VERSION = "3.11"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "geolocation=(), microphone=(), camera=()"

[[headers]]
  for = "/assets/fonts/*"
  [headers.values]
    Cache-Control = "public, max-age=31536000, immutable"
```

The two interesting sections:

- **`[build]`** tells Netlify how to build the site. Netlify auto-detects MkDocs in many cases, but pinning the command in `netlify.toml` removes ambiguity.
- **`[build.environment]`** pins the Python version. Netlify defaults change over time; pinning prevents builds breaking when Netlify rotates defaults.
- **`[[headers]]`** stanzas set sensible security headers and aggressive cache headers on font files (which are content-hashed by the build, so immutable caching is safe).

If you fork the repo, leave `netlify.toml` as-is unless you have a specific reason to change it. The pinned Python version is the one the project tests against.

## Click-to-deploy

The fastest first deploy is to use the click-to-deploy button in the README. The button is a Netlify deep link that:

1. Forks the upstream repo into your GitHub account.
2. Creates a new Netlify site connected to the fork.
3. Triggers an initial build and assigns a `*.netlify.app` subdomain.

The whole process takes about two minutes. The resulting site is yours to customise.

If you prefer to start from an existing fork, the manual setup is similar:

1. In the Netlify dashboard, click **Add new site** then **Import an existing project**.
2. Authorise Netlify to read your Git provider and pick the repo.
3. Netlify reads `netlify.toml` and pre-fills the build command and publish directory. Confirm the values and click **Deploy site**.
4. The first build takes about a minute. Subsequent builds are slightly faster because pip's package cache is preserved between runs.

## Environment variables

The base template does not require environment variables. You may add them for:

### Analytics tokens

If you switch to a build-time-injected analytics token (less common, but useful for keeping the token out of the repo):

```bash
netlify env:set CF_ANALYTICS_TOKEN "abcd1234"
```

Then reference `${CF_ANALYTICS_TOKEN}` from a small build script that writes the value into `site/assets/js/analytics.js` after `mkdocs build`. Add the script to the `command` in `netlify.toml`:

```toml
[build]
  command = "pip install -r requirements.txt && mkdocs build && ./scripts/inject-analytics.sh"
```

### Algolia DocSearch

If you swap the bundled search for Algolia DocSearch, store the application ID and search-only API key as environment variables and inject them into a partial at build time. Algolia's search-only key is meant to be public, but storing it as an environment variable lets you rotate without a code change.

### Build-only secrets

For secrets that must never reach the browser, use Netlify's **build environment** scope (the default) rather than the **deploy** scope. The browser never sees build-environment variables.

## Custom domains

To add a custom domain:

1. In the Netlify dashboard, open **Site configuration** then **Domains**.
2. Click **Add custom domain** and enter your domain.
3. Netlify produces either an A record (apex) or a CNAME (subdomain) to add at your registrar.
4. Add the record. Propagation usually takes minutes.
5. Once Netlify detects the record, it provisions a Let's Encrypt certificate automatically.

For apex domains, prefer Netlify DNS over A records pointing at Netlify's load balancer, because Netlify DNS allows automatic IP changes without you updating records. If you cannot move DNS, the A record approach works fine; just be aware Netlify occasionally publishes new addresses.

The certificate auto-renews. If renewal fails (usually because of a mistyped DNS record or a CAA record blocking Let's Encrypt), Netlify emails the site owner.

## Branch deploys and previews

By default, Netlify produces a preview deploy for every pull request opened against the production branch. The preview URL has the form `deploy-preview-123--yoursite.netlify.app` and is regenerated on every push to the PR branch.

To enable preview deploys for additional long-lived branches (for example, a `staging` branch), open **Site configuration** then **Build & deploy** then **Branches and deploy contexts**, and add the branch name to the watch list.

Each context can override settings in `netlify.toml`:

```toml
[context.deploy-preview]
  command = "pip install -r requirements.txt && mkdocs build --no-strict"

[context.production]
  command = "pip install -r requirements.txt && mkdocs build --strict"
```

This pattern lets PR previews succeed even when there is a temporary broken link, while keeping production builds strict.

## Netlify Forms

The base template has no forms, but if you add a contact or feedback form, Netlify Forms gives you a no-code submission backend. Add `data-netlify="true"` and `name="contact"` to the form element:

```html
<form name="contact" method="POST" data-netlify="true">
  <input type="email" name="email" required />
  <textarea name="message" required></textarea>
  <button type="submit">Send</button>
</form>
```

Netlify scans the deployed HTML for forms with that attribute and registers them automatically. Submissions appear in the Netlify dashboard. The free tier includes 100 submissions per month.

For spam protection, add `data-netlify-honeypot="bot-field"` and a hidden honeypot field. This catches most bots without inconveniencing real users. Avoid reCAPTCHA unless honeypot proves insufficient — reCAPTCHA introduces third-party requests that conflict with the template's privacy posture.

## Edge functions

Netlify Edge Functions run Deno code at the network edge. For a documentation site, the useful applications are:

- **Authentication gates.** Block specific paths until the visitor presents a cookie or header.
- **Geographic routing.** Serve different content based on `Netlify-Geo` headers without revealing the visitor's location to the client.
- **Custom redirects with logic.** When `_redirects` rules are not expressive enough.

A minimal edge function in `netlify/edge-functions/auth.ts`:

```ts
import type { Context } from "https://edge.netlify.com";

export default async (request: Request, context: Context) => {
  const cookie = request.headers.get("cookie") ?? "";
  if (!cookie.includes("authorised=1")) {
    return new Response("Unauthorised", { status: 401 });
  }
  return context.next();
};

export const config = { path: "/private/*" };
```

Wire it in `netlify.toml`:

```toml
[[edge_functions]]
  function = "auth"
  path = "/private/*"
```

Edge functions add latency and complexity. Use them only when a static rewrite or redirect would not work.

## Redirects and rewrites

For most cases, the file-based `_redirects` syntax is enough. Place a `_redirects` file in `src/` and MkDocs copies it into `site/`:

```
/old-path  /new-path  301
/api/*     https://api.example.com/:splat  200
```

A 301 is a permanent redirect; a 200 is a transparent rewrite. Use 301 for path renames and 200 for proxying through to a backend.

## Logs and observability

Netlify exposes build logs in the dashboard for every deploy. They are kept for the lifetime of the site. For runtime logs (edge function output, function invocations), the **Functions** tab shows recent invocations.

Netlify does not show per-request logs for static asset hits. If you need that detail, attach a privacy-friendly analytics tool (Plausible, Umami, or Cloudflare Web Analytics) or front the site with Cloudflare and use Cloudflare's logging.

## Disabling Netlify analytics

Netlify offers a paid analytics product that runs server-side off the access logs. It is opt-in. The template does not need it, and enabling it is independent of the bundled cookieless analytics options.

## Migrating away

If you decide to leave Netlify, the `site/` directory is portable. Run `mkdocs build` locally and rsync the output to any static host. The `netlify.toml`, `_redirects`, and edge function code are Netlify-specific and would need to be rewritten for the destination platform's equivalents.

## See also

- [Vercel deployment guide](vercel.md) for a comparable platform with similar features.
- [Cloudflare Pages deployment guide](cloudflare.md) for a free-tier-uncapped alternative.
- [Cloudflare Pages guide](cloudflare.md) for an alternative free-tier static host with unlimited bandwidth.
