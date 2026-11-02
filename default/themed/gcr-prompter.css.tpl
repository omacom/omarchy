/* GNOME Keyring's password prompt (gcr-prompter), sized from the polkit dialog's Style.qml tokens.
   The rules override everything Adwaita draws here, so its dark variant serves light themes too.
   GTK3 CSS cannot remove widgets, so selectors follow gcr's grid order (gcr-prompt-dialog.c):
   image, title, description, "Password:", entry, "Confirm:", entry, strength bar, warning, checkbox.
   Sibling selectors skip hidden widgets; :backdrop is the unfocused state Adwaita also styles. */
@import url("resource:///org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css");

@define-color prompter_bg {{ background }};
@define-color prompter_fg {{ foreground }};
@define-color prompter_accent {{ accent }};
@define-color prompter_error {{ red }};

* {
  font-family: monospace;
  -GtkDialog-content-area-border: 0;
  -GtkDialog-action-area-border: 0;
  -GtkButtonBox-child-min-width: 0;
  -GtkButtonBox-child-internal-pad-x: 0;
}

.background,
.background:backdrop {
  background-color: @prompter_bg;
  color: @prompter_fg;
}

/* With the grid's own 6px border this makes the 18px panel padding. */
.dialog-vbox {
  padding: 0 12px;
}

image {
  color: @prompter_accent;
  -gtk-icon-transform: translate(-4px, -6px) scale(0.4);
  margin-right: -12px;
}

/* Five or more visible children means a password row; the transform moves the icon without growing rows. */
image:nth-last-child(n+5) {
  -gtk-icon-transform: translate(-4px, 32px) scale(0.4);
}

/* "Password:" and "Confirm:" stand in for polkit's placeholder. */
grid > label {
  font-size: 18px;
  color: alpha(@prompter_fg, 0.36);
}

/* The title repeats the description ("Authentication required"). */
grid > image + label {
  font-size: 1px;
  color: transparent;
  margin: -8px 0 -3px;
}

grid > image + label + label {
  margin-top: -6px;
  font-size: 11px;
  color: @prompter_fg;
}

/* "The unlock password was incorrect", "Passwords do not match." */
grid > entry + label:last-child,
grid > progressbar + label {
  font-size: 11px;
  color: @prompter_error;
}

entry,
entry:focus,
entry:backdrop {
  min-height: 42px;
  -GtkEntry-invisible-char: 8226; /* U+2022, the bullet polkit masks with */
  padding: 0;
  font-size: 18px;
  background: none;
  color: @prompter_fg;
  border: none;
  box-shadow: none;
}

progressbar trough {
  min-height: 2px;
  background-color: alpha(@prompter_fg, 0.15);
  border: none;
}

progressbar progress {
  min-height: 2px;
  background-color: @prompter_accent;
  border: none;
}

/* The negative margin offsets GtkDialog's button-box spacing, which CSS cannot set. */
.dialog-action-area {
  margin-right: -12px;
  padding: 0 0 8px;
}

button,
button:hover,
button:backdrop {
  min-height: 0;
  padding: 2px 8px;
  font-size: 11px;
  background: none;
  color: alpha(@prompter_fg, 0.5);
  border: none;
  box-shadow: none;
  text-shadow: none;
  -gtk-icon-shadow: none;
  outline-color: alpha(@prompter_accent, 0.6);
  -gtk-outline-radius: 0;
}

button:hover {
  color: @prompter_fg;
}

button.default {
  color: @prompter_accent;
}
