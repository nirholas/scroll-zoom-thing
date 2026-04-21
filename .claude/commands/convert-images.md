Run the `convert-images` skill from `skills/convert-images/SKILL.md`.

1. Check which conversion tools are available (cavif, ffmpeg, magick, rembg).
2. List source images in the directory the user specifies (or "raw/" by default).
3. Convert each image to AVIF at quality 70 and place in `docs/assets/hero/`.
4. Report before/after file sizes.
5. If no tools are available, generate a bash script the user can run locally.

Arguments: $ARGUMENTS
