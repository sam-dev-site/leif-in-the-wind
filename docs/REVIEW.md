# Review gates

Do not call a unit of work complete until the applicable gates pass. Owner is a first-time game maker — write the review in plain language.

## 1. Mission

- Serves at least one current aesthetic in `docs/MISSION.md` (sensation, fantasy, discovery, submission) and does not fight the pillars
- Answers: *which feeling is this for, and does it make the woods worth being in?* Inland travel still counts. Sitting still counts. A checklist that only moves Leif does not.
- Does not turn this slice into a finished camp / town sim or a skill-tree grind. Expression (a house, a town) stays later. Woodcutting and fire-making on this biome are in. They are not a reason to grow the map.

## 2. Knowledge

- Lasting decisions appended to `docs/DECISIONS.md`
- `docs/STATUS.md` updated
- Slice docs do not contradict the mission (mission wins)

## 3. Biome accuracy

- No invented species
- Spawn tables and art names match `docs/research/biomes/`
- New species required a research pass with sources

## 4. Architecture

- No one-off level that would have to be thrown away for a second biome or a second chunk
- Assets named by biome and species (`coastal_north/tree_spruce`), never `tree1`

## 5. Check

- GitHub Actions `check` is green
- When Godot exists: unit tests for seed stability, biome lookup, and the verbs you touched
- A cloud agent may claim this gate after headless tests and a green Actions run. It may not claim Play.

## 6. Feel (owner)

- Owner pressed Play (or ran an exported build) when the change is player-visible
- This gate is only the owner on this PC. Cloud never launches the Godot editor and never writes “Play signed off.”
- Cloud writes **ready for Play** in `docs/STATUS.md`. The local sign-off writes **Play signed off**, including what could not be verified.

## How to review (agents)

Read `MISSION.md`, `STATUS.md`, the biome research file, and the diff. File findings as critical / high / note. Fix critical and high before merge unless the owner accepts them.

Cloud stops after gates 1–5 and the PR. Gate 6 waits for the Surface.
