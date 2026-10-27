# Status

Updated: 2026-10-27

## Where we are

Harness-only. The GitHub repo exists and this knowledge layer is the first real commit. There is **no playable Godot project yet**.

## What exists

- Mission, decision log, slice 0 spec, review gates
- Biome research template + four biome files; `coastal_north` is a **draft** species list (fir, spruce, bakeapple, blueberry, caribou trails). Owner should skim before art.
- Cursor rules and project hooks
- GitHub Actions workflow that checks knowledge files are present
- Art inspiration images and the original (truncated) style guide

## Blocked / next

1. Owner skims `docs/research/biomes/coastal_north.md` and accepts or corrects it
2. Godot 4 project: World + Biome + Chunk, GUT tests, CI job when `game/project.godot` exists
3. PixelLab art from the accepted research list
4. Slice 0 verbs: walk, pick, chop, campfire, night
5. Owner playtest on the Surface Pro

## Local machine

Surface Pro 6, 8 GB RAM. Godot / Aseprite / PixelLab are **not required until there is something to play or draw**. Do not install Unity.

## Checks

First Actions run failed immediately (no jobs). Likely invalid `hashFiles` on a job-level `if`. Workflow simplified to knowledge-file checks only; Godot CI waits until `game/project.godot` exists.
