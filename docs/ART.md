# Art backlog

Checked 2026-11-02 on this PC, after the caribou and the hare. This is the list of pictures. `docs/IDEAS.md` stays wishes and slices. A generation is spent only when you name a row.

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

## Open

What is still a box or a missing file on this coast.

1. **Arctic hare hop.** Idle is in. A hop still holds that picture and turns it. The cat template has `walk-4-frames` (the game loads four frames). One direction at a time, so a full hop is 8 generations. Held on 2026-11-02 because the stack was empty after the idle.
2. **Campfire.** Stones and flame in the woods are colored boxes (`game/world/campfire.gd`). The warm pool is already the night light. A map object is 1 generation. Held on 2026-11-02: the account refused the job, no generations left.
3. **Foraging icon.** The skills row is blank until `game/art/ui/skill_foraging.png` exists. Woodcutting and fire-making already have icons.
4. **Rucksack mark.** A cream rectangle sits between the skills mark and the floppy.
5. **Pitch, stick, torch.** The bag draws three colored squares. Hover already says the names.

## Hold

- **Death skull.** `game/art/ui/death_skull.png` is already a skull and crossed bones drawn in the repo. Play signed that fade off. Do not spend a generation on it unless you ask.

## Not this coast

River valley and the later biomes have research and no pictures. No spawn art until you ask.

## How a row gets made

Say which row. This PC generates it and wires the file the game already looks for. A cloud agent does not call PixelLab.
