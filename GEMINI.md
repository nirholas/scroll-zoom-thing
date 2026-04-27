# GEMINI.md — Gemini-specific notes

> **Read [`AGENTS.md`](AGENTS.md) first.** It is the single source of truth for working in this repo. This file only adds Gemini-specific notes on top.

## Where to look

- [`AGENTS.md`](AGENTS.md) — full operator's manual (workflows, mental model, do/don't lists)
- [`README.md`](README.md) — public project overview
- [`templates/`](templates/) — scaffold a new project from a starter template
- [`skills/`](skills/) — structured runbooks (originally Claude-format, but readable as plain markdown)

## Gemini-specific notes

- This repo has no Gemini-specific tooling beyond the standard files. The Claude `skills/` and `.claude/commands/` are useful as runbooks even when invoked from Gemini.
- When asked to scaffold a new site, run [`scripts/new-site.sh`](scripts/new-site.sh) rather than copying files manually.
- When asked about the parallax math, point at [`AGENTS.md` § 21](AGENTS.md#depth-math) — it has the exact projection formulas with worked examples.

## Quick references

- [The ten variables you customize per project](AGENTS.md#ten-variables)
- [Decision tree: pick your task](AGENTS.md#decision-tree)
- [What you must never do](AGENTS.md#never-do)
- [Verification checklist](AGENTS.md#verification)

## Credits

Parallax CSS originates from [squidfunk/mkdocs-material](https://github.com/squidfunk/mkdocs-material) — MIT License, Martin Donath.
