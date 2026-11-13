# The locked loop

Status: **locked 2026-11-12.** This file is the game. `docs/SLICE_0.md` is only the coast you can play today. `docs/PLAN.md` is the build order. If this file and a slice doc disagree, this file wins. If it and `docs/MISSION.md` disagree, the mission wins.

An agent does not reopen these choices. A new wish still goes in `docs/IDEAS.md` with questions. It does not edit this file unless the owner asks to change the lock.

## The loop

Three beats. Every build serves at least one.

**Night.** Take wood, food, and what the ground drops. Spend wood trying to light a fire, or walk with a light. Eat to buy a heart back. Sleep at the fire, or die in the cold and wake poorer, with the skills kept. Sitting by the fire is a complete night. It is not a failure to travel.

**Place.** The ground underfoot is one researched biome. Use the skills he already has on its trees and its food. Learn the one new skill or craft that biome is there to teach. Sleep there once. The trail keeps going.

**Journey.** The lands below, in that order, from the landing sea inland. The west shore is the end of the walk. After it, the woods are still there. Chilling is still play.

Getting better at the work is the challenge. It is not a grind gate. No biome, no crossing, and not the win, checks a skill level.

## Winning

He wins the first time he stands on the western shore, the last land in the ladder below.

The game shows one line, once: **The other sea.**

The save keeps going. Skills, fog, hearts, and the walk stay. There is no credits wipe and no turn-in. A house, a town, level 99, and a filled map are not the win. Death is not a loss of the run. The cold that takes the last half-heart still wakes him at the last fire he slept by, or on the landing, with the pack taxed and the skills kept.

## Progression

What he can feel, in order:

1. **The work gets easier.** A level changes that skill’s yield, speed, cost, or chance. The coast skills already do this. New skills do it the same way. A perk menu is not on this path.
2. **The ground changes.** The next land is a different researched place, with one new thing to learn.
3. **The maximum hearts grow.** The first time he sleeps through a night in a ladder land, his maximum gains one heart. Sleep does not fill hearts. Berries, and later a fish from the pack, are still the only heal.
4. **The fog remembers the walk.** The corner map and the continent map share one memory.
5. **The other sea.** The line above. Then he can walk home.

### Hearts

- He starts at **3** maximum hearts. That is the baked game. The admin slider on the title is machine QC.
- The first **C** sleep in each ladder land adds **1** to the maximum. Each land pays once.
- The cap is **9** (the start, plus one for each of the six lands). A later biome that is not a new ladder step does not raise the cap.
- Death sets his hearts to **1**. It does not lower the maximum.
- Old saves with no slept-land list start at 3. The next new sleep is what pays. Nothing is granted on load.
- **R** keeps the maximum and the slept lands, the way it keeps skills. It still clears the last sleep tile and the fog.
- When the admin hearts slider is the baked **3**, the save’s earned maximum is what he plays with. When the slider is anything else, that number is the maximum for the session and a sleep does not add to it.

### The continent map

- The corner minimap stays a small circle. A look still opens about 6 tiles. The trail he has walked stays clear.
- A single click on that minimap opens the continent map. Double-click stays the pack’s equip.
- The map draws the six ladder bands. A band he has never entered is a blank block with the ladder name. A band he has entered shows the same fog as the corner map.
- It is not an item in the pack. `docs/research/journey.md` stays a design file.
- The clock does not pause while the map is open. Night still spends hearts.
- Ship this when the plan says. The click can show blank inland bands before those chunks exist, so the next land is a rumor he can see.

## Skills

Woodcutting, fire-making, and foraging stay on the numbers in `docs/SKILLS.md`. They are signed off. Do not retune them, and do not move them onto the shared table below.

Every skill that is not in yet uses one shared table. Cumulative XP for level L is the Old School RuneScape total, integer-divided by 2:

```text
osrs(L) = floor( sum_{k=1}^{k=L-1} floor(k + 300 * 2^(k/7)) / 4 )
threshold(L) = osrs(L) // 2
```

Anchors an agent must test: level 2 is **41**, level 30 is **6,681**, level 92 is **3,258,626**, level 99 is **6,517,215**. Level 92 is half of level 99. The coast table is not these numbers. Coast level 99 stays **341,036**.

