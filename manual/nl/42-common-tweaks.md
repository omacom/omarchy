# Veelvoorkomende aanpassingen

Dit is een verzameling veelvoorkomende aanpassingen aan de Omarchy-setup. Weet dat het af en toe nodig kan zijn dat systeemupdates bepaalde configs terugzetten naar hun oorspronkelijke staat. Als dit gebeurt, gaan je wijzigingen niet verloren, maar worden ze in een `.bak`-bestand in dezelfde map gezet.

Als je iets verknoeit, kun je individuele configs terugzetten naar hun oorspronkelijke setup via _Bijwerken > Config_ in het Omarchy-menu. Als je _echt_ alles verknoeit, kun je alle configs resetten via `omarchy-reinstall`.

### Alle tray-pictogrammen altijd tonen

Standaard zijn tray-pictogrammen, zoals Dropbox, 1password of Steam, verborgen achter de uitklappijl van de tray, die ze toont als je eroverheen zweeft. Als je ze altijd zichtbaar wilt hebben, klik je met de rechtermuisknop op de uitklappijl om de tray-pictogrammenbeheerder te openen, en pin je vervolgens de pictogrammen vast die je zichtbaar wilt houden (je kunt ook degene verbergen die je nooit wilt zien).

### Afgeronde vensterhoeken

Het standaardontwerp van Omarchy is er een van vierkante hoeken, maar als je dat wat wilt verzachten, kun je `~/.config/hypr/looknfeel.lua` zo wijzigen dat rounding niet langer is uitgecommentarieerd:

```
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})
```

### Vensteropeningen verwijderen

Op laptopschermen geven sommige mensen er de voorkeur aan geen pixels te verspillen aan vensteropeningen (of zelfs een bovenste balk, die je kunt uitschakelen met `Super + Shift + Space`). Je kunt alle openingen en randen uitschakelen met `Super + Shift + Backspace`, of ze permanent verwijderen door de commentaren in dit gedeelte van `~/.config/hypr/looknfeel.lua` te verwijderen:

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
