# Hero artwork

Replace the four placeholder AVIF files in `src/assets/hero/` with your
own layered artwork. Each layer represents a different depth plane:

| Filename | Depth | Contents | Transparency |
|---|---|---|---|
| `1-far@4x.avif` | 8 | Sky, horizon, distant scenery | Opaque |
| `2-mid@4x.avif` | 5 | Mid-distance silhouette | Transparent |
| `3-near@4x.avif` | 2 | Foreground objects | Transparent |
| `4-front@4x.avif` | 1 | Closest elements | Transparent |

## Generating layers

The fastest path:

1. Use `skills/generate-prompts` to write four AI image prompts (one per
   depth, sharing a style anchor).
2. Run the prompts through Google ImageFX, Midjourney, or DALL·E 3.
3. Run `skills/convert-images` (or `avifenc` directly) to produce AVIF
   from the PNG outputs.
4. Drop the AVIFs in this directory.

See `AGENTS.md` in the repo root after scaffolding for the full workflow.

## Sizing

- Source PNGs: 4096 × 2304 minimum, 16:5 panoramic aspect ratio preferred.
- AVIF target sizes: layer 1 ≤ 600 KB, layers 2–4 ≤ 150 KB each.
- Use `--min 28 --max 36 --speed 4` with `avifenc` for a good
  quality/size tradeoff.

The placeholder files in `src/assets/hero/` are zero bytes. **The build
will fail until you replace them.**
