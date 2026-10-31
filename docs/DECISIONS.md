# Decision log

Append only. Newest at the top. Date, decision, why, what we rejected.

## 2026-10-30 — Playtest handoff, not a new pipeline

**Decision:** Cloud still writes verbs and research as a PR. This PC still presses Play and does PixelLab. The ceremony in between is harnessed. Session start names the branch, whether the tree is dirty, and any open PRs. A new local chat with exactly one open PR lands it and says Godot is ready. Sign-off words (`done`, `good`, `save`, and the rest) sync GitHub `main` to this PC: commit if needed, merge the playtest PR, checkout `main`, pull. Every phase change ends with one next-action line from `.cursor/rules/dev-loop.mdc`. Cloud never launches the Godot editor and never claims Play. Cloud writes **ready for Play** in `docs/STATUS.md`. The local sign-off writes **Play signed off**.

**Why:** The owner is a first-time vibe coder. “Pull the PR,” “tell me when Godot is ready,” and a sign-off that only pushed the feature branch were four prompts for a two-step job. They still click **Build in Cloud**, start a new local chat, and press Play.

**Rejected:** Dropping PRs. Auto-merge when CI is green. Auto-checkout inside the hook. A Cursor Automation for this. Opening Godot from the agent. Making this laptop the CI machine.

## 2026-10-30 — Death is signed off in Play

**Decision:** Play signed off death as shipped. Cold at the last half-heart fades to black with the cream skull. Sleep stays a blank blink. He wakes at dawn at the last slept fire (or the landing), wood and forage halved, one heart. Skills and the map stay. Hint stays **The cold took him. Half the pack is gone.** The placeholder skull stays; PixelLab does not spend generations on it in this sign-off.

**Why:** Owner Play: everything worked.

**Rejected:** Changing the tax, the wake place, or the skull art in this sign-off.

## 2026-10-30 — Death: half the pack, wake at the fire

**Decision:** Cold that would take the last half-heart is death. The screen fades to black like sleep. A cream skull and crossed bones (`game/art/ui/death_skull.png`, 32×32 placeholder) fades in on that black and holds about 0.8s. Sleep stays a blank blink. He wakes at dawn at the last tile he slept on (**C** by a fire). If he never slept this run, or the file has no `sleep_x` / `sleep_y`, he wakes on the landing. Wood and forage are halved (wood floors to a tenth; forage floors to a whole berry). Hearts become **1**. Skills, fog, caribou, and seed stay. Hint: **The cold took him. Half the pack is gone.** A named shore writes the floppy after death so Continue cannot undo it. **R** clears the sleep mark with the old ground. PixelLab does not spend generations on the skull in this cut.

**Why:** Night and berries-only heal were signed off with nothing ending the walk. Waking at the fire makes the camp load-bearing (submission, fantasy). Half the pack is the tax — not a corpse run, not a wipe of XP. Challenge is getting better at the work; a death that erases levels fights that. Discovery keeps the trail he already walked.

**Rejected:** Dropping the pack on the ground. Losing all wood and berries. Wiping XP or the map. Death during sleep, the quit ask, or the name box. Spending PixelLab generations on the skull. A scary or gory mark.

## 2026-10-30 — No heart regen is signed off in Play

**Decision:** Play signed off no heart regen as shipped. Daylight does not heal. Fire warmth does not heal — it only stops the night drain. **E** (Foraging eat cost) is the only way hearts come back. Eat cost stays 10→2. The last half-heart stays.

**Why:** Owner Play: tested and confirmed.

**Rejected:** Turning day or fire heal back on in this sign-off. Retuning the eat price.

## 2026-10-30 — No heart regen

**Decision:** Hearts do not come back on their own. Daylight does not heal. Fire warmth does not heal — it only stops the night drain. **E** (Foraging eat cost) is the only way hearts come back. Night away from a fire still spends half a heart every 5 seconds. The last half-heart stays. Sleep still skips to dawn and does not restore hearts. Eat cost stays as shipped (10→2). `heal_acc` is dropped from supplies and new saves; old files that still carry the key load and ignore it.

**Why:** Day and fire heal made berries optional. Berries as the only restore makes a cold night matter and makes the Foraging handful the way he stays (submission, fantasy, challenge). Fire stays how he sits the night.

**Rejected:** Keeping day heal. Keeping fire-warmth heal. Retuning the eat price in this cut. Death at 0 hearts.

## 2026-10-30 — Foraging is signed off in Play

**Decision:** Play signed off foraging as shipped. Bakeapple and blueberry share it. One-tap pick, 10 XP, yield 1→4, eat cost 10→2 on the current level. No miss. No stored berry quality. The icon stays empty until PixelLab.

**Why:** Owner Play: forage mechanics all working great.

**Rejected:** Changing yield, eat cost, or adding a miss in this sign-off.

## 2026-10-30 — Foraging is a skill on this biome

**Decision:** Foraging is in on `coastal_north`. Bakeapple and blueberry share it. **Space** still picks in one tap and always works. XP is **10** per pick on the same 1–30 OSRS then 3% table. Yield is whole berries: **1** through level 29, **2** at 30–49, **3** at 50–79, **4** at 80–99. Eat cost for half a heart is quality on the current Foraging level (no stored berry age): **10** at 1–10, then **9 / 8 / 7 / 6 / 5 / 4 / 3** each ten levels, floor **2** from 81–99. **E** always heals half a heart. The skills panel stacks a Foraging row under Fire-making. The floppy writes `forage_xp`. Old files without the key load as 0. **R** keeps it. Icon is empty until PixelLab replaces it. A miss is not in this Play.

**Why:** Challenge on this biome before more map. Berries already heal; getting better at the pick and the handful is why this place stays interesting after chop and fire. Quality on the skill, not the pack, keeps one forage count.

**Rejected:** A miss chance. Stored berry quality. Fractional hearts. Spending the last PixelLab generations on an icon. Cranberry in this cut.

## 2026-10-30 — Caribou on the trail is signed off in Play

**Decision:** Play signed off the woodland caribou as shipped. Walk, graze, spook at 4 tiles jogging / 2 tiles walking toward it, always-away flee faster than Leif, no despawn, no hunt. The ColorRect stays until PixelLab generations cover an 8-direction walk.

**Why:** Owner Play: it works great.

**Rejected:** Changing spook ranges or adding hunt in this sign-off.

## 2026-10-30 — One woodland caribou on the trail

**Decision:** The first animal is one woodland caribou (`Rangifer tarandus`) on the existing `coastal_north` trail. It walks that one-tile path, pauses to graze, and is look-don’t-touch: Space does nothing, no hunt, no meat. Jog toward it spooks at **4 tiles**. Walk toward it spooks at **2 tiles**. Standing still, walking away, or stepping onto the moss does not spook. Flee is always away from Leif, faster than his jog (~130 vs 100), along the trail. It does not despawn; it runs off screen and stays on the strip. It only steps toward him if every other way is blocked (log, tree, rock, water, or the strip edge). New Game puts it inland. Continue stores `caribou_x` / `caribou_y` / `caribou_facing` / `caribou_dir`. Old files without those keys seed-spawn inland. **R** builds a new one from the new seed. Art is the ColorRect fallback until PixelLab generations cover an 8-direction walk.

