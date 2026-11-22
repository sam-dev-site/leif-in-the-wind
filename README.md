# Leif in the Wind

Single-player top-down survival. Leif Erikson is stranded on the Vinland coast. Survival is the opening. The point is walking **inland** across a generated continent.

This repository is the source of truth — not any one chat.

**GitHub:** [https://github.com/sam-dev-site/leif-in-the-wind](https://github.com/sam-dev-site/leif-in-the-wind)

If you are an agent or a new collaborator, start with [CLAUDE.md](CLAUDE.md).

The current game is branch `cursor/other-sea-943d`. `main` is an older coast (through the hares) and does not contain the locked loop. Check that branch out before reading the docs below, or the files will not match the game.

1. [CLAUDE.md](CLAUDE.md) — session brief, stack, and locks
2. [AGENTS.md](AGENTS.md) — how to work in this repo
3. [docs/MISSION.md](docs/MISSION.md) — why the game exists
4. [docs/LOOP.md](docs/LOOP.md) — the locked game
5. [docs/DECISIONS.md](docs/DECISIONS.md) — what we already decided
6. [docs/STATUS.md](docs/STATUS.md) — what exists right now

On that branch you can walk a generated `coastal_north` forest into a river valley (chop, forage, fire, night, a raft, a hand-line). Lands past the empty plains are in the build and are not on the walk from the landing. The coast is a slice of the full game, not a different game.

## Play on this PC

1. Install [Godot 4.7.2 Standard](https://godotengine.org/download/windows/) (not the .NET build).
2. Godot → Import → choose the `game` folder (the one with `project.godot`).
3. Press Play. WASD / arrows walk. **R** loads a new seed. Water is behind you; the brown trail leads inland.

Placeholder art is colored rectangles. Fir, spruce, bakeapple, and blueberry are labeled in data even when they look like boxes.
