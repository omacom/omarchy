# Prvi koraci

Omarchy se instalira pomoću ISO-a. Možete birati između instalacije na cijeli disk, koja preuzima cijeli pogon, ili instalacije u slobodan prostor, koja Omarchy smješta u nedodijeljeni prostor na pogonu — tako se radi dvojno pokretanje uz Windows ili drugi OS (pogledajte [instalaciju s dvojnim pokretanjem](50-dual-boot-install.md) — imajte na umu da ćete najprije morati isključiti BitLocker u Windowsu). U svakom slučaju, instalacija prema zadanim postavkama koristi potpuno šifriranje, a opcija cijelog diska izbrisat će odabrani pogon, pa svakako napravite sigurnosnu kopiju prije nego što upotrijebite postojeći!

Najprije [preuzmite Omarchy ISO](https://omarchy.org/), stavite ga na USB stick (upotrijebite [balenaEtcher](https://etcher.balena.io/) na Macu/Windowsu ili [caligula](https://github.com/ifd3f/caligula) na Linuxu) i pokrenite računalo s tog sticka.

_Morate isključiti Secure Boot i/ili TPM u BIOS-u. Morate ih isključiti da biste mogli instalirati Omarchy. To su Microsoftove sigurnosne sheme namijenjene Windowsu i Linux distribucijama povezanim s Microsoftom._

Zatim odgovorite na konfiguracijska pitanja i potvrdite ih ovako:

 ![install-config](images/install-config.webp)

Zatim odaberite pogon za svoju instalaciju, zavalite se i gledajte kako instalacijski show ide dalje. Na najbržim modernim računalima može biti gotovo za manje od minute, ali ni na starijem računalu ne bi trebalo trajati više od 5 minuta.

 ![install-done](images/install-done.webp)

Sada ste spremni za Omarchy!

### Koristite žičanu ili 2.4ghz tipkovnicu!

Potpuno šifriranje diska neće vam omogućiti da pri pokretanju unesete lozinku s Bluetooth tipkovnice. Isto kao što Bluetooth tipkovnicom ne možete ući u BIOS na PC-ju. Trebat će vam tipkovnica koja koristi 2.4ghz dongle ili kabel (što je ionako puno ljepše zbog latencije!). Osobno obožavam [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalacija za drugog vlasnika

Ako postavljate računalo za nekoga drugog — člana obitelji, novog zaposlenika, kupca — ne biste trebali odgovarati na osobna pitanja u njihovo ime. Pritisnite `Ctrl + C` na samom prvom zaslonu instalacijskog programa (odabiru tipkovnice) i Omarchy će umjesto toga ponuditi pripremiti računalo za drugog vlasnika. Sustav se instalira odmah, ali sve osobno postavljanje — raspored tipkovnice, korisničko ime, lozinka — odgađa se do prvog pokretanja računala. Pogon je i dalje prema zadanim postavkama šifriran, a lozinka koju novi vlasnik odabere pri tom prvom pokretanju postaje i lozinka za šifriranje. (Računalo koje ste već koristili također se može predati bez ponovne instalacije — pogledajte [resetiranje računala](48-security.md).)

### Instalacije bez nadzora

ISO se također može instalirati potpuno sam — bez tipkovnice, bez čarobnjaka — kada mu se njegova konfiguracija preda na drugom pogonu. Tako Omarchy tretirate kao osnovnu sliku za VM-ove i računala u floti. Pogledajte [instalacije bez nadzora](51-unattended-installs.md).

### Instalacije bez šifriranja

Omarchy se prema zadanim postavkama instalira sa šifriranjem. To je siguran, odgovoran izbor za svako računalo koje se može izgubiti ili ukrasti. Ne želite da itko s pristupom vašem hardveru može doći do vaših podataka!

Ali u posebnim okolnostima, poput udaljenih instalacija Omarchyja na zaštićenim računalima ili za jednokratne instalacije bez osjetljivih podataka, možda ćete htjeti instalirati bez šifriranja. Možete pritisnuti `Ctrl + C` na potvrdi formatiranja diska da biste se prebacili na instalaciju bez šifriranja.

### Jezik

Omarchy govori 50 jezika — isti skup kao omarchy.org — a engleski je zadani. Za promjenu otvorite izbornik Omarchyja i idite na _Setup > Language_ ili pokrenite `omarchy language <code>` u terminalu (`omarchy language list` prikazuje kodove). Izbornik, radna površina i Omarchyjeve vlastite obavijesti odmah mijenjaju jezik, a svaka aplikacija koju nakon toga otvorite također slijedi. Aplikacije koje su već bile otvorene prebacuju se nakon što ih ponovno pokrenete.

### Pomoć ako zapnete

Ako zapnete, obično možete pronaći nekoga tko je voljan pomoći u kanalu _#omarchy-help_ na [Discordu zajednice](https://omarchy.org/discord).
