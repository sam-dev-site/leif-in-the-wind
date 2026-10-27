# PixelLab in Cursor

PixelLab is how we turn researched species into pixel art from this chat. The MCP config is already in `.cursor/mcp.json`. **The only thing a human has to do is create an account and put the API token on this PC.**

Never commit the token. Never paste it into a GitHub file.

## You (one sitting)

1. Open [https://www.pixellab.ai/mcp](https://www.pixellab.ai/mcp) (this chat should have opened it).
2. Sign up / log in. MCP needs an active PixelLab plan, not only a free peek.
3. Copy your **API token** from that page (or Account).
4. Put it in a **user** environment variable named `PIXELLAB_API_TOKEN` (not in the repo):

   Windows Search → “environment variables” → Environment Variables → your user → New:

   - Name: `PIXELLAB_API_TOKEN`
   - Value: the token

5. **Fully quit Cursor** (not just the chat) and open this project again.

When it worked, a new chat will see PixelLab tools (`create_character`, `create_topdown_tileset`, and so on). Say “PixelLab is in” and we generate Leif + coastal tiles against the forest screenshot.

## Agents

- If PixelLab tools are visible, use them. Do not curl the REST API as a workaround.
- Species and prompts must match `docs/research/biomes/`. Style reference: `art-inspo/screen-layout-pixels.jpg`. View: high top-down. 16×16 tiles.
- Save outputs under `art/biomes/<id>/` with species names (`tree_spruce.png`), then import into Godot. Do not invent `tree1`.
- Token lives only in `PIXELLAB_API_TOKEN` on the owner’s machine.
