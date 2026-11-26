# Začetek

Omarchy namestite z datoteko ISO. Izbirate lahko med namestitvijo na celoten disk, ki prevzame celoten pogon, ali namestitvijo v prosti prostor, ki Omarchy namesti v nedodeljeni prostor na pogonu — tako ga zaganjate v dvojnem zagonu poleg sistema Windows ali drugega operacijskega sistema (glejte [namestitev z dvojnim zagonom](50-dual-boot-install.md) — upoštevajte, da boste morali v sistemu Windows najprej izklopiti BitLocker). V obeh primerih je namestitev privzeto s popolnim šifriranjem, možnost namestitve na celoten disk pa bo izbrisala izbrani pogon, zato pred uporabo obstoječega pogona obvezno naredite varnostno kopijo!

Na računalniku Mac z Apple Silicon namestitev namesto tega izvedete iz sistema macOS, brez datoteke ISO ali ključka USB. Glejte [Omarchy za Apple Silicon](44-mac-support.md#omarchy-for-apple-silicon).

Najprej [prenesite datoteko ISO za Omarchy](https://omarchy.org/), jo namestite na ključek USB (v sistemu Windows uporabite [Rufus](https://rufus.ie/), na računalniku Mac [balenaEtcher](https://etcher.balena.io/) ali v sistemu Linux [caligula](https://github.com/ifd3f/caligula)) in zaženite računalnik z njega.

_V BIOS-u morate izklopiti Secure Boot in/ali TPM. Za namestitev sistema Omarchy ju morate izklopiti. Gre za Microsoftovi varnostni shemi, namenjeni sistemu Windows in z Microsoftom povezanim distribucijam Linuxa._

Nato odgovorite na vprašanja o konfiguraciji in jih potrdite takole:

 ![install-config](images/install-config.webp)

Nato izberite pogon za namestitev, se naslonite nazaj in opazujte predstavo namestitve. Na najhitrejših sodobnih računalnikih je lahko končana v manj kot minuti, a tudi na starejšem računalniku ne bi smela trajati več kot 5 minut.

 ![install-done](images/install-done.webp)

Zdaj ste pripravljeni na Omarchy!

### Uporabite žično tipkovnico ali tipkovnico 2.4ghz!

Šifriranje celotnega diska vam ob zagonu ne bo omogočilo vnosa gesla s tipkovnico Bluetooth. Tako kot tipkovnice Bluetooth ne morete uporabiti za vstop v BIOS na osebnem računalniku. Potrebovali boste tipkovnico, ki uporablja sprejemnik 2.4ghz ali kabel (kar je glede zakasnitve tako ali tako veliko prijetneje!). Meni osebno je zelo všeč [Lofree Flow84](https://www.lofree.co/products/lofree-flow-the-smoothest-mechanical-keyboard)!

### Namestitev za drugega lastnika

Če računalnik pripravljate za nekoga drugega — družinskega člana, novega zaposlenega, kupca — na osebna vprašanja ne bi smeli odgovarjati v njegovem imenu. Na prvem zaslonu namestitvenega programa (izbira tipkovnice) pritisnite `Ctrl + C` in Omarchy bo namesto tega ponudil pripravo računalnika za drugega lastnika. Sistem se namesti takoj, vsa osebna nastavitev — razporeditev tipkovnice, uporabniško ime, geslo — pa je preložena, dokler se računalnik prvič ne zažene. Pogon je še vedno privzeto šifriran, geslo, ki ga novi lastnik izbere ob tem prvem zagonu, pa postane tudi geslo za šifriranje. (Računalnik, ki ste ga že uporabljali, lahko predate tudi brez ponovne namestitve — glejte [ponastavitev računalnika](48-security.md).)

### Nenadzorovane namestitve

Datoteka ISO lahko namestitev opravi tudi povsem sama — brez tipkovnice, brez čarovnika — če ji konfiguracijo podate na drugem pogonu. Tako Omarchy obravnavate kot osnovno sliko za VM in skupine računalnikov. Glejte [nenadzorovane namestitve](51-unattended-installs.md).

### Namestitve brez šifriranja

Omarchy je privzeto nameščen s šifriranjem. To je varna in odgovorna izbira za vsak računalnik, ki ga lahko izgubite ali vam ga ukradejo. Nočete, da bi lahko kdorkoli z dostopom do vaše strojne opreme prišel do vaših podatkov!

V posebnih okoliščinah, na primer pri oddaljenih namestitvah sistema Omarchy na zaščitenih računalnikih ali pri namestitvah za enkratno uporabo brez občutljivih podatkov, pa boste morda želeli namestiti brez šifriranja. Na potrditvi formatiranja diska lahko pritisnete `Ctrl + C` in preklopite na namestitev brez šifriranja.

### Jezik

Omarchy govori 50 jezikov — isti nabor kot omarchy.org — privzeta pa je angleščina. Za preklop odprite meni Omarchy in pojdite na _Setup > Region > Language_ ali v terminalu zaženite `omarchy language <code>` (`omarchy language list` prikaže kode). Meni, namizje in lastna obvestila sistema Omarchy takoj spremenijo jezik, temu pa sledi tudi vsaka aplikacija, ki jo odprete pozneje. Aplikacije, ki so bile že odprte, preklopijo, ko jih znova zaženete.

Če želite obdržati jezik, a datume, čase, številke, denar, enote in velikosti papirja zapisovati tako, kot to počne druga regija (recimo angleščina z evropskimi datumi in 24-urno uro), izberite regijo v _Setup > Region > Formats_, kjer je ob vsaki izbiri prikazan vzorec, ali zaženite `omarchy region formats <code>` (`omarchy region formats list` prikaže kode). _Same as language_ vas vrne na formate jezika samega. Tako kot preklop jezika doseže aplikacije, ki jih odprete pozneje.

### Pomoč, če obtičite

Če obtičite, običajno najdete nekoga, ki vam je pripravljen pomagati, na kanalu _#omarchy-help_ na [Discord skupnosti](https://omarchy.org/discord).
