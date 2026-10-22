# Varnost

Omarchy jemlje varnost izjemno resno. To naj bi bil operacijski sistem, ki ga lahko uporabite za _pravo delo_ v _pravem svetu_. Kjer izguba prenosnika ne more voditi v varnostno izredno stanje. Tukaj je torej, kaj počnemo:

1. *Šifriranje celotnega diska je obvezno*: To je najpomembnejši korak k zavarovanju fizične zaščite vaših podatkov. Če je vaš računalnik izgubljen ali ukraden, so podatki popolnoma šifrirani s standardnim LUKS (Linux Unified Key Setup).
2. *Požarni zid je privzeto omogočen*: Ves dohodni promet je privzeto blokiran, razen vrat 53317 za [LocalSend](https://localsend.org/). Celo ssh je izklopljen, dokler ga ne vklopite prek _Nastavitve > Security > SSHD_, kar odpre vrata 22 (z omejitvijo hitrosti proti napadom s surovo silo) kot del namestitve. Z nastavitvijo [ufw-docker](https://github.com/chaifeng/ufw-docker) celo zaklenemo dostop Docker, da preprečimo, da bi bili vaši vsebniki pomotoma izpostavljeni svetu.
3. *Arch ima vedno najnovejše posodobitve*: Arch, temeljna distribucija, na kateri je zgrajen Omarchy, je sprotna distribucija. To pomeni, da je vsaka varnostna ranljivost, ki je odkrita in popravljena v katerem koli paketu, hitro na voljo za namestitev z `omarchy-update`. Tako vedno uporabljate najnovejše, najbolj varne različice vsega.
4. *Omarchy vzdržuje svoje lastne pakete in zrcalo*: Omarchy se privzeto zanaša le na pakete iz Archovih repozitorijev core/extra/multilib in svojega lastnega repozitorija paketov Omarchy. Programsko opremo lahko namestite neposredno iz AUR, vendar osnovna namestitev tega ne stori — le nekaj izbirnih namestitev, kot so brskalniki tretjih oseb, vleče iz AUR.
5. *Cloudflare nas ščiti pred DDoS*: Vsa infrastruktura distribucije Omarchy — ISO-ji, paketi Omarchy, zrcalo Arch — je zaščitena za mogočnim DDoS ščitom Cloudflare in gostuje na njihovem CDN. To zagotavlja vrhunsko razpoložljivost.

## Spreminjanje vaših gesel

Na šifrirani namestitvi imate dve gesli: tistega, ki ob zagonu odklene pogon, in tistega, s katerim se prijavite in izvajate `sudo`. Namestitev ju naredi enaki. Obe lahko spremenite pod _Posodobi > Password_ v meniju Omarchy — _Drive Encryption_ za prvo, _User_ za drugo. Spreminjanje gesla pogona najprej zahteva trenutnega, zato ga imejte pri roki. Če je sprememba prekinjena, znova zaženite _Drive Encryption_: zahteva geslo, ki pogon odklene zdaj, in dokonča spremembo.

## Predaja računalnika, ki ste ga že uporabljali

Če predajate svoj računalnik nekomu drugemu, ga ni treba znova namestiti. V meniju Omarchy zaženite _Nastavitve > Reset Computer_, vnesite `reset` za potrditev in znova zaženite. To izbriše vsak uporabniški račun in vse v `/home`, zavrže vse pakete in sistemske spremembe, ki ste jih naredili od namestitve, in počisti identiteto računalnika — omrežne povezave, gostiteljske ključe in vse. Kar se vrne, je čarovnik za namestitev od prvega zagona, pripravljen, da njegov novi lastnik vnese svoje ime, geslo in geslo za šifriranje.

Deluje tako, da obnovi temeljni posnetek, ki ga naredi namestitveni program, zato je na voljo samo na računalnikih, nameščenih iz ISO-ja Omarchy. In na pogonu brez šifriranja je ponastavitev brisanje in ne varno brisanje, zato če so bili podatki občutljivi, namesto tega naredite svežo namestitev.

## sudo brez gesla

Včasih želite, da `sudo` neha spraševati, najpogosteje, ko agent AI za vas opravlja dolg odsek sistemskega dela. _Nastavitve > Security > Passwordless Sudo_ vpraša, kako dolgo dovoliti dostop: **15 minutes**, **1 Hour**, **1 Day** ali **Permanently**. Medtem ko je dostop dejaven, se ob drugih kazalnikih v vrstici prikaže rdeča ikona opozorila. Kliknite jo ali znova zaženite ukaz, da dostop izklopite. S `omarchy-sudo-passwordless 30` lahko podate tudi svoje število minut (od 1 do 1440) ali uporabite `omarchy-sudo-passwordless permanent`.

Časovni dostop samodejno poteče, vključno takoj po prebujanju iz Spanja, ki je prestopilo rok. Ponovni zagon računalnika ga konča predčasno. Trajni dostop preživi ponovne zagone in ostane omogočen, dokler ga ne onemogočite.

Posodobitev ali odstranitev paketa z nastavitvami Omarchyja konča vsako začasno dodelitev, preden se njena podpora za potek spremeni. Če ukaz sporoči napako avtorizacije ali čiščenja, jo odpravite, preden poskušate omogočiti drugo dodelitev; napaka ne pomeni, da je dostop brez gesla nedejaven.

Bodite trezne glave glede tega: medtem ko je vklopljeno, lahko vse, kar se izvaja kot vaš uporabnik, naredi kar koli kot root, ne da bi ga vprašali. To je ves smisel in to je tudi vse tveganje.

## Podpisni ključi

Javni ključ za vse podpise ISO in paket repo Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([preverite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` to prav tako vsebuje in bo uporabljen za brezhibno uvajanje morebitnih posodobitev.

Podpis za katero koli izdajo ISO najdete tako, da URL-ju dodate .sig. Kot https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