**Why:** The trail already said an animal made it. Seeing one is sensation, fantasy, and discovery. Hunting would need systems this coast does not have. Two spook ranges let him watch on foot and still flush it if he jogs in. Keeping the node when it leaves the view is how the woods stay real.

**Rejected:** A herd. Hunting or a Space verb. Despawning at the map edge. Spooking from standing still. Running toward Leif when an away step exists. Spending the last trial generations on an 8-direction object.

## 2026-10-30 — The save mark is a floppy disc

**Decision:** The top-right woods mark is a cream 16×16 floppy disc (`game/art/ui/save_floppy.png`), not two pause bars. Click still writes the shore. First click still asks for a name. The clickable square stays 28×28 at (448, 2).

**Why:** Play read the bars as pause.

**Rejected:** Keeping the bars. Spending PixelLab generations on `create_ui_asset`.

## 2026-10-30 — Foliage slider runs from empty to a little denser than today

**Decision:** The admin foliage knob is **−100% to +25%** against the baked scatter chances. 0 is today’s woods. The top is about a quarter denser, so today’s density sits near 80% of the max. The bottom can strip trees, forage, rocks, fallen logs, and ground clutter.

**Why:** Play: the old −50% floor still looked like a full forest, and doubling at +100% was more top than we wanted.

**Rejected:** Keeping −50 / +100. Changing the baked default in this pass.

## 2026-10-30 — Admin cog on the title; Escape quits to the menu

**Decision:** Admin is machine-wide QC on the title only, not a shore save and not a player options menu. A cream cog (already on `main` as `ca7c8ab`) opens an overlay with the first knobs: day length, night length (cold night; dawn stays a fixed 10s), hearts, XP curve scale, foliage/ground stuff percent, walk speed, run speed. Sliders update `AdminSettings` in session. Session values apply to the next New Game / Continue even if he skips Save. **Save** writes `user://admin_settings.json` (on this PC: `%APPDATA%\Godot\app_userdata\Leif in the Wind\admin_settings.json`) and shows that absolute path. **Reset** restores baked `DEFAULTS` in session only. Baked consts on DayClock / Player / Skills / Supplies stay the shipped numbers; live code reads `AdminSettings` at the point of use. Bake-later workflow: when a setting feels right, a later session reads the JSON and copies values into `DEFAULTS`. Escape in the woods is **Quit to the main menu?** Yes / No (and Y / N), not pause. Yes loads `title.tscn` without closing the game. No / N / Escape on the ask stays in the woods. The clock pauses while the ask is up so night does not drain. Walk, skills, and the floppy stay until he answers. Floppy is still how a shore is written; quit without it leaves the box as it was. No cog on the woods HUD.

**Why:** Tune day/night, hearts, XP, foliage, and speed while playing instead of playtest → tell Cursor → wait. Leave the woods without killing the process. Pause and a real options menu stay later ideas.

**Rejected:** Autoload for settings. Cog on the woods HUD. Admin as a third title Screen that replaces New Game / Continue. Escape as pause. A “save first?” prompt on quit. In-woods foliage rebuild / `World.refresh_strip`. Replacing the cream cog PNG.

## 2026-10-30 — Fire-making Play keeps the early miss

**Decision:** Play signed off fire-making as shipped. Early lights cost 7 and can miss. That is not too tough, and it is a motivator. Catch, wood cost, and XP stay. Longer burn and a bigger warmth radius stay later.

**Why:** Owner Play: the first fires worked as expected. The miss is the challenge, not a wall.

**Rejected:** Softening catch or cost after Play. Adding longer burn or a bigger pool in this sign-off.

## 2026-10-30 — Fire-making is a skill on this biome

**Decision:** Fire-making is in on `coastal_north`. **F** spends the level’s wood cost for an attempt. A miss still spends the wood; the hint stays **The fire does not catch.** Catch chance climbs from **35%** at level 1 to **95%** at level 30, then stays 95%. Wood cost is a flat **7** through level 30, then linear down to **1** at 99. XP is **40** per successful light (more than a fell’s 25). Fail grants 0. The two bars write `firemaking_xp` next to `woodcutting_xp`. Old files without the key load as 0. **R** keeps it. The skills panel stacks a Fire-making row under Woodcutting. A lit fire still burns one cold night and uses the same warmth radius. Live docs say **this biome** when they mean the playable skill ground, not “this coast” / “this shore.”

**Why:** Challenge on this biome before more map. Early nights should tax kindling; past 30, cheaper wood is the payoff. A miss burning a stack is why a light pays more XP than a tree. Longer burn and a bigger warmth radius can wait until this curve feels right in Play.

**Rejected:** Sure fire from level 1. Keeping cost at 3. Matching fell XP. Longer burn or warmer radius in this Play. Rewriting old decision paragraphs (append-only).

## 2026-10-29 — Fallen branches are drawn smaller

**Decision:** The fallen fir branch picture stays `clutter_fir_branch.png`, 32×32. The woods draw it at **0.7 scale** (about 30% smaller). Space still clears it for half a wood. It still does not block the walk. The title uses the same scale. Needles stay at the picture’s own size.

**Why:** At full size the branch was almost as wide as a standing fir. It should read as kindling on the ground, not a second tree.

**Rejected:** A new picture. Shrinking the PNG. Changing pay or walk-block.

## 2026-10-29 — Ideas have no order

**Decision:** `docs/IDEAS.md` is an unordered set of slices. A heading only groups slices that belong together. There is no queue. When the owner asks what to work on next, read the mission, the decisions, the status, and that file, and choose one slice. Taking in a new idea includes a pass over the file: combine lines that are the same slice, split a line that is more than one, and drop a duplicate. In that file the land you walk is called the map.

**Why:** The numbered order was choosing the work. They want that choice made when they ask, from the whole project. “Coast” in the ideas file was unclear. Crafting, a house, and a town were one line. Heart regen and more hearts belong in one group and stay two slices.

**Rejected:** A standing numbered list in the ideas file. Keeping a grab-bag line as one slice. Treating “ask what’s next” as a prompt to read a queue.

## 2026-10-28 — Woodcutting is a skill on this shore

**Decision:** Woodcutting is the first skill, on `coastal_north`. Fir, spruce, and fallen logs share it. A branch stays one tap, half a wood, and grants no XP. XP is granted only when the tree falls, 25 per fell. A bite that leaves it standing grants nothing.

A level-1 tree rolls **3 or 4** Spaces and pays **0.5 wood**. Yield is **3 at level 30** and **10 at 99**. Chops stay a range until level 80 (1–19: 3–4, 20–49: 2–3, 50–79: 1–2, 80–99: 1). A fire still costs 3 wood and always lights. Fire-making is not in this Play.

Levels 1–30 use Old School RuneScape’s XP table uncut. After 30 each step costs 3% more than the last. Level 92 is not half of 99. The two bars write `woodcutting_xp` in that shore’s file. Level is derived from it. Old files with no key load as 0. **R** keeps the XP. Continue still shows name and time. A skills mark sits left of the bars and opens a short panel with the level. Hover on the icon or number shows the step (`25/83`). A level-up drops green leaves around Leif and says **Woodcutting is now 2.**

