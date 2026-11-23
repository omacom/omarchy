# Varnost

Omarchy jemlje varnost izjemno resno. To naj bi bil operacijski sistem, ki ga lahko uporabljate za _Resnično delo_ v _Resničnem svetu_. Kjer izguba prenosnika ne more povzročiti varnostnih izrednih razmer. Tukaj je torej, kaj počnemo:

1. *Šifriranje celotnega diska je privzeto vklopljeno*: To je najpomembnejši korak za varovanje fizične zaščite vaših podatkov. Če računalnik izgubite ali vam ga ukradejo, so podatki v celoti šifrirani s standardnim LUKS (Linux Unified Key Setup). Namestitveni program vam omogoča, da se pri napravah za enkratno uporabo od tega odjavite (glejte [Začetek](02-getting-started.md)); namestitev brez šifriranja nima nobene od te zaščite in vsak, ki ima disk, ga lahko prebere.
2. *Požarni zid je privzeto omogočen*: Ves dohodni promet je privzeto blokiran, z nekaj izjemami: vrata 53317 za [LocalSend](https://localsend.org/); poizvedbe DNS do lastnega razreševalnika računalnika na naslovu mostu Docker (172.17.0.1), sprejete iz zasebnih obsegov naslovov, ki jih Docker dodeli svojim vsebnikom; in DNS za večvrstno oddajanje (multicast DNS, vrata 5353), ki tiskalnikom in drugim napravam v vašem omrežju omogoča, da se med seboj najdejo, in tam tudi objavi ime vašega računalnika. Poleg teh požarni zid ohranja standardne dovolitve UFW za ping, pridobivanje naslova od usmerjevalnika (DHCP) in odkrivanje UPnP. Tudi ssh je izklopljen, dokler ga ne vklopite prek _Nastavitev > Varnost > SSHD_, kar odobri vaš ključ SSH, izklopi prijave z geslom in šele nato odpre vrata 22 (z omejitvijo hitrosti proti napadom s surovo silo). Z nastavitvijo [ufw-docker](https://github.com/chaifeng/ufw-docker) celo zaklenemo dostop Docker, da preprečimo, da bi bili vaši vsebniki pomotoma izpostavljeni svetu.
3. *Arch ima vedno najnovejše posodobitve*: Arch, osnovna distribucija, na kateri je zgrajen Omarchy, je sprotna distribucija (rolling distribution). To pomeni, da je vsaka varnostna ranljivost, ki je odkrita in popravljena v katerem koli paketu, hitro na voljo za namestitev z `omarchy-update`. Tako vedno uporabljate najnovejše, najvarnejše različice vsega.
4. *Omarchy vzdržuje lastne pakete in zrcalni strežnik*: Omarchy se privzeto zanaša le na pakete iz Archovih lastnih repozitorijev core/extra/multilib (na napravah ARM iz Arch Linux ARM ter Asahi ALARM na Apple Silicon) in lastnega repozitorija Omarchy Package Repository. Programsko opremo lahko namestite neposredno iz AUR, vendar osnovna namestitev tega ne počne — le nekaj izbirnih namestitev, kot so brskalniki tretjih oseb, črpa iz AUR.
5. *Cloudflare nas ščiti pred DDoS*: Infrastruktura za distribucijo sistema Omarchy — slike ISO, paketi Omarchy, zrcalni strežnik Arch — je zaščitena za mogočnim ščitom Cloudflare proti DDoS in gostuje na njihovem CDN. To zagotavlja vrhunsko razpoložljivost.

## Spreminjanje gesel

Pri šifrirani namestitvi imate dve gesli: eno, ki ob zagonu odklene disk, in eno, s katerim se prijavite in uporabljate `sudo`. Namestitev ju nastavi enaki. _Posodobitev > Geslo_ v meniju Omarchy spremeni obe hkrati, tako da ostaneta enaki: vpraša po trenutnem geslu diska, nato po novem, spremeni geslo diska in nato nastavi vaše prijavno geslo, da se ujema. Brez šifriranja diska spremeni le vaše prijavno geslo. Če je sprememba prekinjena, znova zaženite _Posodobitev > Geslo_: vpraša po geslu, ki zdaj odklene disk, dokonča spremembo in nanj nastavi vaše prijavno geslo. Če želite spremeniti geslo drugega šifriranega diska, v terminalu zaženite `omarchy-drive-password`.

## Predaja naprave, ki ste jo že uporabljali

Če napravo predajate nekomu drugemu, je ni treba znova namestiti. V meniju Omarchy zaženite _Odstrani > Ponastavitev na tovarniške nastavitve_, za potrditev vnesite `reset`, po potrebi vnesite geslo za šifriranje diska in znova zaženite. To izbriše vsak uporabniški račun in vse v `/home`, zavrže vse pakete in sistemske spremembe, ki ste jih naredili od namestitve, in počisti identiteto naprave — omrežne povezave, gostiteljske ključe in vse. Ob ponovnem zagonu se prikaže čarovnik za namestitev s prvega zagona, pripravljen, da novi lastnik vnese svoje ime, geslo in geslo za šifriranje.

Deluje tako, da obnovi osnovni posnetek, ki ga naredi namestitveni program, zato je na voljo le na napravah, nameščenih s slike Omarchy ISO. Na disku brez šifriranja pa je ponastavitev brisanje in ne varno prepisovanje, zato namesto tega naredite svežo namestitev, če so bili podatki občutljivi.

## sudo brez gesla

Včasih želite, da `sudo` preneha spraševati, najpogosteje, ko agent UI za vas opravlja dolg odsek sistemskega dela. _Nastavitev > Varnost > sudo brez gesla_ vpraša, kako dolgo naj bo dostop dovoljen: **15 minut**, **1 ura**, **1 dan** ali **Trajno**. Medtem ko je dostop aktiven, se poleg drugih kazalnikov v menijski vrstici prikaže rdeča opozorilna ikona. Kliknite jo ali znova zaženite ukaz, da dostop izklopite. Z `omarchy-sudo-passwordless 30` lahko podate tudi svoje število minut (od 1 do 1440) ali uporabite `omarchy-sudo-passwordless permanent`.

Časovno omejen dostop samodejno poteče, vključno z neposredno po nadaljevanju iz mirovanja, ki je prekoračilo rok. Ponovni zagon računalnika ga predčasno konča. Trajni dostop preživi ponovne zagone in ostane omogočen, dokler ga ne onemogočite.

Posodobitev ali odstranitev paketa z nastavitvami za Omarchy konča vsako začasno dovoljenje, preden se spremeni njegova podpora za potek. Če ukaz poroča o napaki pri pooblastilu ali čiščenju, jo odpravite, preden poskusite omogočiti drugo dovoljenje; napaka ne pomeni, da je dostop brez gesla neaktiven.

Pri tem bodite trezni: medtem ko je vklopljeno, lahko vse, kar teče kot vaš uporabnik, brez vprašanja naredi vse kot root. To je ves smisel in to je tudi vse tveganje.

## Podpisni ključi

Javni ključ za vse podpise ISO in pakete repozitorija Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([preverite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` ga prav tako vsebuje in bo uporabljen za brezšivno uvajanje morebitnih posodobitev.

Podpis za katero koli izdajo ISO najdete tako, da njenemu URL dodate `.sig`, na primer `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