A level changes the work. Comfortable play is around level 30. The late tail is a stay in the woods, not a key.

| Skill | Where it is learned | What a level changes | Status |
|---|---|---|---|
| Woodcutting | `coastal_north`, then any land whose research lists a chop tree | Chops and wood, as shipped | In. Same XP on valley trees. |
| Fire-making | `coastal_north` | Catch and wood cost, as shipped | In. Valley wood is the same wood. |
| Foraging | `coastal_north`, then any land whose research lists a forage | Yield and eat cost, as shipped | In. Valley plants join the same handful. |
| Fishing | `river_valley` | Catch chance and fish per catch | Locked below. Not built. |
| The plains’ travel tool | `inland_plains`, after that research file names the material | The plan’s plains phase | Not named until the research exists. |
| The bayou’s water skill | `bayou`, after that research file says how the water works | The plan’s bayou phase | Not named until the research exists. |

There is no character level and no skill tree.

### Fishing

The river valley is where fishing is learned. The coast research names Atlantic fish as a group and does not list a catch, so the sea is not a fishery.

- **Tool.** A hand-line: **1 stick + 1 pitch**, made in the pack the way a torch is made. No bone. Caribou, hare, and the valley deer are not hunted. The line is one stack, cap **1**. It is not used up by a cast. Death’s extras tax can take it.
- **Equip.** One held tool. Equipping the line, the torch, or the raft unequips the other held tool. The unequipped one stays in the pack.
- **Cast.** Stand on a bank tile facing the main stem. **Space** with the line equipped casts. If a prop is on that facing tile, Space still does the prop (chop, pick, clear) and does not cast.
- **Water.** The main stem only. Brooks refuse. The landing sea refuses.
- **Catch table.** Weights out of 100, and nothing else: rainbow smelt **40**, gaspereau **30** (alewife and blueback are one stack), American shad **12**, American eel **10**, Atlantic salmon **8**. Sturgeon and striped bass are not catches.
- **Chance.** **40%** at level 1, climbing to **90%** at level 30, then 90%. A miss grants 0 XP and does not spend the line.
- **Yield.** **1** fish through level 29, **2** at 30–59, **3** at 60–99. XP is **20** per successful cast, on the shared table.
- **Eat.** Fish live in the pack, one stack per species, cap **99**. They are not the HUD forage count. A pack **Eat** on a fish stack spends one fish and heals half a heart. Full hearts refuse and spend nothing. **E** still spends forage.
- **Level-up.** The line says **Fishing is now 2.** The leaf burst is the stand-in. A new picture waits until someone names it on `docs/ART.md`.

### Foraging on new plants

One skill, one HUD count, one eat cost. A butternut, a grape, or a fiddlehead adds to the same forage number as a bakeapple. The pick hint names the plant. **E** still spends that count for half a heart. Fish do not enter this count.

### Wood on new trees

One wood count. Valley trees train Woodcutting with the coast XP (25 on the fall) and the coast yield for his level. Pitch stays a fir and spruce extra. The valley does not drop pitch or sticks. He brings the hand-line from the coast, or he walks back for stick and pitch. The coast stays useful.

## Lands

Fantasy is the length of the walk. The plants are the plants in `docs/research/biomes/`. Compass, so the landing sea is not “south along the rivers”:

- The landing sea stays south. `chunk_y > 0` stays water. He does not win by walking into that sea.
- Inland is decreasing `chunk_y`, the direction the caribou trail already points.
- “South along the rivers” and “west” are later bands on that inland road. They are the geographic fantasy. They are not a U-turn into the surf.

Chunks are 48×48. The coast strip stays `chunk_x` **−1..1**, `chunk_y` **0..−3**.