**Why:** Today’s one-tap for 3 wood was the comfortable middle, not the start. The first hour should be clumsy. Kindling (branches) is how he lives; trees are the work. The OSRS late tail made 99 a grind for almost no extra wood. Half the early table would have stolen the part of that curve that feels good.

**Rejected:** Halving the whole OSRS table. Keeping 92 as half of 99. Capping yield at 5. A sure one-tap at 30. XP on a bite. Printing the level on Continue. A skill-tree screen. Fire-making in this Play.

## 2026-10-28 — Skills on this coast come before more map

**Decision:** Growing the coastal strip is not the next priority. The shore he can already walk is enough land. The first steps show the whole vocabulary of this forest, so more of the same ground is not the next discovery and is not the default suggestion. The next mechanic to open is leveling on `coastal_north`: woodcutting and fire-making. A skill shows up first in the biome that suits it. This one is trees, fallen branches, and cold. A caribou on the trail is a possible later option. The river valley stays researched and unbuilt until this coast is worth staying in. Do not recommend a longer coast, a new biome, or spawn tables as the next step.

**Why:** He can wander the strip and there is nothing new to do. He wants to enjoy this place before a biome with new things to learn. Agents had been biased toward expanding the map.

**Rejected:** Growing the quiet north edge as the next Play. Introducing woodcutting in a later forest. Starting `river_valley` so there is something new to see. Putting the caribou ahead of these skills.

## 2026-10-28 — A sign-off pushes

**Decision:** `perfect`, `everything is working`, `save and commit`, `all set`, `good`, `done`, and `push` commit if needed and then push. The reply says the hash is on GitHub only after `git push` succeeds. `perfect. everything is working. save and commit` is one sign-off.

**Why:** That sentence was committed as `c594e94` and the reply stopped at “only on this machine.” The owner wants GitHub `main` to match this PC. Stopping at a local commit missed the point of the rule.

**Rejected:** Pushing only when they say the word `push`. Telling them a sign-off is unpushed.

## 2026-10-28 — The save mark is two bars, and a lit fire waits

**Decision:** The button in the top right is a cassette pause mark: two vertical bars. It still writes the file. A fire that is burning when he saves is stored with the time it has left. Loading that file puts the fire back on the same tile, still burning, with that same time left. The burn does not run while the file sits on disk. Chopped trees and picked bushes still grow back from the seed. A fire that has already gone out is not stored.

**Why:** In Play the floppy read as a bad pause button, and a fire he had lit was gone after load. Sitting by that fire is the night (submission). The rest of the woods still comes from the seed.

**Rejected:** Saving stumps and picked bushes. Letting the fire keep burning after he quits.

## 2026-10-28 — An x deletes one shore

**Decision:** A filled Continue box, and a filled box on the overwrite list, has a small **x**. It asks **Are you sure you want to delete this save?** **No** and Escape leave the file. **Yes** removes that file and the box says **No save file** again. The other two stay.

**Why:** Three shores fill up. He needs a way to drop one without starting a new game over it.

**Rejected:** Deleting on the first click. An x on an empty box.

## 2026-10-28 — Three shores, written by the floppy

**Decision:** Continue’s three boxes are files in Godot’s user folder (`user://saves/slot_0.json` through `slot_2.json`). An empty box still says **No save file** and does nothing. **New Game** claims the first empty box and writes nothing yet. A floppy in the top right of the woods writes that box. The first click asks **Enter save name.** Later clicks keep the name and move the time. Continue shows the name and the save time in Costa Rica, UTC−6, labeled CST. Loading a file leaves the same way New Game does, then he is where he saved: seed, place, facing, wood, forage, hearts, the map he uncovered, and time of day. Chopped trees, picked bushes, and fires come back from the seed. If all three boxes have a file, New Game asks before it overwrites, then which box. The old file stays until that run’s first floppy. Quitting without the floppy leaves the box as it was. There is no account. The same three files are what an export uses, and later Steam Auto-Cloud can watch that folder. The Godot project name stays **Leif in the Wind**, because that is the folder name.

**Why:** The walk was gone on quit. The name and the clock time are how the three shores stay telling apart (discovery, submission). A chopped tree growing back keeps this cut to the walk, not a second copy of the whole woods.

**Rejected:** Writing the file on its own while he plays. Wiping a box the moment New Game is chosen. Showing the seed on the button. Saving stumps and fires in this cut.

## 2026-10-28 — Minimap opens a small circle

**Decision:** The corner map stays 41×41, one pixel per tile, bottom-left. A look opens a circle of **6 tiles** around Leif. Ground he has uncovered stays clear when he walks on. **R** wipes the walk. He stays the cream pip.

**Why:** Opening every tile on the screen drew a rectangle that filled the circle in one glance. The wanted picture is a smaller circle, with the trail left behind.

**Rejected:** Opening the whole play view. Opening only the cell under his feet. One pixel covering several tiles.

## 2026-10-28 — Sign-off words run git

**Decision:** `commit`, `save`, `save and commit`, `all set`, `good`, `done`, `all done`, and `push` are the order to commit in that turn. The reply’s hash comes from `git log -1` after the command succeeds. `push` also pushes. A follow-on note (`good, but…`) is still notes, not a sign-off.

**Why:** “good! all done, save and commit” was answered with a hash and “has not been pushed” as if git had run. The owner wants those words to be the commit.

**Rejected:** Asking whether to commit after a sign-off. Reporting a commit that was only described.

## 2026-10-28 — Sphagnum is a small patch on the moss

**Decision:** The sphagnum picture stays 32×32, including the bottom-right of the cushion. It is stamped at half size (16×16, nearest neighbor) onto its tile after the ground is painted. It stays scenery: not firewood, and it does not block the walk. Needles stay at the picture’s own size. The title still uses the same half size.

**Why:** At full size the yellow cushion was as wide as Leif is tall, so it read as a bush sitting on the moss. Half size fits one tile and sits under him as patchy ground cover.

**Rejected:** A new picture. Cropping the cushion. Shrinking needles and branches with it.

## 2026-10-28 — Ground is painted before the cushions

**Decision:** For each slice of a chunk, the moss, shore, and trail are painted first. Sphagnum and needles are stamped after that. A cushion stays wider than one tile.

**Why:** Each cushion hangs eight pixels into the next tile. Painting that tile’s ground afterwards covered the right edge, so every yellow cushion looked bitten on the bottom-right.

**Rejected:** Editing only the cushion picture. The picture was already on screen, and the next tile was covering it.

## 2026-10-28 — The view is not stacked with the trees

**Decision:** The camera stays on Leif with smoothing off, but it is no longer his child. It follows his position from outside the y-sorted woods. Walk stays 70. Jog stays 100. Bumping a rock slides along it by this frame’s small step. The picture stays the scaled 480×270.

**Why:** Leif is restacked among the trees whenever his height changes. The view was on him, so up, down, and diagonals hitched. Left and right do not change that order, which is why they felt fine. Stepping in whole pixels did not remove the hitch, and a bump then threw him forward.

**Rejected:** Whole-pixel steps. Camera smoothing. Drawing at the window’s own size.

## 2026-10-28 — A diagonal jog steps both ways at once

