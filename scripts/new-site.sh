#!/usr/bin/env bash
#
# scripts/new-site.sh — scaffold a new site from a scroll-zoom-thing template.
#
# Usage:
#   ./scripts/new-site.sh <project-name> <template>
#
# <template> is one of:
#   minimal          — bare hero, no pillars, no intro cards
#   marketing-hero   — full PAI-style home (hero + pillars + intro)
#   product-docs     — hero + deep nav, no pillars
#
# Example:
#   ./scripts/new-site.sh my-app minimal
#
# The new project is created at ../<project-name>/ (sibling to this repo).

set -euo pipefail

# ── Args ───────────────────────────────────────────────────────────────────
if [[ $# -lt 2 ]]; then
  echo "usage: $0 <project-name> <template>"
  echo "  template: minimal | marketing-hero | product-docs"
  exit 1
fi

PROJECT_NAME="$1"
TEMPLATE="$2"

case "$TEMPLATE" in
  minimal|marketing-hero|product-docs) ;;
  *)
    echo "error: unknown template '$TEMPLATE'"
    echo "       choices: minimal, marketing-hero, product-docs"
    exit 1
    ;;
esac

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$(cd "$REPO_ROOT/.." && pwd)/$PROJECT_NAME"

if [[ -e "$DEST" ]]; then
  echo "error: $DEST already exists"
  exit 1
fi

# ── Source layout ──────────────────────────────────────────────────────────
# minimal: copy templates/minimal/ as-is.
# marketing-hero: copy the root repo (it IS the canonical marketing-hero).
# product-docs: copy the root repo, then strip pillars/intro sections.

if [[ "$TEMPLATE" == "minimal" ]]; then
  SRC="$REPO_ROOT/templates/minimal"
else
  SRC="$REPO_ROOT"
fi

echo "→ Scaffolding $PROJECT_NAME from $TEMPLATE"
echo "  source: $SRC"
echo "  destination: $DEST"
echo

# ── Copy ───────────────────────────────────────────────────────────────────
mkdir -p "$DEST"

if [[ "$TEMPLATE" == "minimal" ]]; then
  cp -r "$SRC"/. "$DEST"/
else
  # Copy everything except .git, _site, templates/, scripts/, node_modules
  rsync -a \
    --exclude='.git' \
    --exclude='_site' \
    --exclude='templates' \
    --exclude='scripts' \
    --exclude='node_modules' \
    --exclude='.venv' \
    "$SRC"/ "$DEST"/
fi

# ── Prompt for placeholder values ──────────────────────────────────────────
prompt() {
  local var="$1" prompt_text="$2" default="$3" answer
  if [[ -n "${!var:-}" ]]; then
    answer="${!var}"
  else
    read -r -p "  $prompt_text [$default]: " answer
    answer="${answer:-$default}"
  fi
  echo "$answer"
}

echo "→ Tell me about your project"
SITE_NAME="$(prompt SITE_NAME 'Site name' "${PROJECT_NAME^} Documentation")"
SITE_DESCRIPTION="$(prompt SITE_DESCRIPTION 'One-line description' "Documentation for $PROJECT_NAME")"
SITE_URL="$(prompt SITE_URL 'Production URL' "https://$PROJECT_NAME.example.com")"
REPO_URL="$(prompt REPO_URL 'Repo URL' "https://github.com/USER/$PROJECT_NAME")"
REPO_NAME="$(prompt REPO_NAME 'Repo name (org/repo)' "USER/$PROJECT_NAME")"
HERO_HEADLINE="$(prompt HERO_HEADLINE 'Hero headline (≤8 words)' "Build with $SITE_NAME")"
HERO_SUBHEAD="$(prompt HERO_SUBHEAD 'Hero subhead (one sentence)' "$SITE_DESCRIPTION")"
PRIMARY_CTA_LABEL="$(prompt PRIMARY_CTA_LABEL 'Primary CTA label' 'Get started')"
PRIMARY_CTA_HREF="$(prompt PRIMARY_CTA_HREF 'Primary CTA href' 'getting-started/')"
SECONDARY_CTA_LABEL="$(prompt SECONDARY_CTA_LABEL 'Secondary CTA label' 'Learn more')"
SECONDARY_CTA_HREF="$(prompt SECONDARY_CTA_HREF 'Secondary CTA href' 'about/')"
PRIMARY_COLOR="$(prompt PRIMARY_COLOR 'Primary brand color (hex)' '#0e7c66')"
ACCENT_COLOR="$(prompt ACCENT_COLOR 'Accent color (hex)' '#14a484')"

