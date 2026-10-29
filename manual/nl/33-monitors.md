# Monitoren

Omarchy gaat er standaard van uit dat je draait op een 2x-capabel beeldscherm van retina-klasse. Dit heb je nodig om die mooie, scherpe programmeerfonts te krijgen. Hier zijn bijna alle nieuwe premium laptops met hogeresolutieschermen voor geoptimaliseerd. Dit wil je draaien op een 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) of 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Maar als je geen beeldscherm met een PPI van 218 of hoger draait, wil je de monitorinstellingen wijzigen. Als je bijvoorbeeld een 27" of 32" 4K hebt, kun je fractionele schaling gebruiken door `~/.config/hypr/monitors.lua` te openen (via _Setup > Monitors_ in het Omarchy-menu) en over te schakelen naar de aanbeveling voor die combinatie:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Als je een 1080p- of 1440p-beeldscherm gebruikt, wil je waarschijnlijk gewoon 1x-schaling gebruiken, dus dan kun je dit gebruiken:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Wijzigingen in `GDK_SCALE` gelden voor applicaties die na de wijziging worden gestart (en GTK accepteert alleen hele getallen, dus houd het op het dichtstbijzijnde gehele getal van je monitorschaal). Zorg er dus voor dat je de vensters sluit die na de wijziging te groot zijn (of sluit alle vensters met `Ctrl + Alt + Del`!).

Je kunt ook snel door de belangrijkste monitorschaalverhoudingen stappen (1x, 1.25x, 1.6x, 2x, 3x, 4x) met `Super + /` om hoger te gaan en `Super + Alt + /` om lager te gaan, of er een kiezen uit het monitorpaneel in de bovenbalk. Deze wijzigen alleen de monitor waarop je gefocust bent, zodat een laptopscherm en een extern beeldscherm elk hun eigen schaal kunnen hebben. De keuze wordt opgeslagen in `~/.config/hypr/monitors.lua` als een `hl.monitor`-regel voor die monitor, dus hij blijft behouden na opnieuw opstarten en heeft voorrang op `omarchy_monitor_scale`, die de schaal blijft voor elke monitor zonder een eigen regel. Omdat `GDK_SCALE` één waarde is voor alle schermen, stellen deze wijzigingen hem in op basis van de monitor met de laagste schaal, zodat X11-apps er op het dichtere scherm een beetje klein uitkomen in plaats van te groot op het andere.

### Tekst groter of kleiner maken

Monitorschaling verandert de grootte van alles. Als je alleen grotere of kleinere _tekst_ wilt, is daar één enkele knop voor:

```
omarchy display text size 14
```

Dat neemt een pixelgrootte tussen 9 en 20, en beweegt de Omarchy-shell, GTK-applicaties en je terminal samen, zodat het hele bureaublad in verhouding blijft. Voer het uit zonder een argument om te zien waar je zit, en `omarchy display text size reset` om terug te gaan naar de standaardwaarde. Foot is de enige achterblijver: het heeft geen manier om zijn config opnieuw te laden, dus draaiende terminals houden hun oude grootte totdat je een nieuwe opent.

### Laptopbeeldschermen uitbreiden en spiegelen

Wanneer je een extern scherm op je laptop aansluit, wordt het beeldscherm automatisch uitgebreid. Maar je kunt dat met _Trigger > Hardware_ in het Omarchy-menu of `Super + Ctrl + Alt + Delete` veranderen in spiegelen. Dit is vooral handig als dat externe scherm een projector is en je iets wilt laten zien terwijl je werkt.

Wanneer je uitbreidt, zal het sluiten van de klep van de laptop het interne scherm automatisch uitschakelen. Het openen van de klep schakelt het weer in. Je kunt dit ook handmatig regelen met _Trigger > Hardware_ in het Omarchy-menu of `Super + Ctrl + Delete`.

### Meerdere schermen rangschikken

Hyprland werkt uitstekend met meerdere schermen. Lees meer over hoe je ze indeelt in [de Hyprland-monitordocumentatie](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy gaan deze in `~/.config/hypr/monitors.lua` als `hl.monitor`-items — het bestand wordt geleverd met voorbeelden in commentaar om een specifieke monitor vast te zetten op een resolutie, positie en rotatie.

Elke monitor heeft zijn eigen werkruimten 1 tot en met 10, dus `Super + 1` betekent altijd de eerste werkruimte van de monitor waar je op zit. Achter de schermen nummert Hyprland werkruimten nog steeds over alle monitoren heen: je laptopscherm (of eerste monitor) krijgt 1–10, de volgende monitor 11–20, enzovoort, en elke monitor behoudt zijn blok elke keer dat je hem aansluit. Gebruik die nummers als je [werkruimtregels](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) of vensterregels voor een specifieke monitor schrijft, zodat werkruimte 12 de tweede werkruimte van je tweede monitor is. `~/.local/state/omarchy/monitor-workspaces` vermeldt welk blok elke monitor heeft.

De pijltjestoetsen werken tussen monitoren die een rand delen in je indeling. Schermen die elkaar alleen in een hoek raken, of waar een gat tussen zit, zijn geen buren, dus gebruik `Ctrl + Alt + Tab` om ertussen te komen.

| Sneltoets | Tussen monitoren |
| --- | --- |
| `Super + Arrow` | Verplaatst de focus naar de monitor aan die kant zodra er in die richting geen venster meer over is |
| `Super + Shift + Arrow` | Ruilt met een venster op de monitor aan die kant |
| `Super + Alt + Arrow` | Verplaatst het venster naar een groep op de monitor aan die kant |
| `Super + Shift + Ctrl + Arrow` | Verplaatst het venster naar de monitor aan die kant, naar de werkruimte die hij toont |
| `Super + Shift + Alt + Arrow` | Verplaatst de werkruimte naar de monitor aan die kant, met behoud van zijn nummer als dat vrij is |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Verplaatst de focus naar de volgende of vorige monitor, ongeacht de indeling |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Blijven op de monitor waar je op zit |

Je kunt ook [Hyprmon](https://github.com/erans/hyprmon/) bekijken, als je een TUI wilt om je te helpen bij het positioneren van meerdere schermen.

### Helderheid regelen

De helderheid van de monitor wordt geregeld met de speciale functietoetsen voor helderheid omhoog/omlaag. Als je shift ingedrukt houdt terwijl je deze indrukt, ga je naar maximale of minimale helderheid. De toetsen regelen het beeldscherm waarop je gefocust bent, dus externe monitoren die DDC/CI spreken worden op dezelfde manier aangepast als het laptopscherm.

### Apple-beeldschermen

Als je een Apple-beeldscherm gebruikt, werken de gewone helderheidstoetsen van het toetsenbord ook automatisch, als je gefocust bent op het Apple-beeldscherm. Dit gebeurt via het `asdcontrol`-commando.

Let op: als je een Apple 6K XDR-beeldscherm gebruikt, zie je mogelijk een fantoomscherm in je `hyprctl monitors`-overzicht. Je kunt dit uitschakelen met iets als `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

Op Intel-machines moet je verbinding maken met Apple-beeldschermen met een gewone Thunderbolt-kabel. Op andere machines zonder Thunderbolt moet je doorgaans een [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) gebruiken om het te laten werken.
