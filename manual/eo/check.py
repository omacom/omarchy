#!/usr/bin/env python3
"""Check manual/eo/ against the English source.

Runs the same integrity rules the upstream test uses (headings, URLs, fenced
code, relative links, protected inline spans) plus a prose-level check that
the translation is not just a copy of the English.

Usage:
    python3 manual/eo/check.py            # report problems
    python3 manual/eo/check.py --quiet    # exit code only
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
MANUAL = ROOT / "manual"
EN_DIR, EO_DIR = MANUAL, MANUAL / "eo"


def bag(items):
    return json.dumps(sorted(items))


def fences(text):
    return [m.group(1) for m in re.finditer(r"```[^\n]*\n([\s\S]*?)```", text)]


def urls(text):
    return re.findall(r"https?://[^\s)]+", text) or []


def rel_dests(text):
    return [m.group(1) for m in re.finditer(r"\]\((?!<?https?://)([^)\s]+)", text)]


def protected_inline(text):
    out = []
    for m in re.finditer(r"`([^`\n]+)`", text):
        span = m.group(1)
        if re.search(r"[/~$]", span) or span.startswith("omarchy ") or span.startswith("omarchy-"):
            out.append(re.sub(r"<[^>]+>", "<>", re.sub(r"\[[^\]]+\]", "[]", span)))
    return out


def problems(en, eo):
    found = []
    if len(re.findall(r"^#{1,6} ", en, re.M)) != len(re.findall(r"^#{1,6} ", eo, re.M)):
        found.append("heading count changed")
    if bag(urls(en)) != bag(urls(eo)):
        found.append("URLs changed")
    if bag(fences(en)) != bag(fences(eo)):
        found.append("code block contents changed")
    if bag(rel_dests(en)) != bag(rel_dests(eo)):
        found.append("relative link destinations changed")
    if bag(protected_inline(en)) != bag(protected_inline(eo)):
        found.append("commands or paths in inline code changed")
    return found


def prose_ratio(en, eo):
    """Rough share of sentences left verbatim in English."""
    def sentences(text):
        # Drop code, links and images, then split on sentence enders.
        text = re.sub(r"```[\s\S]*?```", " ", text)
        text = re.sub(r"!?\[[^\]]*\]\([^)]*\)", " ", text)
        text = re.sub(r"`[^`\n]+`", " ", text)
        parts = [s.strip() for s in re.split(r"(?<=[.!?])\s+", text)]
        return [s for s in parts if len(s.split()) >= 4]

    en_set = set(sentences(en))
    eo_sents = sentences(eo)
    if not eo_sents:
        return 0.0
    untranslated = sum(1 for s in eo_sents if s in en_set)
    return untranslated / len(eo_sents)


def main():
    quiet = "--quiet" in sys.argv
    say = (lambda *a: None) if quiet else print
    english = sorted(p.name for p in EN_DIR.glob("*.md"))
    problems_found = 0

    missing = [f for f in english if not (EO_DIR / f).exists()]
    for f in missing:
        say(f"MISSING  {f}")
        problems_found += 1

    extra = sorted(p.name for p in EO_DIR.glob("*.md") if p.name not in set(english))
    for f in extra:
        say(f"EXTRA    {f}")
        problems_found += 1

    for name in english:
        eo_path = EO_DIR / name
        if not eo_path.exists():
            continue
        en_text = (EN_DIR / name).read_text(encoding="utf-8")
        eo_text = eo_path.read_text(encoding="utf-8")

        if not eo_text.strip():
            say(f"EMPTY    {name}")
            problems_found += 1
            continue

        issues = problems(en_text, eo_text)
        if issues:
            say(f"BROKEN   {name}: {'; '.join(issues)}")
            problems_found += 1
        else:
            ratio = prose_ratio(en_text, eo_text)
            if not quiet:
                flag = "  <-- still English" if ratio > 0.5 else ""
                print(f"ok       {name}  ({ratio:.0%} untranslated){flag}")
            if ratio > 0.5:
                problems_found += 1

    done = len([f for f in english if (EO_DIR / f).exists()])
    say(f"\n{done}/{len(english)} chapters translated, {problems_found} problems")
    return 1 if problems_found else 0


if __name__ == "__main__":
    sys.exit(main())