**Decision:** Leif moves in whole pixels. On a diagonal, horizontal and vertical step by the same count in the same moment. Walk stays 70. Jog stays 100, and only while the double-tapped key is still held. The camera stays on him with smoothing off. The picture stays the scaled 480×270.

**Why:** The clip shows a straight jog sliding on one line, and a diagonal jog lurching: a bit more sideways, then a bit more up or down. The chunky picture can only move a whole pixel at a time, and those two pixels were not landing together.

**Rejected:** Drawing at the window’s own size (that smoothed the font and made up-and-down chug). Camera smoothing.

## 2026-10-28 — The chunky picture stays

**Decision:** The game draws a **480×270** picture and scales that picture to the window (`viewport`, keep, fractional). The font is that same picture, so the letters stay blocky. Walk stays 70. Jog stays 100. The camera stays on Leif with smoothing off.

**Why:** Drawing at the window’s own size replaced the blocky font with a smooth one, and up-and-down movement chugged from spot to spot. Left and right were fine. That was worse than the diagonal chop.

**Rejected:** `canvas_items` stretch. Keeping the smooth font.

## 2026-10-28 — A diagonal jog is one slide

**Decision:** The 480×270 play size stays. The picture is drawn at the window’s own size (`canvas_items`), still kept in proportion, still fractional. The camera stays on Leif with smoothing off. Walk stays 70. Jog stays 100, and only while the double-tapped key is still held.

**Why:** The game was painting a 480×270 picture and then enlarging it. On that coarse grid a diagonal jog steps sideways, then down. A straight jog hid it, because the whole picture stepped along one line. Turning pixel snap off did not change the feel. The grid was the picture itself.

**Rejected:** Camera smoothing. Changing walk or jog speed. Pixel snap as the fix. Integer scale (this screen cannot fit 3× without black bars).

## 2026-10-28 — Three berries heal half a heart

**Decision:** A pick still grants **1** forage. **E** spends **3** forage to heal half a heart, the same price shape as 3 wood for a fire. Fewer than 3 refuses and spends nothing. Full hearts refuse and spend nothing. A bite still never goes past max. There is no hunger bar.

**Why:** One berry for half a heart made the handful too strong next to the fire, which already asks for three of a thing. Berries stay a way to sit the night or keep walking (submission, fantasy). They are not a grind, a cook, or a skill.

**Rejected:** Healing on one berry. Spending a partial handful. A hunger meter.

## 2026-10-28 — Ideas is a dump, not an interview

**Decision:** `docs/IDEAS.md` keeps one line per idea, in the owner’s words. Logging it does not start a design conversation. Dig into an idea only when they ask to open that one.

**Why:** The owner uses that file as a dumping ground. Writing options and questions on the way in was getting ahead of them.

**Rejected:** A design brief, a build order, or follow-up questions for every dump.

## 2026-10-28 — Bugs that are not this Play go in a backlog

**Decision:** Breaks the owner finds that are not the current playtest go in `docs/BUGS.md`. Each one is its own heading: what they saw, what the game is supposed to do, and where it showed up. Logging a bug does not start the fix. A later “do some bug fixes” session reads that file and names the open headings, in those words, before changing the game. New wishes stay in `docs/IDEAS.md`. Feedback on the feature being signed off stays in that session. GitHub Actions requires `docs/BUGS.md` and `docs/IDEAS.md` to exist.

**Why:** The owner will keep finding breaks while playing other things. Those need a home that does not take over the current slice, and a later fix session has to quote what was written.

**Rejected:** Fixing a parked bug in the same turn it was reported. Parking breaks inside the slice doc, in status as next work, or as ideas. Treating chat memory as the bug list.

## 2026-10-28 — The coast fills the title; the menu is a box on top

**Decision:** The title background is the coastal still from the top of the screen to the water. A green box sits on that picture and holds **New Game** and **Continue**. There is no Start button. **New Game** starts building the woods at once: the box fades, then Leif turns so his back faces you and walks inland. That walk is the loading screen. **Continue** opens the three file boxes. An empty box does nothing. Choosing a file that exists leaves the same way New Game does.

**Why:** The flat green was covering the woods. The owner wants to see the coast behind the menu, then watch that menu leave as Leif walks into the trees.

**Rejected:** A full-width green slab. A Start button in front of New Game and Continue. Turning him around before the box has faded.

## 2026-10-28 — Title coast, hover only, walk while the woods load

**Decision:** The menu sits on a flat green block. Behind and below it is a coastal still made from the existing shore tiles, fir, spruce, granite, bakeapple, blueberry, sphagnum, needles, a branch, and a fallen fir. Buttons stay plain until the pointer is on them. **New Game** hides that block, turns Leif so his back faces the camera, and he walks inland while the coast is built a slice at a time. Then the real woods appear. Empty Continue boxes still do nothing.

**Why:** The first button was lit just because it was first. New Game sat on a blank wait of several seconds. The still he leaves should be the same kind of shore the game starts on, so the walk reads as entering the woods.

**Rejected:** A keyboard highlight on the first row. A separate loading caption. Building the whole strip in one freeze before he can move.

## 2026-10-28 — Title screen, then New Game or Continue

**Decision:** Play opens on a title. One button, **Start**, then **New Game** or **Continue**. Continue shows three boxes that say **No save file**. Nothing is saved or loaded. New Game opens the same woods as before (seed 11). The picture behind the menu is the existing Leif (facing the camera, half scale), one fir, one spruce, and a short water-and-shore band from the Wang sheets. The title is silent. Escape steps back on the menu and does nothing on the title. Escape in the woods is reserved for a pause screen, which is not built. There is no options menu and no way back to the title from the woods.

**Why:** The owner wanted a front door before saves exist, so the next cut has somewhere to hang three files. The art is already in the game (sensation). Each empty box says “No save file,” with no second line. Pause stays a later idea so this cut is only the launch menu.

**Rejected:** A settings menu. Writing a save in this cut. Opening pause from the woods now. A generated chunk behind the title. New PixelLab art. Title music. The line “No shore saved yet.”

## 2026-10-28 — A Play sign-off is the commit

**Decision:** When the owner signs off a Play, commit that work in the same session. Do not ask whether to commit. GitHub `main` is the brain. A signed-off change left only in the working tree is not done.

**Why:** Eating worked, and the owner still had to answer “say if you want them committed.” They do not want that ask each time.

**Rejected:** Waiting for a separate commit request after a sign-off. Leaving signed-off Play only on this PC.

## 2026-10-28 — E eats one berry for half a heart

**Decision:** Press **E** to eat 1 forage already in hand and heal **half a heart**. Bakeapple and blueberry share that one count. Empty hands refuse. Hearts already at max refuse, and a bite never goes past max. There is no hunger bar and no starve clock. Day heal, fire heal, and night cold stay as they are. **E** during the sleep blink does nothing.

**Why:** The berries were carried and did nothing. Eating one is survival that lets him stay: a cold night still costs hearts, and a berry buys half of one back. That serves **submission** (sit the night, or keep the walk going) and **fantasy** (these are the coastal berries, eaten as picked). It is not a grind, not cooking, and not a skill.

**Rejected:** A hunger meter that ticks while walking. A starve clock. Cooking. Death. Healing a full heart per bite. Eating past max. Remembering which berry is which.

