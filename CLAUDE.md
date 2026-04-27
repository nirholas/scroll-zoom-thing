# CLAUDE.md — Claude Code-specific notes

> **Read [`AGENTS.md`](AGENTS.md) first.** It is the single source of truth for working in this repo. This file only adds Claude-specific notes on top.

## What's in `AGENTS.md`

- 30-second orientation
- Mental model of the parallax
- Files: edit / configure / never touch
- Decision tree for picking a workflow
- Nine workflows (clone, hero copy, artwork, depth tuning, sections, pages, nav, palette, deploy)
- Verification, common mistakes, depth math, browser quirks, performance, accessibility, security
- Glossary, pointers, file-tree walkthrough

If the user asks you to do anything in this repo, jump to `AGENTS.md` and find the matching workflow before improvising.

## Claude-specific tooling

This repo ships skills and slash commands that automate common workflows. Use them when applicable.

### Skills

| Skill | Path | Use when |
|---|---|---|
| `setup-parallax` | [`skills/setup-parallax/SKILL.md`](skills/setup-parallax/SKILL.md) | Scaffolding the parallax for a new site |
| `tune-layers` | [`skills/tune-layers/SKILL.md`](skills/tune-layers/SKILL.md) | User reports a visual problem with the depth effect |
| `convert-images` | [`skills/convert-images/SKILL.md`](skills/convert-images/SKILL.md) | PNG→AVIF pipeline |
| `generate-prompts` | [`skills/generate-prompts/SKILL.md`](skills/generate-prompts/SKILL.md) | AI image prompts for hero artwork |

Each skill's frontmatter declares `inputs`, `outputs`, `triggers`, and `constraints`. Honor the constraints; they exist because past agents made each mistake.

### Slash commands

| Command | Maps to |
|---|---|
| `/setup-parallax` | `setup-parallax` skill |
| `/tune-layers` | `tune-layers` skill |
| `/convert-images` | `convert-images` skill |
| `/generate-prompts` | `generate-prompts` skill |
| `/deploy` | Walks Workflow I (deploy targets) in AGENTS.md |

### Templates

[`templates/`](templates/) contains pre-built starter directories. Use [`scripts/new-site.sh`](scripts/new-site.sh) to scaffold a new project from a template:

```bash
./scripts/new-site.sh my-project minimal
```

Choices: `minimal`, `marketing-hero`, `product-docs`. See [`templates/README.md`](templates/README.md).

## Claude Code conventions in this repo

- **Use `Read` before `Edit`.** Always. The harness enforces it.
- **Use `Edit` for edits, `Write` only for new files or full rewrites.** Edits cost less context.
- **Run `mkdocs build --strict` before reporting "done"** — it is the test suite.
- **Don't create planning docs (`PLAN.md`, `NOTES.md`) unless the user asks.** Work from conversation context.
- **Don't create new `.md` files speculatively.** Every new file becomes a nav decision.

## Quick references

- [The ten variables you customize per project](AGENTS.md#ten-variables)
- [What you must never do](AGENTS.md#never-do)
- [Common mistakes and their fixes](AGENTS.md#common-mistakes)
- [Verification checklist before shipping](AGENTS.md#verification)

## Credits

Parallax CSS originates from [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) — MIT License, Martin Donath.
