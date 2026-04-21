---
name: setup-parallax
description: Scaffold a complete CSS 3D parallax hero for MkDocs Material from scratch — home.html, home.css, and mkdocs.yml.
version: 0.1.0
triggers:
  - when the user wants to add a parallax hero to their MkDocs site
  - when the user asks to set up the parallax from scratch
  - when the user has AVIF layer files and wants them wired up
inputs:
  - name: hero_headline
    type: string
    required: true
    description: The H1 text shown in the hero
  - name: hero_subtext
    type: string
    required: false
    description: The paragraph text below the headline
  - name: primary_button_label
    type: string
    required: false
    description: Label for the primary CTA button (default "Get started")
  - name: primary_button_href
    type: string
    required: false
    description: URL for the primary button (default "getting-started/")
  - name: layer_files
    type: list
    required: false
    description: List of AVIF filenames in docs/assets/hero/ (agent will detect if not provided)
outputs:
  - docs/overrides/home.html with correct layer <picture> elements
  - docs/assets/stylesheets/home.css with full parallax CSS
  - mkdocs.yml updated with custom_dir and extra_css
constraints:
  - must not overwrite existing home.html without user confirmation
  - layer filenames must match actual files in docs/assets/hero/
  - must run mkdocs build after writing files and confirm no errors
---

# setup-parallax

Scaffold the complete CSS 3D perspective parallax hero for a MkDocs Material site.

## 1. Purpose

Wire up layered AVIF images into a working parallax hero using the exact
CSS 3D perspective approach from squidfunk/mkdocs-material (MIT). No JS
required beyond what the Material theme already ships.

## 2. Instructions

1. **Detect layer files** — if `layer_files` was not provided, list
   `docs/assets/hero/*.avif`. Report what was found and ask the user to
   confirm before proceeding.

2. **Assign depths** — use the following defaults based on filename sort
   order (lowest number = furthest back):

   | Position | Depth | `--md-image-position` |
   |---|---|---|
   | First (far bg) | `8` | `70%` |
   | Second | `5` | `25%` |
   | Third | `2` | `40%` |
   | Fourth (fg) | `1` | `50%` |

   If there are fewer or more than 4 layers, adjust the depth spread evenly.

3. **Write `docs/overrides/home.html`** — use the template:

   ```html
   {% extends "base.html" %}
   {% block tabs %}
     {{ super() }}
     <style>
       .md-header{position:initial}
       .md-main__inner{margin:0}
       .md-content{display:none}
       @media screen and (min-width:60em){.md-sidebar--secondary{display:none}}
       @media screen and (min-width:76.25em){.md-sidebar--primary{display:none}}
     </style>
     <div class="mdx-parallax" data-mdx-component="parallax">
       <section class="mdx-parallax__group" data-md-color-scheme="slate">
         <!-- one <picture> per layer, see home.html in this repo -->
         <div class="mdx-parallax__layer mdx-parallax__blend"></div>
         <div class="mdx-hero" data-mdx-component="hero">
           <div class="mdx-hero__scrollwrap md-grid">
             <div class="mdx-hero__inner">
               <div class="mdx-hero__teaser md-typeset">
                 <h1>{{ hero_headline }}</h1>
                 <p>{{ hero_subtext }}</p>
                 <a href="..." class="md-button md-button--primary">{{ primary_button_label }}</a>
                 <a href="..." class="md-button">Learn more</a>
               </div>
               <div class="mdx-hero__more">
                 <svg ...></svg>
               </div>
             </div>
           </div>
         </div>
       </section>
       <section class="mdx-parallax__group" data-md-color-scheme="slate">
         <div class="md-content md-grid" data-md-component="content">
           <div class="md-content__inner md-typeset">{{ page.content }}</div>
         </div>
       </section>
     </div>
   {% endblock %}
   {% block content %}{% endblock %}
   {% block footer %}{% endblock %}
   ```

4. **Copy `docs/assets/stylesheets/home.css`** from this repo verbatim — do
   not modify the parallax CSS without the user's request.

5. **Update `mkdocs.yml`** — ensure these keys are present:
   ```yaml
   theme:
     custom_dir: docs/overrides
   extra_css:
     - assets/stylesheets/home.css
   ```

6. **Run `mkdocs build`** — report the last 5 lines of output. If errors,
   fix and re-run before reporting success.

## 3. Guardrails

- Do not use `animation-timeline: scroll()` — this repo uses the CSS
  `perspective` + `translateZ` approach.
- The `.mdx-parallax__blend` div must be the last layer before `.mdx-hero`.
- Do not remove `contain: strict` from the first group — it is needed for
  correct clipping.
- Do not add `will-change: transform` to layers — already implied.

## 4. Example session

```
User:  I have 4 AVIF files in docs/assets/hero/ and want to add the parallax.
Agent: Found: 1-landscape@4x.avif, 2-plateau@4x.avif, 5-plants-1@4x.avif,
       6-plants-2@4x.avif. Assigning depths 8, 5, 2, 1. What's your hero headline?
User:  "Ship faster. Think clearer."
Agent: Wrote home.html, home.css, updated mkdocs.yml. mkdocs build: success.
```

## 5. Changelog

- `0.1.0` — Initial skill.
