# Začetek uporabe

Omarchy se namesti z uporabo ISO. Izbirate lahko med namestitvijo na celoten disk, ki prevzame celoten pogon, ali namestitvijo v prosti prostor, ki namesti Omarchy v nedodeljeni prostor na pogonu — tako izvedete dvojni zagon poleg Windows ali drugega OS (glejte [namestitev z dvojnim zagonom](50-dual-boot-install.md) — upoštevajte, da boste morali najprej v Windows izklopiti BitLocker). V obeh primerih je namestitev privzeto s popolnim šifriranjem, možnost celotnega diska pa bo izbrisala izbrani pogon, zato pred uporabo obstoječega obvezno naredite varnostno kopijo!

Najprej [prenesite Omarchy ISO](https://omarchy.org/), ga namestite na USB ključek (uporabite [Rufus](https://rufus.ie/) na Windows, [balenaEtcher](https://etcher.balena.io/) na Mac ali [caligula](https://github.com/ifd3f/caligula) na Linux) in se zaženite s ključka.

_V BIOS morate izklopiti Secure Boot in/ali TPM. Za namestitev Omarchy ju morate izklopiti. Gre za Microsoftove varnostne sheme, namenjene Windows in distribucijam Linux, povezanim z Microsoftom._

Nato odgovorite na vprašanja o konfiguraciji in jih potrdite takole:

 ![install-config](images/install-config.webp)

Nato izberite pogon za namestitev, se naslonite nazaj in opazujte predstavo namestitve. Na najhitrejših sodobnih strojih je lahko končana v manj kot minuti, na starejšem računalniku pa ne bi smela trajati več kot 5 minut.

 ![install-done](images/install-done.webp)

Zdaj ste pripravljeni na Omarchy!

### Uporabite žično tipkovnico ali tipkovnico 2.4ghz!

Šifriranje celotnega diska vam ob zagonu ne bo omogočilo vnosa gesla s tipkovnico Bluetooth. Tako kot na PC ne morete uporabiti tipkovnice Bluetooth za vstop v BIOS. Potrebovali boste tipkovnico, ki uporablja sprejemnik 2.4ghz ali kabel (kar je tako ali tako veliko prijetneje zaradi zakasnitve!). Osebno obožujem [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Namestitev za drugega lastnika

Če stroj pripravljate za nekoga drugega — družinskega člana, novega zaposlenega, kupca — ne bi smeli na osebna vprašanja odgovarjati v njihovem imenu. Na čisto prvem zaslonu namestitvenega programa (izbira tipkovnice) pritisnite `Ctrl + C` in Omarchy vam bo namesto tega ponudil, da stroj pripravi za drugega lastnika. Sistem se namesti takoj, vsa osebna nastavitev — razporeditev tipkovnice, uporabniško ime, geslo — pa je odložena do prvega zagona stroja. Pogon je še vedno privzeto šifriran, geslo, ki ga novi lastnik izbere ob tem prvem zagonu, pa postane tudi geslo za šifriranje. (Stroj, ki ste ga že uporabljali, lahko predate tudi brez ponovne namestitve — glejte [ponastavitev računalnika](48-security.md).)

### Nenadzorovane namestitve

ISO se lahko namesti tudi popolnoma sam — brez tipkovnice, brez čarovnika — ko mu posredujete konfiguracijo na drugem pogonu. Tako Omarchy obravnavate kot osnovno podobo za VM in stroje v floti. Glejte [nenadzorovane namestitve](51-unattended-installs.md).

### Namestitve brez šifriranja

Omarchy je privzeto nameščen s šifriranjem. To je varna in odgovorna izbira za vsak računalnik, ki bi ga lahko izgubili ali bi vam ga lahko ukradli. Nočete, da bi lahko kdorkoli z dostopom do vaše strojne opreme prišel do vaših podatkov!

V posebnih okoliščinah, kot so oddaljene namestitve Omarchy na zaščitenih računalnikih ali namestitve za enkratno uporabo brez občutljivih podatkov, pa boste morda želeli namestiti brez šifriranja. Pri potrditvi formatiranja diska lahko pritisnete `Ctrl + C`, da preklopite na namestitev brez šifriranja.

### Jezik

Omarchy govori 50 jezikov — isti nabor kot omarchy.org — angleščina pa je privzeta. Za preklop odprite meni Omarchy in pojdite v _Setup > Region > Language_ ali v terminalu zaženite `omarchy language <code>` (`omarchy language list` prikaže kode). Meni, namizje in lastna obvestila Omarchy takoj zamenjajo jezik, prav tako pa mu sledi vsaka aplikacija, ki jo odprete pozneje. Aplikacije, ki so že bile odprte, se preklopijo, ko jih znova zaženete.

Če želite jezik obdržati, a datume, čase, številke, denar, enote in velikosti papirja zapisovati tako, kot to počne druga regija (recimo angleščino z evropskimi datumi in 24-urno uro), izberite regijo v _Setup > Region > Formats_, kjer vsaka izbira prikaže vzorec, ali zaženite `omarchy region <code>` (`omarchy region list` prikaže kode). _Same as language_ vas vrne na zapise samega jezika. Tako kot preklop jezika velja tudi ta za aplikacije, ki jih odprete pozneje.

### Pomoč, če obtičite

Če obtičite, lahko običajno najdete nekoga, ki vam je pripravljen pomagati, v kanalu _#omarchy-help_ na [Discord skupnosti](https://omarchy.org/discord).
