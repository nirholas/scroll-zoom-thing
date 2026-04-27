# Deploying to Vercel

This guide covers deploying the CSS 3D Parallax Scrolling MkDocs Material site to Vercel — from CLI-based deploys to fully automated GitHub integration with preview deployments, custom domains, security headers, and AVIF asset caching.

---

## Why Vercel for MkDocs Sites

Vercel is primarily known as a Next.js and frontend hosting platform, but it handles Python-based static site generators equally well. For a MkDocs Material site, Vercel offers several advantages over GitHub Pages:

- **Preview deployments on every pull request.** Every PR gets a unique URL (e.g., `scroll-zoom-thing-abc123-nirholas.vercel.app`) where reviewers can see the rendered site before merging. This is Vercel's killer feature for documentation workflows.
- **Edge network with global PoPs.** Vercel's CDN has points of presence on six continents. Static assets like AVIF layers are cached at the edge closest to each visitor, reducing latency compared to GitHub Pages' CDN.
- **Instant cache invalidation.** On each deploy, Vercel invalidates cache only for changed files. AVIF layers that did not change keep their cached copies at every edge node.
- **Security headers.** You can set HSTS, CSP, and other security headers directly in `vercel.json`, without needing a separate reverse proxy.
- **Environment variables.** MkDocs plugins that call external APIs (e.g., `mkdocs-git-revision-date-localized`, social card generators) can consume environment variables set in the Vercel dashboard.
- **Build logs and error reporting.** Every build's stdout and stderr are stored and searchable in the Vercel dashboard, making debugging straightforward.

The primary trade-off versus GitHub Pages is the free tier limit. Vercel's Hobby plan allows unlimited deployments for personal projects but limits commercial use and enforces a 100 GB bandwidth cap per month. For documentation sites, this is rarely a constraint.

---

## The `vercel.json` Configuration File

For a MkDocs Material site, `vercel.json` does three things: tells Vercel how to build the site, where to find the output, and what HTTP headers to attach to responses.

Here is a complete, annotated `vercel.json` for this project:

```json
{
  "buildCommand": "pip install -r requirements.txt && mkdocs build",
  "outputDirectory": "_site",
  "installCommand": "echo 'skipping node install'",
  "framework": null,
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Strict-Transport-Security",
          "value": "max-age=63072000; includeSubDomains; preload"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        },
        {
          "key": "Permissions-Policy",
          "value": "camera=(), microphone=(), geolocation=()"
        }
      ]
    },
    {
      "source": "/assets/hero/:file*",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/:path*.avif",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        },
        {
          "key": "Content-Type",
          "value": "image/avif"
        }
      ]
    },
    {
      "source": "/:path*.css",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/:path*.js",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=31536000, immutable"
        }
      ]
    },
    {
      "source": "/(.*).html",
      "headers": [
        {
          "key": "Cache-Control",
          "value": "public, max-age=0, must-revalidate"
        }
      ]
    }
  ]
}
```

### Field-by-Field Explanation

**`buildCommand`**

```json
"buildCommand": "pip install -r requirements.txt && mkdocs build"
```

This is the shell command Vercel runs to build your site. Because there is no `package.json`-based build step, the entire build is driven by pip and mkdocs. The `&&` ensures that if `pip install` fails (e.g., a package is unavailable), the `mkdocs build` step is skipped and the deployment fails cleanly rather than deploying a broken or empty `_site/`.

Do not add `--strict` here unless you are confident your site has zero MkDocs warnings. A strict failure will block the deploy and surface an error in the Vercel dashboard.

**`outputDirectory`**

```json
"outputDirectory": "_site"
```

MkDocs writes its build output to `_site/` by default (as configured by `site_dir: _site` in `mkdocs.yml`, or the default). Vercel serves files from this directory. If you have changed `site_dir` in `mkdocs.yml`, update this field to match.

**`installCommand`**

```json
"installCommand": "echo 'skipping node install'"
```

Vercel's default install command is `npm install` or `yarn install`, which is irrelevant for a Python project. Overriding it with a no-op echo prevents Vercel from attempting to install Node dependencies that don't exist, shaving a few seconds off the build time. You could also set this to an empty string (`""`), but an explicit echo makes the intent clear in build logs.

