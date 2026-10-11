# Rex, the Regular Expression Workbench

Rex is Omarchy's workbench for regular expressions: write a pattern, see what it matches, understand why, make it faster, and learn how it all works. It runs entirely offline, so patterns and test text never leave your machine, and every result comes from the real engine of the language you pick, not an imitation of it.

Launch _Rex_ from the app launcher (`Super + Space`), or run `omarchy-launch-rex` from a terminal. Give it a pattern to start with: `omarchy-launch-rex '\d{4}-\d{2}-\d{2}'`. Launching it again brings the open window forward.

## Flavors

Pick the flavor in the top left. Rex offers every engine it finds installed:

- **Always there:** PCRE2 (PHP, `grep -P`, and much else), Python's `re`, Perl, Ruby, POSIX extended and basic syntax, Lua patterns, grep, sed, gawk, Vim (through Neovim), and Qt's own JavaScript engine.
- **When the toolchain is installed:** JavaScript as V8 runs it (Node), Go, Rust, Java, .NET, C++ `std::regex`, Python's `regex` module, and Resid.

Go, Rust, Java, .NET, C++, and Resid are compiled the first time you use them, which takes a few seconds; Rex says so while it waits. Rust's `regex` crate has to be in Cargo's cache: run `omarchy-rex-worker --fetch rust` once while online if Rex asks for it.

The flags next to the flavor are that engine's own: `i` to ignore case, `m` for multiline, and so on. Hover a flag to see what it does. `all` switches between every match and just the first.

## The Workbench

Type the pattern on top and the text to search below. Matches light up as you type, each group underlined in its own color, and the pattern itself is tinted by what each part does. Mistakes are underlined in red, with the engine's own error message beneath.

The panel on the right has four tabs:

- **Matches** lists every match and group with its position. Click one to jump to it in the text.
- **Explain** walks through the pattern piece by piece in plain language, noting where the flavor matters ("\d is ASCII only here"). Hover a line to see its part of the pattern.
- **Optimize** reviews the pattern for catastrophic backtracking, slow constructs, and simpler ways to write the same thing. Rex runs every suggested rewrite on the engine first and only lets you apply one that matches the same on your text and passes your tests. For backtracking risks, _Measure_ times the pattern on texts built to trigger the problem.
- **Tests** pins down what the pattern must do: texts it has to match, has to reject, or has to capture a certain value from. They run on every change.

Below the text, _Substitute_, _List_, and _Split_ use the flavor's own rules: `$1` in JavaScript, `\1` in Python, `%1` in Lua, and so on.

### Large Files

_Open file…_, or dropping a file onto the text, searches a file of any size. Files over 64K characters open read-only in a view that only draws what is on screen, and the engine reads the file itself, so even a multi-megabyte log stays quick.

## The Other Pages

The icons down the left switch pages:

- **Compare flavors** runs the pattern on every installed engine at once and shows where they disagree, and why a flavor rejects it.
- **Debugger** steps through PCRE2 matching the pattern: the item it tries, where, and every backtrack. Its busiest items show where a slow pattern spends its time. Arrow keys step; space plays.
- **Benchmark** times the pattern on every engine, one at a time, on your text or on it repeated ten or a hundred times.
- **Code** writes the pattern into code for the flavor's language, quoted so it arrives intact.
- **Reference** lists every construct the flavor understands, each with an example that opens on the workbench.
- **Lessons** is a thirty-lesson course, from a first literal to how engines work inside, with exercises checked as you type.
- **Library** saves patterns with their flavor, flags, test text, replacement, and tests, and keeps the patterns you used recently.

## Where Rex Keeps Things

Rex reopens with whatever you were last working on. Your session, saved patterns, recent patterns, and lesson progress live in `~/.local/share/rex/`. Compiled engines are cached in `~/.cache/omarchy/rex/`; deleting that folder only means they are built again.
