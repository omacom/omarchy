-- Local model shortcuts. Recording itself stays on the dictation keys.
o.bind("SUPER + CTRL + Y", "Run an action by what you say", "omarchy-launch-floating-terminal-with-presentation omarchy-ml-intent")
o.bind("SUPER + SHIFT + CTRL + N", "Fold notifications", "omarchy-ml-notify-fold --notify")
o.bind("SUPER + CTRL + G", "Search screenshots", "omarchy-launch-floating-terminal-with-presentation 'omarchy-ml-shot search'")
o.bind("SUPER + CTRL + U", "Restore workspace", "omarchy-ml-workspace restore")
o.bind("SUPER + CTRL + J", "Training workspace", "omarchy-ml-workspace train")
o.bind("SUPER + CTRL + M", "Park training workspace", "omarchy-ml-workspace park")
o.bind("SUPER + CTRL + Q", "Local model chat", "omarchy-ml-chat")
o.bind("SUPER + CTRL + SLASH", "Jupyter", "omarchy-launch-jupyter")
