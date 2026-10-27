# Agent and collaborator instructions

The project owner is making a first game. Make sound defaults. Explain consequential choices in plain language. Prefer work that can run in the cloud / on GitHub so this Surface Pro stays a playtest machine.

## Where the truth lives

GitHub `main` is the brain. Chat memory is not.

| File | Job |
|---|---|
| [docs/MISSION.md](docs/MISSION.md) | Why the game exists. Never overridden by a slice doc. |
| [docs/DECISIONS.md](docs/DECISIONS.md) | Append-only log of lasting choices. |
| [docs/STATUS.md](docs/STATUS.md) | What exists, what is blocked, what is next. |
| [docs/SLICE_0.md](docs/SLICE_0.md) | Current playable cut only. |
| [docs/REVIEW.md](docs/REVIEW.md) | Do not call work done until these gates pass. |
| [docs/research/biomes/](docs/research/biomes/) | Flora and fauna with sources. |

Before doing project work, read `MISSION.md`, the latest `DECISIONS.md` and `STATUS.md`, and any biome research file you will touch.

## Facts you must not invent

Never silently invent species, climate, period details, or “this plant grows in Vinland.” If it is not in `docs/research/biomes/`, research it with sources, write the doc, then use it. Same rule as not inventing prices on a client site.

If you make a lasting decision (engine, tile size, scope, tool change), **append `docs/DECISIONS.md` in the same session**. Update `docs/STATUS.md` before you finish.

## How work should happen

1. Prefer a cloud agent + pull request for research, code, tests, and review.
2. This PC is for `git pull` and pressing Play. Do not treat it as the CI machine.
3. Never replace the continent with a one-off `Level1` scene. World / seed / chunk / biome-as-data from day one.
4. Every feature must answer: *how does this help Leif go inland?*
5. Stay agile: if a tool or workflow is wrong for a newbie on this laptop, change it and log why.

## Checks

GitHub Actions runs two jobs: knowledge files exist, and Godot headless tests.

```text
godot --headless --path game -s res://tests/run.gd
```

Do not call a slice done if Actions is red or `docs/REVIEW.md` gates fail.

The Godot project lives in `game/`. Open that folder in Godot, not the repo root.

Do not install Unity, Unreal, Blender, or Meshy for this game. It is 2D pixel art in Godot.

Pixel art: PixelLab MCP is configured in `.cursor/mcp.json`. It needs `PIXELLAB_API_TOKEN` on this PC (see [docs/PIXELAB.md](docs/PIXELAB.md)). If those tools are missing, ask the owner to finish that doc — do not put a token in git.

Never commit secrets. Do not force-push `main`. Do not change git config.
