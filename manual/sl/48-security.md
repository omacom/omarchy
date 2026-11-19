# Varnost

Omarchy jemlje varnost izjemno resno. To naj bo operacijski sistem, ki ga lahko uporabljaš za _pravo delo_ v _pravem svetu_. Kjer izguba prenosnika ne more povzročiti varnostne krize. Tukaj je torej, kaj počnemo:

1. *Šifriranje celotnega diska je privzeto vklopljeno*: To je najpomembnejši korak za fizično zaščito tvojih podatkov. Če računalnik izgubiš ali ti ga ukradejo, so podatki v celoti šifrirani s standardnim LUKS (Linux Unified Key Setup). Namestitveni program ti pri začasnih napravah omogoča, da to izklopiš (glej [Začetek uporabe](02-getting-started.md)); namestitev brez šifriranja te zaščite nima in vsak, ki ima disk, ga lahko prebere.
2. *Požarni zid je privzeto omogočen*: Ves dohodni promet je privzeto blokiran, z nekaj izjemami: vrata 53317 za [LocalSend](https://localsend.org/); poizvedbe DNS do lastnega razreševalnika računalnika na naslovu mostu Docker (172.17.0.1), sprejete iz obsegov zasebnih naslovov, ki jih Docker dodeli svojim vsebnikom; in multicast DNS (vrata 5353), ki tiskalnikom in drugim napravam v tvojem omrežju omogoča, da se med seboj najdejo, in tam tudi objavi ime tvojega računalnika. Poleg teh požarni zid ohranja standardna dovoljenja UFW za ping, pridobivanje naslova od tvojega usmerjevalnika (DHCP) in odkrivanje UPnP. Celo ssh je izklopljen, dokler ga ne vklopiš prek _Setup > Security > SSHD_, kar kot del namestitve odpre vrata 22 (z omejitvijo hitrosti proti napadom z grobo silo). Z nastavitvijo [ufw-docker](https://github.com/chaifeng/ufw-docker) celo zaklenemo dostop Dockerja, da preprečimo, da bi bili tvoji vsebniki po nesreči izpostavljeni svetu.
3. *Arch ima vedno najnovejše posodobitve*: Arch, osnovna distribucija, na kateri je zgrajen Omarchy, je sprotno posodabljana distribucija. To pomeni, da je vsaka odkrita in popravljena varnostna ranljivost v katerem koli paketu hitro na voljo za namestitev z `omarchy-update`. Tako vedno uporabljaš najnovejše, najbolj varne različice vsega.
4. *Omarchy vzdržuje lastne pakete in zrcalo*: Omarchy se privzeto zanaša le na pakete iz Archovih lastnih repozitorijev core/extra/multilib in lastnega repozitorija Omarchy Package Repository. Programsko opremo lahko namestiš neposredno iz AUR, vendar osnovna namestitev tega ne počne — le nekaj izbirnih namestitev, kot so brskalniki tretjih ponudnikov, črpa iz AUR.
5. *Cloudflare nas ščiti pred DDoS*: Distribucijska infrastruktura Omarchyja — ISO-ji, paketi Omarchy in Archovo zrcalo — je zaščitena za mogočnim Cloudflareovim ščitom pred DDoS in gostuje na njihovem CDN. To zagotavlja vrhunsko razpoložljivost.

## Spreminjanje gesel

Pri šifrirani namestitvi imaš dve gesli: eno, ki ob zagonu odklene disk, in eno, s katerim se prijaviš in uporabljaš `sudo`. Začetna namestitev ju nastavi na isto. Obe lahko spremeniš pod _Update > Password_ v meniju Omarchy — _Drive Encryption_ za prvo, _User_ za drugo. Spreminjanje gesla diska najprej zahteva trenutno geslo, zato ga imej pri roki. Če je sprememba prekinjena, znova zaženi _Drive Encryption_: vprašal bo za geslo, ki disk zdaj odklene, in dokončal spremembo.

## Predaja naprave, ki si jo že uporabljal

Če napravo predajaš nekomu drugemu, je ni treba znova namestiti. V meniju Omarchy zaženi _Remove > Factory Reset_, za potrditev vtipkaj `reset` in znova zaženi. To izbriše vsak uporabniški račun in vse v `/home`, zavrže vse pakete in sistemske spremembe, ki si jih naredil od namestitve, ter počisti identiteto naprave — omrežne povezave, gostiteljske ključe, vse. Ob zagonu se vrne čarovnik za namestitev s prvega zagona, pripravljen, da novi lastnik vnese svoje ime, geslo in geslo za šifriranje.

Deluje tako, da obnovi osnovni posnetek, ki ga naredi namestitveni program, zato je na voljo le na napravah, nameščenih z ISO-ja Omarchy. Na disku brez šifriranja pa je ponastavitev brisanje, ne varno brisanje, zato raje naredi svežo namestitev, če so bili podatki občutljivi.

## sudo brez gesla

Včasih želiš, da `sudo` neha spraševati, najpogosteje takrat, ko zate agent z umetno inteligenco opravlja dolg niz sistemskega dela. _Setup > Security > Passwordless Sudo_ vpraša, kako dolgo naj bo dostop dovoljen: **15 minut**, **1 Hour**, **1 Day** ali **Permanently**. Medtem ko je dostop aktiven, se poleg drugih kazalnikov v menijski vrstici prikaže rdeča opozorilna ikona. Klikni jo ali znova zaženi ukaz, da dostop izklopiš. Z `omarchy-sudo-passwordless 30` lahko podaš tudi lastno število minut (od 1 do 1440) ali uporabiš `omarchy-sudo-passwordless permanent`.

Časovno omejen dostop samodejno poteče, tudi takoj po prebujanju iz stanja mirovanja, med katerim je rok potekel. Ponovni zagon računalnika ga konča predčasno. Trajni dostop preživi ponovne zagone in ostane omogočen, dokler ga ne onemogočiš.

Posodobitev ali odstranitev Omarchyjevega paketa z nastavitvami konča vsako začasno dovoljenje, preden se spremeni njegova podpora za potek. Če ukaz javi napako pri avtorizaciji ali čiščenju, jo odpravi, preden poskusiš omogočiti drugo dovoljenje; napaka ne pomeni, da dostop brez gesla ni aktiven.

Pri tem imej odprte oči: dokler je vklopljeno, lahko vse, kar teče kot tvoj uporabnik, brez vprašanja počne vse kot root. To je ves smisel in to je tudi vse tveganje.

## Podpisni ključi

Javni ključ za vse podpise ISO in pakete repozitorija Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([preveri na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` ga prav tako vsebuje in bo uporabljen za brezhibno uvajanje vseh morebitnih posodobitev.

Podpis za katero koli izdajo ISO najdeš tako, da njenemu URL-ju dodaš `.sig`, kot na primer `https://iso.omarchy.org/omarchy-x.x.x.iso.sig`.