# ── Substitute placeholders ────────────────────────────────────────────────
echo
echo "→ Substituting placeholders"

# Use a single-pass sed with multiple expressions. Limit to text files.
substitute() {
  local file="$1"
  # Skip binaries and large files
  if [[ ! -f "$file" ]] || file -b --mime "$file" | grep -q binary; then
    return
  fi
  # Use perl for safer multi-replace (handles special chars in values)
  perl -pi -e "
    s/\\Q{{SITE_NAME}}\\E/\$ENV{SITE_NAME}/g;
    s/\\Q{{SITE_DESCRIPTION}}\\E/\$ENV{SITE_DESCRIPTION}/g;
    s/\\Q{{SITE_URL}}\\E/\$ENV{SITE_URL}/g;
    s/\\Q{{REPO_URL}}\\E/\$ENV{REPO_URL}/g;
    s/\\Q{{REPO_NAME}}\\E/\$ENV{REPO_NAME}/g;
    s/\\Q{{HERO_HEADLINE}}\\E/\$ENV{HERO_HEADLINE}/g;
    s/\\Q{{HERO_SUBHEAD}}\\E/\$ENV{HERO_SUBHEAD}/g;
    s/\\Q{{PRIMARY_CTA_LABEL}}\\E/\$ENV{PRIMARY_CTA_LABEL}/g;
    s/\\Q{{PRIMARY_CTA_HREF}}\\E/\$ENV{PRIMARY_CTA_HREF}/g;
    s/\\Q{{SECONDARY_CTA_LABEL}}\\E/\$ENV{SECONDARY_CTA_LABEL}/g;
    s/\\Q{{SECONDARY_CTA_HREF}}\\E/\$ENV{SECONDARY_CTA_HREF}/g;
    s/\\Q{{PRIMARY_COLOR}}\\E/\$ENV{PRIMARY_COLOR}/g;
    s/\\Q{{ACCENT_COLOR}}\\E/\$ENV{ACCENT_COLOR}/g;
  " "$file"
}

export SITE_NAME SITE_DESCRIPTION SITE_URL REPO_URL REPO_NAME
export HERO_HEADLINE HERO_SUBHEAD
export PRIMARY_CTA_LABEL PRIMARY_CTA_HREF SECONDARY_CTA_LABEL SECONDARY_CTA_HREF
export PRIMARY_COLOR ACCENT_COLOR

# Find text files (skip AVIF, PNG, etc.)
while IFS= read -r -d '' f; do
  substitute "$f"
done < <(find "$DEST" \
            -type f \
            \( -name '*.md' -o -name '*.yml' -o -name '*.yaml' \
               -o -name '*.html' -o -name '*.css' -o -name '*.js' \
               -o -name '*.json' -o -name '*.toml' -o -name '*.txt' \
               -o -name 'CNAME' -o -name '.gitignore' \
            \) \
            -print0)

# ── Strip pillars/intro for product-docs ───────────────────────────────────
if [[ "$TEMPLATE" == "product-docs" ]]; then
  echo "→ Stripping pillars and intro sections"
  # Remove the two extra <section> blocks from overrides/home.html
  perl -i -0pe 's{<section class="mdx-parallax__group mdx-pillars".*?</section>\s*}{}sg' "$DEST/overrides/home.html"
  perl -i -0pe 's{<section class="mdx-parallax__group mdx-intro".*?</section>\s*}{}sg' "$DEST/overrides/home.html"
fi

# ── Initialize git ─────────────────────────────────────────────────────────
echo "→ Initializing git"
cd "$DEST"
rm -rf .git
git init -q
git add .
git commit -q -m "init: scaffold $PROJECT_NAME from $TEMPLATE template"

# ── Done ───────────────────────────────────────────────────────────────────
echo
echo "✓ Created $DEST"
echo
echo "Next steps:"
echo "  cd $DEST"
echo "  python -m venv .venv && source .venv/bin/activate"
echo "  pip install -r requirements.txt"
echo "  # Replace placeholder AVIFs in src/assets/hero/"
echo "  mkdocs serve"
echo
echo "Then read AGENTS.md (copied into your project) for the full guide."
