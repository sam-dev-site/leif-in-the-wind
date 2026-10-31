#!/usr/bin/env node
const { spawnSync } = require("child_process");

let raw = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", (chunk) => {
  raw += chunk;
});
process.stdin.on("end", () => {
  const lines = [
    "This is Leif in the Wind. GitHub sam-dev-site/leif-in-the-wind is the source of truth, not chat memory.",
    "Before any work, read AGENTS.md, docs/MISSION.md, docs/DECISIONS.md, and docs/STATUS.md.",
    "Do not invent flora or fauna. Species must come from docs/research/biomes/.",
    "If you make a lasting decision, append docs/DECISIONS.md in the same session. Update docs/STATUS.md before you finish.",
    "Bugs that are not the current Play go in docs/BUGS.md. When the owner asks for bug fixes, name the open headings in that file before changing the game.",
    "Prefer cloud/PR work. This PC is for playtest.",
    "sessionStart does not run on Cursor cloud agents — AGENTS.md and .cursor/rules still do.",
    "First local reply is one next-action line from .cursor/rules/dev-loop.mdc. Follow .cursor/skills/playtest-pr when landing a PR or syncing after sign-off.",
  ];

  appendGitState(lines);
  appendOpenPrs(lines);

  process.stdout.write(JSON.stringify({ additional_context: lines.join("\n") }));
});

function run(bin, args, timeoutMs) {
  const files =
    process.platform === "win32" ? [`${bin}.cmd`, `${bin}.exe`, bin] : [bin];
  const env = Object.assign({}, process.env, {
    GH_PROMPT_DISABLED: "1",
    GH_NO_UPDATE_NOTIFIER: "1",
    GIT_TERMINAL_PROMPT: "0",
  });
  for (const file of files) {
    const result = spawnSync(file, args, {
      encoding: "utf8",
      timeout: timeoutMs || 3000,
      windowsHide: true,
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
      env,
    });
    if (result.error && result.error.code === "ENOENT") {
      continue;
    }
    if (!result.error && result.status === 0) {
      return (result.stdout || "").trim();
    }
    return null;
  }
  return null;
}

function appendGitState(lines) {
  const branch = run("git", ["branch", "--show-current"]);
  if (branch === null) {
    lines.push("Could not read git branch. Ask instead of guessing.");
  } else {
    lines.push(`Current branch: ${branch || "(detached)"}`);
  }

  const porcelain = run("git", ["status", "--porcelain"]);
  if (porcelain === null) {
    lines.push("Could not read git status. Ask instead of guessing.");
  } else if (porcelain === "") {
    lines.push("Working tree: clean");
  } else {
    const n = porcelain.split(/\r?\n/).filter(Boolean).length;
    lines.push(
      `Working tree: dirty (${n} changed path(s)). Do not switch branches until the owner says save.`
    );
  }
}

function appendOpenPrs(lines) {
  const prJson = run(
    "gh",
    [
      "pr",
      "list",
      "--state",
      "open",
      "--json",
      "number,title,url,headRefName,statusCheckRollup",
      "--limit",
      "20",
    ],
    3500
  );
  if (prJson === null) {
    lines.push(
      "Could not list GitHub PRs (gh missing, not logged in, or failed). Ask instead of guessing."
    );
    return;
  }

  let prs;
  try {
    prs = JSON.parse(prJson);
  } catch (_err) {
    lines.push("Could not parse GitHub PR list. Ask instead of guessing.");
    return;
  }

  if (!Array.isArray(prs)) {
    lines.push("Could not parse GitHub PR list. Ask instead of guessing.");
    return;
  }

  if (prs.length === 0) {
    lines.push("Open PRs: none");
    return;
  }

  lines.push(`Open PRs: ${prs.length}`);
  for (const pr of prs) {
    const checks = summarizeChecks(pr.statusCheckRollup);
    lines.push(
      `- #${pr.number} ${pr.title} (${pr.headRefName}) ${pr.url} checks:${checks}`
    );
  }
}

function summarizeChecks(rollup) {
  if (!Array.isArray(rollup) || rollup.length === 0) {
    return "unknown";
  }
  const states = rollup.map((item) => {
    const raw = item.conclusion || item.state || item.status || "";
    return String(raw).toUpperCase();
  });
  if (
    states.some((s) =>
      ["FAILURE", "ERROR", "CANCELLED", "TIMED_OUT", "ACTION_REQUIRED"].includes(
        s
      )
    )
  ) {
    return "red";
  }
  if (
    states.some((s) =>
      ["PENDING", "QUEUED", "IN_PROGRESS", "EXPECTED", "WAITING"].includes(s)
    )
  ) {
    return "pending";
  }
  if (
    states.every((s) =>
      ["SUCCESS", "SKIPPED", "NEUTRAL", "COMPLETED"].includes(s)
    )
  ) {
    return "green";
  }
  return "unknown";
}
