# Almindelige tilpasninger

Dette er en samling af almindelige tilpasninger af Omarchy-opsætningen. Vær opmærksom på, at det af og til kan være nødvendigt for systemopdateringer at gendanne visse konfigurationer til deres oprindelige tilstand. Hvis det sker, går dine ændringer ikke tabt, men lægges i en `.bak.<timestamp>`-fil ved siden af originalen.

Hvis du kludrer i det, kan du gendanne individuelle konfigurationer til deres oprindelige opsætning via _Update > Config_ i Omarchy-menuen. Hvis du _virkelig_ kludrer i alt, kan du nulstille alle konfigurationer via `omarchy reinstall configs` eller geninstallere hver standardpakke og -konfiguration med `omarchy reinstall`.

### Vis alle bakkeikoner hele tiden

Som standard er bakkeikoner som Dropbox, 1password eller Steam skjult bag pilen til udvidelse af bakken, som viser dem, når du holder musen over den. Hvis du gerne vil have dem fremme hele tiden, skal du højreklikke på udvidelsespilen for at åbne administrationsværktøjet til bakkeikoner og derefter fastgøre de ikoner, du vil holde synlige (du kan også skjule dem, du aldrig vil se).

### Afrundede vindueshjørner

Omarchys standarddesign har firkantede hjørner, men hvis du gerne vil bløde det lidt op, kan du vælge _Appearance > Windows > Window Corners > Rounded Corners_ i Omarchy-menuen eller køre `omarchy hyprland corners rounded`. _Theme Corners_ går tilbage til det, temaet bruger. Hvis du vil vælge din egen radius, skal du blive på _Theme Corners_ (`omarchy hyprland corners theme`), da Rounded og Sharp indlæses efter din konfiguration og tilsidesætter den, og fjerne kommenteringen af rounding i `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Fjern mellemrum mellem vinduer

På bærbare skærme foretrækker nogle ikke at spilde nogen pixels på mellemrum mellem vinduer (eller endda en øverste bjælke, som du kan slå fra med `Super + Shift + Space`). Du kan slå alle mellemrum og kanter til og fra med `Super + Shift + Backspace` eller fjerne dem permanent ved at fjerne kommentarerne i dette afsnit af `~/.config/hypr/looknfeel.lua`:

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
