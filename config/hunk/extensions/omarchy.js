// Registers the palette Omarchy renders on every theme switch as a Hunk theme
// named "omarchy". omarchy-theme-set-hunk installs this file once and publishes
// the palette beside it as themes/omarchy.json; choosing another theme in
// Hunk's config leaves both in place to come back to.
import { readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

export default function (hunk) {
  const configDir = process.env.XDG_CONFIG_HOME || join(homedir(), ".config");
  let theme;

  try {
    theme = JSON.parse(readFileSync(join(configDir, "hunk", "themes", "omarchy.json"), "utf8"));
  } catch {
    // No palette published yet, so the theme is simply absent from the selector.
    return;
  }

  hunk.registerTheme({ ...theme, id: "omarchy", label: "Omarchy" });
}
