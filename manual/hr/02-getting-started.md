# Početak rada

Omarchy se instalira pomoću ISO datoteke. Možete birati između instalacije na cijeli disk, koja preuzima cijeli pogon, ili instalacije u slobodni prostor, koja Omarchy smješta u nedodijeljeni prostor na pogonu — tako se izvodi dual boot uz Windows ili drugi OS (vidi [instalacija za dual boot](50-dual-boot-install.md) — imajte na umu da ćete najprije morati isključiti BitLocker u sustavu Windows). U oba slučaja instalacija prema zadanim postavkama uključuje potpunu enkripciju, a opcija za cijeli disk obrisat će odabrani pogon, pa svakako napravite sigurnosnu kopiju prije nego što upotrijebite postojeći pogon!

Najprije [preuzmite Omarchy ISO](https://omarchy.org/), stavite ga na USB stick (upotrijebite [Rufus](https://rufus.ie/) na sustavu Windows, [balenaEtcher](https://etcher.balena.io/) na Macu ili [caligula](https://github.com/ifd3f/caligula) na Linuxu) i pokrenite računalo s tog sticka.

_Morate isključiti Secure Boot i/ili TPM u BIOS-u. Morate ih isključiti da biste mogli instalirati Omarchy. Riječ je o Microsoftovim sigurnosnim shemama namijenjenima sustavu Windows i Linux distribucijama povezanim s Microsoftom._

Zatim odgovorite na konfiguracijska pitanja i potvrdite ih ovako:

 ![install-config](images/install-config.webp)

Zatim odaberite pogon za instalaciju, zavalite se i gledajte predstavu instalacije. Na najbržim modernim računalima može biti gotova za manje od minute, ali ni na starijem računalu ne bi smjela trajati dulje od 5 minuta.

 ![install-done](images/install-done.webp)

Sada ste spremni za Omarchy!

### Upotrijebite žičanu tipkovnicu ili tipkovnicu od 2.4ghz!

Potpuna enkripcija diska neće vam dopustiti da lozinku pri pokretanju unesete s Bluetooth tipkovnice. Baš kao što Bluetooth tipkovnicu ne možete upotrijebiti ni za ulazak u BIOS na PC-ju. Trebat će vam tipkovnica koja upotrebljava 2.4ghz dongle ili kabel (što je ionako puno ugodnije zbog latencije!). Osobno obožavam [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalacija za drugog vlasnika

Ako postavljate računalo za nekoga drugoga — člana obitelji, novog zaposlenika, kupca — ne biste trebali odgovarati na osobna pitanja u njihovo ime. Pritisnite `Ctrl + C` na samom prvom zaslonu instalacijskog programa (odabir tipkovnice) i Omarchy će ponuditi da računalo umjesto toga pripremi za drugog vlasnika. Sustav se odmah instalira, ali sve osobno postavljanje — raspored tipkovnice, korisničko ime, lozinka — odgađa se dok se računalo prvi put ne pokrene. Pogon je i dalje prema zadanim postavkama enkriptiran, a lozinka koju novi vlasnik odabere pri tom prvom pokretanju postaje i lozinka za enkripciju. (Računalo koje ste već upotrebljavali možete predati i bez ponovne instalacije — vidi [resetiranje računala](48-security.md).)

### Instalacije bez nadzora

ISO se može instalirati i potpuno samostalno — bez tipkovnice, bez čarobnjaka — kada mu se konfiguracija preda na drugom pogonu. Tako Omarchy možete tretirati kao osnovnu sliku za VM-ove i flote računala. Vidi [instalacije bez nadzora](51-unattended-installs.md).

### Instalacije bez enkripcije

Omarchy se prema zadanim postavkama instalira s enkripcijom. To je siguran i odgovoran izbor za svako računalo koje se može izgubiti ili biti ukradeno. Ne želite da itko tko ima pristup vašem hardveru može doći do vaših podataka!

Ali u posebnim okolnostima, poput udaljenih instalacija Omarchyja na zaštićenim računalima ili instalacija za jednokratnu upotrebu bez osjetljivih podataka, možda ćete htjeti instalirati bez enkripcije. Na potvrdi formatiranja diska možete pritisnuti `Ctrl + C` da biste se prebacili na instalaciju bez enkripcije.

### Jezik

Omarchy govori 50 jezika — isti skup kao omarchy.org — a engleski je zadani. Za promjenu otvorite izbornik Omarchy i idite na _Postavljanje > Regija > Jezik_ ili u terminalu pokrenite `omarchy language <code>` (`omarchy language list` prikazuje kodove). Izbornik, radna površina i vlastite obavijesti Omarchyja odmah mijenjaju jezik, a slijedi ih i svaka aplikacija koju nakon toga otvorite. Aplikacije koje su već bile otvorene promijenit će se nakon što ih ponovno pokrenete.

Da biste zadržali jezik, ali datume, vremena, brojeve, novac, jedinice i veličine papira pisali onako kako to čini druga regija (recimo engleski s europskim datumima i 24-satnim satom), odaberite regiju pod _Postavljanje > Regija > Formati_, gdje svaki izbor prikazuje uzorak, ili pokrenite `omarchy region <code>` (`omarchy region list` prikazuje kodove). _Isto kao jezik_ vraća na formate samog jezika. Kao i promjena jezika, i ovo se odnosi na aplikacije koje otvorite nakon toga.

### Pomoć ako zapnete

Ako zapnete, obično možete pronaći nekoga tko je voljan pomoći u kanalu _#omarchy-help_ na [Discordu zajednice](https://omarchy.org/discord).
