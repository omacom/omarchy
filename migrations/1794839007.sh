echo "Add launchers for the local models already set up"

# Setting up a local model now adds a launcher of its own beside Agent, with
# the model's name and its vendor's logo. Models set up before that get theirs
# here; a machine without any gets nothing. Neither does one whose engine was
# removed: without omarchy-local-ai no model can be read, let alone opened.
if omarchy-cmd-present omarchy-local-ai; then
  omarchy-models-launchers
fi