**`framework`**

```json
"framework": null
```

Setting `framework` to `null` disables Vercel's framework auto-detection. Without this, Vercel might try to detect the project as a Next.js or Vite project and apply incorrect build defaults. Explicitly opting out avoids surprising behavior.

**Security Headers**

The first `headers` entry applies to all routes (`/(.*)`):

- **`Strict-Transport-Security`** — Instructs browsers to always use HTTPS for this domain, including subdomains, for two years. The `preload` directive submits the domain to the HSTS preload list, which browsers ship built-in. Once submitted, this cannot easily be undone, so add `preload` only when you are certain HTTPS will be maintained permanently.
- **`X-Content-Type-Options: nosniff`** — Prevents browsers from MIME-sniffing responses away from the declared `Content-Type`. Without this, a browser might execute a JavaScript file returned with `Content-Type: text/plain`.
- **`X-Frame-Options: DENY`** — Prevents the site from being embedded in an `<iframe>` on another domain. This protects against clickjacking attacks. If you intentionally embed this site in iframes, change this to `SAMEORIGIN`.
- **`Referrer-Policy`** — Controls how much referrer information is included in requests. `strict-origin-when-cross-origin` sends the full URL for same-origin requests but only the origin for cross-origin requests, and nothing for requests to HTTP from HTTPS.
- **`Permissions-Policy`** — Explicitly disables access to camera, microphone, and geolocation for all frames. A pure static documentation site has no use for these browser APIs.

**Cache Headers for AVIF Assets**

```json
{
  "source": "/assets/hero/:file*",
  "headers": [
    {
      "key": "Cache-Control",
      "value": "public, max-age=31536000, immutable"
    }
  ]
}
```

`max-age=31536000` is one year in seconds — the maximum practical TTL for a static asset. The `immutable` directive tells the browser that this file will never change at this URL, so it should never send a conditional request (e.g., `If-None-Match`) for it. This eliminates an entire round-trip for repeat visitors.

These long TTLs are safe for AVIF hero layers because MkDocs Material uses content-hashed asset URLs by default. When an image changes, its URL changes, so cached copies of the old URL are never served for new content.

**HTML files get `max-age=0`** — This forces the browser to always revalidate HTML before using a cached copy. Since HTML files contain references to your versioned CSS, JS, and image URLs, it's critical that visitors always get the latest HTML even if the underlying assets are cached for a year.

---

## Installing the Vercel CLI

The Vercel CLI is a Node.js package. Install it globally:

```bash
npm install -g vercel
```

Verify the install:

```bash
vercel --version
```

Authenticate with your Vercel account:

```bash
vercel login
```

This opens a browser window for OAuth authentication. After logging in, your credentials are stored in `~/.vercel/credentials.json`.

---

## CLI Deployment Walkthrough

### First Deploy

```bash
# From the root of the repository
vercel
```

On the first run, the CLI prompts you to:

1. **Link to an existing project or create a new one.** Choose "Create a new project" for a fresh deployment.
2. **Confirm the project name.** The default is derived from the repository directory name. For this repo, it would be `scroll-zoom-thing`.
3. **Confirm the root directory.** Press Enter to accept the repository root.

The CLI reads `vercel.json` automatically. You will see output like:

```
Detected project settings from vercel.json:
- Build Command: pip install -r requirements.txt && mkdocs build
- Output Directory: _site
- Install Command: echo 'skipping node install'
```

The first build takes 60-90 seconds (mostly pip downloading packages). Subsequent builds are faster because Vercel caches the pip download cache between builds.

### Production Deploy

```bash
vercel --prod
```

The `--prod` flag promotes the build to your production URL (your custom domain or `project-name.vercel.app`). Without `--prod`, the deploy goes to a preview URL only.

### Overriding Build Settings

If you need to override a setting without modifying `vercel.json`, use CLI flags:

```bash
vercel --prod \
  --build-env MKDOCS_EXTRA_VAR=value \
  --env SECRET_KEY=abc123
```

`--build-env` sets variables available during the build; `--env` sets runtime variables (not relevant for a static site, but useful if you run Vercel Edge Functions alongside it).

---

## GitHub Integration: Automatic Deploys

Connecting Vercel to your GitHub repository enables:

