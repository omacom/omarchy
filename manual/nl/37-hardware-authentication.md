# Hardwareauthenticatie

### Vingerafdrukauthenticatie

Veel laptops hebben een vingerafdruksensor om authenticatie mee te doen. Je kunt die met Omarchy gebruiken door _Setup > Security > Fingerprint_ te openen in het Omarchy-menu (`Super + Space`).

Dat opent een vingerafdruk op volledig scherm die zich vult terwijl je de sensor aanraakt. Achter de schermen installeert Omarchy het vingerafdrukpakket, registreert het je afdruk, verifieert het die, en daarna kun je je vingerafdruk gebruiken om te ontgrendelen vanaf het vergrendelscherm (dat je kunt activeren met `Super + Ctrl + L`), om de sudo-modus in te gaan en om systeemverzoeken te autoriseren.

Zodra het vergrendelscherm het beeldscherm heeft uitgeschakeld, gaat de sensor in ruststand om stroom te besparen, dus wek het scherm met een willekeurige toets of het touchpad voordat je de sensor aanraakt.

Wanneer het deksel van je laptop gesloten is, wordt de vingerafdrukprompt automatisch overgeslagen, zodat je direct naar de wachtwoordprompt gaat in plaats van te wachten op een sensor die je niet kunt bereiken. Als je om een andere reden moet werken op een extern toetsenbord zonder sensor, druk je gewoon op `CTRL + C` wanneer je tijdens `sudo` om je vingerafdruk wordt gevraagd.

Je kunt de vingerafdrukauthenticatie verwijderen onder _Remove > Security > Fingerprint_ in het Omarchy-menu.

### Fido2-authenticatie

Als je een Fido2-apparaat gebruikt, kun je het instellen voor `sudo`-authenticatie via _Setup > Security > Fido2_ in het Omarchy-menu (`Super + Space`). Het dekt echter `sudo` en systeemautorisatieverzoeken, niet het ontgrendelen van je computer.

Je kunt de fido2-authenticatie verwijderen onder _Remove > Security > Fido2_ in het Omarchy-menu.
