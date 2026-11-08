-- Plymouth keeps the boot splash animating until a compositor asks for the
-- display (bin/omarchy-plymouth-handoff). Asked here, while Hyprland reads its
-- config and before it opens the display; only a waiting handoff is asked.
local _, err = io.open("/run/omarchy-plymouth-handoff.sock", "r")
if err and not err:find("No such file", 1, true) then
  os.execute((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/bin/omarchy-plymouth-release")
end
