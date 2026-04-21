---
name: convert-images
description: Convert PNG or WebP source images to AVIF format for use as parallax layers, with optional background removal.
version: 0.1.0
triggers:
  - when the user has PNG or WebP images and needs AVIF files
  - when the user wants to convert their layer images
  - when the user asks how to export images for the parallax
inputs:
  - name: source_dir
    type: string
    required: false
    description: Directory containing source images (default "raw/")
  - name: output_dir
    type: string
    required: false
    description: Output directory for AVIF files (default "docs/assets/hero/")
  - name: quality
    type: integer
    required: false
    description: AVIF quality 0–100 (default 70)
  - name: remove_background
    type: boolean
    required: false
    description: Whether to run background removal before conversion (default false)
outputs:
  - AVIF files in docs/assets/hero/
  - shell script the user can run locally if tools are not available in the environment
constraints:
  - do not overwrite existing AVIF files without user confirmation
  - report file sizes before and after conversion
---

# convert-images

Convert source images to AVIF for use as parallax layers.

## 1. Purpose

The parallax hero expects AVIF files in `docs/assets/hero/`. This skill
converts PNG or WebP source files and optionally removes backgrounds for
mid/foreground layers.

## 2. Tool detection

Check which conversion tools are available before proceeding:

```bash
command -v cavif   && echo "cavif available"
command -v ffmpeg  && echo "ffmpeg available"
command -v magick  && echo "ImageMagick available"
command -v rembg   && echo "rembg available"
```

Use the first available tool. If none are available, generate a shell
script the user can run on their local machine.

## 3. Conversion commands

**cavif (preferred):**
```bash
cavif --quality 70 input.png -o output@4x.avif
```

**ffmpeg (fallback):**
```bash
ffmpeg -i input.png -c:v libavc -crf 30 output@4x.avif
```

**ImageMagick (last resort):**
```bash
magick input.png -quality 70 output@4x.avif
```

## 4. Background removal

For mid/near/foreground layers that need transparency:

```bash
rembg i input.png output_nobg.png
# then convert
cavif --quality 70 output_nobg.png -o layer@4x.avif
```

If `rembg` is not available, generate a requirements file:
```
rembg[gpu]
```
And instruct the user to run: `pip install rembg[gpu] && rembg i input.png output.png`

## 5. Naming convention

Output files should follow the convention expected in `home.html`:

| Layer | Filename |
|---|---|
| Far background | `1-landscape@4x.avif` |
| Mid background | `2-plateau@4x.avif` |
| Near midground | `5-plants-1@4x.avif` |
| Foreground | `6-plants-2@4x.avif` |

If the user has different filenames, update `home.html` to match — do not
rename files without asking.

## 6. Batch script

Generate this script for users without local tools:

```bash
#!/usr/bin/env bash
set -euo pipefail
QUALITY=70
SRC="${1:-raw}"
OUT="${2:-docs/assets/hero}"
mkdir -p "$OUT"
for f in "$SRC"/*.png "$SRC"/*.webp; do
  [ -f "$f" ] || continue
  base=$(basename "${f%.*}")
  echo "Converting $f → $OUT/${base}@4x.avif"
  cavif --quality "$QUALITY" "$f" -o "$OUT/${base}@4x.avif"
done
echo "Done. Files in $OUT:"
ls -lh "$OUT"/*.avif
```

## 7. Changelog

- `0.1.0` — Initial skill.
