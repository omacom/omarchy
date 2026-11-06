# Varnost

Omarchy jemlje varnost izjemno resno. To naj bi bil operacijski sistem, ki ga lahko uporabljate za _Resno Delo_ v _Resničnem Svetu_. Kjer izguba prenosnika ne more voditi v varnostno krizo. Tukaj je, kaj delamo:

1. *Šifriranje celotnega diska je privzeto vklopljeno*: To je najpomembnejši korak za zaščito fizične varnosti vaših podatkov. Če je vaš računalnik izgubljen ali ukraden, so podatki v celoti šifrirani s standardnim LUKS (Linux Unified Key Setup). Namestitveni program vam omogoča izklop za naprave za enkratno uporabo (glejte [Začetek uporabe](02-getting-started.md)); namestitev brez šifriranja nima te zaščite in vsak, ki ima disk, ga lahko prebere.
2. *Požarni zid je privzeto omogočen*: Ves dohodni promet je privzeto blokiran, z nekaj izjemami: vrata 53317 za [LocalSend](https://localsend.org/); poizvedbe DNS do lastnega razreševalnika računalnika na naslovu mostu Docker (172.17.0.1), sprejete iz obsegov zasebnih naslovov, ki jih Docker dodeli svojim vsebnikom; in multicast DNS (vrata 5353), ki tiskalnikom in drugim napravam v vašem omrežju omogoča, da se med seboj najdejo, in tam tudi objavi ime vašega računalnika. Poleg teh požarni zid ohranja standardna dovoljenja UFW za ping, pridobivanje naslova od vašega usmerjevalnika (DHCP) in odkrivanje UPnP. Celo ssh je izklopljen, dokler ga ne vklopite prek _Nastavitev > Varnost > SSHD_, kar kot del nastavitve odpre vrata 22 (z omejitvijo hitrosti proti napadom z grobo silo). Celo dostop do Dockerja zaklenemo z nastavitvijo [ufw-docker](https://github.com/chaifeng/ufw-docker), da preprečimo, da bi bili vaši vsebniki pomotoma izpostavljeni svetu.
3. *Arch ima vedno najnovejše posodobitve*: Arch, osnovna distribucija, na kateri temelji Omarchy, je drseča distribucija. To pomeni, da je vsaka varnostna ranljivost, ki je odkrita in popravljena v katerem koli paketu, hitro na voljo za namestitev z `omarchy-update`. Tako vedno uporabljate najnovejše, najbolj varne različice vsega.
4. *Omarchy vzdržuje lastne pakete in zrcalo*: Omarchy se privzeto zanaša le na pakete iz Archovih lastnih repozitorijev core/extra/multilib in lastnega repozitorija Omarchy Package Repository. Programsko opremo lahko namestite neposredno iz AUR, vendar osnovna namestitev tega ne počne — le nekaj izbirnih namestitev, kot so brskalniki tretjih oseb, črpa iz AUR.
5. *Cloudflare nas ščiti pred DDoS*: Infrastruktura za distribucijo Omarchy — ISO-ji, paketi Omarchy, zrcalo Arch — je zaščitena za mogočnim ščitom DDoS podjetja Cloudflare in gostuje v njihovem CDN. To zagotavlja izvrstno razpoložljivost.

## Spreminjanje gesel

Pri šifrirani namestitvi imate dve gesli: eno, ki ob zagonu odklene disk, in eno, s katerim se prijavite in uporabljate `sudo`. Nastavitev ju nastavi enaki. Obe lahko spremenite pod _Posodobitev > Geslo_ v meniju Omarchy — _Šifriranje diska_ za prvo, _Uporabnik_ za drugo. Spreminjanje gesla diska najprej zahteva trenutno geslo, zato ga imejte pri roki. Če je sprememba prekinjena, znova zaženite _Šifriranje diska_: zahteva geslo, ki zdaj odklene disk, in dokonča spremembo.

## Predaja naprave, ki ste jo že uporabljali

Če svojo napravo predajate nekomu drugemu, je ni treba znova namestiti. Zaženite _Nastavitev > Ponastavi računalnik_ v meniju Omarchy, vnesite `reset` za potrditev in znova zaženite. To izbriše vsak uporabniški račun in vse v `/home`, zavrže vse pakete in sistemske spremembe, ki ste jih naredili od namestitve, ter počisti identiteto naprave — omrežne povezave, gostiteljske ključe in vse. Kar se znova zažene, je čarovnik za nastavitev s prvega zagona, pripravljen, da novi lastnik vnese svoje ime, geslo in geslo za šifriranje.

Deluje tako, da obnovi osnovni posnetek, ki ga naredi namestitveni program, zato je na voljo le na napravah, nameščenih z ISO Omarchy. Na disku brez šifriranja pa je ponastavitev brisanje in ne varno brisanje, zato, če so bili podatki občutljivi, raje opravite svežo namestitev.

## sudo brez gesla

Včasih želite, da `sudo` preneha spraševati, najpogosteje, ko agent UI za vas opravlja daljši sklop sistemskega dela. _Nastavitev > Varnost > sudo brez gesla_ vpraša, kako dolgo dovoliti dostop: **15 minut**, **1 ura**, **1 dan** ali **Trajno**. Rdeča opozorilna ikona se pojavi ob drugih kazalnikih menijske vrstice, medtem ko je dostop aktiven. Kliknite jo ali znova zaženite ukaz, da dostop izklopite. Z `omarchy-sudo-passwordless 30` lahko podate tudi lastno število minut (od 1 do 1440) ali uporabite `omarchy-sudo-passwordless permanent`.

Časovni dostop samodejno poteče, tudi takoj po prebujanju iz stanja mirovanja, ki je prekoračilo rok. Ponovni zagon računalnika ga predčasno konča. Trajni dostop preživi ponovne zagone in ostane omogočen, dokler ga ne onemogočite.

Posodobitev ali odstranitev paketa z nastavitvami Omarchy konča vsako začasno dovoljenje, preden se spremeni njegova podpora za potek. Če ukaz sporoči napako pri avtorizaciji ali čiščenju, jo odpravite, preden poskusite omogočiti drugo dovoljenje; napaka ne pomeni, da dostop brez gesla ni aktiven.

Pri tem imejte odprte oči: medtem ko je vklopljeno, lahko vse, kar teče kot vaš uporabnik, brez vprašanja počne vse kot root. To je ves smisel in to je tudi vse tveganje.

## Podpisni ključi

Javni ključ za vse podpise ISO in pakete repozitorija Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([preverite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` vsebuje tudi ta ključ in bo uporabljen za nemoteno uvajanje morebitnih posodobitev.

Podpis za katero koli izdajo ISO najdete tako, da njenemu URL-ju dodate `.sig`, kot na primer `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
