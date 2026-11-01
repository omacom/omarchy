# Početak rada

Omarchy se instalira pomoću ISO-a. Možete birati između instalacije na cijeli disk, koja preuzima cijeli pogon, ili instalacije u slobodni prostor, koja smješta Omarchy u nedodijeljeni prostor na pogonu — tako se radi dvostruko pokretanje uz Windows ili drugi OS (pogledajte [instalacija s dvostrukim pokretanjem](50-dual-boot-install.md) — imajte na umu da ćete prvo morati isključiti BitLocker u sustavu Windows). U oba slučaja instalacija prema zadanim postavkama koristi potpunu enkripciju, a opcija cijelog diska obrisat će odabrani pogon, pa svakako napravite sigurnosnu kopiju prije korištenja postojećeg pogona!

Najprije [preuzmite Omarchy ISO](https://omarchy.org/), stavite ga na USB stick (upotrijebite [Rufus](https://rufus.ie/) na sustavu Windows, [balenaEtcher](https://etcher.balena.io/) na Macu ili [caligula](https://github.com/ifd3f/caligula) na Linuxu) i pokrenite računalo s tog sticka.

_Morate isključiti Secure Boot i/ili TPM u BIOS-u. Morate ih isključiti da biste mogli instalirati Omarchy. To su Microsoftove sigurnosne sheme namijenjene sustavu Windows i Linux distribucijama povezanim s Microsoftom._

Zatim odgovorite na konfiguracijska pitanja i potvrdite ih ovako:

 ![install-config](images/install-config.webp)

Zatim odaberite pogon za instalaciju, opustite se i gledajte predstavu instalacije. Na najbržim modernim računalima može biti gotova za manje od minute, ali ni na starijem računalu ne bi trebala trajati dulje od 5 minuta.

 ![install-done](images/install-done.webp)

Sada ste spremni za Omarchy!

### Koristite žičanu tipkovnicu ili tipkovnicu od 2.4ghz!

Enkripcija cijelog diska neće vam dopustiti unos lozinke s Bluetooth tipkovnice pri pokretanju. Baš kao što ne možete koristiti Bluetooth tipkovnicu za ulazak u BIOS na PC-ju. Trebat će vam tipkovnica koja koristi 2.4ghz dongle ili kabel (što je ionako puno bolje zbog latencije!). Osobno obožavam [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalacija za drugog vlasnika

Ako postavljate računalo za nekog drugog — člana obitelji, novog zaposlenika, kupca — ne biste trebali odgovarati na osobna pitanja u njihovo ime. Pritisnite `Ctrl + C` na samom prvom zaslonu instalacijskog programa (odabir tipkovnice) i Omarchy će ponuditi pripremu računala za drugog vlasnika. Sustav se odmah instalira, ali sva osobna podešavanja — raspored tipkovnice, korisničko ime, lozinka — odgađaju se do prvog pokretanja računala. Pogon je i dalje prema zadanim postavkama enkriptiran, a lozinka koju novi vlasnik odabere pri tom prvom pokretanju postaje i lozinka za enkripciju. (Računalo koje ste već koristili također se može predati bez ponovne instalacije — pogledajte [resetiranje računala](48-security.md).)

### Instalacije bez nadzora

ISO se također može instalirati potpuno samostalno — bez tipkovnice, bez čarobnjaka — kada mu se konfiguracija preda na drugom pogonu. To je način da Omarchy tretirate kao osnovnu sliku za VM-ove i strojeve u floti. Pogledajte [instalacije bez nadzora](51-unattended-installs.md).

### Instalacije bez enkripcije

Omarchy se prema zadanim postavkama instalira s enkripcijom. To je siguran, odgovoran izbor za svako računalo koje se može izgubiti ili biti ukradeno. Ne želite da itko tko ima pristup vašem hardveru može doći do vaših podataka!

Ali u posebnim okolnostima, poput udaljenih instalacija Omarchyja na zaštićenim računalima ili za privremene instalacije bez osjetljivih podataka, možda ćete htjeti instalirati bez enkripcije. Možete pritisnuti `Ctrl + C` na potvrdi formatiranja diska da biste prešli na instalaciju bez enkripcije.

### Jezik

Omarchy govori 50 jezika — isti skup kao omarchy.org — a engleski je zadani. Za promjenu otvorite izbornik Omarchyja i idite na _Setup > Language_ ili pokrenite `omarchy language <code>` u terminalu (`omarchy language list` prikazuje kodove). Izbornik, radna površina i vlastite obavijesti Omarchyja odmah mijenjaju jezik, a svaka aplikacija koju nakon toga otvorite također ga slijedi. Aplikacije koje su već bile otvorene promijenit će jezik nakon što ih ponovno pokrenete.

### Pomoć ako zapnete

Ako zapnete, obično možete pronaći nekoga tko je voljan pomoći u kanalu _#omarchy-help_ na [Discordu zajednice](https://omarchy.org/discord).
