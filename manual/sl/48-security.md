# Varnost

Omarchy varnost jemlje izjemno resno. To naj bi bil operacijski sistem, ki ga lahko uporabljate za _Resno delo_ v _Resnem svetu_. Kjer izguba prenosnika ne more privedeti do varnostne krize. Takole torej ravnamo:

1. *Šifriranje celotnega diska je obvezno*: To je najpomembnejši korak k fizični zaščiti vaših podatkov. Če računalnik izgubite ali vam ga ukradejo, so podatki v celoti šifrirani s standardnim LUKS (Linux Unified Key Setup).
2. *Požarni zid je privzeto omogočen*: Ves dohodni promet je privzeto blokiran, razen vrat 53317 za [LocalSend](https://localsend.org/). Tudi ssh je izklopljen, dokler ga ne vklopite prek _Nastavitev > Varnost > SSHD_, kar kot del nastavitve odpre vrata 22 (z omejevanjem hitrosti proti napadom z grobo silo). Celo dostop do Dockerja zaklenemo z namestitvijo [ufw-docker](https://github.com/chaifeng/ufw-docker), da preprečimo, da bi bili vaši vsebniki po nesreči izpostavljeni svetu.
3. *Arch ima vedno najnovejše posodobitve*: Arch, osnovna distribucija, na kateri temelji Omarchy, je sprotno posodobljiva distribucija. To pomeni, da je vsaka varnostna ranljivost, ki je odkrita in popravljena v katerem koli paketu, hitro na voljo za namestitev z `omarchy-update`. Tako vedno uporabljate najnovejše, najbolj varne različice vsega.
4. *Omarchy vzdržuje lastne pakete in zrcalni strežnik*: Omarchy se privzeto zanaša le na pakete iz Archovih lastnih repozitorijev core/extra/multilib in iz lastnega repozitorija paketov Omarchy. Programsko opremo lahko namestite neposredno iz AUR, vendar osnovna namestitev tega ne počne — le nekaj izbirnih namestitev, kot so brskalniki tretjih oseb, črpa iz AUR.
5. *Cloudflare nas ščiti pred DDoS*: Distribucijska infrastruktura Omarchyja — ISO-ji, paketi Omarchy in Archov zrcalni strežnik — je zaščitena za mogočnim Cloudflareovim ščitom pred DDoS in gostuje na njihovem CDN. To zagotavlja odlično razpoložljivost.

## Spreminjanje gesel

Pri šifrirani namestitvi imate dve gesli: eno, ki ob zagonu odklene pogon, in eno, s katerim se prijavite in uporabljate `sudo`. Nastavitev ju določi kot enaki. Obe lahko spremenite pod _Posodobitev > Geslo_ v meniju Omarchy — _Šifriranje diska_ za prvo, _Uporabnik_ za drugo. Pri spreminjanju gesla za pogon morate najprej vnesti trenutno, zato ga imejte pri roki. Če je sprememba prekinjena, znova zaženite _Šifriranje diska_: vpraša vas po geslu, ki pogon zdaj odklene, in dokonča spremembo.

## Predaja računalnika, ki ste ga že uporabljali

Če računalnik predajate nekomu drugemu, vam ga ni treba znova namestiti. Zaženite _Nastavitev > Ponastavi računalnik_ v meniju Omarchy, za potrditev vnesite `reset` in znova zaženite računalnik. To izbriše vsak uporabniški račun in vse v `/home`, zavrže vse pakete in sistemske spremembe, ki ste jih naredili od namestitve, ter počisti identiteto računalnika — omrežne povezave, gostiteljske ključe in vse. Kar se zažene nazaj, je čarovnik za nastavitev s prvega zagona, pripravljen, da novi lastnik vnese svoje ime, geslo in šifrirno geslo.

Deluje tako, da obnovi osnovni posnetek, ki ga ustvari namestitveni program, zato je na voljo le na računalnikih, nameščenih iz ISO-ja Omarchy. Na pogonu brez šifriranja pa je ponastavitev brisanje in ne varno brisanje, zato, če so bili podatki občutljivi, raje izvedite svežo namestitev.

## Sudo brez gesla

Včasih želite, da `sudo` preneha spraševati, najpogosteje takrat, ko AI agent za vas opravlja dolgo sistemsko delo. _Nastavitev > Varnost > Sudo brez gesla_ vas vpraša, kako dolgo naj dovoli dostop: **15 minut**, **1 ura**, **1 dan** ali **Trajno**. Medtem ko je dostop aktiven, se poleg drugih kazalnikov v menijski vrstici prikaže rdeča opozorilna ikona. Kliknite jo ali znova zaženite ukaz, da dostop izklopite. Z `omarchy-sudo-passwordless 30` lahko podate tudi svoje število minut (od 1 do 1440) ali uporabite `omarchy-sudo-passwordless permanent`.

Časovno omejen dostop poteče samodejno, tudi takoj po prebujanju iz zaustavitve, med katero je bil rok presežen. Ponovni zagon računalnika ga konča predčasno. Trajni dostop preživi ponovne zagone in ostane omogočen, dokler ga ne onemogočite.

Posodobitev ali odstranitev paketa z nastavitvami Omarchy konča vsako začasno dovoljenje, preden se spremeni njegova podpora za potek. Če ukaz sporoči napako pri pooblaščanju ali čiščenju, jo odpravite, preden poskusite omogočiti drugo dovoljenje; napaka ne pomeni, da dostop brez gesla ni aktiven.

Pri tem imejte odprte oči: medtem ko je vklopljeno, lahko vse, kar teče kot vaš uporabnik, stori vse kot root, ne da bi bilo vprašano. To je ves smisel in to je tudi vse tveganje.

## Ključi za podpisovanje

Javni ključ za vse podpise ISO in pakete repozitorija Omarchy je `40DFB630FF42BCFFB047046CF0134EE680CAC571` ([preverite na openpgp.org](https://keys.openpgp.org/search?q=pkgs%40omarchy.org)). Paket `omarchy/omarchy-keyring` ga prav tako vsebuje in bo uporabljen za brezhibno uvajanje morebitnih posodobitev.

Podpis za katero koli izdajo ISO najdete tako, da URL-ju dodate .sig. Na primer https://iso.omarchy.org/omarchy-x.x.x.iso.sig.
