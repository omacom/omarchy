# Problemen oplossen

### Ik heb mijn systeem kapotgemaakt met een update!

Probeer eerst [je systeem terug te zetten](47-system-snapshots.md) naar de versie van vóór je recente update. Als dat niet werkt, gebruik `omarchy-debug` om je probleem te delen op #omarchy-help in de Discord. En als dat allemaal niet lukt, kun je de standaardconfiguraties en -pakketten opnieuw installeren met `omarchy-reinstall`.

### Waarom zijn sommige apps zo groot op mijn scherm?

Omarchy gaat uit van een 2x-scherm met hoge resolutie, dus stelt het `GDK_SCALE` in op 2 totdat je een schaal kiest in het monitorpaneel. Als je een 1x-scherm hebt en GTK- of X11-apps te groot worden weergegeven, kies dan 1x voor dat scherm in het monitorpaneel, of voeg `hl.env("GDK_SCALE", "1")` toe aan `~/.config/hypr/monitors.lua` (en herstart daarna elke app die te groot is). Zie [de handleiding over monitoren](33-monitors.md).

Voor Spotify kun je `Ctrl + Minus` gebruiken om de UI te verkleinen (en `Ctrl + Plus` om die te vergroten).

### Waarom zijn al mijn Super-toetscombinaties gestopt met werken?

Op sommige ASUS ROG- en TUF-laptops is `Fn + Super` een makkelijk te missen toetsencombinatie waarmee je een firmwarevergrendeling van de Windows-toets in- of uitschakelt (bedoeld voor gaming, zodat je niet per ongeluk een game verlaat). Niets op het scherm vertelt je dat het is gebeurd. Zolang de vergrendeling aanstaat, geeft Super helemaal niets door — dus stopt elke Omarchy-toetscombinatie met Super gewoon, en lijkt het alsof Hyprland kapot is.

Druk één keer op `Fn + Super` voordat je in `~/.config/hypr/` gaat graven, en als Super daarmee niet terugkomt, druk er dan nog een keer op zodat je de vergrendeling niet aan laat staan. Dit is geen Fn-lock, dat verandert alleen wat de rij met F-toetsen doet.

### Mijn Wi-Fi, Bluetooth, audio of trackpad is er net mee opgehouden

Probeer voordat je opnieuw opstart eerst het betreffende subsysteem apart opnieuw te starten. _Update > Hardware_ in het Omarchy-menu heeft Wi-Fi, Bluetooth, Audio en Trackpad, en het opnieuw laden van een daarvan lost de meeste "vijf minuten geleden werkte het nog"-situaties op — een Bluetooth-headset die geen verbinding meer wil maken, een trackpad dat na een slaapstand niets meer doet, geluid dat verdween toen je een monitor loskoppelde.

### Waarom spelen mijn externe luidsprekers niets af?

Waarschijnlijk omdat ze niet zijn ingesteld als primaire uitvoer. Klik op het luidsprekerpictogram aan de rechterkant van de balk, dan opent de volumepopup waarin je het uitvoerapparaat kunt kiezen (en ook het volume per app kunt mixen).

### De luidsprekers van mijn laptop klinken niet goed

Op sommige laptops past Omarchy automatisch een luidsprekerafstemming toe die de frequentierespons van de ingebouwde luidsprekers corrigeert. `omarchy audio tuning status` vertelt je of er een actief is op jouw machine, en `omarchy audio tuning off` schakelt die uit als je de luidsprekers liever onbewerkt hoort.

### Waarom kan ik niet inloggen of sudo gebruiken met mijn wachtwoord?

Je hebt het waarschijnlijk te vaak verkeerd getypt en bent buitengesloten. Als dit gebeurt op het vergrendelscherm, kun je op `CTRL + ALT + F2` drukken om een nieuwe TTY te starten waarin je als root kunt inloggen, en voer dan `faillock --reset --user [your-username]` uit. Dat reset de buitensluiting, en je kunt weer verder.

### Waarom verschijnen mijn 1Password-autorisatieprompts voor 1Password SSH Agent / CLI niet?

Dit kan 2 oorzaken hebben:

Om de uitgebreide goedkeuringsprompt te laten verschijnen, moet Settings > Advanced > Use Hardware Acceleration ingeschakeld zijn. _Let op: Hiervoor is een herstart nodig voordat het werkt._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Of als je 1Password sinds het opstarten nog niet hebt gestart, verschijnt de prompt niet.
