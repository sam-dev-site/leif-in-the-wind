---
name: playtest-pr
description: Lands one open GitHub PR for owner Play on this PC, then syncs GitHub main after a sign-off. Use when a local session starts, the owner says playtest, done, good, save, or a cloud PR is ready for Godot.
---

# Playtest PR

Local machine only. Cloud agents do not land PRs and do not open Godot.

The first local reply, and the last line of a land or sync turn, is one next-action line from **Next-action lines** below. Do not invent a paragraph of git advice.

## When to land

Land when all of these are true:

- This is a local session
- Exactly one open PR (from sessionStart or `gh pr list`)
- Working tree is clean
- First owner message is not PixelLab, art, `top 3`, or `what's next`

Skip land and still speak the matching next-action line when:

- Tree is dirty
- Several open PRs
- First message is PixelLab, art, picking the next idea
- Checks are `red` or `pending` (do not checkout)

`playtest` always lands if the tree is clean and a PR number is known. If several PRs are open, ask which one first.

## Land

1. `gh pr checkout <number>`
2. If `godot` is on PATH, run:

```text
godot --headless --path game -s res://tests/run.gd
```

Headless fail is not a stop if the owner still wants Play. Say so in one clause, then the Play line.
3. Do not launch the Godot editor. Do not play the game.
4. End with the Ready for Play line.

## Sync

On a sign-off (`done`, `good`, `save`, `commit`, `push`, and the other words in `.cursor/rules/commit-signoff.mdc`):

1. Commit Play notes if the tree is dirty (`docs/STATUS.md`, `docs/DECISIONS.md`). Never stage secrets.
2. If this is a PR branch: `git push`, then `gh pr merge <number> --merge`. This repo uses merge commits, not squash.
3. `git checkout main` and `git pull`.
4. Confirm `main` matches `origin/main` (`git status -sb`, `git log -1 --oneline`).
5. End with the after-sign-off line.

Already on clean `main` with nothing to merge: still say the after-sign-off line if GitHub matches. If `main` is ahead, push, then say it.

## Play notes

Small problems stay in this chat. Patch the PR branch. End with: Say what felt wrong. I will patch this branch. Then press Play again.

A large rewrite can go back to cloud. That is the exception.

## Next-action lines

Use these words:

- One open PR, tree clean, checks green or unknown, not an art/ideas chat: Ready for Play. Open the `game` folder in Godot and press Play. When it feels right, say done.
- PR still building / checks red: Not ready for Play yet. Wait until the PR is green, then start this chat again — or say playtest and I will check.
- Several open PRs: Which PR are we playtesting?
- Dirty tree: This PC has unsaved work. Say save so GitHub matches before we switch branches.
- On main, clean, no PR: GitHub matches this PC. Say top 3 for the next slice, or PixelLab for art.
- After plan (verbs/research): Click Build in Cloud. Do not playtest there. When the PR is up, start a new local chat — I will tell you when Godot is ready.
- Cloud PR opened: PR is up. Start a new local chat on the Surface for Play. I will not open Godot here.
- After `done` / `good` / `save`: main matches GitHub. Start a new chat for the next idea.
- Play found a small problem: Say what felt wrong. I will patch this branch. Then press Play again.
