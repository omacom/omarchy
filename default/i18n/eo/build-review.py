#!/usr/bin/env python3
"""Build a review sheet for Esperanto native speakers.

Produces a single Markdown file listing every translated string grouped by
catalog, so a reviewer can go through them in context and flag awkward
wording. Strings whose English source is unchanged (brand names, technical
tokens, clock-format previews) are listed separately so the reviewer knows
those are intentional.
"""
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[3]
I18N = ROOT / "default" / "i18n"
EN, EO = I18N / "en", I18N / "eo"

TITLES = {
    "menu.json": "Menu (`menu.json`) — 413 keys",
    "shell.json": "Shell (`shell.json`) — 558 keys",
    "cli.json": "CLI and notifications (`cli.json`) — 306 keys",
    "keybindings.json": "Keybinding descriptions (`keybindings.json`) — 189 keys",
}

lines = [
    "# Esperanto (`eo`) translation — review sheet",
    "",
    "Omarchy ships in 51 languages. Esperanto was added because it has no",
    "country: glibc provides it as `eo.UTF-8` rather than `eo_XX.UTF-8`,",
    "so `bin/omarchy-locale-generate` needed its locale pattern widened to",
    "accept a country-less locale.",
    "",
    "This sheet lists every translated string, grouped by catalog, so a",
    "native speaker can check wording, register and consistency. Please flag",
    "anything that sounds unnatural, too literal, or inconsistent with",
    "another string.",
    "",
    "## Conventions already applied",
    "",
    "- **Left in English on purpose:** brand and product names (Omarchy,",
    "  Hyprland, Neovim, Firefox, Steam, Rust…), technical tokens (DNS, DHCP,",
    "  SSH, AUR, TUI, GPU), commands, file paths, URLs and key names.",
    "- **Plurals:** Esperanto uses only `one` (n = 1) and `other` per CLDR, so",
    "  plural entries carry those two categories. Esperanto marks the plural in",
    "  the noun (`-oj` for a count), so forms read `1 memorigo` /",
    "  `5 memorigoj`.",
    "- **Placeholders:** every `%1`, `%2`… is preserved from the English source,",
    "  order sometimes changed to suit Esperanto word order.",
    "- **Register:** consumer desktop software — short, direct, imperative.",
    "",
    "## Things a reviewer should look hardest at",
    "",
    "1. **Verb forms.** Esperanto has one past, one present, and a conditional;",
    "   English has more tenses than that. Check that each CLI string reads as",
    "   a natural state or instruction rather than a forced translation.",
    "2. **Imperatives.** Menu actions and toggles were rendered as infinitives",
    "   (`Ŝalti`, `Forigi`). Check these feel right for menu items.",
    "3. **Capitalisation of ALL-CAPS headers** (`BAR, KONEKTOJ, FONTOJ`).",
    "4. **Register of `trigger.*` status labels** such as",
    "   `Stay Awake` → `Resti veka` — English uses adjectives here in some",
    "   places and verb phrases in others; the Esperanto may need to follow",
    "   the surrounding pattern more strictly.",
    "5. **The loading phrases** (`bluetooth.phrase1…`, `power.chargingPhrase…`,",
    "   `network.phrase1…`, `tailscale.phrase1…`, `dropbox.phrase1…`). These are",
    "   playful rotating status text. They were translated literally in tone;",
    "   check whether they still feel light rather than technical.",
    "6. **Idioms in the notifications panel**, e.g.",
    "   `Step aside for …` → `Paŝi flanken por …` and",
    "   `stay on %1` (Wi-Fi band) → `Resti sur %1`.",
    "",
    "## Open questions for the reviewer",
    "",
    "- Esperanto has no fixed UI convention for a *Settings / Setup* menu.",
    "  `setup` was translated as **Agordo** (singular, “arrangement/setup”).",
    "  Some Esperanto localisation guides prefer **Agordoj** or",
    "  **Konfigurado**. Which reads most naturally here?",
    "- `appearance` became **Aspekto**, `trigger` became **Ŝaltilo**. Both are",
    "  fine literally, but `Ŝaltilo` reads slightly like “switch” rather than",
    "  “the toggles section”. Is there a better collective noun?",
    "- The `clock.*` entries that are Qt date patterns (`MMMM d`, `%1 %2`) were",
    "  left in English because the shell hands them straight to Qt, which",
    "  formats them through the `formatLocale`. Please confirm Esperanto’s",
    "  month names do come out localised through `Qt.locale(\"eo\")` on a real",
    "  install — this has not been verified on-device yet.",
    "",
]


def value_text(value):
    if isinstance(value, dict):
        return " / ".join(f"{k}: {v}" for k, v in value.items())
    return value


total = 0
for name in ("menu.json", "shell.json", "cli.json", "keybindings.json"):
    en = json.loads((EN / name).read_text(encoding="utf-8"))
    eo = json.loads((EO / name).read_text(encoding="utf-8"))

    same, changed = [], []
    for key in en:
        if en[key] == eo.get(key):
            same.append(key)
        else:
            changed.append(key)

    lines += [f"## {TITLES[name]}", ""]
    lines += [
        f"{len(changed)} strings translated, {len(same)} intentionally left in",
        "English (brand names and technical tokens).",
        "",
        "<details>",
        "<summary>Translated strings</summary>",
        "",
        "| Key | English | Esperanto |",
        "| --- | --- | --- |",
    ]
    for key in changed:
        e = str(value_text(en[key])).replace("|", "\\|")
        t = str(value_text(eo[key])).replace("|", "\\|")
        lines.append(f"| `{key}` | {e} | {t} |")
    lines += ["", "</details>", ""]

    lines += [
        "<details>",
        "<summary>Left in English (%d, for reference)</summary>" % len(same),
        "",
    ]
    for key in same:
        lines.append(f"- `{key}`: {value_text(en[key])}")
    lines += ["", "</details>", ""]
    total += len(changed)

lines += [
    "## Totals",
    "",
    f"- Translated and needing review: **{total}** strings",
    "- Untranslated on purpose: brand names, technical tokens, Qt date patterns,",
    "  and clock-format previews (where only weekday and month words translate,",
    "  so most of those preview strings are effectively unchanged).",
    "",
]

dest = ROOT / "default" / "i18n" / "eo" / "REVIEW.md"
dest.write_text("\n".join(lines), encoding="utf-8")
print(f"wrote {dest} ({total} strings for review, {len(lines)} lines)")