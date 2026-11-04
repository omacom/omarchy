---
name: diagnose-crash
description: >
  Diagnose why a program crashed on this machine, from a systemd-coredump core dump.
  Use when a process has segfaulted, aborted, or otherwise dumped core, when asked
  why an application crashed or disappeared, or when a "Process crashed:" desktop
  notification is acted on. Triggers: crash, segfault, SIGSEGV, SIGABRT, core dump,
  coredumpctl, "why did X crash", "X keeps crashing", backtrace symbolization.
  Covers reporting a confirmed Omarchy bug upstream — see reporting.md.
---

# Diagnosing a Crash

Work from evidence. The goal is an honest account of what happened, not a
plausible-sounding story.

## Establish the facts

`coredumpctl info <pid>` is the starting point. Beyond the backtrace, note the
**command line** the process was started with — it usually reveals what the
program was working on when it died, which is often the whole answer.

`coredumpctl list` shows whether this crash is a one-off or a pattern. Repeated
crashes of the same program, or several programs dying together, point somewhere
different than a single failure does.

**Check whether it was traced.** `TracerPid:` in the `/proc` status that
`coredumpctl info` records names any strace, gdb or other ptrace tracer attached
at the time. A traced process was already being debugged by someone, and the
tracer can be the cause: some programs assert by breakpoint only when they see a
debugger, which turns a warning they would otherwise log into a fatal SIGTRAP.
A SIGTRAP is in any case a deliberate `int3` or breakpoint, not memory
corruption, so look for the assertion or check that executed it.

**Check whether it was sandboxed.** An `NSpid:` line with more than one value, a
`container=` variable in the core's environment, or a binary path that does not
exist on the host means the process ran in its own namespaces (bwrap, Flatpak,
pressure-vessel). Its paths and PIDs are its own. Map them to the host through
the `Control Group` and `Unit` that `coredumpctl info` shows: `systemd-cgls -u
<unit>` lists what is still running there, and a bwrap command line spells out
each `--bind` from host path to sandbox path.

## Read the program's own logs

Many programs log the reason they are about to die, which a backtrace never
shows: a failed assertion, a fatal check, a missing resource. Find the log the
program writes, often named on its command line, under its config or data
directory, or in the journal, and read the lines from the crash second.

Then find a run of the same program that did **not** crash, on this machine or
in the same log from an earlier start. A warning that appears in both is not the
cause on its own; what differs between them is where the cause is.

## Rule out the boring causes first

Check resource exhaustion before blaming the program: `free -h`, and the journal
for OOM kills. A process killed by the OOM killer is not a bug in that process.

## Correlate against the timeline

The crash timestamp is the most underused piece of evidence. Compare it against:

- **Filesystem mtimes.** A directory or file whose mtime lands on the same second
  as the crash strongly suggests what triggered it.
- **The journal** around that moment, for related warnings from the same or
  neighbouring processes.
- **Recent package updates.** A crash that starts right after an update points at
  the update.

## Read the whole core, not just frame 0

Thread stacks other than the crashing one show what work was **in flight** —
thumbnailers, image loaders, IPC readers, GPU queues. That context often explains
the trigger even when the crashing frame itself cannot be symbolized.

Note any third-party code in the address space: file-manager or browser
extensions, plugins, out-of-tree drivers. In-process third-party code is a common
crash source and worth flagging — but do not pin blame on it without evidence
that it is actually implicated.

## Symbolize when you can

This is Arch, which runs a public debuginfod server:

```bash
core=$(mktemp -t crash-XXXXXX.core)
trap 'rm -f "$core"' EXIT
coredumpctl dump <pid> --output="$core"
DEBUGINFOD_URLS="https://debuginfod.archlinux.org" \
  gdb -q <executable> "$core" \
  -batch -ex 'set debuginfod enabled on' -ex 'bt'
```

A core is a verbatim copy of the process's memory and can hold passwords, tokens,
and private documents. Write it to a fresh `mktemp` path rather than a predictable
shared one, and delete it when you are done — never leave it lying in `/tmp`.

Many packages publish no debug symbols. When frames stay unresolved, say so —
never invent function names to fill the gap. An unsymbolized stack still has
shape: which library each frame belongs to, and whether the crash came from a
signal handler, a main loop, or a worker thread.

A stripped binary still names what it imports. Disassemble a little before the
crashing address, follow each `call` into the PLT, and look up the slot it jumps
through in `readelf -rW <executable>`: the relocation there names the function,
which can be enough to identify the check that fired.

## Report

1. What crashed, and what it was doing at the time.
2. The most likely mechanism — separating clearly what the evidence **proves**
   from what you are **inferring**.
3. Whether any user data was lost, and where it can be recovered from. Check the
   trash before concluding anything is gone.
4. Whether it is likely to recur, and what would avoid or fix it.

Be straight about the limits of the evidence. If the cause is genuinely
ambiguous, say so rather than assembling confidence out of guesswork.

**Leave the system as you found it.** Diagnosis reads; it does not fix, tidy, or
reconfigure. The one thing to clean up is your own: delete the core you extracted
above, which is a copy of the crashed process's memory. The single change a
diagnosis may make is the mute below, and only when the user asks for it.

## Offer to stop the notifications for this program

A crash you have explained often keeps happening anyway. Finish by offering to
silence notifications for **that one program**, and never run it unprompted. Say
how to lift it in the same breath, so it is not a one-way door.

```bash
omarchy-crash-mute '<program>'        # silence it
omarchy-crash-mute '<program>' off    # let it speak again
omarchy-crash-mute                    # list what is muted
```

Pass the `binary:` path from the crash facts, or the `process:` name where no
binary was recorded; the command reduces either to the name the watcher keys on.
A diagnosis run by hand from `omarchy agent crash <pid>` has neither, so take
them from `coredumpctl info`. Prefer the binary: a process name is truncated to
15 characters and a basename is not, so muting the truncated form matches
nothing, forever, while looking like it worked.

Quote it. The name is whatever the crashed program's author called a file, and a
single quote inside one closes yours and runs the rest as your shell.

The key is a bare name, so anything run through an interpreter is keyed as the
interpreter: muting `python3.13` silences every Python program on the machine.
Say so rather than quietly doing it.

None of this fixes anything, and a mute offered in place of a fix that was within
reach is the wrong answer. For every program rather than one, the switch is
_Trigger > Toggle > Crash Capture_.

## If it is an Omarchy bug

Most application crashes are upstream bugs in those applications, not Omarchy's
doing. In the minority of cases where the cause really does sit within Omarchy's
sphere of control, read [`reporting.md`](reporting.md) before offering to file
anything.
