-- SteamVR's status window (vrmonitor, Qt over XWayland) and its error dialogs
-- open on whatever workspace has focus, tile into the layout and steal focus
-- from the game. Float them and keep them from grabbing focus.
o.window({ class = "^vrmonitor$" }, {
  float = true,
  no_initial_focus = true,
  focus_on_activate = false,
})
