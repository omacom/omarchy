# Varnost

Omarchy jemlje varnost izjemno resno. To naj bi bil operacijski sistem, ki ga lahko uporabljate za _resnično delo_ v _resničnem svetu_. Kjer izguba prenosnika ne more povzročiti varnostne krize. Tukaj je, kaj počnemo:

1. *Popolno šifriranje diska je obvezno*: To je najpomembnejši korak za fizično zaščito vaših podatkov. Če računalnik izgubite ali vam ga ukradejo, so podatki v celoti šifrirani s standardnim LUKS (Linux Unified Key Setup).
2. *Požarni zid je privzeto omogočen*: Ves dohodni promet je privzeto blokiran, razen vrat 53317 za [LocalSend](https://localsend.org/). Tudi ssh je izklopljen, dokler ga ne vklopite prek _Nastavitev > Varnost > SSHD_, kar kot del namestitve odpre vrata 22 (z omejitvijo hitrosti proti napadom z grobo silo). Z nastavitvijo [ufw-docker](https://github.com/chaifeng/ufw-docker) celo zaklenemo dostop Docker, da preprečimo, da bi bili vaši vsebniki pomotoma izpostavljeni svetu.
3. *Arch ima vedno najnovejše posodobitve*: Arch, temeljna distribucija, na kateri je zgrajen Omarchy, je sproti posodabljana distribucija. To pomeni, da je vsaka odkrita in odpravljena varnostna ranljivost v katerem koli paketu hitro na voljo za namestitev z `omarchy-update`. Tako vedno uporabljate najnovejše, najbolj varne različice vsega.
4. *Omarchy vzdržuje lastne pakete in zrcalo*: Omarchy privzeto uporablja samo pakete iz Archovih lastnih skladišč core/extra/multilib in svojega lastnega skladišča paketov Omarchy Package Repository. Programsko opremo lahko namestite neposredno iz AUR, vendar osnovna namestitev tega ne počne — le nekaj izbirnih namestitev, kot so brskalniki tretjih ponudnikov, pakete pridobi iz AUR.
5. *Cloudflare nas ščiti pred DDoS*: Distribucijska infrastruktura Omarchy — ISO-ji, paketi Omarchy, zrcalo Arch — je zaščitena za mogočnim ščitom Cloudflare pred DDoS in gostuje na njihovem CDN. To zagotavlja izvrstno razpoložljivost.

## Spreminjanje gesel

Pri šifrirani namestitvi imate dve gesli: eno, ki ob zagonu odklene pogon, in drugo, s katerim se prijavite in uporabljate `sudo`. Namestitev ju nastavi na isto. Obe lahko spremenite pod _Posodobitev > Geslo_ v meniju Omarchy — _Šifriranje pogona_ za prvo, _Uporabnik_ za drugo. Pri spreminjanju gesla pogona morate najprej vnesti trenutno geslo, zato ga imejte pri roki. Če je sprememba prekinjena, znova zaženite _Šifriranje pogona_: vpraša vas za geslo, ki pogon odklene zdaj, in dokonča spremembo.

## Predaja računalnika, ki ste ga že uporabljali

Če računalnik predajate nekomu drugemu, vam ga ni treba znova namestiti. V meniju Omarchy zaženite _Nastavitev > Ponastavi računalnik_, za potrditev vnesite `reset` in znova zaženite računalnik. To izbriše vsak uporabniški račun in vse v `/home`, zavrže vse pakete in sistemske spremembe, ki ste jih naredili od namestitve, ter počisti identiteto računalnika — omrežne povezave, gostiteljske ključe in vse ostalo. Po ponovnem zagonu se prikaže čarovnik za nastavitev s prvega zagona, pripravljen, da novi lastnik vnese svoje ime, geslo in geslo za šifriranje.

To deluje tako, da obnovi osnovni posnetek, ki ga ustvari namestitveni program, zato je na voljo le na računalnikih, nameščenih z ISO Omarchy. Na pogonu brez šifriranja pa je ponastavitev brisanje in ne varno prepisovanje, zato namesto tega opravite svežo namestitev, če so bili podatki občutljivi.

## Sudo brez gesla

Včasih želite, da `sudo` preneha spraševati, najpogosteje takrat, ko agent umetne inteligence za vas opravlja daljše obdobje sistemskega dela. _Nastavitev > Varnost > Sudo brez gesla_ vas vpraša, kako dolgo želite dovoliti dostop: **15 minut**, **1 ura**, **1 dan** ali **Trajno**. Medtem ko je dostop aktiven, se poleg drugih kazalnikov v menijski vrstici prikaže rdeča opozorilna ikona. Kliknite jo ali znova zaženite ukaz, da dostop izklopite. Svoje število minut (od 1 do 1440) lahko podate tudi z `omarchy-sudo-passwordless 30` ali uporabite `omarchy-sudo-passwordless permanent`.

Časovno omejen dostop samodejno poteče, tudi takoj po nadaljevanju iz zaustavitve, med katero je bil rok presežen. Ponovni zagon računalnika ga predčasno konča. Trajni dostop preživi ponovne zagone in ostane omogočen, dokler ga ne onemogočite.

Posodobitev ali odstranitev paketa z nastavitvami Omarchy konča vsako začasno dovoljenje, preden se spremeni njegova podpora za potek. Če ukaz javi napako pri avtorizaciji ali čiščenju, jo odpravite, preden poskusite omogočiti drugo dovoljenje; napaka ne pomeni, da dostop brez gesla ni aktiven.

Pri tem imejte odprte oči: medtem ko je vklopljen, lahko vse, kar teče pod vašim uporabnikom, brez vprašanja počne vse kot root. To je ves smisel, in to je tudi vse tveganje.

## Podpisni ključi

Javni ključ za vse podpise ISO in pakete skladišča Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([preverite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` ga prav tako vsebuje in bo uporabljen za brezšivno uvajanje vseh morebitnih posodobitev.

Podpis za katero koli izdajo ISO najdete tako, da njenemu URL dodate `.sig`, na primer `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
