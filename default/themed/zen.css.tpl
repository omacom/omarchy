/* Omarchy theme for Zen Browser. Rendered from colors.toml on every theme
   switch; omarchy-theme-set-zen copies it into each Zen profile as
   chrome/omarchy.css, adds the window transparency mode, and imports it from
   userChrome.css. Zen reads it when it starts. */

:root {
  --omarchy-background-rgb: {{ background_rgb }};
  --omarchy-foreground-rgb: {{ foreground_rgb }};
  --omarchy-accent-rgb: {{ accent_rgb }};
  --omarchy-muted-rgb: {{ muted_rgb }};

  /* Window transparency. Solid here; omarchy-theme-set-zen overrides it to
     follow omarchy-hyprland-window-transparency. */
  --omarchy-zen-glass: 1;

  --zen-primary-color: {{ accent }} !important;
  --toolbox-textcolor: {{ foreground }} !important;
  --toolbar-color: {{ foreground }} !important;
  --zen-colors-border: {{ muted }} !important;
  --zen-colors-input-bg: rgba({{ dark_background_rgb }}, 0.6) !important;
  --arrowpanel-background: {{ background }} !important;
  --arrowpanel-color: {{ foreground }} !important;

  /* Controls, as T3 Code's rows: a resting 5% lift like its composer, a light
     lift on hover, and an 18% accent tint when pressed. */
  --zen-toolbar-element-bg: rgba({{ foreground_rgb }}, 0.05) !important;
  --zen-toolbar-element-bg-hover: rgba({{ foreground_rgb }}, 0.11) !important;
  --toolbarbutton-hover-background: rgba({{ foreground_rgb }}, 0.06) !important;
  --toolbarbutton-active-background: rgba({{ accent_rgb }}, 0.18) !important;
}

/* Window background. Zen paints its space gradient on these elements'
   pseudo-elements, set inline per element, so it is replaced here rather than
   on :root. The theme background is the only tint, at the transparency the
   window mode asks for. Web pages are drawn over it and never fade. */
#zen-browser-background {
  background: rgba({{ background_rgb }}, var(--omarchy-zen-glass)) !important;
}

.zen-browser-generic-background::before,
.zen-browser-generic-background::after {
  background: none !important;
}

/* Compact mode: the sidebar that slides out over the page. */
.zen-toolbar-background {
  background: {{ background }} !important;
}

.zen-toolbar-background::before,
.zen-toolbar-background::after {
  outline-color: rgba({{ muted_rgb }}, 0.6) !important;
}

/* The open URL bar, lifted 5% off the background like T3 Code's composer. */
#urlbar[breakout-extend] .urlbar-background {
  background: linear-gradient(rgba({{ foreground_rgb }}, 0.05), rgba({{ foreground_rgb }}, 0.05)),
              {{ background }} !important;
  outline-color: {{ muted }} !important;
}

/* Pages before they paint, in the theme background instead of Zen's gray.
   Empty tabs get the same 5% lift, a second tone beside the sidebar. */
#tabbrowser-tabpanels browser[type="content"]:not([transparent="true"]) {
  background: {{ background }} !important;
}

#tabbrowser-tabpanels .browserSidebarContainer {
  --zen-transparent-browser-background: rgba({{ foreground_rgb }}, 0.05) !important;
}

/* Tabs, as T3 Code's sidebar rows: hover is a light 6% lift, and the selected
   tab is the heavier 18% accent tint T3 Code draws its active row with. Zen
   sets these per tab and per tab background, so they are set on both. */
.tabbrowser-tab,
.tabbrowser-tab .tab-background {
  --tab-hover-background-color: rgba({{ foreground_rgb }}, 0.06) !important;
  --tab-background-color-hover: rgba({{ foreground_rgb }}, 0.06) !important;
  --tab-selected-bgcolor: rgba({{ accent_rgb }}, 0.18) !important;
  --tab-background-color-selected: rgba({{ accent_rgb }}, 0.18) !important;
  --zen-essential-tab-selected-bg: rgba({{ accent_rgb }}, 0.18) !important;
  --zen-essential-tab-selected-bg-hover: rgba({{ accent_rgb }}, 0.18) !important;
}

.tabbrowser-tab:active:not([visuallyselected]) > .tab-stack > .tab-background {
  background: rgba({{ accent_rgb }}, 0.18) !important;
}

/* Zen lights up hovered essentials tiles with the selected color; keep hover
   light so only the selected tile looks heavy. */
.tabbrowser-tab[zen-essential="true"]:hover:not([visuallyselected]) .tab-background {
  background: linear-gradient(rgba({{ foreground_rgb }}, 0.06), rgba({{ foreground_rgb }}, 0.06)),
              var(--zen-toolbar-element-bg) !important;
}

/* Flat, like the rest of Omarchy: no shadows around the page, under the open
   URL bar, or behind the compact sidebar. */
#tabbrowser-tabpanels .browserSidebarContainer,
#urlbar[breakout-extend] .urlbar-background,
.zen-toolbar-background {
  box-shadow: none !important;
}
