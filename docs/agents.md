---
title: Automating Parallax Assets with AI Agents
description: How to use AI agents — Claude, GPT-4, local LLMs — to automate parallax layer generation, image processing, MkDocs configuration, and documentation writing.
---

# Automating Parallax Assets with AI Agents

An AI agent can handle the repetitive parts of building a parallax hero: generating consistent image prompts, running image processing pipelines, scaffolding the MkDocs config, and writing documentation. This page covers practical patterns.

---

## What agents are good at here

| Task | Human | Agent |
|---|---|---|
| Writing consistent prompts for each layer | Slow, inconsistent | Fast, anchored to style reference |
| Converting PNG → AVIF in batch | Manual ffmpeg commands | Shell script generation and execution |
| Scaffolding `mkdocs.yml` and overrides | Copy-paste and edit | Generated from description |
| Writing documentation pages | Hours | Minutes with review |
| Tuning `--md-parallax-depth` values | Trial and error | Reasoned suggestion based on scene |

---

## Pattern 1: Prompt generation agent

Give the agent your scene description and let it produce all 4 layer prompts:

```
System: You are an AI image prompt engineer specializing in layered 
parallax assets. Generate prompts that produce images that composite 
cleanly as CSS parallax layers.

User: I want a penthouse office scene at dusk — city skyline visible 
through floor-to-ceiling windows, indoor plants in the foreground.
Generate 4 prompts for layers at depths: far background, mid background,
near midground, foreground. Each must be consistent in lighting and palette.
Output format: layer name, depth value, prompt.
```

The agent produces prompts you can paste directly into ImageFX or Midjourney.

---

## Pattern 2: Image processing pipeline

After downloading your PNGs, an agent (with shell tool access) can run the full processing pipeline:

```python
# Agent-generated pipeline
import subprocess
from pathlib import Path

layers = {
    "1-landscape": {"depth": 8, "position": "70%"},
    "2-plateau":   {"depth": 5, "position": "25%"},
    "5-plants-1":  {"depth": 2, "position": "40%"},
    "6-plants-2":  {"depth": 1, "position": "50%"},
}

for name, meta in layers.items():
    src = Path(f"raw/{name}.png")
    out = Path(f"docs/assets/hero/{name}@4x.avif")
    subprocess.run([
        "cavif", "--quality", "70",
        str(src), "-o", str(out)
    ])
    print(f"{name}: depth={meta['depth']}, position={meta['position']}")
```

---

## Pattern 3: MkDocs scaffold generation

Describe your site to an agent and have it output a complete `mkdocs.yml`, `home.html`, and `home.css`:

```
I want a MkDocs Material site with:
- A CSS 3D parallax hero with 4 AVIF layers
- Slate color scheme, indigo accent
- Navigation tabs
- 3 pages: Home, Docs, Reference
- Custom hero text: "Ship faster. Think clearer."
- Primary button: "Get started" → /getting-started/
- Secondary button: "View docs" → /docs/

Output: mkdocs.yml, docs/overrides/home.html, docs/assets/stylesheets/home.css
```

Review and adjust depth values and `--md-image-position` for your specific images.

---

## Pattern 4: Claude Code (CLI agent)

If you're using [Claude Code](https://claude.ai/code), you can give it the full task in one shot:

```bash
claude "Set up a MkDocs Material site with a CSS 3D parallax hero. 
Use the 4 AVIF files in docs/assets/hero/. Write home.html, home.css, 
and mkdocs.yml. Depths: 1-landscape=8, 2-plateau=5, 5-plants-1=2, 
6-plants-2=1. Hero text: 'Your headline here'. Two buttons: primary 
and secondary. No PAI references."
```

Claude Code can read existing files, write the overrides, run `mkdocs build` to verify, and iterate on CSS issues — all from the terminal.

---

## Pattern 5: Local LLM for iteration

For tuning `--md-parallax-depth` and `--md-image-position` values, a local LLM (via Ollama) works well as a fast iteration partner:

```bash
ollama run llama3.2 "I have a CSS 3D parallax with 4 layers.
Layer 1 (depth 8, far background) looks too fast on scroll — 
barely moves. Layer 4 (depth 1, foreground) barely moves at all.
What depth values should I try? Perspective is 2.5rem."
```

The model understands the `translateZ(perspective * depth * -1) scale(depth + 1)` math and can reason about adjustments.

---

## Recommended agent setup for this project

```
tools the agent should have:
- read/write files
- run shell commands (mkdocs build, cavif, ffmpeg)
- web fetch (to check the live site)

workflow:
1. agent reads existing home.html and home.css
2. agent identifies layer filenames and current depth values
3. agent suggests depth/position adjustments based on image descriptions
4. agent runs mkdocs build and reports any errors
5. human reviews in browser, gives feedback
6. repeat
```

This loop — agent writes, builds, human reviews — converges in 3-5 iterations for most setups.