## 2026-10-28 — Each dumped idea stays open until we talk it through

**Decision:** Home screen, profile, death and respawn, skills and leveling, animals, and NPCs are separate ideas in `docs/IDEAS.md`. A longer coast is its own idea too. None of them is in build. Draft answers from this chat (one local save, a Continue / New shore screen, waking at the last fire, chop-and-fire with no level number, a caribou you can see) are notes inside those ideas, not locked choices. An idea is pulled into a slice only after its own conversation, when you say it is ready.

**Why:** The owner asked for them to be fleshed out as separate ideas. The backlog had collapsed them into one sequence and treated the drafts as decisions.

**Rejected:** A build order that chains them. Starting the save, the start screen, or a longer strip before that idea has been talked through. Keeping animals and NPCs as one item.

## 2026-10-28 — A longer coast is not a gate

**Decision:** Growing the `coastal_north` strip and adding a local save are both ready. Either can be the next Play. The save may come first. Skills and death still wait: skills because the first chops get clumsier and fires start failing, death because three hearts cannot buy a cold night. “A place you would stay” means the current camping is worth keeping, not that the map got bigger.

**Why:** The owner asked why fun had to wait on more map. It does not. The quiet north edge is one hole. Losing the walk on quit is another. A long strip with no save is how an evening disappears.

**Rejected:** Holding the save, the start screen, and the caribou until the strip grows. Treating map size as the reason skills and death wait.

## 2026-10-28 — A profile is one local save; the first creature is a caribou

**Decision:** A profile is one save on this PC (name, seed, place, supplies, hearts, fog, time of day). No account. The start screen is Continue and New shore, and it comes after that save loads. Death, when it exists, wakes Leif at the last fire he slept by, or on the landing if he never slept, on the same seed. Skills stay woodcutting and fire-making in `docs/SKILLS.md`, with no character level. The first animal is a coastal caribou you can see on the trail. People you talk to stay unscheduled. None of this jumps ahead of growing the coastal strip.

**Why:** Home, save, death, skills, and creatures arrived as one dump. The save is what the others hang on. A login, a level number, or a quest giver would be a different game. A caribou matches the trail that is already in the woods. Wolves and a talking person would need systems this coast does not have.

**Rejected:** A user account. Several save slots in the first save cut. A skill-tree level. A quest NPC as the first “animal.” Building any of this before the strip grows inland.

## 2026-10-28 — Ideas live in a backlog

**Decision:** Brain-dump ideas go in `docs/IDEAS.md`, sequenced coast-first, one playable change at a time. `docs/SLICE_0.md` stays the current cut. Pulling an idea into a slice is a separate choice.

**Why:** The owner will keep a running ideas chat. The coast is already a game. New wishes need a home that does not turn the playable cut into a wishlist, and one change per Play so we can tell what helped.

**Rejected:** Appending every idea to the slice doc or to status as if it were next. Building from a dump in the same turn it was said.

## 2026-10-27 — Fir and spruce stump sprites swapped

**Decision:** `stump_fir.png` and `stump_spruce.png` swapped. The larger leftover sits under the larger tree.

**Why:** Owner Play: the stumps were right, the pairing was backwards.

**Rejected:** Regenerating. Changing scale again.

## 2026-10-27 — Ringed stumps stay; they are drawn smaller

**Decision:** Chop leftovers use the first PixelLab stumps (`stump_fir.png` / `stump_spruce.png`, 32×32, rings and bark) drawn at **0.6 scale**. The PNG is not downsampled. Flattening to 16×16 killed the depth. Half-size trees are not the leftover.

**Why:** Owner Play: those first sprites looked the most like real stumps, just too big. The 16×16 crush and the tiny-tree leftover both looked flat.

**Rejected:** Another PixelLab generation. Keeping the 16×16 oval. Using the standing-tree PNG scaled down.

## 2026-10-27 — Fog opens the play view; leftovers are the tree, smaller

**Decision:** The corner map still only remembers land Leif has seen, but a look opens **every tile on the 480×270 screen**, not the one cell under his feet. Chopped fir and spruce leave the **same tree PNG at half size** (nearest-neighbor). The generated stump blobs are gone.

**Why:** Owner Play: one-pixel reveal felt empty; they wanted the map to match what he can see. The generated stumps looked like mushrooms. The existing fir/spruce art, just smaller, is the leftover they asked for.

**Rejected:** Keeping the mushroom stumps. Another PixelLab stump pass. Revealing a radius that is not the play view.

## 2026-10-27 — Corner map is the walked strip; stumps are named PNGs

**Decision:** The bottom-left minimap is **48×64**, one pixel per 3 world tiles, so the prebuilt `coastal_north` strip fits. Fog opens **only the cell Leif stands on**, not a radius. A map pixel lights if any of its 3×3 was walked. **R** wipes the walk. Leif is a cream pip. Chopped fir and spruce leave `stump_fir.png` / `stump_spruce.png` (32×32, high top-down, same `create_map_object` path as granite and forage). ColorRect fallback stays if a file is missing. Fallen logs still leave no stump.

**Why:** Owner asked to see where they have been on this coast, and for a stump when a tree is gone. A 16×16 canvas is PixelLab’s floor for `create_object_pro_flash` only; `create_map_object` starts at 32, and a 16-pixel stump is a speck under the 48×64 trees. 32×32 matches the other tile props. The corner map serves **discovery** (the shore appears as he walks it) without becoming a held parchment.

**Rejected:** A 16×16 stump canvas. Revealing a radius around him. Showing the `journey.md` continent. Growing the strip or starting `river_valley` as land.

## 2026-10-27 — Tiny fog-of-war minimap, not a map he holds

**Decision:** There is **no handheld world map**. Orientation is a **small minimap in the bottom-left** with fog of war. Simple. The schematic continent in `docs/research/journey.md` stays a design file, not an item.

**Why:** Owner: the long-aim map as something Leif carries is the wrong toy. They want to see where they have been on this coast, not open a parchment.

**Rejected:** A map item in the pack. A full-screen overworld. Filling fog for the whole continent this slice.

## 2026-10-27 — First grove loops on coastal_north

**Decision:** The first biome bed is `The First Grove` (`game/art/coastal_north/the_first_grove.mp3`), about three minutes, **looped**. It lives on the `Biome` resource as `music_path`, not hardcoded to World, so a later biome can bring its own track. Pressing R does not restart it. Sleep does not stop it.

**Why:** Owner brought the soundtrack for the first woods. Sensation is a current aesthetic. Music as biome data keeps the continent from becoming a one-off Level1 playlist.

**Rejected:** A global playlist. Restarting the track on every new seed. Silence during sleep.

## 2026-10-27 — Longer night, log spans, fires burn out

**Decision:** The cold night is **60 seconds** (~6 hearts at ½ / 5s). Dawn is still 10 seconds after that. A 3-heart newbie cannot stand the night; more hearts come later. Fallen logs block their full length (the 64px fir log is five tiles, not one). A campfire burns **one night** of wood and goes out. Sleeping to dawn spends that same time, so a fire you slept through is ash.

**Why:** Owner could almost stand the old night. They asked for ~1.5× / six hearts of cold, ends of logs that actually stop you, and fires that do not last forever. Sleep blink stays as signed off.

