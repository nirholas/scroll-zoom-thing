# Deploying to GitHub Pages

This guide covers everything you need to deploy the CSS 3D Parallax Scrolling for MkDocs Material site to GitHub Pages — from the simplest one-command deploy all the way to a fully automated CI/CD pipeline with caching, strict validation, Git LFS for large AVIF assets, custom domains, and preview deployments.

---

## Why GitHub Pages for MkDocs Material

GitHub Pages is the natural home for MkDocs-based documentation sites. It is free, integrates directly with your repository, and requires zero infrastructure management. For a pure-CSS static site like this parallax demo, there is no server-side logic to worry about — you build once and serve the output forever from GitHub's global CDN.

Key reasons to choose GitHub Pages for this project:

- **Zero cost.** Public repositories get GitHub Pages for free with no bandwidth limits beyond GitHub's fair-use policy.
- **Native git integration.** Your source and deployment live in the same repository. No external tokens or third-party accounts required.
- **HTTPS by default.** GitHub automatically provisions and renews TLS certificates via Let's Encrypt for both the `github.io` subdomain and custom domains.
- **Automatic invalidation.** Every push to the `gh-pages` branch invalidates the CDN cache for changed files.
- **GitHub Actions ecosystem.** The same workflow system you use for testing can drive your deploys, giving you concurrency controls, environment secrets, and deployment protection rules.

The one caveat worth noting upfront: GitHub Pages serves assets from a path-prefixed URL (`username.github.io/repo-name/`) unless you use a custom domain. This affects how MkDocs resolves internal links, which is why setting `site_url` in `mkdocs.yml` is non-negotiable.

---

## Two Deployment Methods

### Method 1: `mkdocs gh-deploy` (Quick and Simple)

The `mkdocs gh-deploy` command is a one-liner that builds your site and force-pushes the output to the `gh-pages` branch of your repository. It is the fastest path from zero to live.

```bash
# Install dependencies
pip install -r requirements.txt

# Build and deploy in one step
mkdocs gh-deploy --force
```

What this command does under the hood:

1. Runs `mkdocs build` to generate the static site into `_site/`.
2. Initializes a temporary git repo inside `_site/`.
3. Commits all generated files with the message `Deployed <commit-sha> to GitHub Pages`.
4. Force-pushes to the `gh-pages` branch of the `origin` remote.

The `--force` flag is required because the `gh-pages` branch history is intentionally kept flat — each deploy replaces the previous one entirely. Without `--force`, the push would fail if the branch already exists.

**When to use this method:**

- Local development previews before opening a PR.
- Projects where a single maintainer owns all deploys.
- Repositories where you have not yet set up GitHub Actions.

**Limitations:**

- Deploys happen from your local machine, meaning they depend on your local Python environment and credentials.
- No audit trail of who deployed what and when.
- No ability to gate deploys on passing tests.
- If two contributors run `gh-deploy` simultaneously, one will overwrite the other.

For a shared project, graduate to Method 2 as soon as possible.

---

### Method 2: GitHub Actions (Recommended)

GitHub Actions automates the build and deploy on every push to `main`. This is the production-grade approach used by the PAI docs site at docs.pai.direct.

The workflow lives at `.github/workflows/deploy.yml` in your repository.

#### Repository Settings: Enabling Pages

Before the workflow can deploy, you need to enable GitHub Pages in your repository settings:

1. Go to **Settings > Pages** in your repository.
2. Under **Source**, select **GitHub Actions** (not the legacy "Deploy from a branch" option).
3. Save. GitHub will now expect a workflow to control deployments rather than watching the `gh-pages` branch directly.

Selecting "GitHub Actions" as the source is critical. If you leave it set to "Deploy from a branch," the OIDC-based permissions in the workflow will not work, and deploys will fail with a `403 Forbidden` error.

#### The Complete Workflow File

