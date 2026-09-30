# Agent comms

Opt-in bar tape for messages agents send you. It is not on the bar until you put it there:

```bash
omarchy plugin enable omarchy.agent-comms --section center
```

The tape stays out of the bar until a new comm arrives. The label and the scrolling line then show for one minute (`visibleSeconds`). A newer comm starts that minute over. Hover pauses the scroll and holds the tape open until the pointer leaves.

Desktop notifications from ChatGPT, Grok, and Muse are followed as soon as their live popup is stored. Dismissing a popup into history does not show the same comm again. The notification summary is the speaker when it is short (a dot's name, "Grok", "Muse") and the body is the comm. Change the app list with the `apps` setting; names match exactly, ignoring case and surrounding whitespace. An empty list ignores notifications.

Coding-session transcripts are not read.

Anything else can append a JSON line to `~/.local/state/omarchy/agent-comms/inbox.jsonl`, or to another `*.jsonl` file in that directory:

```json
{"agent":"guide","role":"out","text":"package is ready","ts":1710000000}
```

`role` is `out` when the agent is speaking and `in` when the line was said to the agent. `source` or `from` can stand in for `agent`, and `message` or `body` for `text`.

```bash
$OMARCHY_PATH/shell/plugins/agent-comms/post.sh guide "package is ready"
$OMARCHY_PATH/shell/plugins/agent-comms/post.sh --in guide "status?"
```

Other settings on the bar entry: `label` (default `comms`), `maxWidth`, and `pixelsPerSecond`. Set them with `omarchy bar set omarchy.agent-comms <key> <value>`.
