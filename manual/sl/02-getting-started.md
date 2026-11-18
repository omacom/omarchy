# Prvi koraki

Omarchy se namesti z ISO-jem. Izberete lahko med namestitvijo na celoten disk, ki prevzame celoten pogon, ali namestitvijo v prosti prostor, ki Omarchy umesti v nedodeljeni prostor na pogonu — tako izvedete dvojni zagon ob Windows ali drugem operacijskem sistemu (glejte [namestitev z dvojnim zagonom](50-dual-boot-install.md) — upoštevajte, da morate v Windows najprej izklopiti BitLocker). V obeh primerih je namestitev privzeto povsem šifrirana, možnost namestitve na celoten disk pa bo izbrisala izbrani pogon, zato pred uporabo obstoječega pogona obvezno naredite varnostno kopijo!

Najprej [prenesite Omarchy ISO](https://omarchy.org/), ga zapišite na USB ključek (v Windows uporabite [Rufus](https://rufus.ie/), na Mac [balenaEtcher](https://etcher.balena.io/) ali na Linux [caligula](https://github.com/ifd3f/caligula)) in se zaženite s ključka.

_V BIOS morate izklopiti Secure Boot in/ali TPM. Če želite namestiti Omarchy, ju morate izklopiti. Gre za Microsoftovi varnostni shemi, namenjeni Windows in z Microsoftom povezanim distribucijam Linux._

Nato odgovorite na vprašanja o konfiguraciji in jih potrdite takole:

 ![install-config](images/install-config.webp)

Nato izberite pogon za namestitev, se udobno namestite in opazujte potek namestitve. Na najhitrejših sodobnih računalnikih je lahko končana v manj kot minuti, a tudi na starejšem računalniku ne bi smela trajati več kot 5 minut.

 ![install-done](images/install-done.webp)

Zdaj ste pripravljeni na Omarchy!

### Uporabite žično tipkovnico ali tipkovnico 2.4ghz!

Šifriranje celotnega diska vam ob zagonu ne bo omogočilo vnosa gesla s tipkovnico Bluetooth. Tako kot tipkovnice Bluetooth ne morete uporabiti za vstop v BIOS na PC. Potrebovali boste tipkovnico, ki uporablja vmesnik 2.4ghz ali kabel (kar je tako ali tako veliko bolje zaradi zakasnitve!). Osebno obožujem [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Namestitev za drugega lastnika

Če računalnik pripravljate za nekoga drugega — družinskega člana, novega zaposlenega, kupca — osebnih vprašanj ne bi smeli izpolnjevati v njegovem imenu. Na prvem zaslonu namestitvenega programa (izbira tipkovnice) pritisnite `Ctrl + C` in Omarchy bo ponudil, da računalnik pripravi za drugega lastnika. Sistem se namesti takoj, vsa osebna nastavitev — razporeditev tipkovnice, uporabniško ime, geslo — pa je odložena do prvega zagona računalnika. Pogon je še vedno privzeto šifriran, geslo, ki ga novi lastnik izbere ob prvem zagonu, pa postane tudi šifrirno geslo. (Računalnik, ki ste ga že uporabljali, lahko predate tudi brez ponovne namestitve — glejte [ponastavitev računalnika](48-security.md).)

### Nenadzorovane namestitve

ISO se lahko namesti tudi povsem samostojno — brez tipkovnice, brez čarovnika — če mu konfiguracijo posredujete na drugem pogonu. Tako Omarchy obravnavate kot osnovno sliko za VM in skupine računalnikov. Glejte [nenadzorovane namestitve](51-unattended-installs.md).

### Namestitve brez šifriranja

Omarchy je privzeto nameščen s šifriranjem. To je varna, odgovorna izbira za vsak računalnik, ki se lahko izgubi ali ga ukradejo. Ne želite, da bi kdorkoli z dostopom do vaše strojne opreme lahko prišel do vaših podatkov!

V posebnih okoliščinah, kot so oddaljene namestitve Omarchy na zaščitenih računalnikih ali namestitve za enkratno uporabo brez občutljivih podatkov, pa boste morda želeli namestitev brez šifriranja. Na potrditvi formatiranja diska lahko pritisnete `Ctrl + C`, da preklopite na namestitev brez šifriranja.

### Jezik

Omarchy govori 50 jezikov — isti nabor kot omarchy.org — privzeti pa je angleščina. Za preklop odprite meni Omarchy in pojdite na _Nastavitve > Jezik_ ali v terminalu zaženite `omarchy language <code>` (`omarchy language list` prikaže kode). Meni, namizje in lastna obvestila Omarchy takoj zamenjajo jezik, vsaka aplikacija, ki jo odprete pozneje, pa prav tako. Aplikacije, ki so že odprte, preklopijo, ko jih znova zaženete.

### Pomoč, če se zataknete

Če se zataknete, lahko običajno najdete nekoga, ki vam je pripravljen pomagati, v kanalu _#omarchy-help_ na [Discord skupnosti](https://omarchy.org/discord).
