# Leif in the Wind

Single-player top-down survival. Leif Erikson is stranded on the Vinland coast. Survival is the opening. The point is walking **inland** across a generated continent.

This repository is the source of truth — not any one chat.

**GitHub:** [https://github.com/sam-dev-site/leif-in-the-wind](https://github.com/sam-dev-site/leif-in-the-wind)

If you are an agent or a new collaborator, start here:

1. [AGENTS.md](AGENTS.md) — how to work in this repo
2. [docs/MISSION.md](docs/MISSION.md) — why the game exists
3. [docs/DECISIONS.md](docs/DECISIONS.md) — what we already decided
4. [docs/STATUS.md](docs/STATUS.md) — what exists right now

The first playable cut is a generated `coastal_north` forest (walk, forage, chop, campfire, night). That cut is a slice of the full game, not a different game.

## Play on this PC

1. Install [Godot 4.7.2 Standard](https://godotengine.org/download/windows/) (not the .NET build).
2. Godot → Import → choose the `game` folder (the one with `project.godot`).
3. Press Play. WASD / arrows walk. **R** loads a new seed. Water is behind you; the brown trail leads inland.

Placeholder art is colored rectangles. Fir, spruce, bakeapple, and blueberry are labeled in data even when they look like boxes.
