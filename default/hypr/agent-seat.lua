-- Apps launched with omarchy agent seat run reach Hyprland through the agent
-- seat broker, which names every window "agent-<n>.<app id>". They open on the
-- agent seat's workspace (set in agent-workspaces.lua) without taking you there,
-- keep rendering while it is hidden (so agents can capture them), never take
-- the user's focus, and are outlined in the agent colour so they never read as
-- one of your own windows.
--
-- windows.lua loads this after every rule under default/hypr/apps, because
-- later rules win and an agent app picks its own title: a page titled
-- "Picture-in-Picture" or "... is sharing ..." would otherwise pick up the
-- pinned, borderless picture-in-picture rule or the hidden special workspace.
-- Floating stays allowed, as picture-in-picture floats legitimately.
--
-- The markings match on a tag of their own as well as coming last: when a
-- window's tags change, Hyprland re-applies only the rules that match on tags,
-- in order, so a marking matched on class alone would lose to the
-- picture-in-picture tag rule in that second pass.
local agent_workspaces = require("default.hypr.agent-workspaces")

local AGENT_CLASS = "agent-[0-9]+(\\..*)?"

agent_workspaces.place("agent-seat-apps", { class = AGENT_CLASS }, true)

o.window(AGENT_CLASS, { tag = "+agent-seat" })
o.window({ tag = "agent-seat" }, {
  render_unfocused = true,
  no_initial_focus = true,
  no_dim = true,
  pin = false,
  border_size = 3,
  border_color = "rgba(ff8a00ff) rgba(ffc266ff) 45deg",
})
