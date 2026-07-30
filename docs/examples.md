# scroll-zoom-thing examples

The repository is a working production site. The docs you see when you build it are the PAI documentation, included verbatim as a real-world example of the parallax pattern in use. Replace the content in `src/` with your own and you have a cinematic, depth-driven docs site for your own project.

## Example 1

```bash
git clone https://github.com/nirholas/scroll-zoom-thing
cd scroll-zoom-thing
pip install -r requirements.txt
mkdocs serve
```

## Example 2

```bash
mkdocs build
```

## Example 3

```text
scroll-zoom-thing/
├── mkdocs.yml                     # MkDocs config — nav, theme, plugins
├── requirements.txt               # mkdocs-material + extensions
├── .python-version                # Python 3.12 pin (Vercel, Railway, etc.)
├── runtime.txt                    # Python version for Heroku-style platforms
│
├── src/                           # Markdown content (docs_dir)
│   ├── index.md                   # Home page (template: home.html)
│   ├── assets/
│   │   ├── hero/                  # AVIF parallax layers
│   │   │   ├── 1-landscape@4x.avif
│   │   │   ├── 2-plateau@4x.avif
│   │   │   ├── 5-plants-1@4x.avif
│   │   │   └── 6-plants-2@4x.avif
│   │   ├── stylesheets/home.css   # All parallax CSS, heavily commented
│   │   ├── pai-theme.css          # Color theme overrides
│   │   ├── pai-logo-white.svg     # Logo
│   │   └── slideshow/             # Optional carousel images
│   ├── general/, ai/, privacy/    # Doc sections
│   └── … rest of PAI docs
│
├── overrides/                     # MkDocs Material template overrides
│   └── home.html                  # The parallax hero template
│
├── images/                        # Site-level images outside docs_dir
│
├── .github/workflows/deploy.yml   # GitHub Pages CI
├── vercel.json                    # Vercel config
├── netlify.toml                   # Netlify config
├── nixpacks.toml                  # Railway / Nixpacks config
├── wrangler.toml                  # Cloudflare Pages config hint
│
├── skills/                        # Claude Code skills for parallax workflows
│   ├── setup-parallax/            # Scaffolds layer structure and template
│   ├── generate-prompts/          # Creates AI image prompts per layer
│   ├── convert-images/            # Batch converts source images to AVIF
│   └── tune-layers/               # Adjusts depth and crop per layer
├── agents/                        # Agent prompt definitions
└── .claude/commands/              # Claude Code slash commands
```

## Example 4

```bash
pip install mkdocs-material
```

## Example 5

```bash
mkdir -p overrides
mkdir -p docs/assets/hero
mkdir -p docs/assets/stylesheets
```

## Example 6

```text
overrides/home.html                    ← copy of overrides/home.html
docs/assets/stylesheets/home.css       ← copy of src/assets/stylesheets/home.css
```

## Example 7

```bash
mkdocs serve
```

## Example 8

```text
[scene], transparent PNG, panoramic 16:5,
[depth cue: distant horizon only / mid-distance only / foreground plants only],
soft dawn lighting, muted cool palette,
consistent with: [style reference]
```


Every snippet above is taken from the [repository documentation](https://github.com/nirholas/scroll-zoom-thing#readme).