**Rejected:** Death at 0 this slice. Fires that persist across seeds. Changing the log art.

## 2026-10-27 — Half-heart cold and heal; sleep blinks; occupancy cache

**Decision:** Night away from a fire spends **half a heart every 5 seconds**. Day or fire warmth heals **half a heart every 10 seconds**. The last half-heart stays (no death this slice). **C** sleep fades to black, holds a blink, then fades in on dawn so the woods lighten as he wakes. Walk-block, occupancy, usable props, and campfires are occupancy maps — not a child scan every footstep or Space.

**Why:** 18 seconds per full heart was too generous. Owner asked for slow natural heal and a lights-out blink on sleep. Run + Space-spam felt like the camera lagged the player because each move frame walked every sprite in the chunk.

**Rejected:** Death at 0. Camera smoothing (that would sit further behind). Skills in this cut.

## 2026-10-27 — Rocks and logs block; night is cold; C sleeps at a fire. Skills wait.

**Decision:** Standing trees, granite rocks, fallen logs, and campfires **block walking**. Berry bushes and loose branches do not. Night away from a fire spends a heart every 18 seconds; the last heart stays (no death this slice). Within about 3.5 tiles of a campfire he is warm. **C** at dusk or night by a fire skips to dawn. Woodcutting and fire-making **skills** are planned in `docs/SKILLS.md` and stay off this Play. Today’s 1-tap / 3 wood / sure fire is the future mid-skill feel.

**Why:** Owner signed off the three next steps and asked when skills should land. Challenge is a later aesthetic. Mixing fail-chance and multi-tap with cold and blocking would hide which change hurt.

**Rejected:** Hunger that ticks while exploring. Dying at 0 hearts. Adding woodcutting XP in the same cut. Pushing rocks (still later).

## 2026-10-27 — Prebuild a coastal strip; bake the floor; do not generate while walking

**Decision:** Slice 0 is a **prebuilt** `coastal_north` strip (3 chunks east-west, 4 north from the landing). It is still seed-generated. It is not generated while Leif walks. Each chunk’s moss/shore/trail and the sphagnum/needle litter are **one baked image**. Only trees, forage, rocks, fallen logs, and clearable branches stay as nodes. Far chunks hide. Crossing a seam only reparents him. The far north of the strip is a quiet edge until we grow the continent later.

**Why:** Owner Play: streaming one chunk per frame made the whole walk choppy; the big window hitching on every footstep; Space lagged; the seam still hitched. They asked for a seamless forest, not live generation.

**Rejected:** Building woods during the walk. Redrawing 2,300 Wang tiles every frame. Keeping moss cushions as nodes.

## 2026-10-27 — Fun is sensation, fantasy, discovery, submission — not only inland motion

**Decision:** The mission now names Hunicke / LeBlanc / Zubek’s MDA aesthetics. Current fun: **sensation**, **fantasy**, **discovery**, **submission**. Later: **expression** (house, town, crafting) and **challenge** (skill trees that raise efficiency or unlock better output). Narrative-as-plot and fellowship stay out. Features are judged by whether the woods are worth being in, not by whether Leif’s coordinate changed. Sitting by a fire is valid play. The continent and inland pull stay; they are the discovery/fantasy spine, not the only pass.

**Why:** Owner: the goal is not simply “get Leif moving.” They want exploration and chilling out. The old review question (*how does this help Leif go inland?*) treated motion as the win and made lingering look like waste.

**Rejected:** Treating inland travel as the only mission test. Adding town-building or mastery trees in this slice. Turning the camp into a win condition. Authored plot or multiplayer as the hook.

## 2026-10-27 — Stream chunks ahead; fill the Game view by keeping aspect

**Decision:** Neighbor woods generate **ahead of the walk**, one chunk per frame, tiles first, then a few props per frame. Wang sheets and plant textures load once and are reused. Crossing a seam does not build a 3×3 of sprites on the spot. Walk-blocking uses a cheap ground peek if that chunk is not ready. The editor Game view for this project is **Keep Aspect Ratio** so the 480×270 picture fills the panel instead of sitting at Fixed Size in a black frame.

**Why:** Owner Play: 2–3 second hitch at the chunk line, and the live view was a postage stamp at 1.0× speed in a 1368×770 Game tab.

**Rejected:** Building the whole next ring when he steps over the line. Making the viewport itself bigger (that shows more world, not a bigger picture).

## 2026-10-27 — The coast is a strip of chunks; walking north loads more woods

**Decision:** Slice 0 is still `coastal_north`, but it is no longer one boxed chunk. The world keeps a 3×3 of seed-generated chunks around Leif. Sea is south of the whole shore (`chunk_y > 0` is water; every `chunk_y == 0` has a south beach). The caribou trail continues on `chunk_x == 0` into the north woods. Distant chunks unload; fires on them go with the old ground, same as **R**. Player stays a child of the chunk he stands on so trees still Y-sort. No new biome.

**Why:** The trail said inland, then the north edge counted as water. That fought the mission. Streaming more coastal woods is how he actually goes inland.

**Rejected:** A second painted level. Loading `river_valley`. Keeping the camera locked to chunk (0,0). Treating east/west of the landing as more ocean.

## 2026-10-27 — Long aim is west; world map is a later artifact, not a new biome pass

**Decision:** Slice 0 stays `coastal_north`. The long walk is: leave Newfoundland, go south using the rivers, then across the later United States toward the Pacific. That is compressed journey length, same as the mission already says. A **world map** (even a schematic one) is on the enhancement list so the continent stays visible. It is not baked into the chunk. Do not research more biomes until this shore is the game we mean to keep playing.

**Why:** Owner Play: river-valley research is right, but they do not want more-more-more biomes right now. They still want the west-coast aim written down so later work has a spine.

**Rejected:** Starting `inland_plains` or west-coast species lists. Painting a Level1 overworld. Treating the river-valley draft as the next playable land.

## 2026-10-27 — Fallen branches clear for 0.5 wood; the trail is a game path

**Decision:** Space on a piney fallen branch (`kind=branch`, species `fir_branch`) removes it and adds **0.5 wood**. Standing trees and fallen logs still add **3**. Sphagnum and needles stay scenery. Wood is a tenth-rounded float so two branches make one fire-log. The caribou trail is **one tile wide**, with moss gaps, so it reads as an animal path and not a road.

**Why:** Owner Play: the woods felt cluttered, and those branches should be clearable firewood. The two-tile trail looked too established.

**Rejected:** Making moss or needles firewood. Changing tree/log pay. Widening the trail. Blocking walk with branches.

## 2026-10-27 — Granite is a rock object; floor clutter is boreal; obstacles later

**Decision:** Big rocks are no longer painted into Wang tiles. The generator scatters **granite** props (`kind=rock`) on moss/peat. They occupy a tile (no fire there) but do **not** block walking and do **not** react to Space. Forest-floor clutter is sphagnum cushions, fir/spruce needles, and short fallen branches — not deciduous leaves. Clutter does not occupy. Rare **fallen** fir/spruce logs are choppable for the same wood as a standing tree and leave no stump. Player collision, pushing rocks, and seasonality are later work.

