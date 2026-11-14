#!/usr/bin/env python3
"""Rebuild shell/plugins/emojis/emojis.json from Unicode's emoji-test.txt.

Names, groups and order come from emoji-test.txt. The keywords already in
emojis.json are kept exactly, so words people search by keep working; names
and subgroups only add words that are missing. Emoji with a full set of
single-tone skin variants carry them in "t" (light to dark).

Usage: scripts/build-emojis.py emoji-test.txt
  emoji-test.txt: https://www.unicode.org/Public/emoji/latest/emoji-test.txt
"""
import json
import re
import sys
from pathlib import Path

TARGET = Path(__file__).resolve().parent.parent / "shell/plugins/emojis/emojis.json"
TONES = [chr(c) for c in range(0x1F3FB, 0x1F400)]
# emoji-test.txt group name -> group id used by EmojiSearch.js GROUPS.
GROUPS = {
    "Smileys & Emotion": "smileys",
    "People & Body": "people",
    "Animals & Nature": "nature",
    "Food & Drink": "food",
    "Travel & Places": "travel",
    "Activities": "activities",
    "Objects": "objects",
    "Symbols": "symbols",
    "Flags": "flags",
}

# Search words for emoji newer than Omarchy's list, which has none for them.
ADDED_KEYWORDS = {
    "head shaking horizontally": "no nope disagree",
    "head shaking vertically": "yes nod agree",
    "family: adult, adult, child": "parents kid",
    "family: adult, adult, child, child": "parents kids",
    "family: adult, child": "parent kid single",
    "family: adult, child, child": "parent kids single",
    "phoenix": "fire bird rebirth reincarnation",
    "lime": "citrus fruit green sour",
    "brown mushroom": "fungus food",
    "broken chain": "break freedom unlink",
    "face with bags under eyes": "tired exhausted sleepy",
    "fingerprint": "identity security biometric",
    "leafless tree": "bare winter dead drought",
    "root vegetable": "radish turnip beet",
    "harp": "music instrument",
    "shovel": "dig spade",
    "splatter": "splash paint stain splat",
    "flag: Sark": "sark channel islands",
    "distorted face": "warped confused glitch",
    "fight cloud": "brawl scuffle cartoon dust",
    "hairy creature": "bigfoot yeti sasquatch",
    "ballet dancer": "ballerina dance",
    "orca": "killer whale ocean",
    "landslide": "rockslide avalanche disaster",
    "trombone": "music brass instrument",
    "treasure chest": "pirate gold loot",
    "cracking face": "broken shattered breaking stress",
    "leftwards thumb sign": "thumb left hitchhike point",
    "rightwards thumb sign": "thumb right hitchhike point",
    "monarch butterfly": "insect orange",
    "pickle": "dill gherkin cucumber",
    "lighthouse": "beacon coast guide",
    "meteor": "shooting star space rock",
    "eraser": "rubber undo delete",
    "net with handle": "butterfly net fishing catch",
}


def bare(s):
    return s.replace("\ufe0f", "")


def untoned(s):
    return "".join(c for c in s if c not in TONES)


def main(test_path):
    keywords = {bare(x["e"]): x["k"] for x in json.loads(TARGET.read_text(encoding="utf-8"))}
    emojis, by_base, toned = [], {}, {}
    group = subgroup = None
    for line in open(test_path, encoding="utf-8"):
        if line.startswith("# group:"):
            group = GROUPS.get(line.split(":", 1)[1].strip())
            continue
        if line.startswith("# subgroup:"):
            subgroup = line.split(":", 1)[1].strip().replace("-", " ")
            continue
        m = re.match(r"^([0-9A-F ]+?)\s+; fully-qualified\s+# \S+ E\S+ (.*)$", line)
        if not m or not group:
            continue
        seq = "".join(chr(int(c, 16)) for c in m.group(1).split())
        name = m.group(2)
        tones = {c for c in seq if c in TONES}
        if tones:
            if len(tones) == 1:
                toned.setdefault(bare(untoned(seq)), {})[TONES.index(tones.pop())] = seq
            continue
        # Existing keywords stay exactly as they are; the name and subgroup
        # only add words that are missing.
        words = keywords.get(bare(seq)) or ADDED_KEYWORDS.get(name, "")
        extra = f"{name} {subgroup}".lower().replace(":", "").replace(",", "").split()
        k = " ".join([words] + [w for w in dict.fromkeys(extra) if w not in words.split()]).strip()
        entry = {"e": seq, "k": k, "n": name, "g": group}
        by_base[bare(seq)] = entry
        emojis.append(entry)

    for base, variants in toned.items():
        if base in by_base and len(variants) == len(TONES):
            by_base[base]["t"] = [variants[i] for i in range(len(TONES))]

    TARGET.write_text(json.dumps(emojis, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"Wrote {len(emojis)} emoji to {TARGET}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
