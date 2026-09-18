echo "Install Atreyu, the AI assistant plugin"

# Atreyu ships as the atreyu package rather than in this checkout; pacman puts
# it under /usr/share/omarchy/plugins, where the shell now looks next to its
# bundled plugins. A package the mirror does not carry yet fails the migration
# on purpose: nothing before this line has changed anything, and the runner
# retries it on the next update or login rather than quietly leaving the
# machine without the plugin.
omarchy-pkg-add atreyu

# A shell that already knows the packaged root (dev-linked, or restarted
# since) picks the plugin up here; the one an update runs under predates it
# and is replaced by omarchy-update-restart right after the migrations.
omarchy-shell -q shell rescanPlugins || true

# The widget sits just left of agents in the default bar, which a machine
# without a shell.json takes on as soon as the shell restarts. A customized
# bar gets the entry written into its file rather than placed over IPC: the
# shell this runs under cannot see a widget its scan never reached and would
# refuse it, whereas the file it hot-reloads carries the entry through to the
# restart. A bar that already carries the widget keeps it where the user put
# it.
source omarchy-shell-config

[[ -s $CONFIG_FILE ]] || exit 0
# A file the shell cannot read is left for its owner to repair.
jq empty "$CONFIG_FILE" 2>/dev/null || exit 0

entry_id='def entry_id: if type == "object" then (.id // "" | tostring) else tostring end;'

if jq -e "$entry_id"'
  any((.bar.layout // {} | .left, .center, .right | arrays)[]; entry_id == "omarchy.atreyu")
' "$CONFIG_FILE" >/dev/null; then
  exit 0
fi

commit "$NORMALIZE | $entry_id"'
  def ids: map(entry_id);
  def insert_at($section; $index):
    .bar.layout[$section] = .bar.layout[$section][:$index] + [{id: "omarchy.atreyu"}] + .bar.layout[$section][$index:];
  . as $config
  | (["left", "center", "right"] | map(select($config.bar.layout[.] | ids | index("omarchy.agents") != null)) | first) as $section
  | if $section != null then
      insert_at($section; .bar.layout[$section] | ids | index("omarchy.agents"))
    else
      insert_at("right"; (.bar.layout.right | ids | index("omarchy.tray")) as $tray
        | if $tray == null then (.bar.layout.right | length) else $tray + 1 end)
    end
'
