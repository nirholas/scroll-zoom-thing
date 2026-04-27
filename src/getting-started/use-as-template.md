---
title: Use as a template
description: Use GitHub's template feature to create a clean repository, choose between forking and cloning, and edit the three files that define your site.
---

# Use as a template

If you want scroll-zoom-thing as the starting point for a project of your
own - rather than a fork that tracks the upstream - GitHub's template
feature is the right tool. This page covers when to template, when to fork,
when to clone, and which three files you should edit first.

## Use this template vs fork vs clone

These three actions look similar in the GitHub UI but produce different
results.

**Use this template** creates a new repository under your account with no
fork relationship to scroll-zoom-thing. The new repo starts with a single
initial commit (or a flattened history, if you choose) and behaves as if
you had created it from scratch. You will not see "forked from" in the
header, and you will not get notifications about upstream activity.

**Fork** creates a copy with a tracked relationship to the upstream. You
can pull future changes from scroll-zoom-thing into your fork, and you can
open pull requests back to the upstream easily. The header shows "forked
from nirholas/scroll-zoom-thing".

**Clone** copies the repository to your local machine. It does not create a
GitHub repo - you would need to create one separately and push to it.

For most users, **Use this template** is the right choice. You are unlikely
to want to merge upstream changes into a heavily-customized site, and a
clean history is easier to reason about.

## Creating a repo from the template

1. Open [github.com/nirholas/scroll-zoom-thing](https://github.com/nirholas/scroll-zoom-thing).
2. Click **Use this template** (top right, next to the Fork button).
3. Choose **Create a new repository**.
4. Pick the owner (you or an organization), give the repository a name, and
   set the visibility (public or private).
5. Leave **Include all branches** unchecked unless you specifically need the
   non-default branches. The default `main` is enough.
6. Click **Create repository**.

GitHub provisions the new repo within a few seconds. You can now clone it
locally if you want to develop against it:

```bash
git clone https://github.com/<you>/<your-repo>.git
cd <your-repo>
```

## The three files to edit first

Once you have your own repo, the changes that have the biggest visual impact
are concentrated in three files.

### `overrides/home.html`

This is the Jinja2 template for the parallax hero. It extends Material's
`base.html` and overrides the `tabs` and `content` blocks to render the
four parallax layers, the headline, the subheading, and the call-to-action
buttons.

The lines you will most often touch:

- The `<h1>` and `<p>` inside the hero.
- The two `<a class="md-button">` elements - their text and their `href`.
- The `style="--md-parallax-depth: ...; --md-image-position: ..."` attributes
  on each layer, if you want to retune the parallax.

A full walkthrough of hero customization lives in
[Hero copy](../guides/hero-copy.md).

### `src/index.md`

This is the home page content. The first line - the front matter - is what
attaches the parallax template to the page:

```yaml
---
title: Home
template: home.html
---
```

The `template:` key tells MkDocs Material to render this page using your
override instead of the default `main.html`. Anything you write below the
front matter appears below the hero in Material's normal content area, so
this is where you put your "below the fold" copy - feature lists, social
proof, secondary call-to-action, and so on.

### `mkdocs.yml`

The site configuration. The lines you will edit on day one:

```yaml
site_name: Your project name
site_url: https://your-domain.example/
site_description: One-line description for SEO and social cards.
repo_url: https://github.com/<you>/<your-repo>
repo_name: <you>/<your-repo>

theme:
  name: material
  custom_dir: overrides
  palette:
    - scheme: default
      primary: indigo
      accent: pink

extra_css:
  - assets/stylesheets/home.css

nav:
  - Home: index.md
  - Overview: overview/index.md
  - Getting started: getting-started/index.md
```

`site_name` appears in the header and the browser tab. `site_url` is used by
MkDocs to generate canonical links and the sitemap. `repo_url` and
`repo_name` populate the "Edit on GitHub" link in the page footer.

For deeper coverage of palette and color customization, see
[Theme](../guides/theme.md). For navigation structure, see
[Pages and nav](../guides/pages-and-nav.md).

## What to do next

You have a repo. You have edited the three high-impact files. There are
two reasonable next steps:

- If you want to iterate locally with hot reload, follow
  [Local development](local-development.md). It covers the Python virtual
  environment, the `mkdocs serve` workflow, and a few debugging tips for
  when the parallax does not render correctly.
- If you would rather edit on GitHub and deploy on every push, return to
  [Quickstart](quickstart.md) and connect your new repo to Vercel,
  Cloudflare Pages, or GitHub Pages.

Either path works. The template does not assume one over the other.
