/* Omarchy chrome for T3 Code. omarchy-theme-set-t3code prepends
   --omarchy-radius from Hyprland's decoration:rounding, so corners follow the
   theme and `omarchy hyprland corners`. Colors mirror the shell's control
   tokens: foreground over the background at 4/8/12/18/40%. */

:root, .dark {
  /* The fontconfig alias `omarchy font set` writes. Naming it twice keeps
     Chromium from shrinking a lone `monospace` to its 13px default. */
  --font-sans: monospace, monospace;
  --font-mono: monospace, monospace;
  --default-font-family: var(--font-sans);
  --radius: var(--omarchy-radius);
}
html, body { font-family: var(--font-sans) !important; }

/* One radius for every framed surface, as the shell draws them. */
[data-slot="composer-host"],
[data-slot="menu-popup"],
[data-slot="popover-popup"],
[data-slot="dialog-popup"],
[data-slot="tooltip-popup"],
[data-slot="button"],
[data-slot="input"],
[data-slot="select-trigger"],
[data-thread-item],
[data-thread-details-card],
[data-user-message-bubble],
.chat-markdown-codeblock {
  border-radius: var(--omarchy-radius) !important;
}

/* Menus and dialogs: flat, framed in the foreground. */
[data-slot="menu-popup"],
[data-slot="popover-popup"],
[data-slot="dialog-popup"] {
  background: {{ background }} !important;
  border: 2px solid {{ foreground }} !important;
  box-shadow: none !important;
}
[data-slot="tooltip-popup"] {
  background: {{ mix background foreground 4% }} !important;
  color: {{ foreground }} !important;
  border: 1px solid {{ mix background foreground 40% }} !important;
  box-shadow: none !important;
}

/* Controls: the shell's normal border, the accent while focused. */
[data-slot="input"],
[data-slot="select-trigger"] {
  border-color: {{ mix background foreground 40% }} !important;
  box-shadow: none !important;
}
[data-slot="input"]:focus-within,
[data-slot="select-trigger"]:focus-visible {
  border-color: {{ accent }} !important;
}

[data-slot="composer-host"] {
  background: {{ background }} !important;
  border: 1px solid {{ mix background foreground 40% }} !important;
  box-shadow: none !important;
}
[data-slot="composer-host"]:focus-within {
  border-color: {{ accent }} !important;
  box-shadow: inset 0 0 0 1px {{ accent }} !important;
}

/* Segmented groups: separate framed buttons, as the shell's button group. */
[data-slot="toggle-group"][data-variant="segmented"] {
  background: transparent !important;
  border: 0 !important;
  box-shadow: none !important;
  padding: 0 !important;
  gap: 6px !important;
}
[data-slot="toggle-group"][data-variant="segmented"] [data-slot="separator"] {
  display: none !important;
}
[data-slot="toggle-group"][data-variant="segmented"] [data-slot="toggle"] {
  background: {{ mix background foreground 4% }} !important;
  color: {{ foreground }} !important;
  border: 1px solid {{ mix background foreground 40% }} !important;
  border-radius: var(--omarchy-radius) !important;
  box-shadow: none !important;
}
[data-slot="toggle-group"][data-variant="segmented"] [data-slot="toggle"]::before {
  box-shadow: none !important;
}
[data-slot="toggle-group"][data-variant="segmented"] [data-slot="toggle"]:hover:not([data-pressed]) {
  background: {{ mix background foreground 8% }} !important;
  border-color: {{ mix background foreground 25% }} !important;
}
[data-slot="toggle-group"][data-variant="segmented"] [data-slot="toggle"][data-pressed] {
  background: {{ mix background foreground 18% }} !important;
  border-color: {{ mix background foreground 18% }} !important;
  font-weight: 700;
}

[data-user-message-bubble] {
  border: 1px solid {{ mix background foreground 25% }} !important;
}
.chat-markdown-codeblock,
[data-thread-details-card] {
  border: 1px solid {{ mix background foreground 12% }} !important;
  box-shadow: none !important;
}

::-webkit-scrollbar { width: 8px; height: 8px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: {{ muted }}; border-radius: var(--omarchy-radius); }
::-webkit-scrollbar-thumb:hover { background: {{ dark_foreground }}; }
[data-slot="scroll-area-thumb"] { background: {{ muted }} !important; }

::selection { background: {{ selection }}; color: {{ bright_foreground }}; }
