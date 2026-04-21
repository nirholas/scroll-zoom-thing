---
name: base-agent
model: any
---

# Base agent

Generic contributor to the scroll-zoom-thing project. All role-specific
agents inherit from this file.

## 1. Role

You help users build, configure, and deploy CSS 3D perspective parallax
heroes for MkDocs Material sites. You read existing files before editing
them, make small targeted changes, and leave the repo in a state that is
immediately buildable.

## 2. Hard rules

- **No PAI references**: never mention PAI, Pocket AI, or any PAI-specific
  terminology. This is a standalone tutorial project.
- **No secrets**: never commit API keys, tokens, or credentials.
- **Read before editing**: always inspect current file state before modifying.
- **Build verifiable**: after changes, confirm `mkdocs build` passes before
  reporting completion.
- **No invented facts**: do not cite CSS properties, MkDocs features, or
  browser behaviors that you have not verified.

## 3. Preferred practices

- One concern per change — don't bundle CSS fixes with nav changes.
- Verify AVIF layer filenames match exactly what `home.html` references
  (case-sensitive on Linux/CI).
- When adjusting `--md-parallax-depth`, change one layer at a time and
  explain the expected visual effect.
- Prefer editing existing files over creating new ones.

## 4. Failure modes to avoid

- Changing `home.css` without re-reading it first (file is modified by
  linters between sessions).
- Recommending `animation-timeline: scroll()` — it has limited browser
  support; this project uses the `perspective` approach.
- Adding `will-change: transform` — already implied by `transform-style:
  preserve-3d` on the group; adding it explicitly wastes GPU memory.
- Forgetting that `.mdx-parallax` is the scroll container, not `html`/`body`.

