# Claude handoff — Leif in the Wind

Written 2026-11-22, on the machine that had been using Cursor. This file is the session brief. Read it before editing the game. The longer law lives in the docs it names. If this file and `docs/MISSION.md` disagree, the mission wins. If this file and `docs/LOOP.md` disagree about a rule of play, the loop wins. If this file and `main` disagree about what is built, this file wins until the branch below is merged.

The owner is making a first game. Explain consequential choices in plain language. Make sound defaults. Do not make them remember git.

## Start on this branch

```text
cursor/other-sea-943d
```

That branch is the game. It holds every phase commit from the night coast through **The other sea.** (`0c98800`), plus the handoff commit on top of that, and it is pull request [#27](https://github.com/sam-dev-site/leif-in-the-wind/pull/27). Confirm with `git branch --show-current` before you change anything.

`main` is commit `1a1a7c9`, “Put a walking caribou and a standing hare on the coast.” It does not contain `docs/LOOP.md`, `docs/PLAN.md`, the river, the raft, fishing, the hearts, or the win. A clone that stays on `main` will look like a finished coast and an empty plan. Check out `cursor/other-sea-943d` and pull.

Repo: https://github.com/sam-dev-site/leif-in-the-wind (public). Local folder on the playtest PC: `C:\Users\tsam2\Desktop\Projects-Local\vikings`. GitHub login for `gh` is **sam-dev-site**, HTTPS. Do not add a second git host. Do not force-push `main`. Do not change git config. Do not commit `PIXELLAB_API_TOKEN` or `.env`.

## What happened

Cursor built the locked path as fourteen stacked pull requests on 2026-11-12 and 2026-11-13. Each PR targets the previous feature branch, not `main`. Every check was green. Nobody pressed Play on that path, and nobody merged it. The owner is leaving Cursor. The code, the tests, and the lock are already on the tip branch. They are not on `main`.

`gh pr merge 27` merges the tip into `cursor/western-shore-research-943d`. It does not update `main`. Do not do that.

## The stack

One history. The tip already contains every row. Intermediate PRs are the same commits seen through a narrower diff.

| Order | PR | Base | What the commit added |
|---|---|---|---|
| 1 | [#13](https://github.com/sam-dev-site/leif-in-the-wind/pull/13) | `main` | Night on the coast: pitch glints, rime, the caribou’s bed, a lit torch that slows the cold |
| 2 | [#14](https://github.com/sam-dev-site/leif-in-the-wind/pull/14) | #13 | Lock: `docs/LOOP.md` and `docs/PLAN.md` |
| 3 | [#16](https://github.com/sam-dev-site/leif-in-the-wind/pull/16) | #14 | Band table. The coast strip still stops. |
| 4 | [#17](https://github.com/sam-dev-site/leif-in-the-wind/pull/17) | #16 | Walk the river valley to the bank |
| 5 | [#18](https://github.com/sam-dev-site/leif-in-the-wind/pull/18) | #17 | Carried raft |
| 6 | [#19](https://github.com/sam-dev-site/leif-in-the-wind/pull/19) | #18 | Hand-line fishing |
| 7 | [#20](https://github.com/sam-dev-site/leif-in-the-wind/pull/20) | #19 | One heart per land, six-band map |
| 8 | [#21](https://github.com/sam-dev-site/leif-in-the-wind/pull/21) | #20 | Plains research. No iron tool. No spawn. |
| 9 | [#22](https://github.com/sam-dev-site/leif-in-the-wind/pull/22) | #21 | Bayou research (Atchafalaya) |
| 10 | [#23](https://github.com/sam-dev-site/leif-in-the-wind/pull/23) | #22 | Bayou band, three channels |
| 11 | [#24](https://github.com/sam-dev-site/leif-in-the-wind/pull/24) | #23 | Connecticut research |
| 12 | [#25](https://github.com/sam-dev-site/leif-in-the-wind/pull/25) | #24 | Connecticut band, one-tile stem |
| 13 | [#26](https://github.com/sam-dev-site/leif-in-the-wind/pull/26) | #25 | Olympic outer coast, research only |
| 14 | [#27](https://github.com/sam-dev-site/leif-in-the-wind/pull/27) | #26 | The win: **The other sea.** once, on chunk −2 |

Leave these alone. They conflict with `main`, and their text is older than the lock:

- [#3](https://github.com/sam-dev-site/leif-in-the-wind/pull/3) hunger plan. Hunger stays an idea in `docs/IDEAS.md`.
- [#4](https://github.com/sam-dev-site/leif-in-the-wind/pull/4) a coastal sound list. It still says one swing fells a tree and a fire costs 3 wood. The signed-off skills are not that. If sounds come back, write a new list from the current verbs.

`cursor/night-coast-bdc2` is the bottom of the stack (PR #13). Checking it out shows the night coast and hides the valley, the raft, and the win. Play the tip.

Old local branches (`cursor/arctic-hare-on-the-moss-8e58`, `cursor/forage-skill-dc1b`, `cursor/no-heart-regen-829a`, `cursor/pack-torch-mvp-453d`, `pr-2`) are history. Their work is already in `main` or in the stack. Do not check them out to finish them.

## When the owner signs the path off

These words mean GitHub `main` should match this PC: `commit`, `save`, `save and commit`, `all set`, `good`, `good!`, `done`, `all done`, `perfect`, `everything is working`, `push`. A follow-on note (`good, but the river is wrong`) is still notes. Finish the notes. Sync only when they close it.

While this stack is the work, a sign-off does this and does not merge #27 into its parent:

1. Commit Play notes if the tree is dirty (`docs/STATUS.md`, `docs/DECISIONS.md`). Never stage secrets.
2. `git push` the tip branch.
3. `git checkout main` and `git pull`.
4. `git merge --no-ff cursor/other-sea-943d` (a merge commit, not a squash).
5. `git push`. Never force-push `main`.
6. Close the stacked PRs (#13, #14, #16–#27). They are the same commits `main` now has. Leave #3 and #4 open.
7. `git status -sb` and `git log -1 --oneline`. The hash you report is that log line, and only after `main` matches `origin/main`.

On PowerShell, pass a commit message with a here-string, not a bash heredoc.

After that merge, `main` is the brain again, and a later slice is one new pull request. Then `gh pr merge <number> --merge` is the right close for that one PR.

## What the game is

**Leif in the Wind.** Leif Erikson is stranded on the Vinland coast in the 11th century. Survival is the opening. The point is to be on a continent that keeps opening, and to stand still in the woods. Single-player. A later Steam world comes from a seed.

Feelings every slice must serve: sensation, fantasy, discovery, submission. Challenge is the work getting easier (chop, fire, forage, and later the one new skill a land teaches). Expression (a house, a town) is later and is not the win. There is no authored plot and no other players. Detail: `docs/MISSION.md`.

Three beats, locked 2026-11-12 in `docs/LOOP.md`. An agent does not reopen them. A new wish goes in `docs/IDEAS.md` with questions. It does not edit the loop unless the owner asks to change the lock.

- **Night.** Gather. Light a fire or walk with a light. Eat to buy a heart back. Sleep at the fire, or die in the cold and wake poorer, skills kept. Sitting by the fire is a complete night.
- **Place.** One researched biome. Old skills on its trees and food. One new thing that land is there to teach. Sleep there once.
- **Journey.** Six lands inland from the landing sea. The first step on the western shore shows **The other sea.** once. The save continues. Level 99, a house, a town, and a filled map are not the win.

Build order is `docs/PLAN.md`. One phase was one pull request. Research before spawn. Phases A–G and I–N are already on this branch. **Phase H has not started, on purpose.** The plains research named no travel tool. Do not invent iron, a bloomery, or a chert knife. Do not generate `chunk_y` −8 through −11 to “connect the map.”

## What you can walk

Chunks are 48×48. Inland is decreasing `chunk_y`. The landing sea is `chunk_y > 0` and it stays water. He does not win by walking into that sea.

The world builds these bands (`game/world/world.gd`):

| Land | `chunk_y` | `chunk_x` | From the landing |
|---|---|---|---|
| `coastal_north` | 0 through −3 | −1..1 | The start. Pixel art, Wang floor, caribou, hares. |
| `river_valley` | −4 through −7 | −1..1 | Walkable. Colored boxes. Bank, six-tile stem, brooks, one deer. |
| `inland_plains` | −8 through −11 | — | Not generated. The walk stops at the valley. |
| `bayou` | −12 through −15 | −1..1 | Generated. Not reachable from the landing. |
| `river_country` | −16 through −19 | −1..1 | Generated. Reachable from the bayou, not from the coast. |
| `western_shore` | −20 through −23 | −3..1 | Generated. Chunk −3 is ocean. Chunk −2 is the walkable shore and the win. |

A person who presses Play at the title can walk the coast and the valley, fish the Saint John stem, and pole the raft. They cannot walk to the bayou. The later lands are in the build and covered by headless tests. Seeing them in Play means starting already in those bands, which the title does not do. Do not generate the plains to make that walk exist. That gap is the locked stop.

Coast species in play: balsam fir, spruce, bakeapple, blueberry. Valley, bayou, Connecticut, and western-shore species are the lists in `docs/LOOP.md` and the research files. Plains draft (not spawned): Rice Lake tallgrass, black oak, white oak, New Jersey tea, one eastern elk. No bison. No iron.

## What Play has signed off

Signed off on the coast, before this stack: title and three save files, woodcutting, fire-making, foraging, berries as the only heal, death, pack and torch, the caribou, the arctic hares, the corner map, ringed stumps, sphagnum size, fallen-branch size. Sleep blink is signed off. Diagonal jog is “good enough” and stays under **Later** in `docs/BUGS.md`. Do not start another pass unless asked.

**Ready for Play, not signed off:** the four night slices (pitch glints, rime, the bed, the slower cold), and the whole inland path (valley, raft, fishing, hearts and continent map, bayou, Connecticut, the win). The foliage slider (−100% to +25%) still needs a Play look. Pictures past the coast are boxes. `docs/ART.md` is the list.

`docs/BUGS.md` has no open bugs. The only later heading is **Running on a diagonal is choppy**. A fix session names the open headings, in those words, before changing the game. There are none to name until a new one is logged.

## Controls

| Input | What it does |
|---|---|
| WASD / arrows | Walk (70). Double-tap the same key within 0.3s and keep holding it to jog (100). |
| Space | Pick, chop, or clear the tile he faces. On a burning fire, lights an equipped torch. With the hand-line equipped, casts at the main stem. With the raft equipped, poles across that stem. A prop in front still wins over a cast. |
| E | Spend forage for half a heart. Fish are eaten from the pack, not with E. |
| F | Spend wood for a fire attempt on the tile ahead. A miss still spends the wood. |
| C | At dusk or night, beside a fire, sleep to dawn. First sleep in a ladder land can add a maximum heart. |
| R | New seed. Keeps skills, pack, earned hearts, slept lands, the raft, fishing XP, and a win already earned. Clears fog and the last sleep tile. |
| Escape | Closes the continent map, the name box, or the pack first. Otherwise asks **Quit to the main menu?** Y / N. That is not pause. The clock pauses only while the ask is up. |
| F11 | Fullscreen. |
| Floppy (top right) | Writes the shore. The first click asks for a name. |
| Skills mark | Woodcutting, fire-making, foraging, and fishing once it exists. |
| Pack mark | Pitch, stick, torch, raft, hand-line. Hover names the stack. Double-click equips the one held tool. |
| Minimap (bottom left) | A 6-tile circle, trail stays clear. One click opens the six-band continent map. The clock keeps running. |
| Admin cog | Title only. QC sliders. Not a player options menu. |

Night is 60 seconds in every land. Away from a fire, half a heart every 5 seconds. A lit torch makes that 10 seconds and does not warm him. Day and fire do not heal. Death at the last half-heart: cream skull, wake at dawn at the last slept fire or the landing, wood and forage halved, extras taxed, one heart, skills and the map kept.

Hearts start at 3. The first **C** sleep in each ladder land adds 1 to the maximum, cap 9, and does not fill hearts. The admin slider at 3 uses the earned maximum. Any other slider is the session maximum and a sleep does not pay.

Coast skill numbers are signed off in `docs/SKILLS.md`. Do not retune them. Woodcutting level 99 stays **341,036**. Fishing uses the half-size Old School table in `docs/LOOP.md` (level 2 is 41, level 99 is 6,517,215). The coast skills do not call that table.

## How to play and how to test

This PC is a Surface Pro. Godot **4.7.2 Standard** is installed (`GodotEngine.GodotEngine` via winget). Open the `game` folder, the one with `project.godot`, not the repo root. Press Play. The agent does not launch the Godot editor and does not play the game. Gate 6 in `docs/REVIEW.md` is the owner.

The window draws 480×270, `viewport` stretch, aspect `keep`, fractional scale, nearest-neighbor. `game/project.godot` keeps those two stretch lines. Godot once dropped them in the working tree. Put them back if they vanish. Compatibility renderer. Do not install Unity, Unreal, Blender, or Meshy.

Headless tests, the same command GitHub Actions runs:

```text
godot --headless --path game --import --quit
godot --headless --path game -s res://tests/run.gd
```

Actions is `.github/workflows/check.yml`: the knowledge files exist, then those tests. Do not call work done if Actions is red. A player-visible change is **ready for Play** in `docs/STATUS.md` until the owner signs it. The agent writes that. The owner’s sign-off is what writes **Play signed off**.

Saves on this PC: `%APPDATA%\Godot\app_userdata\Leif in the Wind\saves\slot_0.json` through `slot_2.json`. Admin: `admin_settings.json` in that same folder. Three shores. An **x** deletes one after a yes. Continue shows the typed name and the Costa Rica time (UTC−6, labeled CST).

## Map of the repo

| Path | What it is |
|---|---|
| `CLAUDE.md` | This brief. |
| `AGENTS.md` | Collaborator rules. Points here. |
| `docs/MISSION.md` | Why the game exists. |
| `docs/LOOP.md` | Locked rules of play. Do not reopen. |
| `docs/PLAN.md` | Phase order. A–N are built on this branch except H, which is the stop. |
| `docs/DECISIONS.md` | Append-only. Newest at the top. |
| `docs/STATUS.md` | What exists. Update it before you finish a session. |
| `docs/SLICE_0.md` | The coast. Not the whole game. |
| `docs/SKILLS.md` | Signed-off coast curves. |
| `docs/REVIEW.md` | Gates 1–6. |
| `docs/IDEAS.md` | Unordered wishes. Questions are not answers. |
| `docs/BUGS.md` | Breaks that are not the current Play. |
| `docs/ART.md` | Pictures that are still boxes. Spend a generation only when the owner names a row. |
| `docs/PIXELAB.md` | Token setup. |
| `docs/research/biomes/` | Species with sources. One file per land. |
| `docs/research/journey.md` | A schematic. Not an item in the game. |
| `leif_survival_style_guide.md` | An early pitch, cut off mid-sentence. It says combat, stamina, bison, and iron. Those are not the game. |
| `game/` | Godot 4.7 project. Main scene `title/title.tscn`. |
| `game/world/` | World, player, chunk, verbs, HUD, animals, pack. |
| `game/data/biomes/` | One `.tres` per land. Plains stays empty. |
| `game/tests/run.gd` | The headless suite. |
| `game/art/` | What the game loads. |
| `art/` | Source copies of generated pictures. |
| `art-inspo/screen-layout-pixels.jpg` | The look. High top-down forest. Not the stock “VIKINGS” sheet. |
| `.mcp.json` | PixelLab for Claude Code. Token is not in the file. |
| `.cursor/` | The old harness. The locks in those rules still apply. Claude does not load them on its own, which is why this file exists. |
| `.github/workflows/check.yml` | Knowledge files plus Godot tests. |

Scripts worth knowing: `world.gd` (strip, bands, win flag), `chunk_generator.gd` (species and water), `biome_catalog.gd` (the ladder), `player.gd` (walk and jog), `interact.gd` (Space), `skills.gd`, `supplies.gd`, `rucksack.gd`, `campfire.gd`, `day_clock.gd`, `shore_save.gd`, `fog_map.gd`, `caribou.gd`, `hare.gd`, `deer.gd`, `hud.gd`, `title/title.gd`, `admin_settings.gd`. Props keep `set_meta("species")` and `set_meta("kind")`. Verbs read the biome resource. They do not hard-code the next forest inside the player script.

## Art and PixelLab

PixelLab stays on this PC. The token is the Windows user variable `PIXELLAB_API_TOKEN`. Claude Code reads `.mcp.json` (`type: http`, `https://api.pixellab.ai/mcp`, header `Bearer ${PIXELLAB_API_TOKEN}`). Quit and relaunch Claude Code after the variable changes. If `claude mcp list` warns that the variable is missing, or PixelLab returns 401, the process did not see the variable. Do not paste the token into the file.

Use PixelLab tools when they are connected. Do not invent a REST client. Do not spend a generation unless the owner names a row in `docs/ART.md`. If you leave a picture as a box, skip a generation, or say the art waits, add that row in the same session. A sentence in the decision log does not count.

Prompts use species from `docs/research/biomes/<id>.md`. Camera: high top-down. Style: `art-inspo/screen-layout-pixels.jpg`. 16×16 tiles. Write `art/biomes/<id>/` with the species in the name (`tree_fir.png`, `forage_bakeapple.png`), then the copy the game loads under `game/art/`. Never `tree1`.

Last written balance is in `docs/ART.md` (checked 2026-11-03: trial generations spent, daily stack empty, credits $0). The daily stack refills. Read the account before you spend. Do not assume it is still zero, and do not spend because it refilled.

Known character ids, if a later edit has to continue them:

- Leif: `327ed41b-0289-49cb-bcd8-787b17f963ea` — 8-direction idle and walk, drawn at half size.
- Woodland caribou: `fdeb44e3-c125-43b7-bf75-540b7101a398` — idle and 8-frame walk. The night bed still uses the standing idle (`docs/ART.md`).
- Arctic hare: `f2402d5a-2593-4727-9bae-5233c81bc69d` — idle only, drawn at 0.32. The hop is that idle turned.

Open pictures, all held until a row is named: hare hop, campfire, foraging icon, fishing icon, rucksack mark, pitch, stick, torch, raft, hand-line, caribou bedded pose, and every valley, bayou, Connecticut, and western-shore tree and food. The death skull stays the in-repo drawing. Valley and later floors are flat color on purpose.

## How to work a new slice

The path in `docs/PLAN.md` is built. The next human step is Play, not a new phase. When they ask what to work on next, say that, unless they asked for art, a bug, or a new wish.

When they do ask for something new:

1. Read this file, `docs/MISSION.md`, `docs/LOOP.md`, `docs/PLAN.md`, the top of `docs/DECISIONS.md`, and `docs/STATUS.md`. Read the biome research for any land you touch.
2. If the loop already locked it, point at the loop. Do not redesign it in the ideas file.
3. If a number, a species, or a width is missing from the loop and the research, stop. Add the question to `docs/IDEAS.md`. Do not invent it.
4. Species that are not in `docs/research/biomes/` need a research pass with sources before art or a spawn table. Never invent “this plant grows in Vinland.”
5. One slice, one pull request, branched from current `main` once the stack has landed. Until then, branch from `cursor/other-sea-943d` so you do not code against the old coast.
6. Headless tests for the change. A picture that ships as a box gets an `docs/ART.md` row in that same change.
7. Append `docs/DECISIONS.md` only when you had to choose something the loop left open. Update `docs/STATUS.md` before you finish.
8. Wait for Actions. Gates 1–5 you may claim. Gate 6 is the owner on this PC.

A wish logged in `docs/IDEAS.md` gets a few questions grounded in the game. The questions are not decisions. Do not fill in a cost, a species, a timer, or a material they did not say. Combine duplicates. Split a line that is more than one slice.

These stay ideas until the owner opens them: perks, hunger, hunting, wolves, bears, sturgeon, NPCs, a house, a town, tree regrowth timers, seasonality, weather, fireflies, pause, a player options menu, bones, a fishing pole, more of this same coast as a substitute for the next land, retuning the three coast skills.

## Cursor leftovers

`.cursor/rules/` and `.cursor/skills/playtest-pr` are still in the repo, and the knowledge check requires them. They are the same locks, written for Cursor’s loader. Claude will not see them unless it opens the files. This brief is that copy. If a Cursor rule and this file disagree about the branch or about merging #27, this file wins until the stack is on `main`.

There is no Cursor cloud agent in the new suite. A research or verb change is still a pull request, still headless-tested, still not a claim that Play happened. This laptop is not the CI machine.

## First session in Claude

1. `git status -sb` and `git branch --show-current`. You want `cursor/other-sea-943d`, tracking origin, tree clean.
2. If you are on `main`, check out the tip branch and pull. Do not start Phase A.
3. Read `docs/LOOP.md` once. You do not need to re-derive it.
4. Tell the owner the path is ready for Play. They open the `game` folder in Godot and press Play. When it feels right, they say done.
5. Small Play notes stay in that chat. Patch this branch. Do not open a second copy of the stack.
