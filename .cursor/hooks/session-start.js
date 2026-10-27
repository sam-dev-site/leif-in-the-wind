#!/usr/bin/env node
let raw = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  raw += chunk;
});
process.stdin.on("end", () => {
  process.stdout.write(
    JSON.stringify({
      additional_context: [
        "This is Leif in the Wind. GitHub sam-dev-site/leif-in-the-wind is the source of truth, not chat memory.",
        "Before any work, read AGENTS.md, docs/MISSION.md, docs/DECISIONS.md, and docs/STATUS.md.",
        "Do not invent flora or fauna. Species must come from docs/research/biomes/.",
        "If you make a lasting decision, append docs/DECISIONS.md in the same session. Update docs/STATUS.md before you finish.",
        "Prefer cloud/PR work. This PC is for playtest.",
        "sessionStart does not run on Cursor cloud agents — AGENTS.md and .cursor/rules still do.",
      ].join("\n"),
    })
  );
});
