# Monitoren

Omarchy gaat er standaard van uit dat je draait op een 2x-capable retina-klasse scherm. Dit is wat je nodig hebt om die mooie, scherpe programmeurlettertypen te krijgen. Het is waar bijna alle nieuwe premium laptops met schermen met hoge resolutie voor geoptimaliseerd zijn. Het is wat je zou willen draaien op een 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) of 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Maar als je geen scherm draait met een PPI van 218 of hoger, wil je de monitorinstellingen wijzigen. Bijvoorbeeld, als je een 27" of 32" 4K hebt, kun je fractionele schaling gebruiken door `~/.config/hypr/monitors.lua` te openen (via _Instellen > Monitoren_ in het Omarchy-menu) en over te schakelen naar de aanbeveling voor die combinatie:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Als je een 1080p- of 1440p-scherm gebruikt, wil je waarschijnlijk gewoon 1x-schaling gebruiken, dus je kunt dit gebruiken:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Wijzigingen aan `GDK_SCALE` zijn van toepassing op applicaties die na de wijziging zijn gestart (en GTK respecteert alleen hele getallen, dus houd het op het dichtstbijzijnde gehele getal van je monitorschaling). Zorg er dus voor dat je de vensters sluit die na de wijziging te groot zijn (of sluit alle vensters met `Ctrl + Alt + Del`!).

Je kunt ook snel door de belangrijkste monitorschalingsverhoudingen stappen (1x, 1.25x, 1.6x, 2x, 3x, 4x) met `Super + /` om hoger te gaan en `Super + Alt + /` om lager te gaan. Als je de standaardconfiguratie hebt, blijven deze wijzigingen ook na herstart behouden.

### Tekst groter of kleiner maken

Monitorschaling verandert de grootte van alles. Als je alleen grotere of kleinere _tekst_ wilt, is er één knop daarvoor:

```
omarchy display text size 14
```

Dat neemt een pixelgrootte tussen 9 en 20, en beweegt de Omarchy-shell, GTK-applicaties en je terminal samen, zodat het hele bureaublad in verhouding blijft. Voer het uit zonder argument om te zien waar je bent, en `omarchy display text size reset` om terug te gaan naar de standaard. Foot is de enige achterblijver: het heeft geen manier om zijn configuratie opnieuw te laden, dus draaiende terminals behouden hun oude grootte totdat je een nieuwe opent.

### Laptopschermen uitbreiden en spiegelen

Wanneer je een extern scherm op je laptop aansluit, wordt het scherm automatisch uitgebreid. Maar je kunt dat veranderen in spiegelen via _Activeren > Hardware_ in het Omarchy-menu of `Super + Ctrl + Alt + Delete`. Dit is vooral handig als dat externe scherm een projector is, en je iets wilt laten zien terwijl je werkt.

Wanneer je uitbreidt, schakelt het sluiten van het deksel van de laptop automatisch het interne scherm uit. Het openen van het deksel schakelt het weer in. Je kunt dit ook handmatig beheren via _Activeren > Hardware_ in het Omarchy-menu of `Super + Ctrl + Delete`.

### Meerdere schermen rangschikken

Hyprland werkt geweldig met meerdere schermen. Lees meer over hoe je ze indeelt in [de Hyprland-monitordocumentatie](https://wiki.hypr.land/Configuring/Basics/Monitors/). Je kunt ook [specifieke workspaces aan specifieke monitoren binden](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/). In Omarchy gaan deze regels in `~/.config/hypr/monitors.lua` als `hl.monitor`-items — het bestand wordt geleverd met becommentarieerde voorbeelden voor het vastzetten van een specifieke monitor aan een resolutie, positie en rotatie.

Je kunt ook [Hyprmon](https://github.com/erans/hyprmon/) bekijken, als je een TUI wilt om je te helpen met de positionering van meerdere schermen.

### Helderheid beheren

De monitorhelderheid wordt beheerd door de speciale functietoetsen voor helderheid omhoog/omlaag. Als je Shift ingedrukt houdt terwijl je hierop drukt, ga je naar maximale of minimale helderheid. De toetsen beheren het scherm waarop je gefocust bent, dus externe monitoren die DDC/CI spreken worden op dezelfde manier aangepast als het laptopscherm.

### Apple-schermen

Als je een Apple-scherm gebruikt, werken de gewone toetsenbord-helderheidstoetsen ook automatisch, als je gefocust bent op het Apple-scherm. Dit gebeurt via het `asdcontrol`-commando.

Let op dat als je een Apple 6K XDR-scherm gebruikt, je een fantoomscherm kunt zien in je `hyprctl monitors`-listing. Je kunt dit uitschakelen met iets als `hl.monitor({ output = "DP-2", disabled = true })` via _Instellen > Monitoren_.

Op Intel-machines moet je verbinding maken met Apple-schermen met een gewone Thunderbolt-kabel. Op andere machines zonder Thunderbolt moet je doorgaans een [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) gebruiken om het te laten werken.
