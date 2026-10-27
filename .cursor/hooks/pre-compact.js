#!/usr/bin/env node
let raw = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  raw += chunk;
});
process.stdin.on("end", () => {
  process.stdout.write(
    JSON.stringify({
      user_message:
        "Context is compacting. Lasting decisions belong in docs/DECISIONS.md and docs/STATUS.md — chat memory will lose them.",
    })
  );
});
