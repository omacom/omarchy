# Kako začeti

Omarchy namestite z datoteko ISO. Izbirate lahko med namestitvijo na celoten disk, ki prevzame celoten pogon, ali namestitvijo v prosti prostor, ki Omarchy namesti v nedodeljeni prostor na pogonu — tako ga namestite v dvojni zagon ob sistemu Windows ali drugem operacijskem sistemu (glejte [namestitev z dvojnim zagonom](50-dual-boot-install.md) — upoštevajte, da boste morali v sistemu Windows najprej izklopiti BitLocker). V obeh primerih je namestitev privzeto povsem šifrirana, možnost namestitve na celoten disk pa bo izbrisala izbrani pogon, zato pred uporabo obstoječega pogona obvezno naredite varnostno kopijo!

Najprej [prenesite ISO za Omarchy](https://omarchy.org/), zapišite ga na ključ USB (v sistemu Windows uporabite [Rufus](https://rufus.ie/), na Macu [balenaEtcher](https://etcher.balena.io/) ali v Linuxu [caligula](https://github.com/ifd3f/caligula)) in zaženite računalnik z njega.

_V BIOS-u morate izklopiti Secure Boot in/ali TPM. Izklopiti ju morate, da boste lahko namestili Omarchy. To sta Microsoftovi varnostni shemi, namenjeni sistemu Windows in Microsoftu pridruženim distribucijam Linuxa._

Nato odgovorite na vprašanja o konfiguraciji in jih potrdite takole:

 ![install-config](images/install-config.webp)

Nato izberite pogon za namestitev, se usedite nazaj in opazujte potek namestitve. Na najhitrejših sodobnih računalnikih je lahko končana v manj kot minuti, a niti na starejšem računalniku ne bi smela trajati več kot 5 minut.

 ![install-done](images/install-done.webp)

Zdaj ste pripravljeni na Omarchy!

### Uporabite žično tipkovnico ali tipkovnico z 2.4ghz!

Šifriranje celotnega diska vam ob zagonu ne bo dovolilo vnosa gesla s tipkovnico Bluetooth. Tako kot tipkovnice Bluetooth ne morete uporabiti za vstop v BIOS na osebnem računalniku. Potrebovali boste tipkovnico, ki uporablja sprejemnik 2.4ghz ali kabel (kar je tako ali tako veliko prijetnejše zaradi zakasnitve!). Sam obožujem [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Namestitev za drugega lastnika

Če računalnik pripravljate za nekoga drugega — družinskega člana, novega zaposlenega, kupca — na osebna vprašanja ne bi smeli odgovarjati v njegovem imenu. Na čisto prvem zaslonu namestitvenega programa (izbira tipkovnice) pritisnite `Ctrl + C` in Omarchy bo ponudil, da računalnik namesto tega pripravi za drugega lastnika. Sistem se namesti takoj, vsa osebna nastavitev — razporeditev tipkovnice, uporabniško ime, geslo — pa je odložena do prvega zagona računalnika. Pogon je še vedno privzeto šifriran, geslo, ki ga novi lastnik izbere ob tem prvem zagonu, pa postane tudi geslo za šifriranje. (Računalnik, ki ste ga že uporabljali, lahko predate brez vnovične namestitve — glejte [ponastavitev računalnika](48-security.md).)

### Namestitve brez nadzora

ISO lahko namestitev izvede tudi povsem sam — brez tipkovnice, brez čarovnika — če mu konfiguracijo posredujete na drugem pogonu. Tako Omarchy obravnavate kot osnovno sliko za VM in stroje v voznem parku naprav. Glejte [namestitve brez nadzora](51-unattended-installs.md).

### Namestitve brez šifriranja

Omarchy je privzeto nameščen s šifriranjem. To je varna in odgovorna izbira za vsak računalnik, ki bi ga lahko izgubili ali bi vam ga lahko ukradli. Nočete, da bi kdorkoli z dostopom do vaše strojne opreme lahko prišel do vaših podatkov!

V posebnih okoliščinah, kot so oddaljene namestitve Omarchyja na zaščitenih računalnikih ali namestitve za enkratno uporabo brez občutljivih podatkov, pa boste morda želeli namestitev brez šifriranja. Na potrditvi formatiranja diska lahko pritisnete `Ctrl + C` in preklopite na namestitev brez šifriranja.

### Jezik

Omarchy govori 50 jezikov — isti nabor kot omarchy.org — angleščina pa je privzeti jezik. Za preklop odprite meni Omarchy in pojdite na _Nastavitve > Regija > Jezik_ ali v terminalu zaženite `omarchy language <code>` (`omarchy language list` pokaže kode). Meni, namizje in Omarchyjeva lastna obvestila takoj spremenijo jezik, vsaka aplikacija, ki jo odprete pozneje, pa prav tako sledi. Aplikacije, ki so že odprte, preklopijo, ko jih znova zaženete.

Če želite obdržati jezik, a datume, čase, števila, denar, enote in velikosti papirja zapisovati tako kot v drugi regiji (recimo angleščina z evropskimi datumi in 24-urno uro), izberite regijo pod _Nastavitve > Regija > Oblike_, kjer vsaka izbira pokaže vzorec, ali zaženite `omarchy region formats <code>` (`omarchy region formats list` pokaže kode). _Enako kot jezik_ vas vrne na oblike, ki pripadajo jeziku. Tako kot preklop jezika tudi to doseže aplikacije, ki jih odprete pozneje.

### Pomoč, če obtičite

Če obtičite, lahko v kanalu _#omarchy-help_ na [Discordu skupnosti](https://omarchy.org/discord) običajno najdete nekoga, ki vam je pripravljen pomagati.
