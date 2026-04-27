# Deploying to Cloudflare Pages

This guide covers deploying the CSS 3D Parallax Scrolling MkDocs Material site to Cloudflare Pages — including git-based deployments, the Wrangler CLI, Python version configuration, custom domains, AVIF asset caching, Cloudflare R2 for large media, Pages Functions, Access policies, and Cloudflare Web Analytics.

---

## Why Cloudflare Pages for MkDocs

Cloudflare Pages is the most generous free-tier hosting option available for static sites. Unlike GitHub Pages (which has no documented bandwidth limit but enforces fair use) and Vercel (which caps Hobby plan bandwidth at 100 GB/month), Cloudflare Pages offers:

- **Unlimited bandwidth** on the free tier. No surprise overages, no upgrade prompts when a blog post goes viral.
- **Global edge network.** Cloudflare operates 300+ points of presence worldwide — more than Vercel or GitHub Pages. For a parallax demo with large AVIF image layers, edge proximity matters for load time.
- **500 build minutes per month on the free tier.** A MkDocs build takes about 60-90 seconds, giving you roughly 300 production deploys per month before hitting limits.
- **Unlimited preview deployments.** Every branch push gets a preview URL, not just pull requests.
- **Integrated with Cloudflare's ecosystem.** You can add R2 object storage for large assets, Workers for edge logic, Access for authentication, and Web Analytics for privacy-first analytics — all from the same dashboard.

The one significant drawback versus Vercel is that Cloudflare Pages' Python build environment is older by default. You must explicitly set the `PYTHON_VERSION` environment variable to get a modern Python runtime.

---

## Two Deployment Methods

### Method 1: Git Integration (Recommended)

Cloudflare Pages connects to your GitHub or GitLab repository and triggers a build on every push. This is the zero-configuration path — once set up, every commit to `main` deploys automatically.

### Method 2: Wrangler CLI (Direct Upload)

The Wrangler CLI lets you build locally and upload the `_site/` directory directly to Cloudflare Pages. This is useful for:

- One-off deploys from a local machine.
- CI/CD systems that are not GitHub or GitLab.
- Testing a specific build before committing it to the repository.

---

## Git Integration Setup

### Step 1: Connect Your Repository

