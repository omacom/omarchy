# Monitoren

Omarchy gaat er standaard van uit dat je een 2x-capabel scherm van retina-klasse gebruikt. Dat heb je nodig voor die mooie, scherpe programmeursfonts. Daar zijn bijna alle nieuwe premium laptops met hogeresolutieschermen voor geoptimaliseerd. Dat wil je draaien op een 27" 5K [Apple Studio Display](https://www.apple.com/studio-display/)/[ProArt PA27JCV](https://www.asus.com/us/displays-desktops/monitors/proart/proart-display-5k-pa27jcv/)/[Samsung S9](https://www.samsung.com/us/computing/monitors/5k/27-viewfinity-s9-5k-monitor-with-thunderbolt-4-matte-display-and-smart-features-ls27c900panxza/)/[Kuycon G27P](https://kuycon.us/monitors/G27P/) of 32" 6K [Apple XDR](https://www.apple.com/pro-display-xdr/)/[ProArt PA32QCV](https://www.asus.com/displays-desktops/monitors/proart/proart-display-6k-pa32qcv/)/[Kuycon G32P](https://kuycon.us/monitors/G32P/).

Maar als je geen scherm met een PPI van 218 of hoger gebruikt, wil je de monitorinstellingen veranderen. Als je bijvoorbeeld een 27" of 32" 4K hebt, kun je er een fractionele schaal voor kiezen in het monitorpaneel in de bovenbalk, of de standaard voor elke monitor instellen door `~/.config/hypr/monitors.lua` te openen en over te schakelen op de aanbeveling voor die combinatie:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.6 })
```

Als je een 1080p- of 1440p-scherm gebruikt, wil je waarschijnlijk gewoon 1x-schaal gebruiken, en hetzelfde voor GTK- en X11-apps, dus je kunt dit gebruiken:

```lua
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
hl.env("GDK_SCALE", "1")
```

Wijzigingen in `GDK_SCALE` gelden voor applicaties die na de wijziging worden gestart (en GTK accepteert alleen hele getallen, dus houd het op het dichtstbijzijnde gehele getal van je monitorschaal). Zorg er dus voor dat je de vensters die je na de wijziging hebt en die te groot zijn, afsluit (of sluit alle vensters met `Ctrl + Alt + Del`!).

Je kunt ook snel door de belangrijkste monitorschaalverhoudingen (1x, 1.25x, 1.6x, 2x, 3x, 4x) stappen met `Super + /` om hoger te gaan en `Super + Alt + /` om lager te gaan, of er een kiezen in het monitorpaneel in de bovenbalk. Deze veranderen alleen de monitor waarop je gefocust bent, zodat een laptopscherm en een extern scherm elk hun eigen schaal kunnen hebben. Het paneel stelt ook de resolutie, verversingssnelheid en rotatie van elke monitor in. Je keuzes worden voor die fysieke monitor opgeslagen in `~/.local/state/omarchy/monitors/settings`, zodat ze een herstart overleven en de monitor volgen naar welke poort of welk dock hij de volgende keer ook wordt aangesloten. Ze hebben voorrang op elke regel voor dezelfde monitor in `~/.config/hypr/monitors.lua`, die Omarchy nooit bewerkt. Als je je monitoren liever volledig in dat bestand instelt, voeg dan `omarchy_monitor_panel_settings = false` toe aan dat bestand, en de wijzigingen van het paneel blijven dan alleen behouden totdat Hyprland opnieuw laadt. Omdat `GDK_SCALE` één waarde voor alle schermen is, stelt een gekozen schaal hem in op basis van de monitor met de laagste schaal, zodat X11-apps op het dichtere scherm een beetje klein uitvallen in plaats van te groot op het andere.

### Tekst groter of kleiner maken

Monitorschaling verandert de grootte van alles. Als je alleen grotere of kleinere _tekst_ wilt, is daar één enkele knop voor:

```
omarchy display text size 14
```

Dat neemt een pixelgrootte tussen 9 en 20, en laat de Omarchy-shell, GTK-applicaties en je terminal samen meebewegen, zodat het hele bureaublad in verhouding blijft. Voer het zonder argument uit om te zien waar je nu zit, en `omarchy display text size reset` om terug te gaan naar de standaardinstelling. Foot is de enige achterblijver: het heeft geen manier om zijn configuratie opnieuw te laden, dus draaiende terminals behouden hun oude grootte totdat je een nieuwe opent.

### Laptopschermen uitbreiden en spiegelen

Wanneer je een extern scherm op je laptop aansluit, wordt het scherm automatisch uitgebreid. Maar je kunt dat met _Uitbreiden_ | _Spiegelen_ in het monitorpaneel in de bovenbalk, _Trigger > Hardware_ in het Omarchy-menu of `Super + Ctrl + Alt + Delete` veranderen in spiegelen. Dit is vooral handig als dat externe scherm een projector is, en je iets wilt tonen terwijl je werkt.

Wanneer je aan het uitbreiden bent, schakelt het sluiten van de laptopklep automatisch het interne scherm uit. Het openen van de klep schakelt het weer in. Je kunt dit ook handmatig regelen met _Trigger > Hardware_ in het Omarchy-menu of `Super + Ctrl + Delete`.

Zolang de laptop is aangesloten, zet het sluiten van de klep hem nooit in slaapstand, zodat een gedockte laptop wakker blijft, zelfs als het externe scherm kortstondig de verbinding verliest. Met geen extern scherm aangesloten, vergrendelt het sluiten van de klep op stroom hem alleen. Op batterij schorst het sluiten van de klep hem zoals gebruikelijk.

### Meerdere schermen rangschikken

Hyprland werkt geweldig met meerdere schermen. Het monitorpaneel in de bovenbalk tekent ze waar ze staan: sleep er een tegen de zijkant van een andere om hem daarheen te verplaatsen, en de rangschikking wordt samen met de andere instellingen van elke monitor opgeslagen. Voor alles wat het paneel niet dekt, lees je meer over hoe je ze indeelt in [de Hyprland-monitordocumentatie](https://wiki.hypr.land/Configuring/Basics/Monitors/). In Omarchy komen deze in `~/.config/hypr/monitors.lua` als `hl.monitor`-vermeldingen — het bestand wordt geleverd met voorbeelden in commentaar voor het uit laten van een monitor, modi die het paneel niet biedt, 10-bit kleur en variabele verversingssnelheid.

Elke monitor heeft zijn eigen werkruimten 1 tot en met 10, zodat `Super + 1` altijd de eerste werkruimte van de monitor betekent waarop je je bevindt. Achter de schermen nummert Hyprland werkruimten nog steeds over alle monitoren heen: je laptopscherm (of eerste monitor) krijgt 1–10, de volgende monitor 11–20, enzovoort, en elke monitor behoudt zijn blok telkens wanneer je hem aansluit. Gebruik die nummers als je [werkruimteregels](https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/) of vensterregels voor een specifieke monitor schrijft, zodat werkruimte 12 de tweede werkruimte van je tweede monitor is. `~/.local/state/omarchy/monitors/workspaces` geeft aan welk blok elke monitor heeft.

De pijltoetsen werken over monitoren heen die in je indeling een rand delen. Schermen die elkaar alleen op een hoek raken, of waar een gat tussen zit, zijn geen buren, dus gebruik `Ctrl + Alt + Tab` om ertussen te komen.

| Sneltoets | Tussen monitoren |
| --- | --- |
| `Super + Arrow` | Verplaatst de focus naar de monitor aan die kant zodra er in die richting geen venster meer is |
| `Super + Shift + Arrow` | Ruilt met een venster op de monitor aan die kant |
| `Super + Alt + Arrow` | Verplaatst het venster naar een groep op de monitor aan die kant |
| `Super + Shift + Ctrl + Arrow` | Verplaatst het venster naar de monitor aan die kant, op de werkruimte die hij toont |
| `Super + Shift + Alt + Arrow` | Verplaatst de werkruimte naar de monitor aan die kant, met behoud van zijn nummer als dat vrij is |
| `Ctrl + Alt + Tab` / `Ctrl + Alt + Shift + Tab` | Verplaatst de focus naar de volgende of vorige monitor, ongeacht de indeling |
| `Super + 1-0`, `Super + Tab`, `Super + Scroll Wheel` | Blijven op de monitor waarop je je bevindt |

Bekijk ook [Hyprmon](https://github.com/erans/hyprmon/), als je graag een TUI wilt om je te helpen met de positionering van meerdere schermen.

### Helderheid regelen

De helderheid van de monitor wordt geregeld met de speciale functietoetsen voor helderheid omhoog/omlaag. Als je shift ingedrukt houdt terwijl je op deze toetsen drukt, ga je naar de maximale of minimale helderheid. De toetsen regelen het scherm waarop je gefocust bent, zodat externe monitoren die DDC/CI spreken op dezelfde manier worden aangepast als het laptopscherm.

### Apple-schermen

Als je een Apple-scherm gebruikt, werken de gewone helderheidstoetsen van het toetsenbord ook automatisch, als je op het Apple-scherm gefocust bent. Dit gebeurt via de `asdcontrol`-opdracht.

Let op: als je een Apple 6K XDR-scherm gebruikt, zie je mogelijk een spookscherm in je `hyprctl monitors`-overzicht. Je kunt dit uitschakelen met iets als `hl.monitor({ output = "DP-2", disabled = true })` in `~/.config/hypr/monitors.lua`.

Op Intel-machines moet je met een gewone Thunderbolt-kabel verbinding maken met Apple-schermen. Op andere machines zonder Thunderbolt moet je doorgaans een [DP + USB-A -> USB-C-kabel](https://www.amazon.com/dp/B0BNX7MS6N) gebruiken om het werkend te krijgen.