**Why:** Owner Play: baked granite looked like something you should move; repeating moss dots felt sterile; they asked for biome-fitting litter and named fallen trees as wood sources.

**Rejected:** Maple/oak leaves. Making rocks or fallen logs block the player in this pass. Baking boulders back into the moss sheet. Seasonality now.

## 2026-10-27 — Wire the PixelLab Wang sheets; do not buy an itch floor yet

**Decision:** The chunk draws the four existing PixelLab tileset15 sheets (`water_shore`, `shore_moss`, `moss_trail`, `moss_granite`) with 4-corner Wang matching. Peat uses the moss tiles. Off-map south is water; north stays moss so the inland edge is not a fake beach. ColorRects stay as fallback. Recolor later with `pixelart_workbench` if Play says a sheet is too muddy. Itch packs stay a backup.

**Why:** Owner asked to wire what we have. Those sheets already say moss, peat, granite, trail, and shore. A new generate or an itch grass pack would spend gens or fight Vinland ground.

**Rejected:** Regenerating the floor. Downloading an itch pack first. Treating off-map as water on every edge.

## 2026-10-27 — `river_valley` is the Saint John and inner Miramichi, not a generic oak wood

**Decision:** The inland river-valley biome is the temperate deciduous valley of the Saint John River and the inner Southwest Miramichi (about 46–47°N), in the 11th century. Signature plants are the hardwoods coastal North saved for inland: butternut, riverbank grape, basswood, elm, beech, ash, plus maple, oak, and hemlock. The ground is intervale silt over clay and clay loam, not peat and granite. The main river is a barrier (raft or timber bridge). Intervale trails are white-tailed deer. Moose are native here. Coyote is not. Caribou stay the coastal trail, not this one. Full list and sources: `docs/research/biomes/river_valley.md`. No spawn table, art, or PixelLab prompt until the owner skims that file.

**Why:** Mission row 2 is this valley. Wallace’s butternuts and grapes from L’Anse aux Meadows point here, not at the Newfoundland shore. Copying the coastal species list, or inventing a generic forest, would erase the first biome change.

**Rejected:** A generic oak-maple-birch list with no sources. Treating New Brunswick moose like Newfoundland’s introduced moose. Letting coyote or caribou define the valley. Filling `river_valley.tres` in the same pass as the research.

## 2026-10-27 — Play window fills the largest 16:9 that fits; F11 fullscreen

**Decision:** The game stays **480×270**. The play window is resized at launch to the largest 16:9 rectangle on the usable screen, with `viewport` stretch, `aspect=keep`, and **fractional** scale. **F11** toggles fullscreen. This Surface’s desktop is 1368×912; integer 3× needs 1440×810, so integer scale was stuck at 2× (960×540) with black bars in a 1280×720 window.

**Why:** Owner Play: plants look excellent; dragging the window only grew black bars.

**Rejected:** Changing the viewport. Camera zoom (that shows less woods). Non-uniform stretch. Leaving integer scale as the playtest default on this 3:2 laptop.

## 2026-10-27 — Slice 0 plants are PixelLab map objects, one generation each

**Decision:** Fir, spruce, bakeapple, and blueberry are still sprites from `create_map_object` (high top-down, transparent background). Files are species-named: `tree_fir.png`, `tree_spruce.png`, `forage_bakeapple.png`, `forage_blueberry.png` in `art/biomes/coastal_north/` and `game/art/coastal_north/`. Chunk loads those PNGs and keeps ColorRect fallback. Stumps stay boxes for now.

**Why:** Owner said go on the art lane. Pro Flash objects quote 5 generations for one 32×48 still. Map objects cost 1. Trial had 18 left; these four used 4.

**Rejected:** Pro Flash objects for still plants. Generic `tree1` filenames. Regenerating the first fir because it reads a bit like a Christmas tree — owner Play decides.

## 2026-10-27 — Dawn fades like dusk; night does not snap to day

**Decision:** Night still lasts 40 seconds. The last 10 of those are **dawn**: darkness eases from 1 to 0, and the campfire pool eases out with it. Dusk already eases in over the last 10 seconds of day. A new walk still starts in full daylight.

**Why:** Owner Play: pick/chop/fire felt good; night-to-day was a hard cutoff.

**Rejected:** Keeping the wrap from full night to full day. Adding extra cycle time. Starting the game in dawn.

## 2026-10-27 — Space picks and chops; F still lights the fire

**Decision:** The main action is **Space**. It picks bakeapple/blueberry and chops fir/spruce, same reach and facing as before. **F** still spends wood to light a campfire. **R** still reseeds.

**Why:** The owner asked for Space as the gather/chop button while playing. F already reads as fire, so that key stays.

**Rejected:** Keeping E. Using Space for the campfire too.

## 2026-10-27 — Slice 0 verbs: E picks or chops, F lights a fire, night does not freeze

**Decision:** Press **E** on the tile Leif is standing on, or a neighboring tile he is facing. Forage on the biome resource (`bakeapple`, `blueberry`) adds 1 forage and the bush is removed. Trees on that resource (`fir`, `spruce`) add 3 wood, the tree node is removed, and a stump marks the spot. The stone axe is already in hand: no crafting, no durability. Press **F** to spend 3 wood and place a lit campfire one tile ahead (not on water, not on a prop). One fir or spruce pays for one fire. More wood can light more fires along the trail. A day is 50 seconds, the last 10 of them dusk, then 40 seconds of night, then dawn. Night is a cold `CanvasModulate`. Each campfire is a warm `PointLight2D` that is off in full daylight and fades in with the dark, so the day ground stays readable and the fire is the night light. The camera stays inside the chunk, because the window clear color is not shaded by that night tint. Hearts stay at 3. Forage is carried, not eaten. **R** reseeds the coast and keeps wood, forage, and the clock; fires were on the old ground and go with it. Verbs read `Biome.tree_species` / `forage_species` and prop meta `kind` / `species`. They do not live on the player script.

**Why:** Berries in hand and a fire on the ground let Leif see the caribou trail and keep walking inland after dark. The camp is a light along the way, not the destination. Hunger and freezing would stop the walk before those systems are the slice. A later biome adds species on its resource; the player script stays the walk.

**Rejected:** Eating berries in slice 0. Freezing damage. Crafting the axe. A free campfire. E placing a fire whenever the tile ahead is empty (too easy to mis-light). A fire halo that washes out the day. Hard-coding coastal species inside the verb instead of the biome list. Cranberry and tamarack in the verb — they are in the research doc and stay off the slice 0 spawn list until that list changes. PixelLab props. Editing walk/run.

## 2026-10-27 — Two lanes: this PC does PixelLab; cloud does verbs/research

**Decision:** We do not back up. The world exists; art is replacing placeholders, not starting the game. While this PC generates Leif/tiles/props, a **cloud agent + PR** builds pick/chop/campfire/night against the colored boxes and `species` metadata. A second cloud PR can research `river_valley`. Lanes are in `AGENTS.md`. Push local work before the cloud agent branches.

**Why:** Owner asked for this harness. PixelLab’s token only lives here. Verbs do not need finished sprites. Research never needed this laptop.

**Rejected:** Pausing the continent until the forest looks pretty. One chat doing art and verbs in series. A cloud agent calling PixelLab (it cannot).

