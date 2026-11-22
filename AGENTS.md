# Agent and collaborator instructions

The project owner is making a first game. Make sound defaults. Explain consequential choices in plain language. Prefer work that can run in the cloud / on GitHub so this Surface Pro stays a playtest machine.

## Where the truth lives

Read [CLAUDE.md](CLAUDE.md) first. Chat memory is not the brain.

Until the 2026-11-13 stack is merged, the game is branch `cursor/other-sea-943d`, not `main`. `main` is the signed-off coast through the hares. The loop, the valley, and the win are on that branch. After the owner signs the path off and that branch is merged, GitHub `main` is the brain again.

| File | Job |
|---|---|
| [CLAUDE.md](CLAUDE.md) | Session brief for Claude. Branch, stack, locks, and how to work without Cursor. |
| [docs/MISSION.md](docs/MISSION.md) | Why the game exists. Never overridden by a slice doc. |
| [docs/LOOP.md](docs/LOOP.md) | Locked loop, skills, lands, hearts, and win. Agents do not reopen it. |
| [docs/PLAN.md](docs/PLAN.md) | Build order. One phase, one PR. Research before spawn. |
| [docs/DECISIONS.md](docs/DECISIONS.md) | Append-only log of lasting choices. |
| [docs/STATUS.md](docs/STATUS.md) | What exists, what is blocked, what is next. |
| [docs/SLICE_0.md](docs/SLICE_0.md) | Current playable cut only. |
| [docs/REVIEW.md](docs/REVIEW.md) | Do not call work done until these gates pass. |
| [docs/IDEAS.md](docs/IDEAS.md) | Unordered slices. No queue. Each open slice has questions for the next agent. When asked what is next, choose one from the whole project. |
| [docs/BUGS.md](docs/BUGS.md) | Breaks that are not the current Play. Log them. A fix session names the open headings before changing the game. |
| [docs/ART.md](docs/ART.md) | Pictures still missing or standing in as boxes. Spend a generation only when the owner names a row. A hold in the same session must add the row here. |
| [docs/research/biomes/](docs/research/biomes/) | Flora and fauna with sources. |

Before doing project work, read `CLAUDE.md`, `docs/MISSION.md`, `docs/LOOP.md`, `docs/PLAN.md`, the latest `docs/DECISIONS.md` and `docs/STATUS.md`, and any biome research file you will touch. Phases A–N are already on `cursor/other-sea-943d`. Do not restart them because `main` lacks them. Phase H is the stop. Do not reopen the lock.

## Facts you must not invent

Never silently invent species, climate, period details, or “this plant grows in Vinland.” If it is not in `docs/research/biomes/`, research it with sources, write the doc, then use it. Same rule as not inventing prices on a client site.

If you make a lasting decision (engine, tile size, scope, tool change), **append `docs/DECISIONS.md` in the same session**. Update `docs/STATUS.md` before you finish.

## How work should happen

1. Prefer a pull request for research, code, tests, and review. Cursor cloud is no longer the lane. Claude follows [CLAUDE.md](CLAUDE.md).
2. This PC is for PixelLab and pressing Play. The open work is one stack, tip `cursor/other-sea-943d`. Do not land a single PR out of it. An agent does not open Godot. Do not treat this laptop as the CI machine.
3. Never replace the continent with a one-off `Level1` scene. World / seed / chunk / biome-as-data from day one.
4. Every feature must serve a named aesthetic in `docs/MISSION.md`. Sensation and sitting still count. “Leif moved,” or “the map got bigger,” is not enough. The loop is locked in `docs/LOOP.md`. When the owner asks what to work on next, the path on `cursor/other-sea-943d` is built and waiting for Play. Phase H is the stop. After that, art, a bug, or a wish in `docs/IDEAS.md`. Open wishes have no order. Do not treat the ideas file as a queue.
5. Stay agile: if a tool or workflow is wrong for a newbie on this laptop, change it and log why.
6. When the owner signs off — `commit`, `save`, `save and commit`, `all set`, `good`, `done`, `all done`, `perfect`, `everything is working`, or `push` — sync GitHub `main` to this PC in that turn. While the stack is open, merge `cursor/other-sea-943d` into `main`. Do not `gh pr merge` #27 into its parent branch. After the path is on `main`, a normal playtest PR merges with `gh pr merge`. Commit if needed, push, checkout `main`, pull. Do not ask. Do not report a commit hash unless `git log -1` printed it. Do not say it has not been pushed. A signed-off change left only on this PC is not done. Detail: `CLAUDE.md`, `.cursor/rules/commit-signoff.mdc`, and `.cursor/skills/playtest-pr`.
7. Bugs that are not the current Play go in `docs/BUGS.md`. Logging one does not start the fix. When the owner asks for bug fixes, read that file and name the open headings, in those words, before changing the game. New wishes stay in `docs/IDEAS.md`. Taking one in includes a pass over that file: combine the same slice, split a line that is more than one, drop a duplicate, and add questions grounded in the game. Do not invent the answers. See `.cursor/rules/ideas.mdc`.

## Dev loop

The owner should never have to remember git. Right now the loop is the stack in `CLAUDE.md`: Play `cursor/other-sea-943d`, then a sign-off merges that branch into `main`. Cursor’s **Build in Cloud** button is not the next step. After `main` holds the path, a new slice is a pull request again. Every phase change ends with **one next-action line** (copy in `.cursor/rules/dev-loop.mdc`, stack exception in `CLAUDE.md`).

- An agent opens a PR, runs headless tests, and waits for Actions. Review gates 1–5 only. STATUS says **ready for Play**. The agent does not open Godot and does not claim Play.
- While the stack is open, do not land one of the fourteen PRs. The tip branch is already the game.
- Sign-off of that path: merge the branch into `main`, both sides match. Last line: start a new chat for the next idea.
- Play notes stay in the playtest chat. A third agent is not required.

## Parallel lanes (do not collide)

Art and code can run at the same time if they do not edit the same files. **Push this PC’s work before a cloud agent starts**, or it will code on a stale `main`.

| Lane | Where | Owns | Must not touch |
|---|---|---|---|
| **Art** | This PC, PixelLab MCP | `art/`, `game/art/`, player sprites/animations, swapping ColorRects for named PNGs | Slice verbs, HUD counts, other biomes’ research |
| **Verbs** | Cloud agent + PR | The next phase in `docs/PLAN.md`. Pick, chop, campfire, night, HUD numbers, tests. New scripts under `game/world/`. Props keep `set_meta("species")` / `set_meta("kind")` | PixelLab, tokens, generating or replacing PNGs. A later plan phase |
| **Research** | Cloud agent + PR | `docs/research/biomes/` with sources, when that phase is the next unfinished one. `river_valley` is already researched | Spawn tables and art. Researching a land before its phase |

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
