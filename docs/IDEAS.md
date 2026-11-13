# Ideas

No order. Each open slice is one thing you could build. A heading only means those slices belong together. Nothing here is in build until you say so.

The loop, the skills, the lands, the hearts, the raft, fishing, the continent map, and the win are locked in [LOOP.md](LOOP.md). The build order is [PLAN.md](PLAN.md). A slice marked **Locked** points there. Do not re-ask it. When you ask what to work on next, the next unfinished phase in the plan is the answer, unless you asked for art, a bug, or a new wish.

When you ask what to work on next outside that plan, read the mission, the decisions, the status, and this file, and choose one open slice.

Taking in a new idea includes a pass over this file. Combine lines that are the same slice. Split a line that is more than one slice. Drop a duplicate. Then add questions. The questions are for the next agent to ask. They are not decisions. Do not fill in an answer that was not said. Rule: `.cursor/rules/ideas.mdc`.

[SLICE_0.md](SLICE_0.md) is what you can play now. The word for the land you walk is the map. Pictures that are still boxes live in [ART.md](ART.md). This file does not queue them.

## In

- **Home screen.** Title with New Game and Continue. Continue shows three files by the name he typed and the Costa Rica time. The floppy in the woods writes them. An x on a filled box deletes it after a yes. A run already survives quitting in those files, so a separate profile slice is not open.
- **Woodcutting.** In. A tree’s wood follows that skill. The earlier wish of 1, then 1–3, then 2–5 is not its own slice.
- **Fire-making.** In. Catch chance climbs through level 30; wood cost starts at 7 and drops after 30. Longer burn and a bigger warmth radius stay open wishes below if they return.
- **Admin mode.** In. A cream cog on the title opens QC sliders (day/night, hearts, XP curve, foliage %, walk/run). Save writes `user://admin_settings.json`. More knobs can still be added to the same panel.
- **Quit to the menu.** In. Escape in the woods asks quit to the main menu? Y/N. Yes returns to the title without closing the game. Not a pause screen.
- **Caribou.** In. Play signed off. One woodland caribou walks the trail, grazes, and runs away if he jogs at 4 tiles or walks at 2. No hunt. Eight-direction idle and walk are in. See [ART.md](ART.md).
- **Foraging.** In. Play signed off. Bakeapple and blueberry share it. Yield and eat cost follow the skill. PixelLab icon waits on generations.
- **No heart regen.** In. Play signed off. Day and fire warmth do not heal. Berries (**E**) are the only way hearts come back. Fire still sits the night.
- **Death and respawn.** In. Play signed off. Cold at the last half-heart is death. Cream skull on the black. Wake at the last slept fire (or the landing), half the pack gone, one heart, skills and map kept. PixelLab skull waits on generations.
- **Arctic hare.** In. Play signed off. Three arctic hares hop the moss beside the caribou trail, sit, and run away if he jogs at 4 tiles or walks at 2. No hunt. Eight-direction idle is in. The hop cycle still waits. See [ART.md](ART.md).

## Hearts

- **More hearts.** Locked. He starts at 3. The first sleep in each ladder land adds one to the maximum, cap 9. Death still wakes him at 1 heart and does not lower the maximum. Berries, and later a fish from the pack, are still the only heal. See [LOOP.md](LOOP.md).

## Night

On this coast. In the build, ready for Play, not signed off. Four slices. Dawn clears them. Sleep skips the night. The land bridge is not one of them.

- **Torchlight pitch.** At night a lit torch makes balsam blisters glint on standing fir and spruce. Space takes one pitch and does not chop. Dawn wipes a glint he left. The day fell still drops pitch at 10%. At most five a night, not on adjacent tiles, and only inside the torch pool. No woodcutting XP.
- **Rime.** Pale flecks on open moss and on the trail, at least four tiles apart, never on a trunk or on the caribou’s bed. They show with no torch. Look only. Dawn melts them.
- **The caribou’s bed.** The one caribou walks to a moss or peat cell 3–6 tiles off the trail and stays. Walking close does not make it run. A jog at 4 tiles still does, and then it does not return until the next night. Dawn puts it back on the nearest trail tile. Space does nothing.
- **Exploring with a torch.** A lit torch, away from a fire, makes the same half-heart take 10 seconds instead of 5. Walking and standing both count. An unlit torch does not. This is a rule on the torch, not the perk menu.

## Skills

