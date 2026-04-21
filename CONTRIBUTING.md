# Contributing to scroll-zoom-thing

Thanks for your interest in contributing.

## What this project is

A minimal, well-documented reference implementation of pure-CSS 3D perspective parallax for MkDocs Material. The goal is clarity over cleverness.

## How to contribute

### Bug reports and feature requests

Open an issue using the templates in `.github/ISSUE_TEMPLATE/`.

### Pull requests

1. Fork the repo
2. Create a branch: `git checkout -b fix/your-thing`
3. Make your changes
4. Test with `mkdocs serve`
5. Open a PR against `main`

### CSS changes

- Preserve the inline comment style — comments are the documentation
- Test in at least Chrome and Firefox before submitting
- Keep `--md-parallax-depth` values consistent with the existing ladder (`8`, `5`, `2`, `1`)

### Documentation

- All docs live in `docs/` and are built with MkDocs Material
- Run `mkdocs serve` to preview locally

### Agent skills

Skills in `skills/` and commands in `.claude/commands/` are welcome contributions. Keep the `SKILL.md` interface spec in sync with any implementation changes.

## Code style

- 2-space indentation
- LF line endings
- No trailing whitespace

## License

By contributing, you agree your contributions will be licensed under the MIT License.