```yaml
# .github/workflows/deploy.yml
#
# Builds the MkDocs Material site and deploys it to GitHub Pages
# on every push to main. Uses OIDC-based authentication — no PAT required.

name: Deploy MkDocs to GitHub Pages

on:
  push:
    branches:
      - main          # Run on every push to main
  workflow_dispatch:  # Allow manual triggers from the Actions tab

# Grant only the permissions this workflow actually needs.
# The principle of least privilege: don't give write access to everything.
permissions:
  contents: read      # Read the repository source code
  pages: write        # Write to GitHub Pages (required for deploy)
  id-token: write     # Mint an OIDC token for the Pages deploy action

# Prevent two deploys from running at the same time.
# If a new push comes in while a deploy is in progress, cancel the
# in-progress deploy and start fresh with the latest commit.
concurrency:
  group: "pages"
  cancel-in-progress: true

jobs:
  build:
    name: Build MkDocs Site
    runs-on: ubuntu-latest
    steps:
      # Step 1: Check out the repository code.
      # fetch-depth: 0 fetches full history, which MkDocs uses to populate
      # the "Last updated" date on each page if you enable git-revision-date.
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      # Step 2: Set up Python.
      # Pin the version explicitly — floating "latest" causes surprise breakage
      # when GitHub upgrades the runner's default Python version.
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          # Cache pip's download cache between runs.
          # The cache key includes the hash of requirements.txt, so a new
          # dependency causes a fresh download, but unchanged deps are reused.
          cache: "pip"
          cache-dependency-path: requirements.txt

      # Step 3: Install MkDocs Material and all plugins.
      - name: Install dependencies
        run: pip install -r requirements.txt

      # Step 4: Configure the GitHub Pages environment.
      # This action reads your repository's Pages settings and exports
      # the base_url as an environment variable used by the deploy step.
      - name: Configure GitHub Pages
        uses: actions/configure-pages@v4

      # Step 5: Build the site.
      # --strict promotes MkDocs warnings to errors.
      # Remove --strict if your site has known warnings you haven't fixed yet.
      - name: Build site
        run: mkdocs build --strict
        env:
          # Makes the build reproducible across runs
          SOURCE_DATE_EPOCH: ${{ github.event.repository.updated_at }}

      # Step 6: Upload the built site as a Pages artifact.
      # The upload-pages-artifact action handles packaging _site/ into
      # the format that the deploy-pages action expects.
      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: _site/   # MkDocs build output directory

  deploy:
    name: Deploy to GitHub Pages
    # Only run the deploy job after the build job succeeds.
    needs: build
    runs-on: ubuntu-latest
    # Associate this job with the "github-pages" environment.
    # This enables deployment protection rules and the "Environments" UI
    # in your repository's Actions tab.
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

#### Understanding the `permissions` Block

The `permissions` block at the top of the workflow is essential and often misunderstood. GitHub Actions workflows run with a default token (`GITHUB_TOKEN`) whose permissions vary by repository and organization settings. Explicitly declaring only the permissions you need is a security best practice — it ensures that a compromised workflow step cannot, for example, push commits to your repository.

- `contents: read` — Allows `actions/checkout@v4` to clone the repository.
- `pages: write` — Allows `actions/deploy-pages@v4` to publish to GitHub Pages.
- `id-token: write` — Allows the workflow to request an OIDC token from GitHub's identity provider. This is the mechanism that lets `deploy-pages` prove to GitHub that it has the right to deploy, without needing a stored Personal Access Token (PAT).

If you omit `id-token: write`, the deploy step will fail with `Error: HttpError: Resource not accessible by integration`.

#### Understanding Concurrency

The `concurrency` block prevents race conditions when multiple commits land on `main` in quick succession:

```yaml
concurrency:
  group: "pages"
  cancel-in-progress: true
```

Without this, two deploys could run in parallel. Because the deploy step atomically replaces the entire Pages content, the last-to-finish deploy wins — but the "winner" may be the deploy for an older commit, meaning a newer commit's changes get overwritten. The concurrency block prevents this by canceling the older in-progress run when a newer one starts.

---

## Setting `site_url` in `mkdocs.yml`

MkDocs uses `site_url` to construct absolute URLs for the sitemap, canonical link tags, and navigation. Without it, relative links break when your site is served from a subpath.

For a repository named `scroll-zoom-thing` owned by `nirholas`, the GitHub Pages URL is:

```
https://nirholas.github.io/scroll-zoom-thing/
```

Set this in `mkdocs.yml`:

```yaml
site_name: CSS 3D Parallax Scrolling
site_url: https://nirholas.github.io/scroll-zoom-thing/

