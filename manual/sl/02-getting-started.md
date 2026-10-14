# Prvi koraki

Omarchy se namesti z ISO. Izberete lahko med namestitvijo na cel disk, ki prevzame celoten pogon, ali namestitvijo v prosti prostor, ki Omarchy namesti v nedodeljeni prostor na pogonu — tako ga lahko poganjate v dvojnem zagonu ob sistemu Windows ali drugem operacijskem sistemu (glejte [namestitev za dvojni zagon](50-dual-boot-install.md) — upoštevajte, da morate v sistemu Windows najprej izklopiti BitLocker). V obeh primerih namestitev privzeto uporabi popolno šifriranje, možnost namestitve na cel disk pa bo izbrisala izbrani pogon, zato pred uporabo obstoječega pogona obvezno naredite varnostno kopijo!

Najprej [prenesite ISO za Omarchy](https://omarchy.org/), ga zapišite na USB ključek (uporabite [balenaEtcher](https://etcher.balena.io/) v Macu/Windows ali [caligula](https://github.com/ifd3f/caligula) v Linuxu) in zaženite računalnik s ključka.

_V BIOS-u morate izklopiti Secure Boot in/ali TPM. Izklopiti ju morate, da lahko namestite Omarchy. Gre za Microsoftova varnostna mehanizma, namenjena sistemu Windows in z Microsoftom povezanim distribucijam Linuxa._

Nato odgovorite na vprašanja o nastavitvah in jih potrdite takole:

 ![install-config](images/install-config.webp)

Nato izberite pogon za namestitev ter se usedite in si oglejte namestitveno predstavo. Na najhitrejših sodobnih računalnikih je lahko končana v manj kot minuti, a tudi na starejšem računalniku ne bi smela trajati več kot 5 minut.

 ![install-done](images/install-done.webp)

Zdaj ste pripravljeni na Omarchy!

### Uporabite žično tipkovnico ali tipkovnico 2.4ghz!

Zaradi šifriranja celotnega diska ob zagonu ne boste mogli vnesti gesla s tipkovnico Bluetooth. Tako kot s tipkovnico Bluetooth v osebnem računalniku ne morete vstopiti v BIOS. Potrebovali boste tipkovnico, ki uporablja sprejemnik 2.4ghz ali kabel (kar je v vsakem primeru veliko boljše za zakasnitev!). Osebno obožujem [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Namestitev za drugega lastnika

Če nastavljate računalnik za nekoga drugega — družinskega člana, novega zaposlenega, kupca — ne bi smeli v njegovem imenu odgovarjati na osebna vprašanja. Na prvem zaslonu namestitvenega programa (izbira tipkovnice) pritisnite `Ctrl + C` in Omarchy vam bo ponudil, da namesto tega računalnik pripravi za drugega lastnika. Sistem se namesti takoj, a vsa osebna nastavitev — razporeditev tipkovnice, uporabniško ime, geslo — je odložena do prvega zagona računalnika. Pogon je še vedno privzeto šifriran, geslo, ki ga novi lastnik izbere ob tem prvem zagonu, pa postane tudi geslo za šifriranje. (Računalnik, ki ste ga že uporabljali, lahko predate tudi brez ponovne namestitve — glejte [ponastavitev računalnika](48-security.md).)

### Nenadzorovane namestitve

ISO se lahko namesti tudi popolnoma sam — brez tipkovnice, brez čarovnika — kadar svojo konfiguracijo dobi na drugem pogonu. Tako lahko Omarchy obravnavate kot osnovno sliko za VM-je in flote računalnikov. Glejte [nenadzorovane namestitve](51-unattended-installs.md).

### Namestitve brez šifriranja

Omarchy se privzeto namesti s šifriranjem. To je varna in odgovorna izbira za vsak računalnik, ki ga je mogoče izgubiti ali ukrasti. Ne želite, da bi lahko kdorkoli z dostopom do vaše strojne opreme prišel do vaših podatkov!

V posebnih okoliščinah, na primer pri oddaljenih namestitvah sistema Omarchy na zaščitene računalnike ali pri začasnih namestitvah brez občutljivih podatkov, pa boste morda želeli namestiti brez šifriranja. Pri potrditvi formatiranja diska lahko pritisnete `Ctrl + C`, da preklopite na namestitev brez šifriranja.

### Jezik

Omarchy govori 50 jezikov — isti nabor kot omarchy.org — privzeta pa je angleščina. Za zamenjavo odprite meni Omarchy in pojdite v _Setup > Language_ ali v terminalu zaženite `omarchy language <code>` (`omarchy language list` pokaže kode). Meni, namizje in obvestila sistema Omarchy zamenjajo jezik takoj, temu pa sledi tudi vsaka aplikacija, ki jo odprete pozneje. Aplikacije, ki so bile že odprte, se zamenjajo, ko jih znova zaženete.

### Pomoč, če se zataknete

Če se zataknete, lahko v kanalu _#omarchy-help_ na [skupnostnem Discordu](https://omarchy.org/discord) običajno najdete nekoga, ki vam je pripravljen pomagati.
