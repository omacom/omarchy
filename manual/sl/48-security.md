# Varnost

Omarchy jemlje varnost izjemno resno. To naj bi bil operacijski sistem, ki ga lahko uporabljaš za _resnično delo_ v _resničnem svetu_. Kjer izguba prenosnika ne more povzročiti varnostne krize. Takole torej ravnamo:

1. *Šifriranje celotnega diska je privzeto vklopljeno*: To je najpomembnejši korak za fizično zaščito tvojih podatkov. Če računalnik izgubiš ali ti ga ukradejo, so podatki v celoti šifrirani s standardnim LUKS (Linux Unified Key Setup). Namestitveni program ti omogoča izklop za naprave za enkratno uporabo (glej [Začetek uporabe](02-getting-started.md)); namestitev brez šifriranja te zaščite nima in vsak, ki ima disk, ga lahko prebere.
2. *Požarni zid je privzeto omogočen*: Ves dohodni promet je privzeto blokiran, z nekaj izjemami: vrata 53317 za [LocalSend](https://localsend.org/); poizvedbe DNS do lastnega razločevalnika računalnika na naslovu premostitve Docker (172.17.0.1), sprejete iz zasebnih obsegov naslovov, ki jih Docker dodeli svojim vsebnikom; in večvrstni DNS (vrata 5353), ki tiskalnikom in drugim napravam v tvojem omrežju omogoča, da se med seboj najdejo, tam pa tudi objavi ime tvojega računalnika. Poleg teh požarni zid obdrži standardna dovoljenja UFW za ping, pridobivanje naslova od usmerjevalnika (DHCP) in odkrivanje UPnP. Celo ssh je izklopljen, dokler ga ne vklopiš prek _Nastavitve > Varnost > SSHD_, kar avtorizira tvoj ključ SSH, izklopi prijave z geslom in šele nato odpre vrata 22 (z omejitvijo hitrosti proti napadom s surovo silo). Z namestitvijo [ufw-docker](https://github.com/chaifeng/ufw-docker) celo zaklenemo dostop do Dockerja, da preprečimo, da bi bili tvoji vsebniki po nesreči izpostavljeni svetu.
3. *Arch ima vedno najnovejše posodobitve*: Arch, temeljna distribucija, na kateri je zgrajen Omarchy, je sprotno posodabljana distribucija. To pomeni, da je vsaka varnostna ranljivost, ki je odkrita in popravljena v kateremkoli paketu, hitro na voljo za namestitev z `omarchy-update`. Tako vedno uporabljaš najnovejše, najbolj varne različice vsega.
4. *Omarchy vzdržuje lastne pakete in zrcalo*: Omarchy se privzeto zanaša samo na pakete iz Archovih lastnih repozitorijev core/extra/multilib (na napravah ARM iz repozitorijev Arch Linux ARM, na Apple Silicon pa še Asahi ALARM) in na lastni Omarchy Package Repository. Programsko opremo lahko namestiš neposredno iz AUR, vendar osnovna namestitev tega ne počne — le nekaj izbirnih namestitev, kot so brskalniki tretjih oseb, črpa iz AUR.
5. *Cloudflare nas ščiti pred DDoS*: Distribucijska infrastruktura Omarchy — slike ISO, paketi Omarchy, zrcalo Arch — je zaščitena za mogočnim ščitom Cloudflare proti DDoS in gostuje na njihovem CDN. To zagotavlja vrhunsko razpoložljivost.

## Spreminjanje tvojih gesel

Na šifrirani namestitvi imaš dve gesli: eno, ki ob zagonu odklene disk, in eno, s katerim se prijaviš in uporabljaš `sudo`. Namestitev ju nastavi na isto. Obe lahko spremeniš v meniju Omarchy pod _Posodobitev > Geslo_ — _Šifriranje diska_ za prvo, _Uporabnik_ za drugo. Pri spreminjanju gesla diska moraš najprej vnesti trenutno, zato ga imej pri roki. Če je sprememba prekinjena, znova zaženi _Šifriranje diska_: vpraša po geslu, ki zdaj odklene disk, in dokonča spremembo.

## Predaja naprave, ki si jo že uporabljal

Če napravo predajaš nekomu drugemu, je ni treba znova namestiti. V meniju Omarchy zaženi _Odstrani > Ponastavitev na tovarniške nastavitve_, vtipkaj `reset` za potrditev, vnesi geslo za šifriranje diska, če si k temu pozvan, in znova zaženi. To izbriše vsak uporabniški račun in vse v `/home`, zavrže vse pakete in sistemske spremembe, ki si jih naredil od namestitve, in počisti identiteto naprave — omrežne povezave, gostiteljske ključe in vse. Kar se znova zažene, je čarovnik za namestitev od prvega zagona, pripravljen, da novi lastnik vnese svoje ime, geslo in geslo za šifriranje.

Deluje tako, da obnovi osnovni posnetek, ki ga naredi namestitveni program, zato je na voljo samo na napravah, nameščenih z Omarchy ISO. Na disku brez šifriranja pa je ponastavitev brisanje in ne varno prepisovanje, zato, če so bili podatki občutljivi, raje naredi svežo namestitev.

## Sudo brez gesla

Včasih želiš, da `sudo` neha spraševati, najpogosteje, ko agent z umetno inteligenco zate opravlja daljši sklop sistemskega dela. _Nastavitve > Varnost > Sudo brez gesla_ vpraša, kako dolgo naj bo dostop dovoljen: **15 minut**, **1 ura**, **1 dan** ali **Trajno**. Medtem ko je dostop aktiven, se poleg drugih kazalnikov v menijski vrstici prikaže rdeča opozorilna ikona. Klikni jo ali znova zaženi ukaz, da dostop izklopiš. Svoje število minut (od 1 do 1440) lahko podaš tudi z `omarchy-sudo-passwordless 30` ali uporabiš `omarchy-sudo-passwordless permanent`.

Časovno omejen dostop samodejno poteče, tudi takoj po prebujanju iz stanja pripravljenosti, med katerim je rok potekel. Ponovni zagon računalnika ga konča predčasno. Trajni dostop preživi ponovne zagone in ostane omogočen, dokler ga ne onemogočiš.

Posodobitev ali odstranitev paketa z nastavitvami Omarchy konča vsako začasno dovoljenje, preden se spremeni njegova podpora za potek. Če ukaz sporoči napako pri avtorizaciji ali čiščenju, jo odpravi, preden poskusiš omogočiti drugo dovoljenje; napaka ne pomeni, da dostop brez gesla ni aktiven.

Pri tem imej odprte oči: ko je vklopljeno, lahko vse, kar teče kot tvoj uporabnik, brez vprašanja naredi karkoli kot root. To je celoten smisel, in to je tudi celotno tveganje.

## Ključi za podpisovanje

Javni ključ za vse podpise ISO in pakete repozitorija Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([preveri na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` ga prav tako vsebuje in bo uporabljen za brezšivno uvajanje vseh morebitnih posodobitev.

Podpis za katerokoli izdajo ISO najdeš tako, da njenemu URL dodaš `.sig`, na primer `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
