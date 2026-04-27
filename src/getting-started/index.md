---
title: Getting started
description: Three paths to ship scroll-zoom-thing - one-click deploy, GitHub template, or integrate into an existing MkDocs site.
---

# Getting started

There are three ways to get scroll-zoom-thing running. Pick the one that
matches what you already have.

## Path 1: Deploy in one click

The fastest path. You click a button on the README, the host (Vercel,
Cloudflare Pages, or GitHub Pages via Actions) forks the repository into
your account, runs `mkdocs build`, and serves the result on a generated URL.
You can edit the hero copy and swap the AVIF layers without ever touching a
local development environment - GitHub's web editor is enough.

This is the right choice if:

- You want a live preview URL inside an hour.
- You are comfortable editing files directly on GitHub.
- You do not need to run plugins that require a local Python environment to
  experiment with.

Continue with [Quickstart](quickstart.md) for the click-by-click walkthrough,
including which deploy targets work out of the box and what to edit first.

## Path 2: Use as a GitHub template

GitHub's "Use this template" button creates a fresh repository under your
account with no fork relationship to the upstream. This is the cleanest
option if you plan to maintain scroll-zoom-thing as your project rather than
as a tracked fork. You get a clean commit history starting at your initial
commit, and pull requests you open against the upstream are explicit rather
than accidental.

This is the right choice if:

- You want to own the repository outright.
- You plan to diverge significantly from the upstream template.
- You want to invite collaborators without exposing the upstream fork
  relationship.

The walkthrough is in [Use as a template](use-as-template.md). It covers the
"Use this template" flow, the difference between forking and cloning, and
the three files you should edit first - `overrides/home.html`, `src/index.md`,
and `mkdocs.yml`.

## Path 3: Integrate into an existing site

If you already run an MkDocs Material site and you want to bolt the parallax
hero onto your existing landing page, you do not need to start from scratch.
The hero is contained in three places:

- `overrides/home.html` - the Jinja2 template that renders the hero markup.
- `src/assets/stylesheets/home.css` - the CSS that drives the perspective and
  layer transforms.
- The four AVIF assets in `src/assets/`.

You can copy these into your existing project, add the stylesheet to your
`extra_css` list in `mkdocs.yml`, point your home page at the override with
`template: home.html` front matter, and run `mkdocs serve` to see the result.
This path requires more familiarity with how MkDocs Material's `custom_dir`
overrides work, but it lets you keep your existing navigation, plugins, and
content untouched.

The walkthrough is in [Local development](local-development.md), which also
covers the Python virtual environment setup and the day-to-day commands
you will use - `mkdocs serve` for hot reload, `mkdocs build` for a
production bundle, and a few debugging tricks for when the parallax does
not look right.

## Which path should you pick

```
                                  +---------------------+
  Want a URL today?  -- yes -->   | Quickstart          |
                                  | (one-click deploy)  |
                                  +---------------------+
            |
            no
            v
                                  +---------------------+
  New repo from scratch? -- yes ->| Use as a template   |
                                  +---------------------+
            |
            no
            v
                                  +---------------------+
  Existing MkDocs site?     ----> | Local development   |
                                  | (integrate)         |
                                  +---------------------+
```

If you are unsure, start with [Quickstart](quickstart.md). The deploy flow
takes about ten minutes and gives you a working baseline you can then move
local if you want.

A note on prerequisites: paths 1 and 2 require only a GitHub account. Path 3
requires Python 3.9 or later and `pip`. None of the paths require Node.js,
because there is no JavaScript bundle to compile.
