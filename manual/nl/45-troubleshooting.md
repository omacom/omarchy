# Problemen oplossen

### Ik heb mijn systeem kapotgemaakt met een update!

Probeer eerst [je systeem terug te zetten](47-system-snapshots.md) naar de versie van vóór je recente update. Als dat niet werkt, gebruik dan `omarchy-debug` om je probleem te delen in #omarchy-help op Discord. En als dat allemaal niet lukt, kun je de standaardconfiguraties en -pakketten opnieuw installeren met `omarchy-reinstall`.

### Waarom zijn sommige apps zo groot op mijn scherm?

Omarchy gaat uit van een 2x-scherm met hoge resolutie, dus stelt het `GDK_SCALE` in op 2 totdat je een schaal kiest in het monitorpaneel. Als je op een 1x-scherm zit en GTK- of X11-apps te groot worden weergegeven, kies dan 1x daarvoor in het monitorpaneel, of voeg `hl.env("GDK_SCALE", "1")` toe aan `~/.config/hypr/monitors.lua` (en herstart daarna elke app die te groot is). Zie [de handleiding over monitoren](33-monitors.md).

Bij Spotify kun je `Ctrl + Minus` gebruiken om de UI te verkleinen (en `Ctrl + Plus` om die groter te maken).

### Waarom werken al mijn Super-toetscombinaties ineens niet meer?

Op sommige ASUS ROG- en TUF-laptops is `Fn + Super` een makkelijk te missen toetscombinatie die een Windows-toetsvergrendeling in de firmware in- en uitschakelt (bedoeld voor gamen, zodat je niet per ongeluk een game verlaat). Niets op het scherm vertelt je dat het is gebeurd. Zolang de vergrendeling aanstaat, geeft Super helemaal niets door — dus stopt elke Omarchy-combinatie met Super gewoon, en het lijkt alsof Hyprland kapot is.

Druk één keer op `Fn + Super` voordat je in `~/.config/hypr/` gaat graven, en als Super daardoor niet terugkomt, druk er dan nog een keer op zodat je de vergrendeling niet aan laat staan. Dit is geen Fn-lock; die verandert alleen wat de rij met F-toetsen doet.

### Mijn Wi-Fi, Bluetooth, audio of trackpad werkt ineens niet meer

Probeer voordat je opnieuw opstart eerst het betreffende subsysteem apart opnieuw te starten. _Update > Hardware_ in het Omarchy-menu heeft Wi-Fi, Bluetooth, Audio en Trackpad, en het opnieuw laden van een daarvan lost de meeste "het werkte vijf minuten geleden nog"-situaties op — een Bluetooth-headset die geen verbinding meer wil maken, een trackpad dat ermee ophield na een slaapstand, geluid dat verdween toen je een monitor loskoppelde.

### Waarom spelen mijn externe speakers niet af?

Waarschijnlijk omdat ze niet zijn ingesteld als primaire uitvoer. Klik op het speakerpictogram aan de rechterkant van de balk; dan opent de volumepop-up waar je het uitvoerapparaat kunt kiezen (en ook het volume per app kunt mixen).

### De speakers van mijn laptop klinken niet goed

Op sommige laptops past Omarchy automatisch een speaker-tuning toe die de frequentierespons van de ingebouwde speakers corrigeert. `omarchy audio tuning status` vertelt je of er een actief is op jouw machine, en `omarchy audio tuning off` schakelt die uit als je de speakers liever rauw hoort.

### Waarom kan ik niet inloggen of sudo gebruiken met mijn wachtwoord?

Je hebt het waarschijnlijk te vaak verkeerd getypt en bent buitengesloten. Als dit gebeurt op het vergrendelscherm, kun je op `CTRL + ALT + F2` drukken om een nieuwe TTY te starten waar je als root kunt inloggen, en voer dan `faillock --reset --user [your-username]` uit. Dat reset de uitsluiting, en je kunt weer verder.

### Mijn wachtwoord wordt geaccepteerd, maar ik kom terug op het inlogscherm

Een kapot omgevingsbestand voor de sessie kan voorkomen dat de desktop start, zelfs als je wachtwoord klopt. Dit is vooral de moeite waard om te controleren nadat je `~/.config/uwsm/env.d/` hebt bewerkt.

Druk op `Ctrl + Alt + F2`, log in met je normale gebruikersnaam en wachtwoord, en bekijk het gebruikerslogboek van de huidige opstartsessie:

```bash
journalctl --user -b -t uwsm_env-preloader --no-pager
```

Zoek naar een foutmelding waarin een van je omgevingsbestanden wordt genoemd, zoals `bad substitution`, net vóór een melding dat de env output mark niet is gevonden. Verplaats dat bestand uit `env.d` voordat je opnieuw probeert in te loggen. Als de fout bijvoorbeeld `99-custom` noemt:

```bash
mkdir -p ~/.config/uwsm/disabled
mv -i ~/.config/uwsm/env.d/99-custom ~/.config/uwsm/disabled/
```

UWSM slaat een bestand met een syntaxfout over, maar een fatale fout die pas opduikt terwijl het bestand wordt uitgevoerd, zoals `bad substitution`, kan nog steeds voorkomen dat de desktop start. Een rollback naar een systeemsnapshot repareert deze bestanden niet, omdat `/home` niet wordt teruggezet.

Zodra je weer kunt inloggen, repareer je de bewaarde kopie voordat je die terugplaatst. `sh -n` vangt syntaxfouten op zonder het bestand uit te voeren, maar kan niet elke fout opvangen die optreedt wanneer het wordt ingelezen. Houd een werkende terminal open terwijl je wijzigingen test.

### Waarom verschijnen mijn 1Password-autorisatieprompts voor 1Password SSH Agent / CLI niet?

Dit kan 2 redenen hebben:

Om de uitgebreide goedkeuringsprompt te laten verschijnen, moet Settings > Advanced > Use Hardware Acceleration zijn ingeschakeld. _Let op: Hiervoor is een herstart nodig om te gaan werken._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Of als je 1Password sinds het opstarten nog niet hebt gestart, verschijnt de prompt niet.