## 2026-10-27 — Double-tap a move key to run; hold is always walk

**Decision:** Hold WASD/arrows = walk (70). Double-tap the **same** key within 0.3s and keep holding it = jog (100). Releasing that key returns to walk. Diagonals stay a run only while the double-tapped key is still down.

**Why:** Owner clarified the first playtest request: hold-without-double-tap must never speed up.

**Rejected:** Hold-to-jog after 0.28s (the previous rule). Toggle run. Sprint-scale speed.

## 2026-10-27 — PixelLab for generated sprites; Cursor for the world

**Decision:** Keep PixelLab for characters, Wang tiles, and animations. Cursor writes Godot, biomes, and tests. `pixelart_workbench` (free, no generations) is how we poke individual pixels after a generate. Do not ask a Cursor agent to invent 8-dir sheets or autotiles from scratch.

**Why:** Photo-to-8-dir and chained tilesets are PixelLab’s job. A Cursor agent drawing pixels by hand is slow, inconsistent, and would burn chat tokens on this Surface Pro. World/seed/chunk is already ours.

**Rejected:** Replacing PixelLab with Cursor image tools. Paying Architect ($50) before we have outgrown Apprentice.

## 2026-10-27 — Leif is the friend in viking clothes, PixelLab Pro 8-dir

**Decision:** First Leif sprite is PixelLab `create_character` mode=pro, 64px, high top-down, 8 directions, from `art-inspo/viking-inspo.jpeg` (head crop uploaded as `upload:a56525a8-...`). Character id `327ed41b-0289-49cb-bcd8-787b17f963ea`. PNGs live in `art/characters/leif/` and `game/art/leif/`. Godot draws him at 0.5 scale so he is about two tiles tall.

**Why:** Owner asked for the character based on that photo. Pro is the mode that takes a concept photo. 64px was too tall on 16px tiles, so we scale in-engine rather than regenerating.

**Rejected:** Ignoring the photo and inventing a generic Norseman. Sending the full 1600px JPEG as inline base64 (MCP truncates it). Regenerating before the owner sees the first pass.

## 2026-10-27 — PixelLab MCP in the project, token stays on the PC

**Decision:** `.cursor/mcp.json` points at `https://api.pixellab.ai/mcp` with `Authorization: Bearer ${env:PIXELLAB_API_TOKEN}`. The owner sets that env var locally. Setup notes live in `docs/PIXELAB.md`.

**Why:** We generate Leif and tiles from Cursor against researched species, without putting a secret in GitHub.

**Rejected:** Committing a real token. Calling PixelLab’s REST API from scripts as the default. Blender/Meshy.

## 2026-10-27 — Hold a direction to jog, do not sprint

**Decision:** First moment of WASD/arrows is a walk (70). After holding any move key ~0.28s, speed becomes a jog (100). Releasing resets to walk. Same in every direction.

**Why:** First playtest: walk felt a bit slow. Owner asked for `w-wwwwww` hold-to-run, “a bit” faster not a sprint.

**Rejected:** Toggle run. Double-tap. A large speed boost.

## 2026-10-27 — Tiny headless test runner, not GUT (yet)

**Decision:** Tests are `game/tests/run.gd` run with `godot --headless -s res://tests/run.gd`. GitHub Actions installs Godot 4.7.2 and runs them. GUT is not in the repo yet.

**Why:** Zero addons, works in CI, enough for seed/biome/species checks. We can switch to GUT when tests get awkward.

**Rejected:** Making this Surface Pro run the tests. Shipping a Level1.tscn with no generator.

## 2026-10-27 — World / chunk / biome data from day one

**Decision:** Playable land is `ChunkGenerator` + `Biome` resources. Slice 0 loads chunk (0,0) as `coastal_north`. Other biomes exist as empty resources. Water is south; inland is −Y (north).

**Why:** The continent dies if the first map is a unique painted scene.

**Rejected:** Hand-placed clearing. GUT addon on day one.

## 2026-10-27 — Coastal North trails are caribou, not white-tailed deer

**Decision:** On `coastal_north`, “deer trails” in the mission are **woodland caribou** trails. White-tailed deer, moose, coyote, and snowshoe hare stay out of this biome.

**Why:** Insular Newfoundland’s native ungulate is caribou. Moose (1878/1904) and coyote (1985) are later. Accuracy is a pillar.

**Rejected:** Generic Stardew deer as the Vinland path-makers.

## 2026-10-27 — CI checks knowledge files only until Godot exists

**Decision:** GitHub Actions `check` verifies the knowledge harness files. Headless Godot/GUT is not in CI until `game/project.godot` exists.

**Why:** First run failed with zero jobs (job-level `hashFiles` is a bad fit). An empty Godot job should not break the harness.

**Rejected:** Skipping CI until a game binary exists. Running Godot on this Surface Pro as the test machine.

## 2026-10-27 — GitHub is home; this PC is a thin client

**Decision:** Canonical repo is https://github.com/sam-dev-site/leif-in-the-wind. Cloud agents, hooks, and Actions do research, code, tests, and review. The Surface Pro is for `git pull` and Play.

**Why:** 8 GB Intel UHD 620 cannot be the factory. Chat memory compresses; GitHub does not.

**Rejected:** Keeping the only copy in `Projects-Local/vikings`. Creating a second Cursor-hosted repo. Unity/Unreal on this laptop.

**Note:** The GitHub repo was created empty and **public**. We did not change visibility. Switch to private if that was accidental.

## 2026-10-27 — Knowledge harness over chat memory

**Decision:** `AGENTS.md`, `docs/MISSION.md`, this log, `docs/STATUS.md`, biome research files, Cursor rules, and project hooks are the source of truth. Lasting choices must be written here in the same session.

**Why:** Context compaction loses decisions. The owner already uses this pattern on Just Keep Talking.

**Rejected:** Treating a slice spec as the whole game. Treating this conversation as the archive.

## 2026-10-27 — Godot 4, not Unity; 2D pixel, not Blender/Meshy

**Decision:** Engine is Godot 4.7.x Standard (GDScript, Compatibility renderer). Art is 16×16 pixel, PixelLab then Aseprite. No Unity, Unreal, Blender, or Meshy.

**Why:** Top-down 16-bit survival matches the forest screenshot. This laptop cannot carry Unity/Unreal. 3D tools do not serve a 2D pixel game.

**Rejected:** Phaser/browser-first (browser was only “can I open it in Chrome,” not the game). RuneScape click-to-move / MMO.

## 2026-10-27 — Single-player generated world

**Decision:** Single-player only. World is seed + chunks + biome-at-position. Slice 0 is one generated `coastal_north` chunk, not a unique Level1 scene.

**Why:** Other players would 10x the first game. Procgen and biomes are the mission; delaying them until “later” is how they die.

**Rejected:** Multiplayer from day one. Hand-painted diorama with no world system.

## 2026-10-27 — Biome species must be researched

**Decision:** Each biome gets `docs/research/biomes/<id>.md` with sources before art or spawn tables. Agents must not invent flora or fauna.

**Why:** The land should be accurate. Vinland is a real ecoregion. The walk inland is compressed; the plants are not random.

**Rejected:** Generic “forest trees” and “berries.”
