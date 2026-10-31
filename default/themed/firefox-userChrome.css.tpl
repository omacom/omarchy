/* Omarchy theme for Firefox-based browsers: Firefox, Zen, LibreWolf, Floorp
 * and Waterfox. omarchy-theme-set-firefox copies it into each profile as
 * chrome/omarchy.css, which the profile's userChrome.css imports. Browsers read
 * it at startup.
 *
 * The browsers' own colour variables are renamed between engine releases, and
 * forks lag Firefox by several. Both the current Firefox names and the older
 * ones are set here; a browser ignores the names it doesn't use. */

:root {
  color-scheme: {{ mode }} !important;

  /* Firefox */
  --toolbox-background-color: {{ background }} !important;
  --toolbox-background-color-inactive: {{ background }} !important;
  --toolbox-text-color: {{ foreground }} !important;
  --toolbox-text-color-inactive: {{ dark_foreground }} !important;
  --toolbar-background-color: {{ background }} !important;
  --toolbar-text-color: {{ foreground }} !important;
  --toolbar-field-background-color: {{ lighter_background }} !important;
  --toolbar-field-background-color-focus: {{ lighter_background }} !important;
  --toolbar-field-text-color: {{ foreground }} !important;
  --toolbar-field-text-color-focus: {{ bright_foreground }} !important;
  --toolbar-field-border-color: {{ selection }} !important;
  --toolbar-field-border-color-focus: {{ accent }} !important;
  --tab-background-color-selected: {{ mix background accent 18% }} !important;
  --tab-background-color-hover: {{ mix background foreground 10% }} !important;
  --tab-text-color-selected: {{ bright_foreground }} !important;
  --tabpanel-background-color: {{ background }} !important;
  --panel-background-color: {{ dark_background }} !important;
  --panel-border-color: {{ selection }} !important;
  --sidebar-background-color: {{ background }} !important;
  --sidebar-text-color: {{ foreground }} !important;
  --urlbarview-background-color-selected: {{ mix background accent 25% }} !important;
  --urlbarview-background-color-hover: {{ mix background foreground 10% }} !important;
  --urlbarview-text-color-selected: {{ bright_foreground }} !important;
  --focus-outline-color: {{ accent }} !important;

  /* Older names, which Zen and most forks still use */
  --toolbox-textcolor: {{ foreground }} !important;
  --toolbar-bgcolor: {{ background }} !important;
  --toolbar-color: {{ foreground }} !important;
  --toolbar-field-color: {{ foreground }} !important;
  --toolbar-field-focus-background-color: {{ lighter_background }} !important;
  --toolbar-field-focus-color: {{ bright_foreground }} !important;
  --toolbar-field-focus-border-color: {{ accent }} !important;
  --tab-selected-bgcolor: {{ mix background accent 18% }} !important;
  --tab-selected-textcolor: {{ bright_foreground }} !important;
  --tab-hover-background-color: {{ mix background foreground 10% }} !important;
  --arrowpanel-background: {{ dark_background }} !important;
  --arrowpanel-color: {{ foreground }} !important;
  --arrowpanel-border-color: {{ selection }} !important;

  /* Zen */
  --zen-primary-color: {{ accent }} !important;
  --zen-colors-primary: {{ lighter_background }} !important;
  --zen-colors-secondary: {{ selection }} !important;
  --zen-colors-tertiary: {{ dark_background }} !important;
  --zen-colors-hover-bg: {{ mix background foreground 10% }} !important;
  --zen-colors-primary-foreground: {{ foreground }} !important;
  --zen-colors-border: {{ selection }} !important;
  --zen-colors-border-contrast: {{ muted }} !important;
  --zen-colors-input-bg: {{ lighter_background }} !important;
  --zen-dialog-background: {{ dark_background }} !important;
  --zen-urlbar-background: {{ lighter_background }} !important;
  --zen-main-browser-background: {{ background }} !important;
  --zen-main-browser-background-toolbar: {{ background }} !important;
  --zen-themed-toolbar-bg: {{ background }} !important;
  --zen-themed-toolbar-bg-transparent: {{ background }} !important;
}

/* Zen's workspace gradient sets its background variables on these elements
 * rather than on :root, and paints the window through the pseudo-elements. */
#browser,
#navigator-toolbox,
.zen-browser-generic-background {
  --zen-main-browser-background: {{ background }} !important;
  --zen-main-browser-background-old: {{ background }} !important;
  --zen-main-browser-background-toolbar: {{ background }} !important;
  --zen-main-browser-background-toolbar-old: {{ background }} !important;
}

.zen-browser-generic-background::before,
.zen-browser-generic-background::after {
  background: {{ background }} !important;
}

/* The page area of an empty tab, and the floating address bar */
.browserSidebarContainer {
  --zen-transparent-browser-background: {{ lighter_background }} !important;
}

#urlbar .urlbar-background {
  --zen-urlbar-background-base: {{ dark_background }} !important;
  --zen-urlbar-background-transparent: {{ dark_background }} !important;
}

::selection {
  background-color: {{ selection_background }} !important;
  color: {{ selection_foreground }} !important;
}
