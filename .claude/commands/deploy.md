Deploy the MkDocs site to GitHub Pages.

1. Check that `.github/workflows/deploy.yml` exists — if not, write it using the template in `docs/github-pages.md`.
2. Run `mkdocs build --strict` and confirm it passes.
3. Check that `site_url` in `mkdocs.yml` matches the repo's GitHub Pages URL.
4. Confirm `docs/assets/hero/*.avif` files are committed (not gitignored).
5. Show the git status of any uncommitted changes and ask before committing.
6. Report the GitHub Pages URL after push.