const { execFileSync } = require("node:child_process");

try {
  execFileSync("git", ["config", "core.hooksPath", ".husky"], {
    stdio: "ignore",
  });
} catch {
  console.warn("Could not set core.hooksPath to .husky automatically.");
  console.warn("Run: git config core.hooksPath .husky");
}
