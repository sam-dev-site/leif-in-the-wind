# Art backlog

Checked 2026-11-02 on this PC. This is the list of pictures. `docs/IDEAS.md` stays wishes and slices. A generation is spent only when you name a row.

## When you hold a picture

If you leave a picture as a box, skip a generation, or write that art waits, add the row here in that same session. Say what is on screen now, the file the game should load, and why it waited. A sentence in `docs/DECISIONS.md`, `docs/STATUS.md`, or `docs/IDEAS.md` does not count. Those files can point here. They are not this list.

## Balance

PixelLab account on this machine:

- Credits: **$0.00**
- Plan: trial, **2 of 40** generations left (38 used)
- Daily stack: **20** (the cap). It is spent only after those 2 are gone. It refills **+5** each night, up to 20.
- Spendable before the next refill: **22**
- Paid floor, if we ever buy it: Pixel Apprentice **$12/mo for 2,000** generations

Known prices, from earlier work on this coast:

- A map object (`create_map_object`) is **1** generation.
- A Pro Flash still was quoted at **5**. Plants on this coast used the 1-generation path.
- Leif’s character was **10** generations before his walk frames.

## In the game

- Leif: 8-direction idle and walk (`game/art/leif/`)
- Coast: fir, spruce, bakeapple, blueberry, ringed stumps, granite, sphagnum, needles, fallen fir, fir branch
- Ground: Wang sheets for water, shore, moss, trail (`game/art/tiles/`)
- Marks: skills, woodcutting (axe), fire-making (campfire), fir leaf, floppy, admin cog

## Open

What is still a box or a missing file on this coast.

1. **Foraging icon.** The skills row is blank until `game/art/ui/skill_foraging.png` exists. Woodcutting and fire-making already have icons.
2. **Campfire.** Stones and flame in the woods are colored boxes (`game/world/campfire.gd`). The warm pool is already the night light. A map object is 1 generation.
3. **Rucksack mark.** A cream rectangle sits between the skills mark and the floppy.
4. **Pitch, stick, torch.** The bag draws three colored squares. Hover already says the names.
5. **Woodland caribou.** A cream box on the trail. It needs an 8-direction walk the way Leif has one. His character alone was 10 generations before the walk, so one animal can use a large share of the 22. Do not start this and the hare in the same sitting unless the quote fits what is left.
6. **Arctic hare.** Same kind of job. Three cream boxes on the moss, off the trail. Hop and sit are the motion Play already signed off.

## Hold

- **Death skull.** `game/art/ui/death_skull.png` is already a skull and crossed bones drawn in the repo. Play signed that fade off. Do not spend a generation on it unless you ask.

## Not this coast

River valley and the later biomes have research and no pictures. No spawn art until you ask.

## How a row gets made

Say which row. This PC generates it and wires the file the game already looks for. A cloud agent does not call PixelLab.
