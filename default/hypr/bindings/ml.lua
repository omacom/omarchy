-- Local model shortcuts. Recording itself stays on the dictation keys.
-- These sit on the quick-action plane, not as Alt variants of app keys.
o.bind("SUPER + CTRL + ALT + A", "Run an action by what you say", "omarchy-launch-floating-terminal-with-presentation omarchy-ml-intent")
o.bind("SUPER + SHIFT + CTRL + N", "Fold notifications", "omarchy-ml-notify-fold --notify")
o.bind("SUPER + CTRL + ALT + P", "Search screenshots", "omarchy-launch-floating-terminal-with-presentation 'omarchy-ml-shot search'")
o.bind("SUPER + CTRL + ALT + U", "Restore workspace", "omarchy-ml-workspace restore")
o.bind("SUPER + CTRL + ALT + I", "Training workspace", "omarchy-ml-workspace train")
o.bind("SUPER + CTRL + ALT + O", "Park training workspace", "omarchy-ml-workspace park")
o.bind("SUPER + CTRL + ALT + Y", "Local model chat", "omarchy-ml-chat")
o.bind("SUPER + CTRL + ALT + J", "Jupyter", "omarchy-launch-jupyter")
