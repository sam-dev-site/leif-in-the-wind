# PixelLab

PixelLab is how we turn researched species into pixel art. **The only thing a human has to do is keep the API token on this PC.** Never commit the token. Never paste it into a GitHub file.

Claude Code reads [`.mcp.json`](../.mcp.json) and expands `PIXELLAB_API_TOKEN` from the environment. Cursor reads `.cursor/mcp.json` the same way. Both files name the variable. Neither file holds the token.

The Windows user variable must already be set before the app launches. Fully quit Claude Code (or Cursor) and open the project again after you create or change it. `claude mcp list` should show the server without a missing-variable warning. If PixelLab answers 401, the variable did not expand. Do not paste the token into `.mcp.json` to get past that.

## You (one sitting)

1. Open [https://www.pixellab.ai/mcp](https://www.pixellab.ai/mcp) (this chat should have opened it).
2. Sign up / log in. MCP needs an active PixelLab plan, not only a free peek.
3. Copy your **API token** from that page (or Account).
4. Put it in a **user** environment variable named `PIXELLAB_API_TOKEN` (not in the repo):

   Windows Search → “environment variables” → Environment Variables → your user → New:

   - Name: `PIXELLAB_API_TOKEN`
   - Value: the token

5. **Fully quit Claude Code** (not just the chat) and open this project again. The same quit applies if Cursor is still what launches the tools.

When it worked, a new chat will see PixelLab tools (`create_character`, `create_topdown_tileset`, and so on). Say “PixelLab is in” and we generate Leif + coastal tiles against the forest screenshot.

First Leif (2026-10-27): character id `327ed41b-0289-49cb-bcd8-787b17f963ea`, mode=pro, 64px, high top-down, concept photo `art-inspo/viking-inspo.jpeg` via `get_upload_url` (do not paste large base64 — MCP truncates it). Trial plan had 40 generations; this character cost 10.

## Agents

- If PixelLab tools are visible, use them. Do not curl the REST API as a workaround.
- Species and prompts must match `docs/research/biomes/`. Style reference: `art-inspo/screen-layout-pixels.jpg`. View: high top-down. 16×16 tiles.
- Save outputs under `art/biomes/<id>/` with species names (`tree_spruce.png`), then import into Godot. Do not invent `tree1`.
- Token lives only in `PIXELLAB_API_TOKEN` on the owner’s machine.