- **Automatic production deploys** when commits are pushed to `main`.
- **Automatic preview deploys** for every pull request.
- **Status checks** posted directly to the PR, with a link to the preview URL.

### Setup

1. Go to [vercel.com/new](https://vercel.com/new) and click **Import Git Repository**.
2. Authorize Vercel to access your GitHub account (or the specific repository).
3. Select `nirholas/scroll-zoom-thing`.
4. Vercel reads `vercel.json` and pre-fills all build settings. Verify them and click **Deploy**.

After the initial deploy, every subsequent push to `main` triggers a production deploy automatically. Pushes to any other branch trigger a preview deploy.

### Python Version

Vercel's default Python version changes over time. To pin a specific version, add a `.python-version` file to the repository root:

```
3.12
```

Alternatively, specify it in `vercel.json`:

```json
{
  "buildCommand": "pip install -r requirements.txt && mkdocs build",
  "outputDirectory": "_site",
  "installCommand": "echo 'skipping node install'",
  "build": {
    "env": {
      "PYTHON_VERSION": "3.12"
    }
  }
}
```

The `.python-version` file approach is more portable — it also works with pyenv locally and with other hosting providers.

---

## Environment Variables

MkDocs itself does not require environment variables. However, several popular MkDocs plugins do:

- **`mkdocs-git-revision-date-localized`** — Needs access to git history. No env vars required, but `fetch-depth: 0` must be set in CI (Vercel's git clone is always full-depth).
- **Social card generators** — May need API tokens for external image generation services.
- **Custom plugins** — Anything you write that calls an external API.

To set environment variables in Vercel:

1. Go to your project in the Vercel dashboard.
2. Click **Settings > Environment Variables**.
3. Add each variable, specifying which environments it applies to (Production, Preview, Development).

Variables set here are available as standard environment variables during the build command. For the `pip install && mkdocs build` command chain, any variable in the environment is accessible to MkDocs plugins via Python's `os.environ`.

---

## Preview Deployments in Detail

Every pull request to your repository gets its own preview deployment at a URL like:

```
https://scroll-zoom-thing-git-fix-parallax-nirholas.vercel.app
```

The URL format is: `{project}-git-{branch}-{team}.vercel.app`.

Vercel posts a status check on the PR in GitHub:

```
✓ Vercel — Preview deployment ready
  Visit Preview: https://scroll-zoom-thing-git-fix-parallax-nirholas.vercel.app
```

This URL is accessible to anyone with the link by default. On the Pro plan, you can restrict preview URL access to authenticated Vercel team members.

Preview deployments use the same `vercel.json` configuration as production, including all security headers and cache policies. The only difference is that they use a distinct subdomain instead of your custom domain, and they do not affect the production deployment at all — merging a PR to `main` creates a new production deploy; it does not "promote" the preview.

---

## Custom Domains

### Adding a Domain in the Vercel Dashboard

1. Go to your project in the Vercel dashboard.
2. Click **Settings > Domains**.
3. Enter your domain (e.g., `docs.example.com`) and click **Add**.
4. Vercel shows you the DNS record to add.

### DNS Configuration

For a subdomain (e.g., `docs.example.com`):

| Type  | Host  | Value                   | TTL  |
|-------|-------|-------------------------|------|
| CNAME | docs  | cname.vercel-dns.com.   | 3600 |

For an apex domain (e.g., `example.com`):

| Type | Host | Value          | TTL  |
|------|------|----------------|------|
| A    | @    | 76.76.21.21    | 3600 |

Vercel automatically provisions a TLS certificate via Let's Encrypt once DNS propagates. You will see "Valid Configuration" in the Domains settings when the certificate is active.

### Update `site_url` in `mkdocs.yml`

```yaml
site_url: https://docs.example.com/
```

Commit and push to trigger a new production deploy with the correct canonical URLs.

---

## Edge Network and AVIF Caching

Vercel's edge network caches static files at every point of presence automatically. When a visitor in Tokyo requests `/assets/hero/layer-01.avif`, Vercel's Tokyo edge node serves it from cache (after the first request from any Tokyo visitor populates that cache).

The AVIF layers in `docs/assets/hero/` are ideal candidates for aggressive caching because:

1. They are large binary files unlikely to change frequently.
2. MkDocs Material can be configured to content-hash asset filenames, guaranteeing cache busting when content changes.
3. Their `Cache-Control: public, max-age=31536000, immutable` header (set in `vercel.json`) tells both browsers and Vercel's CDN to cache them for a full year.

To verify caching is working, check the `X-Vercel-Cache` response header:

```bash
curl -I https://your-domain.com/assets/hero/layer-01.avif
```

You should see `X-Vercel-Cache: HIT` after the first request has warmed the cache.

---

## Build Logs and Common Errors

### Finding Build Logs

In the Vercel dashboard, go to your project, click the **Deployments** tab, and click any deployment. The **Build Logs** tab shows the complete stdout and stderr from the build command.

### Python Not Found

```
Error: Python not found
```

This means Vercel's build environment did not locate Python. Fix: add `.python-version` to the repository root with the value `3.12`. This tells Vercel's build environment to activate a Python 3.12 runtime before running the build command.

### `mkdocs` Not Found

```
/bin/sh: mkdocs: not found
```

This means `pip install -r requirements.txt` did not succeed before `mkdocs build` ran — or the pip install ran in a different PATH context than the mkdocs call. Fix: ensure the build command is a single string with `&&`:

```json
"buildCommand": "pip install -r requirements.txt && mkdocs build"
```

Never split it into separate commands in a POSIX shell array — Vercel runs the `buildCommand` as a single shell string.

### `_site` Not Found

```
Error: No output directory named '_site' found
```

This happens when `mkdocs build` exits before creating `_site/`. Check the build logs for the mkdocs error message. Usually this is a `mkdocs.yml` configuration error or a missing plugin.

### Python Version Mismatch

Some MkDocs plugins use syntax (e.g., `match` statements, `|` union types in type hints) that requires Python 3.10+. If the build fails with a `SyntaxError`, the Python version is likely too old. Add `.python-version` with `3.12`.

---

## Comparing Vercel to GitHub Pages

| Feature | Vercel (Hobby) | GitHub Pages |
|---|---|---|
| Cost | Free for personal use | Free for public repos |
| Bandwidth | 100 GB/month | Fair use (no hard limit documented) |
| Preview deployments | Yes, every PR | No (requires workarounds) |
| Custom domain | Yes, free | Yes, free |
| HTTPS | Automatic | Automatic |
| Security headers | Via `vercel.json` | Not configurable |
| Build environment | Vercel cloud | GitHub Actions runner |
| Python support | Yes (via runtime detection) | Yes (via Actions workflow) |
| Build caching | pip cache between builds | pip cache via Actions cache |
| Global CDN | Yes, 100+ PoPs | Yes, GitHub's CDN |
| Commercial use | Requires Pro plan ($20/month) | Allowed on public repos |

For a personal or open-source parallax demo site, both are free and capable. Vercel wins on developer experience (preview deployments, security headers, faster cache propagation). GitHub Pages wins on simplicity and the absence of vendor lock-in.

---

## Real-World Example: docs.pai.direct

The PAI documentation site at docs.pai.direct is deployed on Vercel with the GitHub integration. The `vercel.json` uses the same `buildCommand` and `outputDirectory` pattern described in this guide. Security headers are configured as shown above, including HSTS with `preload`. The AVIF hero layers in `docs/assets/hero/` are served with `Cache-Control: public, max-age=31536000, immutable`, and Vercel's edge network caches them globally. Preview deployments are used by the documentation team to review content changes before they go live — each PR to the docs repository generates a Vercel preview URL that is linked in the PR's status checks.

---

## Quick Reference

```bash
# Install Vercel CLI
npm install -g vercel

# Authenticate
vercel login

# Preview deploy (from repo root)
vercel

# Production deploy
vercel --prod

# Check cache headers on an AVIF asset
curl -I https://your-domain.com/assets/hero/layer-01.avif | grep -i cache
```

Key files:
- `vercel.json` — Build command, output directory, headers.
- `.python-version` — Pin Python version (recommended: `3.12`).
- `mkdocs.yml` — Set `site_url` to your custom domain or Vercel URL.
- `requirements.txt` — Pin mkdocs-material version for reproducible builds.
