# Monitoren

Omarchy gaat er standaard van uit dat je een 2x-capabel scherm van retina-klasse gebruikt. Dat heb je nodig om die mooie, scherpe programmeerfonts te krijgen. Het is waar bijna alle nieuwe premium laptops met schermen met hoge resolutie voor geoptimaliseerd zijn. Het is wat je wilt gebruiken op een 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) of 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Maar als je geen scherm gebruikt met een PPI van 218 of hoger, wil je de monitorinstellingen veranderen. Als je bijvoorbeeld een 27" of 32" 4K hebt, kun je er een fractionele schaal voor kiezen in het monitorpaneel in de bovenbalk, of de standaard instellen voor elke monitor door `~/.config/hypr/monitors.lua` te openen en over te schakelen naar de aanbeveling voor die combinatie:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Als je een 1080p- of 1440p-scherm gebruikt, wil je waarschijnlijk gewoon 1x-schaling gebruiken, en hetzelfde voor GTK- en X11-apps, dus je kunt gebruiken:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Wijzigingen in `GDK_SCALE` gelden voor applicaties die na de wijziging worden gestart (en GTK accepteert alleen hele getallen, dus houd het op het dichtstbijzijnde gehele getal van je monitorschaal). Zorg er dus voor dat je de vensters sluit die je open hebt en die na de wijziging te groot zijn (of sluit alle vensters met `Ctrl + Alt + Del`!).

Je kunt ook snel door de belangrijkste monitorschaalverhoudingen stappen (1x, 1.25x, 1.6x, 2x, 3x, 4x) met `Super + /` om hoger te gaan en `Super + Alt + /` om lager te gaan, of er een kiezen in het monitorpaneel in de bovenbalk. Deze veranderen alleen de monitor waarop je gefocust bent, zodat een laptopscherm en een extern scherm elk hun eigen schaal kunnen hebben. Het paneel stelt ook de resolutie van elke monitor in. Je keuzes worden voor die fysieke monitor opgeslagen in `~/.local/state/omarchy/monitors/settings`, zodat ze een herstart overleven en de monitor volgen naar welke poort of dock hij de volgende keer ook wordt aangesloten. Ze hebben voorrang op elke regel voor dezelfde monitor in `~/.config/hypr/monitors.lua`, die Omarchy nooit bewerkt. Omdat `GDK_SCALE` één waarde is voor alle schermen, wordt een gekozen schaal ingesteld op basis van de monitor met de laagste schaal, zodat X11-apps op het dichtere scherm een beetje klein uitvallen in plaats van te groot op het andere.

### Tekst groter of kleiner maken

Monitorschaling verandert de grootte van alles. Als je alleen grotere of kleinere _tekst_ wilt, is daar één knop voor:

```
omarchy display text size 14
```

Die neemt een pixelgrootte tussen 9 en 20, en beweegt de Omarchy-shell, GTK-applicaties en je terminal samen, zodat het hele bureaublad in verhouding blijft. Voer het uit zonder argument om te zien waar je zit, en `omarchy display text size reset` om terug te gaan naar de standaard. Foot is de enige achterblijver: het heeft geen manier om zijn configuratie opnieuw te laden, dus draaiende terminals houden hun oude grootte totdat je een nieuwe opent.

### Laptopschermen uitbreiden en spiegelen

Wanneer je een extern scherm op je laptop aansluit, wordt het scherm automatisch uitgebreid. Maar je kunt dat veranderen naar spiegelen via _Trigger > Hardware_ in het Omarchy-menu of `Super + Ctrl + Alt + Delete`. Dit is vooral handig als dat externe scherm een projector is, en je iets wilt laten zien terwijl je werkt.

Wanneer je uitbreidt, schakelt het sluiten van het laptopdeksel automatisch het interne scherm uit. Het openen van het deksel schakelt het weer in. Je kunt dit ook handmatig regelen via _Trigger > Hardware_ in het Omarchy-menu of `Super + Ctrl + Delete`.

### Meerdere schermen rangschikken

Hyprland werkt uitstekend met meerdere schermen. Het monitorpaneel in de bovenbalk tekent ze waar ze staan: sleep er een tegen de zijkant van een andere om hem daarheen te verplaatsen, en de rangschikking wordt opgeslagen met de andere instellingen van elke monitor. Voor alles wat het paneel niet dekt, lees je meer over hoe je ze indeelt in [de documentatie over monitoren van Hyprland](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy komen deze in `~/.config/hypr/monitors.lua` als `hl.monitor`-vermeldingen — het bestand wordt geleverd met voorbeelden in commentaar voor het vastpinnen van een specifieke monitor op een resolutie, positie en rotatie.

Elke monitor heeft zijn eigen workspaces 1 tot en met 10, dus `Super + 1` betekent altijd de eerste workspace van de monitor waarop je je bevindt. Achter de schermen nummert Hyprland workspaces nog steeds over alle monitoren heen: je laptopscherm (of eerste monitor) krijgt 1–10, de volgende monitor 11–20, enzovoort, en elke monitor behoudt zijn blok elke keer dat je hem aansluit. Gebruik die nummers als je [workspaceregels](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) of vensterregels voor een specifieke monitor schrijft, zodat workspace 12 de tweede workspace van je tweede monitor is. `~/.local/state/omarchy/monitors/workspaces` vermeldt welk blok elke monitor heeft.

De pijltjestoetsen werken over monitoren die een rand delen in je indeling. Schermen die alleen in een hoek raken, of waar een gat tussen zit, zijn geen buren, dus gebruik `Ctrl + Alt + Tab` om ertussen te komen.

| Sneltoets | Over monitoren heen |
| --- | --- |
| `Super + Arrow` | Verplaatst de focus naar de monitor aan die kant zodra er in die richting geen venster meer is |
| `Super + Shift + Arrow` | Ruilt met een venster op de monitor aan die kant |
| `Super + Alt + Arrow` | Verplaatst het venster naar een groep op de monitor aan die kant |
| `Super + Shift + Ctrl + Arrow` | Verplaatst het venster naar de monitor aan die kant, op de workspace die die toont |
| `Super + Shift + Alt + Arrow` | Verplaatst de workspace naar de monitor aan die kant, met behoud van zijn nummer als dat vrij is |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Verplaatst de focus naar de volgende of vorige monitor, ongeacht de indeling |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Blijven op de monitor waarop je je bevindt |

Bekijk ook [Hyprmon](https://github.com/erans/hyprmon/), als je een TUI wilt om je te helpen met het positioneren van meerdere schermen.

### Helderheid regelen

De helderheid van de monitor wordt geregeld met de speciale functietoetsen voor helderheid omhoog/omlaag. Als je shift ingedrukt houdt terwijl je deze indrukt, ga je naar maximale of minimale helderheid. De toetsen regelen het scherm waarop je gefocust bent, dus externe monitoren die DDC/CI spreken worden op dezelfde manier aangepast als het laptopscherm.

### Apple-schermen

Als je een Apple-scherm gebruikt, werken de gewone helderheidstoetsen op het toetsenbord ook automatisch, als je gefocust bent op het Apple-scherm. Dit gebeurt via het `asdcontrol`-commando.

Merk op dat als je een Apple 6K XDR-scherm gebruikt, je mogelijk een fantoomscherm ziet in je `hyprctl monitors`-overzicht. Je kunt dit uitschakelen met iets als `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua`.

Op Intel-machines moet je Apple-schermen aansluiten met een gewone Thunderbolt-kabel. Op andere machines zonder Thunderbolt moet je doorgaans een [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) gebruiken om het werkend te krijgen.