# If you have a custom domain (see below), use that instead:
# site_url: https://docs.example.com/
```

If `site_url` ends without a trailing slash, MkDocs adds one automatically. Include it explicitly to be unambiguous.

---

## The `--strict` Flag: What It Catches

Running `mkdocs build --strict` promotes all MkDocs warnings to build errors, causing the workflow to fail (non-zero exit code) if any of these problems exist:

- **Missing pages** — A page referenced in `nav:` that has no corresponding `.md` file.
- **Broken internal links** — A `[link](other-page.md)` that points to a file that does not exist.
- **Missing navigation entries** — A `.md` file in `docs/` that is not listed under `nav:`.
- **Plugin configuration errors** — A plugin that emits a warning about its own configuration.

For a parallax demo site, the most common `--strict` failure is a broken link to an asset file. AVIF images referenced in HTML templates with a hardcoded path will not be checked by MkDocs's link validator (it only checks Markdown links), but missing `.md` cross-references will be caught.

**Recommendation:** Use `--strict` in CI but not locally during development. This way, in-progress drafts do not block your local build loop, but nothing broken ships to production.

---

## AVIF Files in Git: Size Considerations and Git LFS

The parallax hero effect uses multiple AVIF image layers stored in `docs/assets/hero/`. AVIF is an efficient format, but layered hero images can still reach several hundred kilobytes to a few megabytes each. When these files live in plain git history, every clone of the repository downloads every version of every binary ever committed — even deleted ones.

### Plain Git (Simple, Works Fine for Small Files)

If your AVIF files are each under ~1 MB and you do not expect to iterate on them frequently, plain git is acceptable. GitHub has a hard limit of 100 MB per file and a soft warning at 50 MB. For files well under those thresholds, the simplicity of plain git outweighs the overhead.

```bash
# Just add and commit as normal
git add docs/assets/hero/
git commit -m "feat: add parallax hero layers"
```

### Git LFS (For Large or Frequently-Changed Binaries)

If your AVIF layers are large or you plan to update them regularly, use Git LFS (Large File Storage). Git LFS stores binary content on a separate server and replaces the actual file in git history with a small pointer file.

```bash
# Install Git LFS (once per machine)
git lfs install

# Track all AVIF files in this repository
git lfs track "*.avif"

# This creates or updates .gitattributes — commit it
git add .gitattributes
git commit -m "chore: track AVIF files with Git LFS"

# Now add your AVIF files normally
git add docs/assets/hero/
git commit -m "feat: add parallax hero AVIF layers"
```

**Important:** GitHub Actions runners have Git LFS support built in. The `actions/checkout@v4` step automatically pulls LFS objects when the repository uses LFS. No extra configuration is needed in the workflow.

**Pros of Git LFS:**
- Repository clone size stays small.
- No risk of hitting GitHub's 100 MB file limit.
- Bandwidth charges apply only to actual downloads, not to every clone.

**Cons of Git LFS:**
- GitHub's free tier includes 1 GB of LFS storage and 1 GB of bandwidth per month. Exceeding this requires a paid data pack.
- Contributors need Git LFS installed locally.
- Some git operations (e.g., `git log -p`) show pointer files instead of diffs.

For the parallax demo site, the recommendation is: start with plain git, switch to LFS if the total size of `docs/assets/hero/` exceeds 10 MB.

---

## Custom Domain Setup

### Step 1: Add the CNAME File

MkDocs copies everything in `docs/` into `_site/` during the build. GitHub Pages looks for a `CNAME` file at the root of the deployed site to identify the custom domain.

Create `docs/CNAME` (no file extension) with exactly one line — your custom domain, no protocol prefix:

```
docs.example.com
```

Commit this file:

```bash
git add docs/CNAME
git commit -m "feat: add custom domain CNAME"
```

Do not add `CNAME` to `.gitignore`. It must be committed and deployed with every build.

### Step 2: DNS Configuration

At your DNS provider, add a CNAME record:

| Type  | Host             | Value                          | TTL  |
|-------|------------------|--------------------------------|------|
| CNAME | docs             | nirholas.github.io.            | 3600 |

The trailing dot in `nirholas.github.io.` is standard DNS notation — include it if your DNS provider requires it.

If you are using an apex domain (e.g., `example.com` without a subdomain), you cannot use a CNAME record. Instead, add four A records pointing to GitHub Pages' IP addresses:

```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

DNS changes propagate within minutes to hours depending on TTL. GitHub Pages will not activate HTTPS on your custom domain until DNS is verified.

### Step 3: Enable HTTPS in GitHub Pages Settings

Once DNS propagates:

1. Go to **Settings > Pages** in your repository.
2. Under **Custom domain**, enter your domain and click **Save**.
3. Check **Enforce HTTPS** once the certificate has been provisioned (this takes a few minutes after DNS verification).

### Step 4: Update `site_url` in `mkdocs.yml`

```yaml
site_url: https://docs.example.com/
```

Commit and push. The next workflow run will deploy with correct canonical URLs.

---

## Preview Deployments for Pull Requests

The workflow above deploys only on pushes to `main`. For a team workflow, you may want preview deployments for pull requests so reviewers can see the rendered site before merging.

GitHub Pages itself does not support multiple simultaneous deployments to different URLs. The workaround used by many teams is to deploy to a separate repository (or a separate branch with a path prefix). A simpler alternative is to use Vercel or Cloudflare Pages for preview deployments (see their respective guides) while keeping GitHub Pages as the production host.

If you want previews within GitHub Pages, one approach is to maintain a `previews/` path structure on the `gh-pages` branch:

