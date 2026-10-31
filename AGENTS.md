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
| [docs/IDEAS.md](docs/IDEAS.md) | Unordered slices. No queue. When asked what is next, choose one from the whole project. |
| [docs/BUGS.md](docs/BUGS.md) | Breaks that are not the current Play. Log them. A fix session names the open headings before changing the game. |
| [docs/research/biomes/](docs/research/biomes/) | Flora and fauna with sources. |

Before doing project work, read `MISSION.md`, the latest `DECISIONS.md` and `STATUS.md`, and any biome research file you will touch.

## Facts you must not invent

Never silently invent species, climate, period details, or “this plant grows in Vinland.” If it is not in `docs/research/biomes/`, research it with sources, write the doc, then use it. Same rule as not inventing prices on a client site.

If you make a lasting decision (engine, tile size, scope, tool change), **append `docs/DECISIONS.md` in the same session**. Update `docs/STATUS.md` before you finish.

## How work should happen

1. Prefer a cloud agent + pull request for research, code, tests, and review.
2. This PC is for PixelLab and pressing Play. Local agents land the one open PR. Cloud never opens Godot. Do not treat this laptop as the CI machine.
3. Never replace the continent with a one-off `Level1` scene. World / seed / chunk / biome-as-data from day one.
4. Every feature must serve a named aesthetic in `docs/MISSION.md`. Sensation and sitting still count. “Leif moved,” or “the map got bigger,” is not enough. Ideas have no order. When the owner asks what to work on next, read the mission, the decisions, the status, and `docs/IDEAS.md`, and choose one slice.
5. Stay agile: if a tool or workflow is wrong for a newbie on this laptop, change it and log why.
6. When the owner signs off — `commit`, `save`, `save and commit`, `all set`, `good`, `done`, `all done`, `perfect`, `everything is working`, or `push` — sync GitHub `main` to this PC in that turn: commit if needed, push, merge a playtest PR if that is the branch, checkout `main`, pull. Do not ask. Do not report a commit hash unless `git log -1` printed it. Do not say it has not been pushed. A signed-off change left only on this PC is not done. GitHub `main` is the brain. Detail: `.cursor/rules/commit-signoff.mdc` and `.cursor/skills/playtest-pr`.
7. Bugs that are not the current Play go in `docs/BUGS.md`. Logging one does not start the fix. When the owner asks for bug fixes, read that file and name the open headings, in those words, before changing the game. New wishes stay in `docs/IDEAS.md`. Taking one in includes a pass over that file: combine the same slice, split a line that is more than one, and drop a duplicate.

## Dev loop

The owner should never have to remember git. Every phase change ends with **one next-action line** (copy in `.cursor/rules/dev-loop.mdc`).

Owner steps after plan: click **Build in Cloud**, start a new local chat when the PR exists, press Play, say `done`. Next idea is a new chat on `main`.

- Cloud: PR + headless + Actions. REVIEW gates 1–5 only. STATUS says **ready for Play**. Last line: start a new local chat on the Surface. Do not open Godot.
- Local, one open PR, clean tree, not an art / `top 3` chat: land the PR (`.cursor/skills/playtest-pr`), then tell them Godot is ready.
- Sign-off: merge, return to `main`, both sides match. Last line: start a new chat for the next idea.
- Play notes stay in the playtest chat. A third agent is not required.

## Parallel lanes (do not collide)

Art and code can run at the same time if they do not edit the same files. **Push this PC’s work before a cloud agent starts**, or it will code on a stale `main`.

| Lane | Where | Owns | Must not touch |
|---|---|---|---|
| **Art** | This PC, PixelLab MCP | `art/`, `game/art/`, player sprites/animations, swapping ColorRects for named PNGs | Slice verbs, HUD counts, other biomes’ research |
| **Verbs** | Cloud agent + PR | Pick, chop, campfire, night, HUD numbers, tests for those. New scripts under `game/world/` (interact, time, fire). Props keep `set_meta("species")` / `set_meta("kind")` | PixelLab, tokens, generating or replacing PNGs |
| **Research** | Cloud agent + PR | `docs/research/biomes/` with sources. `river_valley` is already researched. Do not start another biome. | Spawn tables and art. Skills on this coast come before more map. |

Player movement lives on this PC until art is done with it. Verbs should read facing/position, not rewrite walk/run.

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
