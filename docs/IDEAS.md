# Ideas

No order. Each open slice is one thing you could build. A heading only means those slices belong together. Nothing here is in build until you say so.

When you ask what to work on next, read the mission, the decisions, the status, and this file, and choose one slice.

Taking in a new idea includes a pass over this file. Combine lines that are the same slice. Split a line that is more than one slice. Drop a duplicate. Then add questions. The questions are for the next agent to ask. They are not decisions. Do not fill in an answer that was not said. Rule: `.cursor/rules/ideas.mdc`.

[SLICE_0.md](SLICE_0.md) is what you can play now. The word for the land you walk is the map.

## In

- **Home screen.** Title with New Game and Continue. Continue shows three files by the name he typed and the Costa Rica time. The floppy in the woods writes them. An x on a filled box deletes it after a yes. A run already survives quitting in those files, so a separate profile slice is not open.
- **Woodcutting.** In. A tree’s wood follows that skill. The earlier wish of 1, then 1–3, then 2–5 is not its own slice.
- **Fire-making.** In. Catch chance climbs through level 30; wood cost starts at 7 and drops after 30. Longer burn and a bigger warmth radius stay open wishes below if they return.
- **Admin mode.** In. A cream cog on the title opens QC sliders (day/night, hearts, XP curve, foliage %, walk/run). Save writes `user://admin_settings.json`. More knobs can still be added to the same panel.
- **Quit to the menu.** In. Escape in the woods asks quit to the main menu? Y/N. Yes returns to the title without closing the game. Not a pause screen.
- **Caribou.** In. Play signed off. One woodland caribou walks the trail, grazes, and runs away if he jogs at 4 tiles or walks at 2. No hunt. PixelLab walk art waits on generations.
- **Foraging.** In. Play signed off. Bakeapple and blueberry share it. Yield and eat cost follow the skill. PixelLab icon waits on generations.
- **No heart regen.** In. Play signed off. Day and fire warmth do not heal. Berries (**E**) are the only way hearts come back. Fire still sits the night.
- **Death and respawn.** In. Play signed off. Cold at the last half-heart is death. Cream skull on the black. Wake at the last slept fire (or the landing), half the pack gone, one heart, skills and map kept. PixelLab skull waits on generations.
- **Arctic hare.** In. Play signed off. Three arctic hares hop the moss beside the caribou trail, sit, and run away if he jogs at 4 tiles or walks at 2. No hunt. ColorRect until PixelLab walk art.

## Hearts

- **More hearts.** Pinned. Brainstorm later: how do you get more? Through tasks, new areas, or a skill?
  - Ask: He wakes from death with one heart. If the maximum can grow, does that wake still give one?
  - Ask: Admin already has a hearts slider for QC on this machine. Is a higher maximum the same number, or only something a player can earn?
  - Ask: Berries are the only way a heart comes back. Does “more hearts” mean a higher maximum, or a heart that does not last?

## Night

- **A reason to be out at night.** Going out costs hearts, and there is no reason to risk it yet. Pinned. Brainstorm later.
  - Ask: Night away from a fire spends hearts, and the last half-heart is death. What is out there that is worth that?
  - Ask: Is it something you can only do at night, or something that is gone by dawn?
  - Ask: Fireflies are a separate slice. Do not assume they are this reason.

## Skills

- **Leveling.** The shared curve for skills that are not in yet. Old School RuneScape’s experience curve is the inspiration ([Experience](https://oldschool.runescape.wiki/w/Experience)). Each skill has its own XP, and you get it by doing that skill. The step to the next level costs about 10% more XP than the step before it. From about level 30 the curve runs away: every 7 levels costs about as much as everything before them, so level 92 is half the XP of level 99. Their level 99 is 13,034,431 XP. That shape is what I like. Their grind is too long. Effort here from 0 to 99 starts at half of theirs, on that same kind of curve. What a level changes in the other systems is still open. It will matter. One case already dumped: how many logs a tree gives, or how fast a chop is. Woodcutting, fire-making, and foraging shipped on their own numbers in [SKILLS.md](SKILLS.md). It is not this curve.
  - Ask: The three skills that are in have their own numbers. Does the next skill use this shared curve, or its own table the way they did?
  - Ask: Perks are a separate slice. Does the level itself change the work, or only open a perk choice?
- **Perks.** To brainstorm. A menu like Skyrim’s perks: at certain levels you add a bonus.
  - Ask: Is the bonus on one skill’s levels, or one track for him?
  - Ask: A skills mark already opens a panel. Is the perk list that panel, or another screen?
  - Ask: A perk has to change something the game already does, or is it allowed to add a new action? Do not invent the list.
- **Level-up animations.** Woodcutting and foraging burst leaves for now. Fire-making and foraging still want their own.
  - Ask: Foraging uses the leaf burst as a stand-in. Is its own animation a different picture, and what should fire-making show? Do not pick the picture.
  - Ask: The level line already says the skill and the new number. Does that line stay with the burst?
  - Ask: New pictures go through PixelLab. Generations are scarce. Is this worth a generation, or a picture already in the game?
- **Fishing skill.**
  - Ask: The water on the map is the sea to the south. Is that where he fishes, or water that is not in the game yet?
  - Ask: The coast research names Atlantic fish as a group, not a catch list. Which fish, and does that need a research note before art or a spawn?
  - Ask: Berries are the only food that heals. Is a catch eaten for hearts, or is it something else?
  - Ask: A fishing pole is the worked example under Pack and crafting. Is this skill what that pole is for?
  - Ask: A new skill needs a level-up animation. That is its own slice.

## The map

- **Longer map.** The walk inland stops at the north edge of the strip.
  - Ask: The strip is built before he walks. Is more map more of that, still this same forest?
  - Ask: The river valley is a different slice. Where does “more of this map” stop and that land start?
  - Ask: A save stores the seed and where he stands. More land has to still load from that file.
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

- **River valley.** Land you can walk. Research is written. No art until you ask.
  - Ask: The crossing is the raft slice. Does this slice stop at the bank?
  - Ask: Plants and animals have to come from `docs/research/biomes/river_valley.md`. Do not add a species that is not in that file.
  - Ask: The playable map is one forest, built before he walks. Is this the next place after that strip, or a later one?
- **Raft or timber bridge.** A way across the river once that land exists.
  - Ask: Wood is what he carries today. Pack and crafting may add other materials. Is a raft still only wood, or does it wait until those extras exist?
  - Ask: The river is not on the map yet. Does this wait for the river valley slice?
  - Ask: Can he enter the water anywhere, or only at a spot?
  - Ask: He said raft or timber bridge. Which, or both?
  - Ask: If it breaks, what is left?

## Creatures

- **Animals.** Beaver and later species. The caribou on the trail is in. The arctic hare on the moss is in.
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
- **Crafting (more recipes).** Work backwards from the next thing. Fishing pole stays the worked example for later.
  - Ask: Is the fishing pole the next craft? Fishing is already its own slice.
  - Ask: Does crafting unlock Fishing, or can Fishing start without a crafted tool?
  - Ask: The axe is already in hand, and a fire is already wood plus **F**. Does crafting make things those do not, only?
  - Ask: Is crafting a screen on the rucksack, or the buttons he already uses?
  - Ask: The raft is its own slice. Do not fold it in unless he says they are the same.
- **Bones.** Still open. The fishing-pole example needs a bone.
  - Ask: How does he get a bone?
  - Ask: Caribou and hare are not hunted. Is a bone from them, from something else, or from a source that is not an animal? Do not invent the source.
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
