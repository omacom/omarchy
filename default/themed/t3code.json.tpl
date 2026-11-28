{
  "name": "Omarchy",
  "appearance": "{{ mode }}",
  "canvas": "{{ background }}",
  "accent": "{{ accent }}",
  "colors": {
    "chrome": "{{ background }}",
    "toolbar": "{{ background }}",
    "toolbarForeground": "{{ foreground }}",
    "toolbarBorder": "{{ mix background foreground 12% }}",
    "toolbarControl": "{{ background }}",
    "toolbarControlForeground": "{{ foreground }}",
    "toolbarControlHover": "{{ mix background foreground 8% }}",

    "text": "{{ foreground }}",
    "border": "{{ mix background foreground 12% }}",
    "input": "{{ mix background foreground 40% }}",
    "focus": "{{ accent }}",

    "surface": "{{ background }}",
    "surfaceRaised": "{{ mix background foreground 4% }}",
    "surfaceOverlay": "{{ background }}",
    "secondary": "{{ mix background foreground 8% }}",
    "secondaryForeground": "{{ foreground }}",

    "messageSurface": "{{ mix background foreground 8% }}",
    "messageForeground": "{{ foreground }}",
    "messageActionHover": "{{ mix background foreground 18% }}",

    "sidebar": "{{ background }}",
    "sidebarForeground": "{{ foreground }}",
    "sidebarBorder": "{{ mix background foreground 12% }}",
    "sidebarControlSurface": "{{ mix background foreground 4% }}",
    "sidebarRowHover": "{{ mix background foreground 8% }}",
    "sidebarRowActive": "{{ mix background foreground 18% }}",
    "sidebarRowSelected": "{{ mix background foreground 18% }}",

    "error": "{{ mix red foreground 35% }}",
    "warning": "{{ mix yellow foreground 35% }}",

    "codeBackground": "{{ dark_background }}",
    "codeForeground": "{{ foreground }}",

    "terminalBackground": "{{ background }}",
    "terminalForeground": "{{ foreground }}",
    "terminalCursor": "{{ bright_foreground }}",
    "terminalSelection": "{{ selection }}",
    "terminalScrollbar": "{{ muted }}",
    "terminalScrollbarHover": "{{ dark_foreground }}"
  }
}
