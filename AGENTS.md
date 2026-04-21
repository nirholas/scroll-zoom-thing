# AGENTS.md

Guidance for AI agents (Claude, Gemini, Codex, etc.) working in this repository.

## Project

**scroll-zoom-thing** — CSS 3D perspective parallax for MkDocs Material. No JavaScript. Pure CSS using `perspective`, `translateZ`, and `scale()`.

## Agent skills

Skills are defined in `skills/` and invoked via `.claude/commands/`. Each skill has its own `SKILL.md` describing inputs, outputs, and usage.

| Skill | Path | Purpose |
|---|---|---|
| setup-parallax | `skills/setup-parallax/` | Scaffold the parallax layer structure |
| generate-prompts | `skills/generate-prompts/` | Generate AI image prompts for parallax layers |
| convert-images | `skills/convert-images/` | Convert images to AVIF at correct sizes |
| tune-layers | `skills/tune-layers/` | Adjust depth and crop variables per layer |

## Key files to understand first

1. `docs/assets/stylesheets/home.css` — all parallax CSS with inline comments
2. `docs/overrides/home.html` — layer template structure
3. `mkdocs.yml` — site configuration

## Conventions

- No JavaScript in the parallax implementation
- Images must be AVIF, named `N-name@4x.avif` where N is the layer number
- Layer depth (`--md-parallax-depth`) decreases front-to-back: `8`, `5`, `2`, `1`
- When editing CSS, preserve the existing comment structure — it is the documentation

## What agents should NOT do

- Add JavaScript to implement scroll effects
- Change the MkDocs theme away from Material
- Add tracking pixels, analytics, or external font calls
- Modify `docs/assets/hero/.gitkeep` — that file keeps the directory in git
