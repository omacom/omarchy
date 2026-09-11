# Local AI Omarchy Widget

Native Omarchy bar widget that runs the validated local model for your GPU
and hands it to your coding agents.

## Features

- Shows the one model validated for the detected GPU; Start downloads and
  serves it, Stop removes it, and every refusal says why on the card
- Lists every detected GPU with its VRAM; the largest card with a validated
  recipe is the default, and any other can be pinned
- Opens any installed coding agent (pi, omp, opencode, claude, codex, crush,
  copilot, grok, and more) on the running model with the endpoint and key in
  the agent's own environment; no user config is written
- Shares the endpoint on your tailnet, keyed, with one click
- Bar icon: hollow while idle, filling with progress, full when ready;
  right-click opens the selected agent

## How it works

Recipes come from the [local-ai-registry](https://github.com/0xSero/local-ai-registry)
and are vendored in `recipes.json`, one per hardware id, each validated on
that card. A recipe runs as two labeled Docker containers on a private
network: the engine (image pinned by digest, model pinned by revision) and a
gateway that speaks OpenAI chat, Anthropic Messages, and OpenAI Responses on
`127.0.0.1:12434` and requires a key on every request. Acceptance proves the
served model, the key, a chat reply, decode speed, every dialect, and a tool
call before the model is called ready; a failure rolls back to the previous
model. The gate refuses any recipe that is not digest-pinned, asks for host
IPC, extra capabilities, a weakened security profile, or a mount outside the
plugin's own cache roots.

## Commands

```
omarchy local ai snapshot               refresh and print the state the panel renders
omarchy local ai load                   download if needed, then start the model
omarchy local ai unload                 stop the model; keep downloads
omarchy local ai open-agent [name]      open an installed coding agent on it
omarchy local ai share [--key <value>]  toggle tailnet sharing, or replace the key
omarchy local ai gpu [auto|<key>]       which detected card to use
omarchy local ai agent-dir <path>       directory agents open in
omarchy local ai agent-args <name> [-- flags]  extra flags for one agent
```

## Requirements

- Docker. The user need not be in the `docker` group: Start, Stop, and Share
  each ask for the password once through Omarchy's polkit prompt, the way
  `omarchy-launch-docker-tui` does; with Sudoless Docker enabled there is no
  prompt. A missing NVIDIA container toolkit is installed inside that prompt.
- An NVIDIA GPU or an Intel Arc Pro B70
- `jq`, `curl`; `tailscale` for sharing

State lives in `~/.local/state/omarchy/local-ai/` (0700; `log` records every
step) and weights in `~/.cache/omarchy/local-ai/` or the Hugging Face cache.

## Add to the bar

This widget ships as first-party plugin `omarchy.local-ai`. Add it with
`omarchy plugin enable omarchy.local-ai`, then place it with
`omarchy bar move omarchy.local-ai` if desired.