| Step | Id | `chunk_y` | What he learns there | Spawn |
|---|---|---|---|---|
| 1 | `coastal_north` | 0 through −3 | Woodcutting, fire-making, foraging. Already in. | Playable. Fir, spruce, bakeapple, blueberry. |
| 2 | `river_valley` | −4 through −7 | Fishing, and the raft. Old skills on new trees and new food. | Research is written. Spawn when the plan reaches it. |
| 3 | `inland_plains` | −8 through −11 | One travel tool, after research names the material. | Stub. Research before any spawn. |
| 4 | `bayou` | −12 through −15 | One way through water that is not a single river, after research. | Stub. Research before any spawn. |
| 5 | The later river country | −16 through −19 | Whatever that research file supports. The id is chosen in that file, from a real corridor. | No file yet. |
| 6 | The western shore | −20 through −23, and the win is the west edge of this band (`chunk_x <= -2` once the band is wide enough to have a west edge) | Arrival. The line **The other sea.** | No file yet. |

Until a phase turns a band on, the world does not generate it. The quiet edge stays the north side of the last band that is actually built. Empty biome resources stay empty until their spawn phase.

Night is the same cold in every land: 60 seconds, half a heart every 5 seconds away from a fire, berries the only heal, a lit torch slows that drain on the coast rule already shipped. Do not invent a warmer valley. Rime and balsam glints stay on the coast species that already draw them. The coast track stops at the valley. An empty `music_path` is silence.

### River valley, first spawn

Only this list, from `docs/research/biomes/river_valley.md`. Color boxes until a PixelLab row is named. No Wang sheet of the coast floor.

- **Chop:** sugar maple, yellow birch, American beech, northern red oak, eastern white pine, eastern hemlock.
- **Floodplain trees,** on ground within 4 tiles of the main stem, also chop: silver maple, butternut, bur oak, American elm, green ash, basswood. Butternut the tree is timber. Butternut the food is a separate ground plant, `forage_butternut`, on that same floodplain.
- **Forage:** `forage_butternut`, riverbank grape (a vine prop), ostrich-fern fiddlehead. All three train Foraging and fill the HUD forage count.
- **Ground:** intervale silt, clay-loam slopes, river water. No peat, no granite, no sphagnum, no bakeapple, no fir, no spruce.
- **Path:** one white-tailed deer on a one-tile intervale trail that continues `chunk_x == 0` from the coast seam to the near bank. Moss gaps, not a road. The same spook as the caribou: jog at 4 tiles, walk at 2, standing still does not spook, flee away, no despawn, Space does nothing, no hunt, no bone. Moose and the snowshoe hare wait.
- **Main stem:** a water barrier **6 tiles** thick, running the full width of the generated valley, centered on the middle of the valley band. It blocks walking the way the sea does. It is the fishable water and the raft water.
- **Brooks:** one tile wide, north–south, they stop when they meet the stem. He can walk them. He cannot fish them. A raft does not launch on them.

### The raft

The crossing is a carried raft, not a bridge left on the map.

- Pack button **Make raft** spends **12** wood from the HUD count. Cap **1**. Craft anywhere. The wood is spent at the craft, not at the launch.
- Equip it the same way as the line (one held tool).
- **Space** on a bank tile facing the main stem, raft equipped, moves him in that facing direction to the nearest walkable bank within **24** tiles. The slide does not leave him standing on water.
- Farther than 24 tiles: the hint **The river is too wide here.**
- A brook: the hint **He can wade this.**
- The landing sea refuses.
- The raft stays in the pack after the crossing, so he can pole back. Death’s extras tax can take it.
- A timber bridge left in the world, and the land-bridge tide, are not this crossing.

## What is not on this path

These stay in `docs/IDEAS.md` until the owner opens them. An agent building `docs/PLAN.md` does not slip them into a phase.

Perks. A hunger meter. Hunting, wolves, bears, sturgeon. NPCs, a house, a town. Tree regrowth timers. Seasonality, weather, fireflies. Pause. A player options menu. Bones. A fishing pole. More coast of the same forest as a substitute for the next land. Retuning the three coast skills. PixelLab from a cloud agent.

## How this meets the mission

Sensation is the ground changing underfoot and the fire at night. Fantasy is Leif on real species, on a walk that is shorter than the continent and stricter than a costume. Discovery is the next band and the fog. Submission is sleeping the night and walking after the win with nowhere he is required to be. Challenge is the work getting easier. Expression (a place he built) stays after this path, and it is not the win.