- **Leveling.** Locked. Woodcutting, fire-making, and foraging keep the numbers in [SKILLS.md](SKILLS.md). Every skill that is not in yet uses the Old School RuneScape cumulative table, integer-divided by 2, so level 92 is half of level 99 and level 99 is 6,517,215. A level changes the work. Nothing in the journey checks a level. See [LOOP.md](LOOP.md).
- **Perks.** To brainstorm. A menu like Skyrim’s perks: at certain levels you add a bonus.
  - Ask: Is the bonus on one skill’s levels, or one track for him?
  - Ask: A skills mark already opens a panel. Is the perk list that panel, or another screen?
  - Ask: A perk has to change something the game already does, or is it allowed to add a new action? Do not invent the list.
  - The torch’s slower night drain is a rule on the lit torch, under Night. This menu does not add it.
- **Level-up animations.** Woodcutting and foraging burst leaves for now. Fire-making and foraging still want their own.
  - Ask: Foraging uses the leaf burst as a stand-in. Is its own animation a different picture, and what should fire-making show? Do not pick the picture.
  - Ask: The level line already says the skill and the new number. Does that line stay with the burst?
  - Ask: New pictures go through PixelLab. Generations are scarce. Is this worth a generation, or a picture already in the game?
- **Fishing skill.** Locked. It is learned on the river valley’s main stem, not the landing sea. The tool is a hand-line (1 stick + 1 pitch), not a bone pole. The catch is smelt, gaspereau, shad, eel, and salmon. A fish is eaten from the pack for half a heart. **E** still spends forage. The level-up line uses the leaf burst until a picture is named. See [LOOP.md](LOOP.md).

## The map

- **Uncovering the map.** Locked. The corner minimap stays. One click on it opens the six ladder bands. The same fog is on both. A band he has not entered is a blank block. The clock keeps running. It is not an item in the pack. Double-click stays equip in the pack. There is no third zoom. See [LOOP.md](LOOP.md).
- **Longer map.** Locked as the next land, not more of this forest. The coast strip stays `chunk_y` 0 through −3. The river valley is the next band. A save still loads from the seed. See [LOOP.md](LOOP.md) and [PLAN.md](PLAN.md) Phases B and C.
- **Tree and bush regrowth.** After a harvest, if that kind is gone from the area, a grow cycle starts on its own. A sapling appears, and after some time it is a tree. Bushes do the same. Today a chopped tree or a picked bush comes back from the seed when the file loads. This is a timed grow, not that.
  - Ask: How long is that time, in the days and nights the game already has? Do not invent the number.
  - Ask: How big is “the area”? A chunk, or what he can see?
  - Ask: A chopped tree leaves a stump. Does the sapling replace the stump?
  - Ask: Continue rebuilds trees and bushes from the seed. Does the grow cycle have to be stored in the save, or does it start over on load?
  - Ask: Bakeapple and blueberry are the bushes. Do they share one timer?
- **Less ground clutter.** About 5–10% less stuff on the ground.
  - Ask: Admin already has a foliage slider from empty woods to a little denser than today. Is this 5–10% the new default of that slider?
  - Ask: Which stuff: trees, bushes, rocks, branches, or the moss and needles?
- **Push rocks.**
  - Ask: Granite already blocks the tile. Does a push move it one tile the way he is facing?
  - Ask: What if the next tile is a tree, water, or the edge of the map?
  - Ask: Chopped trees come back from the seed on load. Should a pushed rock be remembered in the save, or return to where the seed put it?
- **Seasonality.**
  - Ask: The clock is day and night, not a year. Do days add up to a season, and how many seasons?
  - Ask: What is allowed to change: the look of the trees, which plants are out, or the cold at night? Do not invent the list.
  - Ask: Fireflies are a separate slice that wants summer. Does this slice have to exist before that one?
- **Fireflies.** Where they fit the season and the place. Summer, where that place has them.
  - Ask: They are not in `docs/research/biomes/coastal_north.md`. Do not add them until a research note says they belong on this map.
  - Ask: Seasonality is a separate slice. Do they wait until the year has a summer?
- **Weather.**
  - Ask: Night is already cold and dark. Is weather something you see, or something that spends hearts?
  - Ask: Can it put out a fire, or stop him walking?

## The river

- **River valley.** Locked as the next land after the coast strip. The first playable slice stops at the bank (Phase C). The raft is the phase after that. Species come from `docs/research/biomes/river_valley.md` and the spawn list in [LOOP.md](LOOP.md). Pictures stay boxes until you name a row in [ART.md](ART.md).
- **Land bridge when the water draws back.** Pinned. Not the first beach. Another biome: a river mouth, or something more swampy. The water recedes and he can cross. Not a coast night slice. Not the raft.
  - Ask: The valley notes mention estuary bars that ships clear on the tide. The swamp is a later biome. Which land is this, when that land exists?
  - Ask: This coast’s clock is day and night. A real tide is not only at night. Does the crossing use that night clock?
  - Ask: Raft or timber bridge is its own slice. Is this the same crossing, or the water leaving on its own?
