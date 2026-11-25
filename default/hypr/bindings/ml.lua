-- Local model shortcuts. Recording itself stays on the dictation keys.
o.bind("SUPER + ALT + A", "Run an action by what you say", "omarchy-ml-intent")
o.bind("SUPER + SHIFT + CTRL + N", "Fold notifications", "omarchy-ml-notify-fold --notify")
o.bind("SUPER + ALT + SHIFT + P", "Search screenshots", "omarchy-ml-shot search")
o.bind("SUPER + ALT + SHIFT + W", "Restore workspace", "omarchy-ml-workspace restore")
o.bind("SUPER + ALT + SHIFT + T", "Training workspace", "omarchy-ml-workspace train")
o.bind("SUPER + ALT + SHIFT + Y", "Park training workspace", "omarchy-ml-workspace park")
o.bind("SUPER + ALT + SHIFT + C", "Local model chat", "omarchy-ml-chat")
o.bind("SUPER + ALT + SHIFT + J", "Jupyter", "omarchy-launch-jupyter")
