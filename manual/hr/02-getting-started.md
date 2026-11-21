# Početak rada

Omarchy se instalira pomoću ISO-a. Možete birati između instalacije na cijeli disk, koja preuzima cijeli disk, i instalacije u slobodan prostor, koja Omarchy smješta u nedodijeljeni prostor na disku — tako možete imati dvostruko pokretanje uz Windows ili drugi OS (pogledajte [instalacija s dvostrukim pokretanjem](50-dual-boot-install.md) — napominjemo da ćete najprije morati isključiti BitLocker u Windowsu). U oba slučaja instalacija prema zadanim postavkama uključuje potpuno šifriranje, a opcija cijelog diska izbrisat će odabrani disk, pa svakako napravite sigurnosnu kopiju prije nego što upotrijebite postojeći!

Najprije [preuzmite Omarchy ISO](https://omarchy.org/), stavite ga na USB stick (koristite [Rufus](https://rufus.ie/) na Windowsu, [balenaEtcher](https://etcher.balena.io/) na Macu ili [caligula](https://github.com/ifd3f/caligula) na Linuxu) i pokrenite sustav s njega.

_Morate isključiti Secure Boot i/ili TPM u BIOS-u. Morate ih isključiti da biste mogli instalirati Omarchy. Riječ je o Microsoftovim sigurnosnim shemama namijenjenima Windowsu i distribucijama Linuxa povezanima s Microsoftom._

Zatim odgovorite na konfiguracijska pitanja i potvrdite ih ovako:

 ![install-config](images/install-config.webp)

Zatim odaberite disk za instalaciju, zavalite se i gledajte predstavu instalacije. Na najbržim modernim strojevima može biti gotova za manje od minute, ali ni na starijem računalu ne bi smjela trajati dulje od 5 minuta.

 ![install-done](images/install-done.webp)

Sada ste spremni za Omarchy!

### Koristite žičanu tipkovnicu ili tipkovnicu s 2.4ghz!

Šifriranje cijelog diska neće vam omogućiti unos lozinke s Bluetooth tipkovnice pri pokretanju. Baš kao što Bluetooth tipkovnicu ne možete koristiti ni za ulazak u BIOS na PC-ju. Trebat će vam tipkovnica koja koristi 2.4ghz dongle ili kabel (što je ionako puno ugodnije zbog latencije!). Osobno obožavam [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Instalacija za drugog vlasnika

Ako postavljate stroj za nekoga drugoga — člana obitelji, novog zaposlenika, kupca — ne biste trebali odgovarati na osobna pitanja u njihovo ime. Pritisnite `Ctrl + C` na samom prvom zaslonu instalacijskog programa (odabir tipkovnice) i Omarchy će umjesto toga ponuditi pripremu stroja za drugog vlasnika. Sustav se odmah instalira, ali sva osobna postavka — raspored tipkovnice, korisničko ime, lozinka — odgađa se dok se stroj prvi put ne pokrene. Disk je i dalje prema zadanim postavkama šifriran, a lozinka koju novi vlasnik odabere pri tom prvom pokretanju postaje i lozinka za šifriranje. (Stroj koji ste već koristili također možete predati bez ponovne instalacije — pogledajte [ponovno postavljanje računala](48-security.md).)

### Instalacije bez nadzora

ISO se može i potpuno samostalno instalirati — bez tipkovnice, bez čarobnjaka — kada mu se konfiguracija preda na drugom disku. Tako Omarchy možete tretirati kao osnovnu sliku za VM i flotu strojeva. Pogledajte [instalacije bez nadzora](51-unattended-installs.md).

### Instalacije bez šifriranja

Omarchy se prema zadanim postavkama instalira sa šifriranjem. To je siguran i odgovoran izbor za svako računalo koje se može izgubiti ili biti ukradeno. Ne želite da itko tko ima pristup vašem hardveru može doći do vaših podataka!

Ali u posebnim okolnostima, poput udaljenih instalacija Omarchyja na zaštićenim računalima ili za privremene instalacije bez osjetljivih podataka, možda ćete htjeti instalirati bez šifriranja. Na potvrdi formatiranja diska možete pritisnuti `Ctrl + C` da biste se prebacili na instalaciju bez šifriranja.

### Jezik

Omarchy govori 50 jezika — isti skup kao omarchy.org — a engleski je zadani. Da biste ga promijenili, otvorite izbornik Omarchy i idite na _Postavke > Regija > Jezik_ ili u terminalu pokrenite `omarchy language <code>` (`omarchy language list` prikazuje kodove). Izbornik, radna površina i vlastite obavijesti Omarchyja odmah mijenjaju jezik, a slijedi ga i svaka aplikacija koju poslije otvorite. Aplikacije koje su već otvorene promijenit će se kad ih ponovno pokrenete.

Da biste zadržali jezik, ali datume, vremena, brojeve, novac, jedinice i veličine papira pisali onako kako to čini druga regija (recimo, engleski s europskim datumima i satom od 24 sata), odaberite regiju pod _Postavke > Regija > Formati_, gdje svaki izbor prikazuje uzorak, ili pokrenite `omarchy region formats <code>` (`omarchy region formats list` prikazuje kodove). _Isto kao jezik_ vraća vas na formate samog jezika. Kao i promjena jezika, doseže aplikacije koje poslije otvorite.

### Pomoć ako zapnete

Ako zapnete, obično možete pronaći nekoga tko je voljan pomoći u kanalu _#omarchy-help_ na [Discordu zajednice](https://omarchy.org/discord).
