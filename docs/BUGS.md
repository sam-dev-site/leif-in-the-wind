# Bugs

Each heading below is one break in the game you already have. It stays open until a fix session takes it and you sign that Play off.

[IDEAS.md](IDEAS.md) is for new wishes. [SLICE_0.md](SLICE_0.md) is the current cut. A bug found while you are signing off that cut stays in that session. This file is for breaks that are not the work in front of you.

## How a bug lands

1. A new want goes in [IDEAS.md](IDEAS.md). This file is only for something the game already does wrong.
2. If it is the feature you are playtesting in this sitting, it stays with that work.
3. Otherwise give it its own heading. Write what you saw, what the game is supposed to do, and where it showed up.
4. Leave it. Fixing is a separate ask.

## How a fix session starts

1. Read this file.
2. In the reply, name the open headings in the words written here, before changing the game.
3. Fix only the ones you pick. If you do not pick, ask which open bugs to take.
4. After you sign off the Play, move those headings under **Fixed** and note the date. Leave the write-up.

## Open

## Save button overlaps the name field

**Status:** Open.

**Found:** 2026-10-29

**What you saw:** On “Enter save name.” the Save button is transparent and sits too high. It covers the bottom edge of the text box. The field’s border runs through the button.

**What the game should do:** The text box is clear. Save sits under it, on the green plate, and does not cover the field.

**Where:** The name box in the woods, `game/world/hud.gd`. The field is at (116, 112), 248×22. Save is at (196, 142), 88×22, on that same plate.

## The save mark is two pause bars

**Status:** Open.

**Found:** 2026-10-29

**What you saw:** The top-right save mark is two vertical bars, like a pause icon.

**What the game should do:** That mark is a floppy disc, in pixel art. It stays in the top right. A click still saves. The first click still asks for a name.

**Where:** `game/art/ui/save_floppy.png` is a 16×16 picture of two cream bars. The woods draw it on the top-right button (`game/world/hud.gd`). The headless test still requires those two bars.

## The fallen branch is almost as big as the trees

**Status:** Open.

**Found:** 2026-10-29

**What you saw:** A pine branch on the ground is a little too big. It is almost the same size as the trees.

**What the game should do:** Keep the same sprite. Draw it about 30% smaller. It is still a fallen fir branch: Space clears it for half a wood, and it does not block the walk.

**Where:** Coastal woods. `game/art/coastal_north/clutter_fir_branch.png` is 32×32 and the woods draw it at full size (`game/world/chunk.gd`). Standing fir and spruce are 48×64. The title still uses that same branch picture at full size.

## Later

Passing is good enough to keep. The heading stays on this list. A later pass is a separate ask.

## Running on a diagonal is choppy

**Status:** Passing. Kept for later. 2026-10-28.

**Found:** 2026-10-28

**Play:** Good enough. The view follows Leif from outside the tree stack, smoothing still off. Walk stays 70. Jog stays 100. A diagonal is still not a perfect slide. Do not start another pass unless asked.

**What you saw:** Jog on a diagonal — NE, NW, SE, or SW — and the world moves in little chops. It feels like the view is taking turns: left, down, left, down. It does not feel like one smooth slide along that diagonal.

**What the game should do:** A diagonal jog is one movement. The woods should slide on the diagonal the way a straight jog slides along a line. Walk stays 70. Jog stays 100, and only while the double-tapped key is still held. The camera stays on Leif. An earlier decision turned camera smoothing off, because a smoothed camera would sit further behind him.

**Where:** In the woods, while jogging on a diagonal. The camera follows Leif with smoothing off, from outside the y-sorted woods (`game/world/world.gd`). Each frame he moves one normalized diagonal at jog speed (`game/world/player.gd`). Straight directions were not part of this report.

## Fixed

## Minimap shows too much

**Status:** Fixed. 2026-10-28.

**Found:** 2026-10-28

**Play:** Signed off. A look opens a small circle. The trail stays clear. **R** still wipes it.

**What you saw:** The bottom-left circle is not helpful. You can already see almost all of it. In the current picture the circle is about 95% uncovered: green and brown ground, a cream pip in the middle, and only a thin black edge left. One glance at the woods fills the map.

**What the game should do:** Match the other picture. Zoom the same circle out. Most of it stays black. The bit his walking uncovers is a smaller patch around the cream pip, with black fog around that patch. The map still sits in the bottom-left. It is still not a map he holds. **R** still wipes it.

An earlier decision opened every tile on the 480×270 screen. That is the picture you do not want. This bug replaces that feel. The fix session writes the new choice into the decision log when you sign the Play off.

**Where:** The corner map, `game/world/fog_map.gd`. The circle is 41 pixels across, one pixel per tile. A look opens a circle of 6 tiles, and the trail stays clear.

## Sphagnum is larger than Leif

**Status:** Fixed. 2026-10-28.

**Found:** 2026-10-28

**Play:** Signed off. The yellow cushions sit on the moss, smaller than Leif. The bottom-right stays whole.

**What you saw:** The yellow sphagnum cushions are larger than Leif. They read as bushes sitting on the moss, not as something on the ground.

**What the game should do:** Sphagnum is smaller. It is occasional patchy ground cover. It stays scenery: not firewood, and it does not block the walk. The corner that Play already signed off stays whole.

**Where:** Coastal woods, baked into the ground. The picture stays `game/art/coastal_north/clutter_sphagnum.png`, 32×32, stamped at half size onto one 16×16 tile (`game/world/chunk.gd`). Leif is about two tiles tall.

## Shrubs are missing the bottom right corner

**Status:** Fixed. 2026-10-28.

**Found:** 2026-10-28

**Play:** Signed off. The yellow cushions on the moss keep their bottom-right corner.

**What you saw:** On the moss, the berry bushes have a bite out of the bottom-right. The rest of the shrub is there. That corner is empty, so the bush reads as a curl instead of a full shrub. It shows on more than one bush in the same look.

**What the game should do:** A yellow cushion on the moss is a whole plant. The bottom-right corner is part of it, the same as the other three corners.

**Where:** Coastal woods, on the ground. The plants in that look are sphagnum, `game/art/coastal_north/clutter_sphagnum.png`. Each cushion is wider than a ground tile. The next tile’s moss was painted over the right edge. Ground for a slice is painted first, then the cushions. Bakeapple and blueberry were already whole.

## From you

- **2026-10-28 — Backlog opened.** Nothing filed yet.
- **2026-10-28 — Shrubs are missing the bottom right corner.** Fixed. The next ground tile no longer covers the cushion’s right edge.
- **2026-10-28 — Running on a diagonal is choppy.** Passing. Kept for later. The view is no longer stacked with the trees.
- **2026-10-28 — Minimap shows too much.** Fixed. A look opens a 6-tile circle, and the trail stays clear.
- **2026-10-28 — Sphagnum is larger than Leif.** Fixed. The cushion is stamped at half size.
- **2026-10-29 — Save button overlaps the name field.** Open. Not this Play.
- **2026-10-29 — The save mark is two pause bars.** Open. It should be a floppy disc. Not this Play.
- **2026-10-29 — The fallen branch is almost as big as the trees.** Open. Same sprite, about 30% smaller. Not this Play.
