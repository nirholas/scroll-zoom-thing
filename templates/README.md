# Templates

Pre-built starter directories for scaffolding new sites from `scroll-zoom-thing`.

## Choose a template

| Template | Use when... | Avoid when... |
|---|---|---|
| [`minimal`](minimal/) | Single-page landing, simple project, ≤ 5 docs pages | You want pillars or intro cards (start with `marketing-hero`) |
| [`marketing-hero`](marketing-hero/) | Product/SaaS docs with marketing-flavored home | You want a "docs first" feel without marketing |
| [`product-docs`](product-docs/) | Deep technical docs (dozens of pages) | You don't need a hero — use upstream Material directly |

## Scaffold a new project

From the repo root:

```bash
./scripts/new-site.sh my-project minimal
cd ../my-project
mkdocs serve
```

The script:

1. Copies `templates/<name>/` to `../<my-project>/`.
2. Prompts you for the ten variables (site name, URL, headline, etc.).
3. Substitutes `{{VAR}}` placeholders with your answers.
4. Initializes a fresh git repo.
5. Prints next steps.

## What's in a template

Each template has the same shape as the root repo, just smaller:

```
templates/<name>/
├── README.md            # template-specific docs ("use when...", "avoid when...")
├── mkdocs.yml           # site config with {{PLACEHOLDERS}}
├── overrides/
│   └── home.html        # Jinja hero with {{PLACEHOLDERS}}
└── src/
    ├── index.md
    ├── ... starter content ...
    └── assets/
        ├── hero/        # placeholder AVIFs (replace with your artwork)
        └── stylesheets/
            └── home.css # parallax engine — copied verbatim
```

Templates **do not** ship with deploy configs (`vercel.json`, `netlify.toml`, etc.) by default — the scaffolding script copies those from the repo root if requested.

## Placeholder syntax

Templates use `{{UPPER_SNAKE_CASE}}` placeholders. The scaffolder replaces them via `sed`. Available placeholders:

| Placeholder | Replaces |
|---|---|
| `{{SITE_NAME}}` | `mkdocs.yml` `site_name` |
| `{{SITE_DESCRIPTION}}` | `mkdocs.yml` `site_description` |
| `{{SITE_URL}}` | `mkdocs.yml` `site_url` |
| `{{REPO_URL}}` | `mkdocs.yml` `repo_url` |
| `{{REPO_NAME}}` | `mkdocs.yml` `repo_name` |
| `{{HERO_HEADLINE}}` | `overrides/home.html` H1 |
| `{{HERO_SUBHEAD}}` | `overrides/home.html` paragraph |
| `{{PRIMARY_CTA_LABEL}}` | Primary button text |
| `{{PRIMARY_CTA_HREF}}` | Primary button target (relative URL) |
| `{{SECONDARY_CTA_LABEL}}` | Secondary button text |
| `{{SECONDARY_CTA_HREF}}` | Secondary button target |
| `{{PRIMARY_COLOR}}` | Brand primary hex (e.g. `#0e7c66`) |
| `{{ACCENT_COLOR}}` | Brand accent hex |

The scaffolder prompts for each one. You can also set them via env vars or pass a `.env` file.

## Don't use templates as god-files

Each template is a **starting point**. Once you scaffold, the new project owns its shape. Add sections, delete pages, restructure as needed for the project at hand. The template's README documents the *original* shape; the scaffolded project documents itself.

## Adding a new template

1. `cp -r templates/minimal templates/my-template`
2. Modify the structure (add sections, remove sections, change defaults).
3. Update `templates/my-template/README.md` to document "use when / avoid when".
4. Add an entry to the table at the top of this file.
5. Add to the choices in `scripts/new-site.sh`.

The right time to add a template is when you've built three projects from the closest existing one and made the same structural change every time. Don't pre-emptively add templates for hypothetical use cases.