1. Go to the [Cloudflare dashboard](https://dash.cloudflare.com) and navigate to **Workers & Pages**.
2. Click **Create application** and select the **Pages** tab.
3. Click **Connect to Git** and authorize Cloudflare to access your GitHub account.
4. Select the `nirholas/scroll-zoom-thing` repository.

### Step 2: Configure Build Settings

On the "Set up builds and deployments" screen, enter the following settings. Do **not** select a framework preset — MkDocs is not in Cloudflare's preset list. Leave the preset as "None" and enter all values manually.

| Setting | Value |
|---|---|
| Framework preset | None |
| Build command | `pip install -r requirements.txt && mkdocs build` |
| Build output directory | `_site` |
| Root directory | *(leave empty)* |

**Build command explained:**

Cloudflare Pages runs the build command in a shell with a Python runtime available. The command installs all MkDocs dependencies from `requirements.txt` and then runs the build. Like Vercel, the `&&` operator ensures the build fails cleanly if pip installation fails.

**Build output directory:**

MkDocs writes output to `_site/` by default. Cloudflare Pages serves files from this directory after the build completes. If you have changed `site_dir` in `mkdocs.yml`, update this field to match.

**Root directory:**

Leave empty unless your `mkdocs.yml` and `docs/` folder are inside a subdirectory of the repository. For a standard MkDocs project layout, this should be blank.

### Step 3: Set the Python Version

Cloudflare Pages' default Python is Python 2.7 (legacy compatibility). MkDocs Material requires Python 3.8+ and the project benefits from Python 3.12 features. Set the `PYTHON_VERSION` environment variable before saving:

1. Expand **Environment variables (advanced)** on the build settings page.
2. Add a variable:
   - **Variable name:** `PYTHON_VERSION`
   - **Value:** `3.12`
3. Set the environment to **Production and Preview** (both).

Click **Save and Deploy**. The first build will take 2-3 minutes. Subsequent builds are faster because Cloudflare Pages caches pip downloads between builds (see the caching section below).

---

## Python Version: Full Configuration

Cloudflare Pages respects the `PYTHON_VERSION` environment variable set in two places:

**In the dashboard (recommended for the initial setup):**
- Navigate to your Pages project.
- Go to **Settings > Environment variables**.
- Add `PYTHON_VERSION` = `3.12` for both Production and Preview environments.

**In a `.python-version` file (alternative):**

Cloudflare Pages does not directly read `.python-version` files, unlike Vercel. The environment variable approach is the authoritative method for Cloudflare.

After setting the variable, all subsequent builds in both Production and Preview environments will use Python 3.12. Verify this by checking the build log — the first line of pip output shows the Python version being used.

---

## Wrangler CLI Deployment

The Wrangler CLI is Cloudflare's command-line tool for Workers, Pages, R2, and other Cloudflare products.

### Install Wrangler

```bash
npm install -g wrangler
```

### Authenticate

```bash
wrangler login
```

This opens a browser for OAuth authentication. Your credentials are stored locally.

### Build and Deploy

```bash
# Build the site locally
pip install -r requirements.txt
mkdocs build

# Deploy _site/ to Cloudflare Pages
wrangler pages deploy _site --project-name scroll-zoom-thing
```

The `--project-name` flag must match the project name in your Cloudflare dashboard. On first run, if the project does not exist, Wrangler will prompt you to create it.

After deployment, Wrangler outputs the deployment URL:

```
✨ Success! Deployed to https://abc123.scroll-zoom-thing.pages.dev
```

### Deploying a Specific Branch

```bash
wrangler pages deploy _site \
  --project-name scroll-zoom-thing \
  --branch staging
```

Deploments to non-`main` branches create preview URLs at `staging.scroll-zoom-thing.pages.dev` rather than replacing the production deployment.

---

## The `_redirects` File for Custom 404 Pages

Cloudflare Pages supports a `_redirects` file for URL redirects and a `_headers` file for custom HTTP headers. These files must be placed in the build output directory (`_site/`). Since MkDocs copies everything from `docs/` into `_site/`, place them in `docs/` and MkDocs will carry them through.

### Custom 404 Page

To serve a custom 404 page, create `docs/404.md`:

```markdown
# Page Not Found

The page you were looking for doesn't exist. Try navigating from the [home page](/).
```

MkDocs Material automatically generates a styled `404.html` from this file. To ensure Cloudflare Pages serves it, add a `_redirects` file at `docs/_redirects`:

```
# Custom 404 page
/404 /404.html 404
/* /404.html 404
```

The second rule catches any URL that does not match a file in `_site/` and serves the custom 404 page with a 404 status code. Without this, Cloudflare Pages serves a plain text "404 Not Found" response for missing routes.

### Redirect Old URLs

If you rename a page, add a redirect to prevent broken links:

```
# docs/_redirects
/old-page /new-page 301
/getting-started /index 301
```

Commit `docs/_redirects` and MkDocs will copy it to `_site/_redirects` during the build.

---

## Custom Domains

### Adding a Domain in the Cloudflare Pages Dashboard

1. Navigate to your Pages project.
2. Click **Custom domains** and then **Set up a custom domain**.
3. Enter your domain (e.g., `docs.example.com`) and click **Continue**.

### DNS Configuration

**If your domain uses Cloudflare nameservers (most common):**

Cloudflare automatically creates the DNS record for you. After you confirm the domain, the record appears in your DNS dashboard within seconds. No manual DNS editing is required.

**If your domain uses external nameservers:**

Add a CNAME record at your DNS provider:

| Type  | Host  | Value                               | TTL  |
|-------|-------|-------------------------------------|------|
| CNAME | docs  | scroll-zoom-thing.pages.dev.        | 3600 |

For apex domains (e.g., `example.com`), Cloudflare requires the domain to be on Cloudflare nameservers, because apex CNAMEs are not supported by the DNS specification. If you transfer the domain to Cloudflare DNS, you can use a `CNAME` flattening feature that works around this limitation.

### HTTPS

TLS is automatic and free for all Cloudflare Pages domains, including custom domains. Cloudflare uses its own certificate authority and manages certificate renewal. There is no configuration required.

### Update `site_url` in `mkdocs.yml`

```yaml
site_url: https://docs.example.com/
```

Commit and push to trigger a new production deploy.

---

## Preview Deployments

Unlike GitHub Pages (which has no built-in preview deployment support), Cloudflare Pages generates a unique preview URL for every push to every branch, not just pull requests.

The preview URL format is:

```
https://{branch-name}.{project-name}.pages.dev
```

For example, a branch named `feature/new-layer` creates:

```
https://feature-new-layer.scroll-zoom-thing.pages.dev
```

(Slashes in branch names are replaced with hyphens in the subdomain.)

Preview deployments are independent of production. They use the same build settings, the same environment variables, and the same Cloudflare CDN — but they are served from a separate URL and do not affect the production deployment at all.

To disable preview deployments for specific branches (e.g., long-lived feature branches you do not want to expose):

1. Go to **Settings > Builds & deployments > Branch control**.
2. Under **Preview branch control**, restrict which branches trigger preview builds.

---

## Environment Variables

Environment variables set in the Cloudflare Pages dashboard are available to the build command as standard shell variables.

Common use cases for MkDocs builds:

```bash
# A plugin that calls an API for social card generation
SOCIAL_CARD_API_KEY=abc123

# Python version (required for MkDocs Material)
PYTHON_VERSION=3.12

# Force MkDocs to use UTC timestamps
TZ=UTC
```

To set variables for different environments:

1. Go to **Settings > Environment variables**.
2. Click **Add variable**.
3. Enter the name and value.
4. Choose whether it applies to **Production**, **Preview**, or **All environments**.

Variables marked as "Encrypted" are stored securely and not shown in build logs. Use this for API tokens and secret keys — though for a pure MkDocs build, no secrets are typically needed.

---

## Cloudflare Cache for AVIF Layers

Cloudflare Pages caches static assets at every edge node automatically. The cache behavior is controlled by the `Cache-Control` header returned with each asset.

For maximum edge caching of AVIF hero layers, add a `_headers` file at `docs/_headers`:

```
# docs/_headers

# AVIF hero layers: cache for one year (immutable)
/assets/hero/*
  Cache-Control: public, max-age=31536000, immutable
  Content-Type: image/avif

# All AVIF files
/*.avif
  Cache-Control: public, max-age=31536000, immutable
  Content-Type: image/avif

# CSS and JS: cache for one year (MkDocs Material content-hashes these)
/*.css
  Cache-Control: public, max-age=31536000, immutable

/*.js
  Cache-Control: public, max-age=31536000, immutable

# HTML: always revalidate
/*.html
  Cache-Control: public, max-age=0, must-revalidate

# Security headers for all routes
/*
  Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
  X-Content-Type-Options: nosniff
  X-Frame-Options: DENY
  Referrer-Policy: strict-origin-when-cross-origin
```

Commit `docs/_headers` and MkDocs copies it to `_site/_headers` on the next build. Cloudflare Pages reads this file and applies the headers to every matching response.

To verify caching, check the `CF-Cache-Status` header:

```bash
curl -I https://docs.example.com/assets/hero/layer-01.avif
```

`CF-Cache-Status: HIT` confirms the asset is being served from Cloudflare's edge cache. `MISS` means it was fetched from the origin (the Pages storage). Subsequent requests will be `HIT`.

---

## Cloudflare R2 for Large Hero Images

Cloudflare R2 is an S3-compatible object storage service with no egress fees. For AVIF hero layers larger than 1 MB each — or for a parallax demo where the hero consists of a dozen high-resolution layers totalling 20+ MB — storing them in R2 instead of the git repository solves two problems at once:

1. **Repository size.** Large binaries in git inflate clone time and disk usage.
2. **Build time.** Including large binaries in `_site/` means Cloudflare Pages uploads them on every build, even if they have not changed. R2 assets are uploaded once and referenced by URL.

### Setting Up R2 for Hero Images

```bash
# Create an R2 bucket
wrangler r2 bucket create scroll-zoom-hero

# Upload hero layers to R2
wrangler r2 object put scroll-zoom-hero/layer-01.avif --file docs/assets/hero/layer-01.avif
wrangler r2 object put scroll-zoom-hero/layer-02.avif --file docs/assets/hero/layer-02.avif
wrangler r2 object put scroll-zoom-hero/layer-03.avif --file docs/assets/hero/layer-03.avif
# ... repeat for all layers
```

By default, R2 buckets are private. To make them publicly accessible:

1. Go to the R2 bucket in the Cloudflare dashboard.
2. Click **Settings > Public access**.
3. Enable **R2.dev subdomain** or connect a custom domain.

With a custom domain (e.g., `assets.example.com`), your hero layers are accessible at:

```
https://assets.example.com/layer-01.avif
```

### Referencing R2 URLs in `home.html`

In your MkDocs Material `home.html` override or the relevant partial template, replace local asset paths with R2 URLs:

```html
<!-- Before: local asset path -->
<img src="{{ config.site_url }}assets/hero/layer-01.avif" alt="Layer 1">

<!-- After: R2 URL -->
<img src="https://assets.example.com/layer-01.avif" alt="Layer 1">
```

For the CSS-based parallax effect, update the CSS `background-image` references similarly:

```css
.parallax-layer-01 {
  background-image: url('https://assets.example.com/layer-01.avif');
}
```

R2 assets served via a custom domain are automatically cached at Cloudflare's edge nodes. You do not need to configure anything — R2 + Cloudflare's edge is a native pairing.

**When to use R2:**

- Total size of `docs/assets/hero/` exceeds 10 MB.
- You update hero images frequently and want to decouple image updates from site builds.
- You need to share assets across multiple sites (e.g., a staging site and production site use the same hero layer files).

---

## Pages Functions: Edge Logic

Cloudflare Pages Functions let you add server-side logic to your otherwise static site, running at the edge in Cloudflare's Workers runtime. For a parallax demo, potential use cases include:

- **Custom 404 handling with analytics.** Log 404s to Cloudflare Analytics Engine.
- **Auth gates.** Redirect unauthenticated users to a login page before showing the parallax demo.
- **A/B testing.** Serve different hero image sets to different visitors.

Functions live in a `functions/` directory at the repository root (not inside `docs/`). Cloudflare Pages automatically discovers and deploys them alongside the static site.

```javascript
// functions/api/ping.js
// Accessible at /api/ping on your Pages site

export async function onRequest(context) {
  return new Response(JSON.stringify({ status: 'ok', timestamp: Date.now() }), {
    headers: { 'Content-Type': 'application/json' },
  });
}
```

For simple redirects, the `_redirects` file (described earlier) is simpler than a Function. Use Functions only when you need dynamic logic.

---

## Cloudflare Access: Restricting Preview Deployments

By default, all Cloudflare Pages preview URLs are publicly accessible. If your parallax demo is not ready for public consumption, or if it contains proprietary content, you can restrict access using Cloudflare Access.

### Setting Up Access for Preview Deployments

1. Go to **Zero Trust > Access > Applications** in the Cloudflare dashboard.
2. Click **Add an application** and select **Self-hosted**.
3. **Application name:** `Scroll Zoom Previews`
4. **Application domain:** `*.scroll-zoom-thing.pages.dev` (wildcard matches all preview subdomains)
5. Under **Policies**, add a policy that allows your team's email addresses or a One-Time PIN.

Once configured, anyone visiting a preview URL will be redirected to a Cloudflare Access login page before seeing the site. Team members authenticate with their work email (or GitHub, Google, etc., depending on your Identity Provider configuration). The production deployment at your custom domain is unaffected.

---

## Build Time Optimization: Caching pip on Cloudflare Pages

Cloudflare Pages supports a pip cache directory that persists between builds. Declare the cache directory in the build command:

```bash
pip install --cache-dir /opt/buildhome/.cache/pip -r requirements.txt && mkdocs build
```

The `/opt/buildhome/.cache/pip` path is Cloudflare Pages' standard cache location. Files stored here persist between builds for the same project, so pip only downloads packages that changed in `requirements.txt`.

For maximum cache effectiveness, pin exact versions in `requirements.txt`:

```
mkdocs-material==9.5.18
```

A floating specifier like `mkdocs-material>=9.0` may resolve to a different version on each build even with a cache hit, defeating the purpose of pinning.

---

## Analytics: Cloudflare Web Analytics

Cloudflare Web Analytics is a privacy-first analytics solution that:

- Requires no cookies.
- Does not track users across sites.
- Does not sell data.
- Is free for all Cloudflare users.
- Provides page views, visit duration, and top pages without identifying individuals.

Unlike Google Analytics, it complies with GDPR without requiring a cookie consent banner.

### Setting Up Web Analytics

1. Go to **Analytics & Logs > Web Analytics** in the Cloudflare dashboard.
2. Click **Add a site** and enter your domain.
3. Cloudflare generates a JavaScript beacon script tag, e.g.:

```html
<script defer src='https://static.cloudflareinsights.com/beacon.min.js' data-cf-beacon='{"token": "YOUR_TOKEN_HERE"}'></script>
```

### Adding the Beacon via MkDocs `extra_javascript`

Do not hardcode the beacon script in a template override. Instead, use MkDocs Material's `extra_javascript` feature to inject it on every page.

Create `docs/js/analytics.js`:

```javascript
// docs/js/analytics.js
// Cloudflare Web Analytics beacon
(function() {
  var script = document.createElement('script');
  script.defer = true;
  script.src = 'https://static.cloudflareinsights.com/beacon.min.js';
  script.dataset.cfBeacon = JSON.stringify({ token: 'YOUR_TOKEN_HERE' });
  document.head.appendChild(script);
})();
```

Then in `mkdocs.yml`:

```yaml
extra_javascript:
  - js/analytics.js
```

MkDocs Material injects this script on every generated page. The beacon fires asynchronously after page load, so it does not affect the parallax animation's performance.

Alternatively, use MkDocs Material's `hooks` or `custom_dir` to add the script tag directly to the `<head>` element via a `main.html` override:

```html
{% extends "base.html" %}

{% block extrahead %}
  {{ super() }}
  <script defer src="https://static.cloudflareinsights.com/beacon.min.js"
          data-cf-beacon='{"token": "YOUR_TOKEN_HERE"}'></script>
{% endblock %}
```

The `extra_javascript` approach is simpler and does not require a full template override.

---

## Comparing Cloudflare Pages to Vercel and GitHub Pages

| Feature | Cloudflare Pages (Free) | Vercel (Hobby) | GitHub Pages |
|---|---|---|---|
| Bandwidth | Unlimited | 100 GB/month | Fair use |
| Build minutes | 500/month | 6,000 minutes/month | Unlimited (Actions) |
| Preview deployments | Every branch | Every PR | None natively |
| Custom domains | Free | Free | Free |
| HTTPS | Automatic | Automatic | Automatic |
| Custom headers | `_headers` file | `vercel.json` | Not possible |
| Python support | Yes (`PYTHON_VERSION` env var) | Yes (`.python-version`) | Yes (Actions) |
| Edge nodes | 300+ PoPs | 100+ PoPs | GitHub CDN |
| Object storage | R2 (free tier: 10 GB) | N/A | Git LFS |
| Edge functions | Pages Functions (free) | Edge Functions (Pro) | N/A |
| Analytics | Web Analytics (free) | Analytics (Pro) | N/A |
| Commercial use | Yes, unlimited | Requires Pro plan | Public repos only |

Cloudflare Pages wins on bandwidth, edge coverage, and free-tier generosity. Vercel wins on developer experience and the quality of its dashboard. GitHub Pages wins on simplicity and native GitHub integration.

For the parallax demo site, the recommendation is:

- **Personal project / open source:** Use GitHub Pages for simplicity.
- **Expecting traffic spikes or global visitors:** Use Cloudflare Pages for unlimited bandwidth and edge coverage.
- **Team collaboration with PR previews:** Use Vercel for its preview deployment workflow.

---

## Troubleshooting

### Python Runtime Not Available

Build log shows `python: command not found` or `pip: command not found`.

Fix: Set `PYTHON_VERSION=3.12` in **Settings > Environment variables** in the Cloudflare Pages dashboard. The variable must be set for both Production and Preview environments.

### `_site` Not Recognized

Build log shows a successful mkdocs build but the deployment fails with "no output directory."

Fix: Verify the **Build output directory** in **Settings > Builds & deployments** is set to `_site`. This is case-sensitive. Check that `mkdocs.yml` does not override `site_dir` to a different path.

### AVIF MIME Type Issues

Some browsers or caching layers serve AVIF files with `Content-Type: application/octet-stream` instead of `image/avif`, causing the images to not render.

Fix: Add explicit `Content-Type` headers in `docs/_headers`:

```
/*.avif
  Content-Type: image/avif
```

Cloudflare Pages does not always infer the MIME type for AVIF files correctly (it is a relatively new format). Explicitly setting the header guarantees correct delivery.

### Build Fails After Updating `requirements.txt`

A new package in `requirements.txt` may have a version that conflicts with an existing dependency.

Fix: Run `pip install -r requirements.txt` locally in a fresh virtual environment to reproduce the conflict, then resolve it locally before pushing:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
mkdocs build
```

### Preview Deployments Not Triggering

By default, Cloudflare Pages triggers preview builds on all branches. If previews are not triggering, check:

1. **Branch control settings.** Go to **Settings > Builds & deployments > Branch control** and verify that preview builds are not restricted to specific branches.
2. **Git integration status.** Go to **Settings > Builds & deployments** and verify the GitHub integration shows "Connected."
3. **GitHub webhook.** In your GitHub repository's **Settings > Webhooks**, verify that a Cloudflare webhook is listed and showing recent deliveries. A red X on a delivery means the webhook failed — click it to see the error.

---

## Quick Reference

```bash
# Install Wrangler CLI
npm install -g wrangler

# Authenticate
wrangler login

# Build locally
pip install -r requirements.txt && mkdocs build

# Direct upload to Cloudflare Pages
wrangler pages deploy _site --project-name scroll-zoom-thing

# Create an R2 bucket for hero images
wrangler r2 bucket create scroll-zoom-hero

# Upload a hero AVIF layer to R2
wrangler r2 object put scroll-zoom-hero/layer-01.avif \
  --file docs/assets/hero/layer-01.avif

# List R2 objects
wrangler r2 object list scroll-zoom-hero
```

Key files:
- `docs/_headers` — Cache-Control and security headers for Cloudflare Pages.
- `docs/_redirects` — URL redirects and custom 404 handling.
- `docs/CNAME` — Not used by Cloudflare Pages; custom domains are configured in the dashboard.
- `mkdocs.yml` — Set `site_url` to your custom domain or `pages.dev` URL.
- `requirements.txt` — Pin versions for reliable pip caching.

Environment variables to set in the Cloudflare Pages dashboard:
- `PYTHON_VERSION=3.12` — Required for MkDocs Material 9.x.
- `TZ=UTC` — Optional; makes build timestamps consistent across runs.
