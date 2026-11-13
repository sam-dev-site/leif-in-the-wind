# Art backlog

Checked 2026-11-03, after the night slices landed on the caribou walk. This is the list of pictures. `docs/IDEAS.md` stays wishes and slices. A generation is spent only when you name a row.

## When you hold a picture

If you leave a picture as a box, skip a generation, or write that art waits, add the row here in that same session. Say what is on screen now, the file the game should load, and why it waited. A sentence in `docs/DECISIONS.md`, `docs/STATUS.md`, or `docs/IDEAS.md` does not count. Those files can point here. They are not this list.

## Balance

PixelLab account on this machine:

- Credits: **$0.00**
- Plan: trial, **0** generations left (40 of 40 used, plus the daily stack)
- Daily stack: **0**. It refills **+5** each night, up to 20.
- Spendable now: **0**. The campfire was refused for that.
- Paid floor, if we ever buy it: Pixel Apprentice **$12/mo for 2,000** generations
- This trial animates **one direction at a time**. An 8-direction walk is eight jobs.

Known prices, from earlier work on this coast:

- A map object (`create_map_object`) is **1** generation.
- A Pro Flash still was quoted at **5**. Plants on this coast used the 1-generation path.
- Leif’s character was **10** generations before his walk frames.

## In the game

- Leif: 8-direction idle and walk (`game/art/leif/`)
- Woodland caribou: 8-direction idle and an 8-frame walk (`game/art/coastal_north/caribou/`). Same 64px canvas as Leif, drawn at half size. Character `fdeb44e3-c125-43b7-bf75-540b7101a398`.
- Arctic hare: 8-direction idle only (`game/art/coastal_north/hare/`). Same canvas, drawn smaller (0.32) so it is not the size of the caribou. Character `f2402d5a-2593-4727-9bae-5233c81bc69d`. The hop still shows that idle.
- Coast: fir, spruce, bakeapple, blueberry, ringed stumps, granite, sphagnum, needles, fallen fir, fir branch
- Ground: Wang sheets for water, shore, moss, trail (`game/art/tiles/`)
- Marks: skills, woodcutting (axe), fire-making (campfire icon), fir leaf, floppy, admin cog
- Night, drawn in the repo, not a PixelLab generation: pitch glint (`game/art/coastal_north/pitch_glint.png`), rime (`game/art/coastal_north/rime.png`), and the pressed bed in the moss (`game/art/coastal_north/caribou_bed.png`).

## Open

What is still a box or a missing file on this coast.

1. **Arctic hare hop.** Idle is in. A hop still holds that picture and turns it. The cat template has `walk-4-frames` (the game loads four frames). One direction at a time, so a full hop is 8 generations. Held on 2026-11-02 because the stack was empty after the idle.
2. **Campfire.** Stones and flame in the woods are colored boxes (`game/world/campfire.gd`). The warm pool is already the night light. A map object is 1 generation. Held on 2026-11-02: the account refused the job, no generations left.
3. **Foraging icon.** The skills row is blank until `game/art/ui/skill_foraging.png` exists. Woodcutting and fire-making already have icons.
4. **Fishing icon.** The skills row is blank until `game/art/ui/skill_fishing.png` exists. Held on 2026-11-12: this pass is a cloud agent, and PixelLab stays on the playtest PC.
5. **Rucksack mark.** A cream rectangle sits between the skills mark and the floppy.
6. **Pitch, stick, torch, raft, hand-line.** The bag draws colored squares. Hover already says the names. The raft square waits on `game/art/ui/raft.png`. The hand-line square waits on `game/art/ui/line.png`. Held on 2026-11-12: this pass is a cloud agent, and PixelLab stays on the playtest PC.
7. **Caribou bedded.** The night bed uses the standing idle until a resting pose exists. File: `game/art/coastal_north/caribou/bed.png`, one direction. Held on 2026-11-03: the stack is not spent on this slice. One still when that row is named. Not eight directions.

## Hold

- **Death skull.** `game/art/ui/death_skull.png` is already a skull and crossed bones drawn in the repo. Play signed that fade off. Do not spend a generation on it unless you ask.

## Not this coast

The river valley is walkable as colored boxes. Spend a generation only when you name a row. Files the game will load, under `art/biomes/river_valley/` and copied into `game/art/river_valley/`:

1. **Valley trees.** Twelve species, each `tree_<species>.png`: sugar maple, yellow birch, beech, red oak, white pine, hemlock, silver maple, butternut, bur oak, elm, green ash, basswood. On screen they are colored crowns. Held on 2026-11-12: this pass is a cloud agent, and PixelLab stays on the playtest PC.
2. **Valley food.** `forage_butternut.png`, `forage_riverbank_grape.png`, `forage_fiddlehead.png`. On screen they are colored berries. Same hold.
3. **White-tailed deer.** `game/art/river_valley/deer.png`. On screen it is a brown rectangle. Same hold. No directions until you ask.

The valley floor is flat color on purpose (silt, clay, river, brook). That is not a missing picture.

The bayou is walkable as colored boxes. Spend a generation only when you name a row. Files the game will load, under `art/biomes/bayou/` and copied into `game/art/bayou/`:

1. **Swamp trees.** `tree_baldcypress.png`, `tree_water_tupelo.png`, `tree_overcup_oak.png`, `tree_water_hickory.png`. On screen they are colored crowns. Spanish moss is not its own picture yet; the cypress box stands in for the tree. Held on 2026-11-12: this pass is a cloud agent, and PixelLab stays on the playtest PC.
2. **Swamp food.** `forage_muscadine.png`, `forage_pecan.png`. On screen they are colored fruit. Same hold.

The bayou floor is flat color on purpose (open channel, tupelo water, cypress margin, higher ground). That is not a missing picture.

The Connecticut is walkable as colored boxes. Spend a generation only when you name a row. Files the game will load, under `art/biomes/river_country/` and copied into `game/art/river_country/`:

1. **River trees.** `tree_eastern_cottonwood.png`, `tree_american_sycamore.png`, `tree_american_chestnut.png`, `tree_shagbark_hickory.png`. On screen they are colored crowns. The chestnut is the old canopy tree, not a blighted sprout. Held on 2026-11-12: this pass is a cloud agent, and PixelLab stays on the playtest PC.
2. **River food.** `forage_chestnut.png`. On screen it is a colored nut. Same hold.

The river floor is flat color on purpose (one stem, a brook, the floodplain, the terrace). That is not a missing picture.

The western shore is walkable as colored boxes. Spend a generation only when you name a row. Files the game will load, under `art/biomes/western_shore/` and copied into `game/art/western_shore/`:

1. **Shore trees.** `tree_sitka_spruce.png`, `tree_western_hemlock.png`, `tree_western_redcedar.png`. On screen they are colored crowns. Held on 2026-11-12: this pass is a cloud agent, and PixelLab stays on the playtest PC.
2. **Shore food.** `forage_salmonberry.png`, `forage_salal.png`. On screen they are colored fruit. Same hold.

The shore floor is flat color on purpose (ocean to the west, forest underfoot). Ferns and moss are that color, not their own props. That is not a missing picture.

## How a row gets made

Say which row. This PC generates it and wires the file the game already looks for. A cloud agent does not call PixelLab.
