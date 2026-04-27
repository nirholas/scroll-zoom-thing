---
title: AI in the scroll-zoom-thing workflow
description: How AI tooling fits into building, populating, and maintaining a parallax MkDocs Material site.
---

# AI

scroll-zoom-thing is a pure-CSS template, but the content that fills it is rarely
hand-drawn or hand-written. The four AVIF layers in the parallax hero, the
copy that lives behind it, and the boilerplate of the surrounding documentation
all benefit from AI assistance. This page maps the workflow so you know which
tool to reach for at which step.

## What AI is good for here

The template asks for a small but specific set of artifacts:

- Four PNG or AVIF layers for the hero, each rendered with a transparent
  background and aligned to the same vanishing point.
- Short marketing copy that sits between the hero and the documentation body.
- A consistent visual identity (colors, type, iconography) that survives
  across hero, navigation, and content pages.
- Repetitive doc scaffolding: frontmatter, navigation entries, redirect
  shims, OpenGraph cards.

Each of these is a place where an LLM or an image model saves real time.
None of them are places where AI replaces the editorial judgment that
makes a site feel intentional.

## Two halves of the workflow

The AI surface area in this repo splits into two halves:

1. **Image generation.** Producing the four-layer parallax stack from a
   single concept image, or from scratch. This is the part that most users
   underestimate, because depth-aligned cutouts are harder than they look.
2. **Agent automation.** Letting a coding agent scaffold pages, wire up
   navigation, and adjust CSS variables without you context-switching to
   the editor for every small change.

The two halves rarely overlap. Image work happens in your image tool of
choice; agent work happens in your editor with a CLI like Claude Code or
similar. Treat them as separate phases of the build.

## Generating layers

The hero stack uses depths `8`, `5`, `2`, and `1`. Each depth corresponds
to a layer that needs to be rendered in isolation, with everything in
front of it removed. A typical generation pipeline looks like:

1. Prompt a base image at the target aspect ratio.
2. Segment or re-prompt to isolate the foreground subject.
3. Re-prompt the background with the subject masked out, so parallax
   reveal does not show a hole.
4. Repeat for mid-ground elements at depth 5 and depth 2.
5. Export each layer as AVIF with an alpha channel.

The full walkthrough, including prompt patterns and tool-specific quirks,
lives in [Image generation](image-generation.md).

## Working with coding agents

Once the layers exist, most of the remaining work is configuration:
`mkdocs.yml`, navigation, CSS custom properties, and the `index.md`
that hosts the hero. A coding agent is well-suited to this kind of
mechanical, file-spanning edit.

Patterns that work well:

- Hand the agent the four layer filenames and ask it to wire them into
  the hero partial at the correct depths.
- Ask the agent to generate the section landing pages from a single
  outline, so frontmatter and navigation stay consistent.
- Use the agent for codemod-style changes: rename a CSS variable across
  the project, swap a font, regenerate redirect shims.

Patterns that work poorly:

- Asking the agent to "make the hero look better." Visual judgment is
  not a strength here; specify exact values.
- Asking the agent to invent content. The result tends to be generic
  and needs a full rewrite.
- Long autonomous runs without checkpoints. The CSS in this template
  is small enough that a tight feedback loop is faster than a long one.

The agent-specific guide, including a baseline `CLAUDE.md` for this
repo and example prompts, lives in [Agents](agents.md).

## A reasonable division of labor

A workable rule of thumb:

- **You** decide the concept, the palette, and the information
  architecture.
- **Image AI** produces the four hero layers from your concept.
- **Agent AI** wires those layers into the template and scaffolds the
  pages around them.
- **You** edit the copy that actually matters and ship it.

The template is intentionally small, so any of these steps is possible
to do by hand. AI is a force multiplier, not a prerequisite.

## Where to go next

- [Image generation](image-generation.md) for the layer pipeline.
- [Agents](agents.md) for editor-side automation.
