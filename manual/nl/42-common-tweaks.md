# Veelvoorkomende aanpassingen

Dit is een verzameling veelvoorkomende aanpassingen aan de Omarchy-configuratie. Houd er rekening mee dat het soms nodig kan zijn dat systeemupdates bepaalde configuraties terugzetten naar hun oorspronkelijke staat. Als dit gebeurt, gaan je wijzigingen niet verloren, maar worden ze in een `.bak.<timestamp>`-bestand naast het origineel geplaatst.

Als je iets verknoeit, kun je afzonderlijke configuraties terugzetten naar hun oorspronkelijke configuratie via _Update > Config_ in het Omarchy-menu. Als je het _echt_ helemaal verknoeit, kun je alle configuraties resetten via `omarchy reinstall configs`, of elk standaardpakket en elke standaardconfiguratie opnieuw installeren met `omarchy reinstall`.

### Alle systeemvakpictogrammen altijd weergeven

Standaard zijn systeemvakpictogrammen, zoals Dropbox, 1password of Steam, verborgen achter de uitklappijl van het systeemvak, die ze toont wanneer je er met de muis overheen beweegt. Als je ze altijd zichtbaar wilt hebben, klik je met de rechtermuisknop op de uitklappijl om de beheerder voor systeemvakpictogrammen te openen, en zet je vervolgens de pictogrammen vast die je zichtbaar wilt houden (je kunt ook de pictogrammen verbergen die je nooit wilt zien).

### Afgeronde vensterhoeken

Het standaardontwerp van Omarchy heeft vierkante hoeken, maar als je dat wat wilt verzachten, kies je _Appearance > Windows > Window Corners > Rounded Corners_ in het Omarchy-menu, of voer je `omarchy hyprland corners rounded` uit. Met _Theme Corners_ ga je terug naar wat het thema gebruikt. Om je eigen radius te kiezen, blijf je op _Theme Corners_ (`omarchy hyprland corners theme`), omdat Rounded en Sharp na je configuratie worden geladen en die overschrijven, en haal je het commentaar weg bij rounding in `~/.config/hypr/looknfeel.lua`:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Vensterruimtes verwijderen

Op laptopschermen verspillen sommige mensen liever geen pixels aan ruimtes tussen vensters (of zelfs aan een bovenbalk, die je kunt uitschakelen met `Super + Shift + Space`). Je kunt alle ruimtes en randen uitschakelen met `Super + Shift + Backspace`, of ze permanent verwijderen door het commentaar weg te halen in dit gedeelte van `~/.config/hypr/looknfeel.lua`:

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
