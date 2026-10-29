# Probleemoplossing

### Ik heb mijn systeem kapotgemaakt met een update!

Probeer eerst [je systeem terug te zetten](47-system-snapshots.md) naar de versie van vóór je recente update. Als dat niet werkt, gebruik dan `omarchy-debug` om je probleem te delen op #omarchy-help in de Discord. En als dat allemaal niet lukt, kun je de standaardconfiguraties en -pakketten opnieuw installeren met `omarchy-reinstall`.

### Waarom zijn sommige apps zo groot op mijn scherm?

Omarchy gaat uit van een scherm met hoge resolutie op 2x, waarvoor `GDK_SCALE` in `~/.config/hypr/monitors.lua` op 2 moet staan. Maar als je een 1x-scherm hebt, kun je `local omarchy_gdk_scale = 2` veranderen in 1 (en daarna elke app herstarten die te groot is). Zie [de handleiding over monitoren](33-monitors.md).

Voor Spotify kun je `Ctrl + Minus` gebruiken om de interface te verkleinen (en `Ctrl + Plus` om hem groter te maken).

### Waarom werken al mijn Super-toetscombinaties ineens niet meer?

Op sommige ASUS ROG- en TUF-laptops is `Fn + Super` een makkelijk te missen toetsencombinatie die een Windows-toetsvergrendeling in de firmware omschakelt (bedoeld voor gamen, zodat je niet per ongeluk een game verlaat). Er verschijnt niets op het scherm dat je vertelt dat het is gebeurd. Zolang de vergrendeling aan staat, geeft Super helemaal niets door — dus elke Omarchy-bind die Super gebruikt, stopt er gewoon mee, en het lijkt alsof Hyprland kapot is.

Druk één keer op `Fn + Super` voordat je in `~/.config/hypr/` gaat graven, en als Super daarmee niet terugkomt, druk er dan nog een keer op zodat je de vergrendeling niet aan laat staan. Dit is geen Fn-lock, die verandert alleen wat de rij met F-toetsen doet.

### Mijn Wi-Fi, Bluetooth, audio of trackpad is er ineens mee gestopt

Herstart niet meteen, maar probeer eerst het betreffende subsysteem op zichzelf opnieuw te starten. _Update > Hardware_ in het Omarchy-menu heeft Wi-Fi, Bluetooth, Audio en Trackpad, en het opnieuw laden van een daarvan lost het merendeel van de "vijf minuten geleden werkte het nog"-situaties op — een Bluetooth-headset die geen verbinding meer wil maken, een trackpad dat dood is na een slaapstand, geluid dat verdween toen je een monitor loskoppelde.

### Waarom spelen mijn externe luidsprekers niets af?

Waarschijnlijk omdat ze niet als primaire uitvoer zijn ingesteld. Klik op het luidsprekerpictogram aan de rechterkant van de balk, dan opent de volumepop-up waar je het uitvoerapparaat kunt kiezen (en ook het volume per app kunt mixen).

### Het geluid van mijn laptopluidsprekers klinkt niet goed

Op sommige laptops past Omarchy automatisch een luidsprekerafstemming toe die de frequentierespons van de ingebouwde luidsprekers corrigeert. `omarchy audio tuning status` vertelt je of er een actief is op jouw machine, en `omarchy audio tuning off` zet die uit als je de luidsprekers liever rauw hoort.

### Waarom kan ik niet inloggen of sudo gebruiken met mijn wachtwoord?

Je hebt het waarschijnlijk te vaak verkeerd getypt en bent buitengesloten. Als dit op het vergrendelscherm gebeurt, kun je `CTRL + ALT + F2` indrukken om een nieuwe TTY te starten waar je als root kunt inloggen, en voer dan `faillock --reset --user [your-username]` uit. Dat reset de blokkering, en je kunt weer verder.

### Waarom verschijnen mijn 1Password-autorisatieprompts voor 1Password SSH Agent / CLI niet?

Dit kan twee oorzaken hebben:

Om de uitgebreide goedkeuringsprompt te laten verschijnen, moet Settings > Advanced > Use Hardware Acceleration aan staan. _Let op: hiervoor is een herstart nodig voordat het werkt._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Of als je 1Password sinds het opstarten nog niet hebt gestart, verschijnt de prompt niet.
