/* Omarchy Theme for Zen Browser */

:root {
  --omarchy-bg: {{ background }};
  --omarchy-fg: {{ foreground }};
  --omarchy-accent: {{ accent }};
  --omarchy-surface: {{ color0 }};
  --omarchy-surface-bright: {{ color8 }};

  --zen-accent-color: var(--omarchy-accent) !important;
  --zen-border-color: var(--omarchy-surface) !important;
  --zen-themed-toolbar-color: var(--omarchy-bg) !important;
  --zen-colors-primary: var(--omarchy-accent) !important;
  --zen-colors-secondary: var(--omarchy-surface) !important;
  --zen-colors-tertiary: var(--omarchy-bg) !important;
  --zen-dialog-background: var(--omarchy-bg) !important;
  --zen-primary-color: var(--omarchy-accent) !important;

  --urlbarview-background-color-selected: var(--omarchy-surface) !important;
  --urlbarview-text-color-selected: var(--omarchy-fg) !important;
}

#TabsToolbar,
#vertical-tabs,
#tabbrowser-tabs,
#zen-sidebar-container,
#zen-appcontent-navbar-container,
#zen-main-app-wrapper,
#zen-sidebar-top-buttons,
#zen-sidebar-foot-buttons,
.zen-sidebar-panel-wrapper {
  background-color: var(--omarchy-bg) !important;
  color: var(--omarchy-fg) !important;
}

#vertical-tabs .toolbarbutton-1,
#zen-sidebar-top-buttons .toolbarbutton-1,
#zen-sidebar-foot-buttons .toolbarbutton-1,
#tabbrowser-tabs .tabbrowser-tab {
  color: var(--omarchy-fg) !important;
}

.tabbrowser-tab:not([pinned]):not([zen-essential="true"]) .tab-background {
  background-color: transparent !important;
}

.tabbrowser-tab[selected] .tab-background,
.tabbrowser-tab[visuallyselected] .tab-background,
#tabbrowser-tabs .tabbrowser-tab[selected] {
  background-color: var(--omarchy-surface) !important;
  border-radius: 8px !important;
}

.tabbrowser-tab .tab-label {
  color: var(--omarchy-fg) !important;
  opacity: 0.6;
}

.tabbrowser-tab[selected] .tab-label,
.tabbrowser-tab[visuallyselected] .tab-label {
  color: var(--omarchy-fg) !important;
  opacity: 1;
}

#nav-bar,
#PersonalToolbar {
  background-color: var(--omarchy-bg) !important;
  border: none !important;
}

#urlbar-background {
  background-color: var(--omarchy-surface) !important;
  border: 1px solid var(--omarchy-surface-bright) !important;
  border-radius: 8px !important;
}

#urlbar:focus-within #urlbar-background {
  border-color: var(--omarchy-accent) !important;
}

#urlbar .urlbar-input {
  color: var(--omarchy-fg) !important;
}

browser,
#tabbrowser-tabpanels,
.browserStack {
  background-color: var(--omarchy-bg) !important;
}

#zen-sidebar-splitter,
#appcontent-splitter,
.zen-sidebar-splitter {
  background-color: var(--omarchy-surface) !important;
  border: none !important;
  min-width: 1px !important;
  width: 1px !important;
}

#main-window {
  border: 1px solid var(--omarchy-surface) !important;
  outline: none !important;
}

#zen-appcontent-navbar-wrapper,
#titlebar {
  background-color: var(--omarchy-bg) !important;
  border: none !important;
  outline: none !important;
  box-shadow: none !important;
}
