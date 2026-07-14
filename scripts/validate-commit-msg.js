const fs = require("node:fs");

const commitMsgPath = process.argv[2];
const message = fs.readFileSync(commitMsgPath, "utf8").trim().split("\n")[0];

const allowedTypes = [
  "feat",
  "fix",
  "docs",
  "style",
  "refactor",
  "perf",
  "test",
  "build",
  "ci",
  "chore",
  "revert",
];

const conventionalCommit = new RegExp(
  `^(${allowedTypes.join("|")})(\\([^)]+\\))?(!)?: .+`
);

if (conventionalCommit.test(message)) {
  process.exit(0);
}

console.error("");
console.error("Invalid commit message.");
console.error("");
console.error("Use: type(scope): short summary");
console.error("");
console.error("Examples:");
console.error("  feat(player): add source filter chips");
console.error("  fix(search): remove unused Pressable import");
console.error("  chore(ci): add PR checks and CODEOWNERS");
console.error("");
console.error(`Allowed types: ${allowedTypes.join(", ")}`);
console.error("");
console.error(`Your message: \"${message}\"`);
console.error("");
console.error("Try again with a Conventional Commit message.");

process.exit(1);
