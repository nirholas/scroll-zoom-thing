Run the `generate-prompts` skill from `skills/generate-prompts/SKILL.md`.

Generate 4 AI image prompts for parallax layers based on a scene description.

1. Ask for: scene description, visual style, lighting, target tool (ImageFX / Midjourney / DALL-E).
2. Lock a style anchor (lighting + palette + camera angle) that is identical across all prompts.
3. Output one ready-to-paste prompt per layer with suggested depth and image-position values.
4. Add tool-specific notes (aspect ratio flags, background removal tips).

Arguments: $ARGUMENTS
