---
title: Contributing
description: How to open issues, submit pull requests, and follow the project's code-style conventions.
---

# Contributing

Thanks for considering a contribution. This page describes how the project handles issues and pull requests, the code style we use, and how the project's CLAUDE.md guidelines apply if you are using an AI assistant to help with your change.

If you have not yet built the site locally, start with [local-setup.md](local-setup.md). The notes below assume you can run `mkdocs serve` and `mkdocs build --strict` successfully.

## Opening an issue

Open an issue before opening a pull request, except for the smallest fixes. The issue gives a maintainer a chance to flag duplicates, point you at related work, or suggest a different approach before you spend effort on a PR.

A useful issue includes:

- A one-line summary in the title.
- The version of the template you are running (commit SHA is fine).
- The version of MkDocs and MkDocs Material (`pip freeze | grep -i mkdocs`).
- The browser and OS if the issue is visual.
- A minimal reproduction. For build errors, the full stack trace. For visual bugs, a screenshot or screen recording.

For feature requests, describe the use case before describing the proposed feature. "I'm trying to do X, and I cannot do it because Y" is more useful than "please add Z".

## The pull request process

The expected flow is:

1. Fork the repository and create a branch off `main`.
2. Make your change in small, focused commits.
3. Run `mkdocs build --strict` and verify it produces no warnings.
4. Run the site locally and verify the change visually.
5. Open a PR. Reference the issue you are addressing in the PR description.
6. Wait for review. Maintainers will usually respond within a week.
7. Address review comments by pushing additional commits to the same branch (do not force-push during review unless asked).
8. Once approved, a maintainer will squash-merge the PR.

PR descriptions should include a "How to verify" section: a short list of steps a reviewer can run to confirm the change works. For visual changes, include before/after screenshots.

## Scope discipline

The project values surgical changes. From the project's CLAUDE.md:

> Touch only what you must. Clean up only your own mess. Don't "improve" adjacent code, comments, or formatting. Don't refactor things that aren't broken. Match existing style, even if you'd do it differently.

Pull requests that bundle a fix with a stylistic refactor are usually asked to split. Pull requests that rename existing files or restructure directories without prior discussion will usually be declined. If you spot something you think should be refactored, open an issue first.

## Code style

The project does not use a formatter beyond the defaults of the languages involved. The conventions are:

### Markdown

- Sentence-case headings.
- One sentence per line is acceptable but not required; the editor's default wrap is fine.
- Internal links use relative paths with the `.md` extension: `[text](relative/path.md)`. MkDocs rewrites these correctly.
- Code blocks specify a language for syntax highlighting (` ```yaml`, ` ```css`, ` ```bash`).

### CSS

- Two-space indentation.
- Custom properties prefixed with `--` and grouped at the top of the rule when reasonable.
- Media queries follow their related rules rather than living in a separate file.
- Avoid `!important` unless overriding MkDocs Material defaults that would otherwise win.

### Python

- The repo has very little Python. What there is follows PEP 8.
- Run `python -m compileall` over any new script to catch syntax errors.

### YAML

- Two-space indentation.
- Quote strings only when needed (when they contain special characters or could be misparsed as a different type).

## CLAUDE.md and AI-assisted contributions

The repo includes a `CLAUDE.md` file that codifies behavioural guidelines for AI coding assistants. The four points it makes are:

1. **Think before coding.** State assumptions, surface tradeoffs, ask when uncertain.
2. **Simplicity first.** Minimum code that solves the problem. No speculative abstractions.
3. **Surgical changes.** Touch only what you must. Match existing style.
4. **Goal-driven execution.** Define success criteria. Verify before declaring done.

If you are using Claude, Cursor, Copilot, or another assistant to help with a contribution, those guidelines apply to your PR even though they are written for the assistant. Reviewers are likely to ask "why is this change here?" about lines that do not trace to the issue you are fixing. Pre-empting that question by keeping the diff narrow makes review faster.

When AI assistance was substantial, mention it in the PR description. We do not require AI-disclosure, but it helps reviewers calibrate.

## Testing your change

The project's testing posture is described in the [Development landing page](index.md). The short version:

- `mkdocs build --strict` must pass.
- The site must load and look correct in `mkdocs serve`.
- Reduced-motion behaviour on the hero must still work.
- Lighthouse scores for the homepage must not regress on changes that touch the hero.

For changes that affect the parallax CSS, test on at least two browsers (Chromium-family and Firefox at minimum). Safari has its own quirks with `transform: translateZ` and is worth a third pass if you have access.

## What gets merged quickly

Changes that tend to merge fast:

- Typo and grammar fixes in the docs.
- Clear bug fixes with a reproduction in the linked issue.
- New layer images contributed under the project's existing licence.
- Improvements to the deployment guides (the [GitHub Pages](../deploy/github-pages.md), [Vercel](../deploy/vercel.md), and [Cloudflare](../deploy/cloudflare.md) pages, plus the Netlify and Railway pages).

## What gets pushed back

Changes that tend to bounce in review:

- Large refactors without a prior issue.
- Adding a JavaScript dependency to the runtime.
- Restructuring the directory layout.
- Replacing the parallax CSS with a JS-driven implementation.
- Adding analytics, telemetry, or fonts loaded from a third-party origin.

If your change falls into one of those categories, open an issue first and we can discuss whether there is a path forward.

## Licence

By contributing, you agree your contribution is licensed under the same terms as the project itself. Check the `LICENSE` file in the repo for the current licence.
