# Hardware-authenticatie

### Vingerafdrukauthenticatie

Veel laptops hebben een vingerafdruksensor voor authenticatie. Je kunt die met Omarchy gebruiken door _Instellen > Beveiliging > Vingerafdruk_ uit te voeren in het Omarchy-menu (`Super + Space`).

Daarmee wordt het vingerafdrukpakket geïnstalleerd, je afdruk vastgelegd en geverifieerd, en dan kun je aan de slag: gebruik je vingerafdruk om te ontgrendelen vanaf het vergrendelscherm (dat je kunt activeren met `Super + Ctrl + L`), om sudo-modus in te gaan en om systeemprompts goed te keuren.

Zodra het vergrendelscherm het scherm heeft uitgeschakeld, rust de sensor om stroom te besparen, dus wek het scherm met een willekeurige toets of het touchpad voordat je hem aanraakt.

Wanneer de klep van je laptop dicht is, wordt de vingerafdrukprompt automatisch overgeslagen, zodat je direct naar de wachtwoordprompt gaat in plaats van te wachten op een sensor waar je niet bij kunt. Als je om een andere reden moet werken op een extern toetsenbord zonder sensor, druk dan gewoon op `CTRL + C` wanneer je tijdens `sudo` om je vingerafdruk wordt gevraagd.

Je kunt de vingerafdrukauthenticatie verwijderen onder _Verwijderen > Beveiliging > Vingerafdruk_ in het Omarchy-menu.

### Fido2-authenticatie

Als je een Fido2-apparaat gebruikt, kun je het instellen voor `sudo`-authenticatie via _Instellen > Beveiliging > Fido2_ in het Omarchy-menu (`Super + Space`). Het geldt echter voor `sudo` en prompts voor systeemautorisatie, niet voor het ontgrendelen van je computer.

Je kunt de fido2-authenticatie verwijderen onder _Verwijderen > Beveiliging > Fido2_ in het Omarchy-menu.
