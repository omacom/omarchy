# Almindelige justeringer

Dette er en samling af almindelige tilpasninger til Omarchy-opsætningen. Vid, at det lejlighedsvis kan være nødvendigt for systemopdateringer at gendanne visse konfigurationer til deres oprindelige tilstand. Hvis det sker, går dine ændringer ikke tabt, men lægges i en `.bak`-fil i samme mappe.

Hvis du ødelægger noget, kan du gendanne individuelle konfigurationer til deres oprindelige opsætning via _Opdater > Konfiguration_ i Omarchy-menuen. Hvis du _virkelig_ ødelægger alt, kan du nulstille alle konfigurationer via `omarchy-reinstall`.

### Vis alle bakkeikoner hele tiden

Som standard er bakkeikoner som Dropbox, 1Password eller Steam skjult bag bakkeudvidelsespilen, som afslører dem, når du holder musen over den. Hvis du gerne vil have dem eksponeret hele tiden, skal du højreklikke på udvidelsespilen for at åbne bakkeikonhåndteringen og derefter fastgøre de ikoner, du vil holde synlige (du kan også skjule dem, du aldrig vil se).

### Rundede vindueshjørner

Omarchys standarddesign er firkantede hjørner, men hvis du kan lide at bløde det lidt op, kan du ændre `~/.config/hypr/looknfeel.lua`, så afrunding ikke længere er udkommenteret:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Fjern vinduesmellemrum

På bærbare skærme foretrækker nogle mennesker ikke at spilde nogen pixels på vinduesmellemrum (eller endda en menulinje, som du kan slå fra med `Super + Shift + Space`). Du kan slå alle mellemrum og kanter fra med `Super + Shift + Backspace` eller fjerne dem permanent ved at fjerne kommentarerne i denne sektion af `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    gaps_out = 0,
    border_size = 0,
  },
})
```