- **Raft.** Locked. 12 wood, made in the pack, poled from a bank across the main stem, and it stays in the pack so he can come back. Brooks he wades. The landing sea refuses. A timber bridge left on the map is not this crossing. See [LOOP.md](LOOP.md).

## Creatures

- **Animals.** Beaver and later species. The caribou on the trail is in. The arctic hare on the moss is in. The valley’s first animal is locked: one white-tailed deer on the intervale, look-don’t-touch, same spook as the caribou. See [LOOP.md](LOOP.md).
  - Ask: Beaver is already in the coast research. Is that the next animal?
  - Ask: Caribou and hare are not hunted. Does a new animal stay that way?
  - Ask: Bear and wolf are in that research as later threats. Is a threat a different slice from an animal that only runs away?
- **NPCs.**
  - Ask: He is alone, and the story is the walk. Is this someone you see, someone you can talk to, or someone who sends you somewhere?
  - Ask: A person whose job is to hand out a task fights the mission. Is that what this is?
  - Ask: A town is a separate slice. Does a person wait until there is a place, or can one stand on this map?

## Pack and crafting

He called this a priority shift. These slices are one design. Crafting is the point of the extras. Decide what he wants to make, then ask this forest where those pieces can fall. A gap becomes its own slice.

He said crafting unlocks other skills. Fishing is the example.

Wood from a tree and berries from a bush stay as they are. They stay on the HUD at all times. They are the two locked necessities. The rucksack is not a second count of wood or berries.

- **Rucksack.** In. Play signed off. Backpack between skills and floppy. Mouse area of stacks (cap 99). Hover names the stack. Clicks are the bag; Space and keys still work the woods while it is open. Floppy and **R** keep extras. Death: 5–10% random tax on extras; wood and berries still half.
- **Drops (pitch and stick).** In. Stick 25% on a cleared branch. Pitch 10% on a fir/spruce fell (standing or log). Same pitch stack. Bushes: no extra.
- **Torch.** In. Play signed off. Make 1 stick + 1 pitch. Double-click equip (faded + E). Space on a burning fire lights it. Walking pool about half the campfire. Light only, one night, single use. PixelLab icons wait.
- **Crafting (more recipes).** The hand-line and the raft are locked in [LOOP.md](LOOP.md). They are pack buttons, like the torch. They make things the axe and **F** do not. Further recipes stay open.
  - Ask: The axe is already in hand, and a fire is already wood plus **F**. A new recipe has to be something those do not already do.
- **Bones.** Still open. The hand-line does not need one. The locked fishing craft is stick and pitch.
  - Ask: How does he get a bone, if a later recipe still wants one?
  - Ask: Caribou, hare, and the valley deer are not hunted. Is a bone from them, from something else, or from a source that is not an animal? Do not invent the source.
- **More extras.** Birch bark and spruce-root cord are attested at L’Anse aux Meadows but not spawned yet.
  - Ask: Is birch or cord the next drop, and what does it craft?
  - Ask: Do not invent feather, vine, acorn, or nut on this coast.

## A place you made
- **A house.**
  - Ask: Death already wakes him at the last fire he slept by, or on the landing. Is a house that place?
  - Ask: A save does not keep chopped trees. Should a house stay when the file loads, unlike a stump?
  - Ask: Wood is what he carries. Is that what it is built from, and is the amount open?
- **A town.**
  - Ask: NPCs are a separate slice. Does a town start as buildings, or does it wait until there are people?
  - Ask: A house is its own slice. Is a town more than one house, or something else?

## The shell

- **Hunger meter.** Eating is in: forage cost for half a heart follows Foraging. A ticking bar is not.
  - Ask: Cold already spends hearts at night, and berries are the only way they come back. Does hunger spend hearts too, or is it a second bar?
  - Ask: What spends it: time, walking, or the work of chopping and picking?
- **Steam page.**
  - Ask: What has to be in the game before a page is worth making?
- **Pause.** Still later. Escape in the woods is quit-to-menu, not pause.
  - Ask: Escape already asks whether to quit. Does pause use another key?
  - Ask: While it is open, does the night keep spending hearts and the fire keep burning?
- **Player options menu.** Still later. Admin on the title is machine-wide QC, not a player options screen.
  - Ask: Admin already changes hearts, speeds, day length, foliage, and the XP curve for this machine. Which of those, if any, belong in a menu a player opens?
