# Probleemoplossing

### Ik heb mijn systeem kapotgemaakt met een update!

Probeer eerst [je systeem terug te zetten](47-system-snapshots.md) naar de versie van vóór je recente update. Als dat niet werkt, gebruik `omarchy-debug` om je probleem te delen op #omarchy-help in de Discord. En als dat allemaal niet lukt, kun je de standaardconfiguraties en -pakketten opnieuw installeren met `omarchy-reinstall`.

### Waarom zijn sommige apps zo groot op mijn scherm?

Omarchy gaat uit van een 2x scherm met hoge resolutie, dus stelt het `GDK_SCALE` in op 2 totdat je een schaal kiest in het monitorpaneel. Als je op een 1x scherm zit en GTK- of X11-apps er te groot uitkomen, kies daarvoor dan 1x in het monitorpaneel, of voeg `hl.env("GDK_SCALE", "1")` toe aan `~/.config/hypr/monitors.lua` (en start daarna elke app die te groot is opnieuw op). Zie [de handleiding over monitors](33-monitors.md).

Voor Spotify kun je `Ctrl + Minus` gebruiken om de UI te verkleinen (en `Ctrl + Plus` om die groter te maken).

### Waarom werken al mijn Super-sneltoetsen ineens niet meer?

Op sommige ASUS ROG- en TUF-laptops is `Fn + Super` een makkelijk te missen combinatie die een Windows-toetsvergrendeling in de firmware omschakelt (bedoeld voor gamen, zodat je niet per ongeluk uit een game gaat). Niets op het scherm vertelt je dat dit is gebeurd. Terwijl de vergrendeling aanstaat, stuurt Super helemaal niets uit — dus elke Omarchy-sneltoets die Super gebruikt, doet het gewoon niet meer, en het lijkt alsof Hyprland kapot is.

Druk één keer op `Fn + Super` voordat je in `~/.config/hypr/` duikt, en als Super daardoor niet terugkomt, druk er nog een keer op zodat je de vergrendeling niet aan laat staan. Dit is geen Fn-lock, dat alleen verandert wat de rij met F-toetsen doet.

### Mijn Wi-Fi, Bluetooth, audio of trackpad werkt ineens niet meer

Probeer voordat je opnieuw opstart eerst het haperende subsysteem op zichzelf opnieuw op te starten. _Update > Hardware_ in het Omarchy-menu heeft Wi-Fi, Bluetooth, Audio en Trackpad, en het opnieuw laden van een daarvan lost het merendeel van de "vijf minuten geleden werkte het nog"-situaties op — een Bluetooth-headset die niet opnieuw wil verbinden, een trackpad dat na een sluimerstand dood is, geluid dat verdween toen je een monitor loskoppelde.

### Waarom geven mijn externe speakers geen geluid?

Waarschijnlijk omdat ze niet als primaire uitvoer zijn ingesteld. Klik op het speakerpictogram aan de rechterkant van de balk, dan opent de volumepopup waar je het uitvoerapparaat kunt kiezen (en ook per app het volume kunt mixen).

### Mijn laptopspeakers klinken vreemd

Op sommige laptops past Omarchy automatisch een speakeraanpassing toe die de frequentierespons van de ingebouwde speakers corrigeert. `omarchy audio tuning status` laat je zien of er een actief is op jouw machine, en `omarchy audio tuning off` zet die uit als je de speakers liever rauw hoort.

### Waarom kan ik niet inloggen of sudo gebruiken met mijn wachtwoord?

Je hebt het waarschijnlijk tien keer verkeerd getypt en bent buitengesloten. De buitensluiting wordt na twee minuten vanzelf opgeheven. Als je niet kunt wachten, en dit gebeurt op het vergrendelscherm, kun je op `CTRL + ALT + F2` drukken om een nieuwe TTY te starten waar je als root kunt inloggen, en vervolgens `faillock --reset --user [your-username]` uitvoeren. Dat reset de buitensluiting, en dan kun je weer aan de slag.

### Mijn wachtwoord wordt geaccepteerd, maar ik kom terug op het inlogscherm

Een kapot omgevingsbestand voor de sessie kan voorkomen dat het bureaublad start, zelfs als je wachtwoord klopt. Dit is vooral de moeite waard om te controleren nadat je `~/.config/uwsm/env.d/` hebt bewerkt.

Druk op `Ctrl + Alt + F2`, log in met je normale gebruikersnaam en wachtwoord, en inspecteer het gebruikerslogboek van de huidige opstart:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Zoek naar een fout die een van je omgevingsbestanden noemt, zoals `bad substitution`, vlak vóór een melding dat het env output mark niet is gevonden. Verplaats dat bestand uit `env.d` voordat je opnieuw probeert in te loggen. Als de fout bijvoorbeeld `99-custom` noemt:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM slaat een bestand met een syntaxisfout over, maar een fatale fout die pas optreedt terwijl het bestand draait, zoals `bad substitution`, kan nog steeds voorkomen dat het bureaublad start. Het terugzetten van een systeemsnapshot repareert deze bestanden niet, omdat `/home` niet wordt teruggezet.

Zodra je kunt inloggen, repareer de bewaarde kopie voordat je die terugplaatst. `sh -n` spoort syntaxisfouten op zonder het bestand uit te voeren, maar kan niet elke fout vinden die optreedt wanneer het wordt geladen. Hou een werkende terminal open terwijl je wijzigingen test.

### Waarom verschijnen mijn 1Password-autorisatieprompts voor 1Password SSH Agent / CLI niet?

Dit kan 2 oorzaken hebben:

Om de uitgebreide goedkeuringsprompt te laten verschijnen, moet Settings > Advanced > Use Hardware Acceleration zijn ingeschakeld. _Let op: Hiervoor is een herstart nodig voordat het werkt._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Of als je 1Password sinds het opstarten nog niet hebt gestart, verschijnt de prompt niet.