```yaml
# Add this job to deploy.yml, triggered only on pull requests
  preview:
    name: Deploy PR Preview
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    needs: build
    permissions:
      contents: write
      pull-requests: write
    steps:
      - name: Checkout gh-pages branch
        uses: actions/checkout@v4
        with:
          ref: gh-pages

      - name: Copy PR build into preview path
        run: |
          mkdir -p previews/pr-${{ github.event.number }}
          # (expand Pages artifact here)

      - name: Commit preview
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add previews/
          git commit -m "preview: PR ${{ github.event.number }}"
          git push
```

This approach adds complexity. For most projects, a simpler solution is to use Vercel for previews (see `vercel.md`).

---

## Build Time Optimization: Caching pip Dependencies

The `actions/setup-python@v5` step handles pip caching automatically when you specify `cache: "pip"` and `cache-dependency-path`. On a cache hit, pip skips downloading packages that are already in the runner's cache, reducing install time from ~30 seconds to ~5 seconds for a typical MkDocs Material install.

The cache key is derived from:
- The runner's operating system.
- The Python version.
- The hash of `requirements.txt`.

When you update `requirements.txt` (adding a new plugin, bumping a version), the hash changes and the cache is invalidated. The next run downloads fresh packages and seeds a new cache entry.

For repositories with many MkDocs plugins, explicitly pinning versions in `requirements.txt` (using `==` instead of `>=`) makes cache hits more reliable, since floating version specifiers may resolve to different packages across runs even with the same `requirements.txt` hash.

```
# requirements.txt — pin for reliable caching
mkdocs-material==9.5.18
mkdocs-minify-plugin==0.8.0
```

---

## Real-World Example: docs.pai.direct

The PAI documentation site at docs.pai.direct is built on MkDocs Material and deployed using this exact GitHub Actions pattern. The workflow runs on every push to `main`, uses `actions/setup-python` with pip caching, builds with `--strict`, and deploys via `actions/deploy-pages`. Custom domain CNAME is committed to `docs/CNAME`, and `site_url` in `mkdocs.yml` is set to `https://docs.pai.direct/`. AVIF hero assets are stored in plain git (each under 500 KB) and copied into `_site/assets/hero/` by the MkDocs build.

---

## Troubleshooting

### 404 on Assets After Deploy

GitHub Pages is case-sensitive. If your HTML references `Hero-Layer-01.avif` but the file is committed as `hero-layer-01.avif`, the link will work on macOS (case-insensitive filesystem) but return 404 on GitHub Pages.

Fix: standardize all asset filenames to lowercase. Audit with:

```bash
find docs/assets -name "*.avif" | sort
```

Compare the output against all `src` and `href` attributes in your HTML templates.

### Parallax Layers Not Loading

Open the browser's Network tab (F12) and filter by `avif`. If the requests are returning 404, the issue is almost always one of:
1. A path case mismatch (see above).
2. The `site_url` in `mkdocs.yml` does not match the deployed URL, causing absolute URLs to be wrong.
3. The files were not committed (check `git status` in your local repo).

### `gh-pages` Branch Confusion

If you previously used `mkdocs gh-deploy` and have now switched to GitHub Actions with the "GitHub Actions" source in Pages settings, the `gh-pages` branch is no longer used. You can delete it to avoid confusion:

```bash
git push origin --delete gh-pages
```

The new workflow writes to Pages storage directly via the OIDC-authenticated `deploy-pages` action — it does not touch any branch.

### Workflow Fails with "Resource not accessible by integration"

This error means the workflow token does not have `pages: write` permission. Ensure:
1. The `permissions` block in the workflow file includes `pages: write` and `id-token: write`.
2. The GitHub Pages source is set to "GitHub Actions" (not "Deploy from a branch") in repository settings.

### Build Fails with `--strict` But Works Locally

Run `mkdocs build --strict` locally to reproduce the error. Common causes:
- A broken internal Markdown link created during a recent edit.
- A page listed in `nav:` that has a typo in the filename.
- A plugin emitting a deprecation warning that `--strict` promotes to an error.

---

## Quick Reference

```bash
# One-command local deploy (no CI)
pip install -r requirements.txt && mkdocs gh-deploy --force

# Build locally without deploying (to check for errors)
mkdocs build --strict

# Track AVIF files with Git LFS
git lfs track "*.avif" && git add .gitattributes && git commit -m "chore: lfs track avif"

# Delete the legacy gh-pages branch after switching to Actions
git push origin --delete gh-pages
```

Key files:
- `.github/workflows/deploy.yml` — The Actions workflow.
- `docs/CNAME` — Custom domain name (no protocol).
- `mkdocs.yml` — Must set `site_url` to the deployed URL.
- `requirements.txt` — Pin versions for reliable caching.
