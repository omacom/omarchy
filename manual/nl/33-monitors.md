# Monitoren

Omarchy gaat er standaard van uit dat je een retina-achtig scherm gebruikt dat 2x-scaling aankan. Dat heb je nodig om die mooie, scherpe programmeerfonts te krijgen. Bijna alle nieuwe premium laptops met hogeresolutieschermen zijn hiervoor geoptimaliseerd. Dit is wat je wilt gebruiken op een 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) of 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Maar als je geen scherm gebruikt met een PPI van 218 of hoger, wil je de monitorinstellingen aanpassen. Als je bijvoorbeeld een 27" of 32" 4K-scherm hebt, kun je fractionele schaling gebruiken door `~/.config/hypr/monitors.lua` te openen (via _Setup > Monitors_ in het Omarchy-menu) en over te schakelen naar de aanbeveling voor die combinatie:

```lua
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6
```

Als je een 1080p- of 1440p-scherm gebruikt, wil je waarschijnlijk gewoon 1x-scaling gebruiken, dus dan kun je dit gebruiken:

```lua
local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
```

Wijzigingen in `GDK_SCALE` zijn van toepassing op applicaties die na de wijziging worden gestart (en GTK accepteert alleen hele getallen, dus houd het op het dichtstbijzijnde gehele getal van je monitorschaal). Zorg er dus voor dat je de vensters die je hebt en die na de wijziging te groot zijn, sluit (of sluit alle vensters met `Ctrl + Alt + Del`!).

Je kunt ook snel door de belangrijkste verhoudingen voor monitorschaling stappen (1x, 1.25x, 1.6x, 2x, 3x, 4x) met `Super + /` om hoger te gaan en `Super + Alt + /` om lager te gaan. Als je de standaardconfiguratie hebt, blijven deze wijzigingen ook na een herstart behouden.

### Tekst groter of kleiner maken

Monitorschaling verandert de grootte van alles. Als je alleen grotere of kleinere _tekst_ wilt, is daar één enkele knop voor:

```
omarchy display text size 14
```

Dat neemt een pixelgrootte tussen 9 en 20, en laat de Omarchy-shell, GTK-applicaties en je terminal samen meebewegen, zodat het hele bureaublad in verhouding blijft. Voer het uit zonder argument om te zien waar je nu zit, en `omarchy display text size reset` om terug te gaan naar de standaardinstelling. Foot is de enige achterblijver: het heeft geen manier om zijn configuratie opnieuw te laden, dus actieve terminals behouden hun oude grootte totdat je een nieuwe opent.

### Laptopschermen uitbreiden en spiegelen

Wanneer je een extern scherm op je laptop aansluit, wordt het scherm automatisch uitgebreid. Maar je kunt dat in plaats daarvan veranderen naar spiegelen via _Trigger > Hardware_ in het Omarchy-menu of `Super + Ctrl + Alt + Delete`. Dit is vooral handig als dat externe scherm een projector is, en je iets wilt laten zien terwijl je werkt.

Wanneer je uitbreidt, schakelt het sluiten van het laptopdeksel automatisch het interne scherm uit. Het openen van het deksel schakelt het weer in. Je kunt dit ook handmatig regelen via _Trigger > Hardware_ in het Omarchy-menu of `Super + Ctrl + Delete`.

### Meerdere schermen rangschikken

Hyprland werkt uitstekend met meerdere schermen. Lees meer over hoe je ze indeelt in [de Hyprland-monitordocumentatie](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy gaan deze in `~/.config/hypr/monitors.lua` als `hl.monitor`-items — het bestand wordt geleverd met voorbeelden in commentaar voor het vastpinnen van een specifieke monitor op een resolutie, positie en rotatie.

Elke monitor heeft zijn eigen werkruimtes 1 tot en met 10, dus `Super + 1` betekent altijd de eerste werkruimte van de monitor waar je op zit. Achter de schermen nummert Hyprland werkruimtes nog steeds over alle monitoren heen: je laptopscherm (of eerste monitor) krijgt 1–10, de volgende monitor 11–20, enzovoort, en elke monitor behoudt zijn blok elke keer dat je hem aansluit. Gebruik die nummers als je [werkruimteregels](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) of vensterregels voor een specifieke monitor schrijft, dus werkruimte 12 is de tweede werkruimte van je tweede monitor. `~/.local/state/omarchy/monitor-workspaces` vermeldt welk blok elke monitor heeft.

De pijltjestoetsen werken over monitoren heen die een rand delen in je indeling. Schermen die elkaar alleen in een hoek raken, of waartussen een opening zit, zijn geen buren, dus gebruik `Ctrl + Alt + Tab` om ertussen te komen.

| Sneltoets | Tussen monitoren |
| --- | --- |
| `Super + Arrow` | Verplaatst de focus naar de monitor aan die kant zodra er in die richting geen venster meer over is |
| `Super + Shift + Arrow` | Wisselt met een venster op de monitor aan die kant |
| `Super + Alt + Arrow` | Verplaatst het venster naar een groep op de monitor aan die kant |
| `Super + Shift + Ctrl + Arrow` | Verplaatst het venster naar de monitor aan die kant, naar de werkruimte die daar wordt weergegeven |
| `Super + Shift + Alt + Arrow` | Verplaatst de werkruimte naar de monitor aan die kant, met behoud van het nummer als dat vrij is |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Verplaatst de focus naar de volgende of vorige monitor, ongeacht de indeling |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Blijven op de monitor waar je op zit |

Je kunt ook [Hyprmon](https://github.com/erans/hyprmon/) bekijken, als je graag een TUI wilt die je helpt bij het positioneren van meerdere schermen.

### Helderheid regelen

De helderheid van de monitor wordt geregeld met de speciale functietoetsen voor helderheid omhoog/omlaag. Als je shift ingedrukt houdt terwijl je deze indrukt, ga je naar maximale of minimale helderheid. De toetsen regelen het scherm waarop je gefocust bent, dus externe monitoren die DDC/CI spreken worden op dezelfde manier aangepast als het laptopscherm.

### Apple-schermen

Als je een Apple-scherm gebruikt, werken de gewone helderheidstoetsen van het toetsenbord ook automatisch, als je gefocust bent op het Apple-scherm. Dit gebeurt via het `asdcontrol`-commando.

Let op: als je een Apple 6K XDR-scherm gebruikt, zie je mogelijk een fantoomscherm in je `hyprctl monitors`-overzicht. Je kunt dit uitschakelen met iets als `hl.monitor({ output = "DP-2", disabled = true })` via _Setup > Monitors_.

Op Intel-machines moet je Apple-schermen aansluiten met een gewone Thunderbolt-kabel. Op andere machines zonder Thunderbolt moet je doorgaans een [DP + USB-A -> USB-C cable](https://www.amazon.com/dp/B0BNX7MS6N) gebruiken om het werkend te krijgen.
