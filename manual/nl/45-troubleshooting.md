# Probleemoplossing

### Ik heb mijn systeem kapotgemaakt met een update!

Probeer eerst [je systeem terug te draaien](47-system-snapshots.md) naar de versie vóór je recente update. Als dat niet werkt, gebruik dan `omarchy-debug` om je probleem te delen op #omarchy-help in de Discord. En als dat allemaal faalt, kun je de standaardconfigs en -pakketten opnieuw installeren met `omarchy-reinstall`.

### Waarom zijn sommige apps zo groot op mijn scherm?

Omarchy gaat uit van een 2x-scherm met hoge resolutie, wat vereist dat `GDK_SCALE` op 2 wordt ingesteld in `~/.config/hypr/monitors.lua`. Maar als je op een 1x-scherm zit, kun je `local omarchy_gdk_scale = 2` wijzigen naar 1 (en vervolgens elke app herstarten die te groot is). Zie [de handleiding over monitors](33-monitors.md).

Voor Spotify kun je `Ctrl + Minus` gebruiken om de UI te verkleinen (en `Ctrl + Plus` om hem groter te maken).

### Mijn wifi, Bluetooth, audio of trackpad stopte er net mee

Probeer voordat je herstart eerst het storende subsysteem op zichzelf te herstarten. _Bijwerken > Hardware_ in het Omarchy-menu heeft Wi-Fi, Bluetooth, Audio en Trackpad, en het herladen van een daarvan ruimt het merendeel van de "het werkte vijf minuten geleden nog"-situaties op — een Bluetooth-headset die geen verbinding meer wil maken, een trackpad dat na een suspend dood ging, geluid dat verdween toen je een monitor loskoppelde.

### Waarom spelen mijn externe luidsprekers niet af?

Waarschijnlijk omdat ze niet als primaire uitvoer zijn ingesteld. Klik op het luidsprekerpictogram aan de rechterkant van de balk, en dat opent de volumepopup waar je het uitvoerapparaat kunt kiezen (en ook volumes per app kunt mixen).

### Mijn laptop-luidsprekers klinken raar

Op sommige laptops past Omarchy automatisch een luidsprekerafstemming toe die de frequentierespons van de ingebouwde luidsprekers corrigeert. `omarchy audio tuning status` vertelt je of er een actief is op je machine, en `omarchy audio tuning off` schakelt hem uit als je de luidsprekers liever rauw hoort.

### Waarom kan ik niet inloggen of sudo'en met mijn wachtwoord?

Je hebt het waarschijnlijk te vaak verkeerd getypt en bent buitengesloten. Als dit op het vergrendelscherm gebeurt, kun je op `CTRL + ALT + F2` drukken om een nieuwe TTY te starten waar je als root kunt inloggen, en vervolgens `faillock --reset --user [your-username]` uitvoeren. Dat reset de blokkering, en je kunt weer verder.

### Waarom verschijnen mijn 1Password-autorisatieprompts voor de 1Password SSH Agent / CLI niet?

Dit kan om 2 redenen gebeuren:

Om de uitgebreide goedkeuringsprompt te laten verschijnen, moet Settings > Advanced > Use Hardware Acceleration zijn ingeschakeld. _Let op: dit vereist een herstart om te gaan werken._

 ![troubleshooting-1password](images/troubleshooting-1password.webp)

Of als je 1Password sinds het opstarten niet hebt gestart, verschijnt de prompt niet.
