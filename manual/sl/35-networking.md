# Omrežje

Za omrežje v Omarchyju skrbi NetworkManager, upravljate pa ga prek ikone omrežja v [zgornji vrstici](05-the-top-bar.md) ali s `Super + Ctrl + N`.

Ta plošča poišče omrežja Wi-Fi, prikaže moč signala in se poveže. Pri ethernetu ne potrebujete ničesar — priključite ga in deluje. Če raje ostanete v terminalu, vam `nmtui` nudi enake možnosti upravljanja, na voljo pa je tudi skupina ukazov `omarchy network`.

## Deljenje vašega Wi-Fi-ja

Namesto da na glas berete dolgo geslo, med povezavo z Wi-Fi-jem zaženite _Nastavitev > Omrežje > Koda QR_. To na zaslon postavi kodo QR, ki jo lahko za pridružitev optično prebere katera koli kamera telefona. To je ena tistih stvari, ki jo boste uporabljali pogosteje, kot bi pričakovali, ko enkrat veste, da je tam.

Če dejansko potrebujete samo geslo, ga izpiše `omarchy network password <interface>`.

## DNS

Omarchy uporablja tisti DNS, ki mu ga vaše omrežje dodeli prek DHCP. To lahko preglasite za celoten računalnik pod _Nastavitev > Omrežje > DNS_, kjer sta Cloudflare in Google oddaljena en klik. Izberite _Po meri_, če želite vpisati lastne strežnike.

Iz terminala `omarchy dns` izpiše trenutnega ponudnika, `omarchy dns Cloudflare` pa enega nastavi.

## Pritrditev pasu Wi-Fi

Če vaš usmerjevalnik postavi 2.4GHz, 5GHz in 6GHz pod isto ime omrežja, se bo vaš prenosnik včasih oklepal počasnega. `omarchy network band` pokaže, na katerem pasu ste, `omarchy network band 5` pa ga pritrdi. Uporabite `auto`, da lahko znova izbira sam.

To pritrdi pas in ne določene dostopne točke, zato se normalno še naprej premikate med dostopnimi točkami.

## Kako hitro je?

_Sprožilec > Test hitrosti > Test hitrosti omrežja_ izmeri vašo dejansko hitrost prenosa navzgor in navzdol z dvema številčnicama. Iz terminala je to `omarchy network speedtest down` ali `up`. (V tem meniju je zraven tudi test hitrosti diska, če merite zmogljivost drugega ozkega grla.)

## Požarni zid

Požarni zid je privzeto vklopljen in blokira ves dohodni promet, z eno izjemo: vrata 53317, tako da [LocalSend](22-guis.md) deluje takoj po namestitvi.

SSH je izklopljen, dokler ga ne vklopite z _Nastavitev > Varnost > SSHD_, kar zažene demon, odpre vrata 22 z omejitvijo hitrosti proti napadom s surovo silo in avtorizira ključ. Tudi Docker je zaklenjen, tako da se vsebniki ne morejo pomotoma izpostaviti svetu. Oglejte si [varnost](48-security.md) za celotno zgodbo.

## Tailscale

[Tailscale](https://tailscale.com/) je mrežni VPN, ki poenostavi in varno omogoči doseganje vseh vaših računalnikov in strežnikov prek interneta. Namestite ga z _Namestitev > Storitev > Tailscale_.

To vam da ploščo Tailscale v vrstici, ki povezuje in prekinja povezavo s tailnetom, preklaplja račune in izbere izhodno vozlišče — na seznamu se prikažejo tako vaši računalniki kot regije Mullvad. Prebrska tudi vaše računalnike in tam živi Taildrop: izberite računalnik in pritisnite `s`, da mu pošljete datoteke, ali `c`, `n` in `d`, da kopirate njegov IP, ime ali polno ime DNS. Ekvivalent v terminalu je `omarchy tailscale send <machine> [file...]`, datoteke, poslane vam, pa samodejno pristanejo v `~/Downloads`. Obvestilo, ki napoveduje prihod, počaka, dokler ga ne kliknete, da ga odprete ali opustite, tako da je datoteka, ki prispe, medtem ko vas ni pri računalniku, še vedno tam in čaka na vaš odziv, ko se vrnete.

Namestitev doda tudi spletno aplikacijo za skrbniško konzolo Tailscale.

## Ko preneha delovati

Pred ponovnim zagonom poskusite znova zagnati samo težavni del. _Posodobitev > Strojna oprema_ ima Wi-Fi, Bluetooth, Audio in Trackpad, ponovno nalaganje enega od teh pa odpravi večino situacij "pred petimi minutami je delovalo". Oglejte si [odpravljanje težav](45-troubleshooting.md).
