# Omrežje

Za omrežje v Omarchyju skrbi NetworkManager, upravljate pa ga z ikone omrežja v [zgornji vrstici](05-the-top-bar.md) ali s `Super + Ctrl + N`.

Ta plošča išče omrežja Wi-Fi, prikaže moč signala in se poveže. Ethernet ne potrebuje prav ničesar — priključite ga in deluje. Če raje ostanete v terminalu, vam `nmtui` ponudi iste možnosti upravljanja, na voljo pa je tudi skupina ukazov `omarchy network`.

## Deljenje vašega Wi-Fi

Namesto da dolgo geslo berete na glas, med povezavo Wi-Fi zaženite _Nastavitev > Omrežje > Koda QR_. To na zaslon postavi kodo QR, ki jo lahko za pridružitev optično prebere kamera katerega koli telefona. To je ena tistih stvari, ki jih boste uporabljali pogosteje, kot bi pričakovali, ko boste vedeli, da je tam.

Če dejansko potrebujete samo geslo, ga izpiše `omarchy network password <interface>`.

## DNS

Omarchy uporablja kateri koli DNS, ki mu ga vaše omrežje ponudi prek DHCP. To lahko za celoten računalnik preglasite pod _Nastavitev > Omrežje > DNS_, kjer sta Cloudflare in Google oddaljena le en klik. Izberite _Po meri_, če želite vpisati lastne strežnike.

Iz terminala `omarchy dns` izpiše trenutnega ponudnika, `omarchy dns Cloudflare` pa enega nastavi.

## Pripinjanje pasu Wi-Fi

Če vaš usmerjevalnik pod isto ime omrežja postavi 2.4GHz, 5GHz in 6GHz, se bo vaš prenosnik včasih oklepal počasnega. `omarchy network band` pokaže, na katerem pasu ste, `omarchy network band 5` pa ga pripne. Uporabite `auto`, da spet izbira sam.

S tem pripnete pas in ne določene dostopne točke, zato še naprej običajno gostujete med AP-ji.

## Kako hiter je?

_Sprožilec > Preizkus hitrosti > Preizkus hitrosti omrežja_ meri vašo dejansko hitrost prenosa navzgor in navzdol s parom merilnikov. Iz terminala je to `omarchy network speedtest down` ali `up`. Meri proti lastni storitvi Omarchyja in šteje samo svoje testne prenose. Drugi prenosi lahko tekmujejo za pasovno širino, a niso prišteti k rezultatu preizkusa hitrosti. (V tem meniju je zraven še preizkus hitrosti diska, če merite zmogljivost drugega ozkega grla.)

## Požarni zid

Požarni zid je privzeto vklopljen in blokira ves dohodni promet z eno izjemo: vrata 53317, da [LocalSend](22-guis.md) deluje takoj po namestitvi.

SSH je izklopljen, dokler ga ne vklopite z _Nastavitev > Varnost > SSHD_, kar zažene demon, odpre vrata 22 z omejevanjem hitrosti proti napadom s surovo silo in odobri ključ. Tudi Docker je zaklenjen, zato se vsebniki ne morejo po nesreči izpostaviti svetu. Celotno zgodbo si oglejte v [varnost](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je mrežni VPN, ki poenostavi in varno omogoči doseganje vseh vaših računalnikov in strežnikov prek interneta. Namestite ga z _Namestitev > Storitev > Tailscale_.

To vam v vrstico doda ploščo Tailscale, ki povezuje in prekinja povezavo s tailnetom, preklaplja med računi in izbere izhodno vozlišče — na seznamu se prikažejo tako vaši računalniki kot regije Mullvad. Prebrska tudi vaše računalnike in tam živi Taildrop: izberite računalnik in pritisnite `s`, da mu pošljete datoteke, ali `c`, `n` in `d`, da kopirate njegov IP, ime ali celotno ime DNS. Enakovredno v terminalu je `omarchy tailscale send <machine> [file...]`, datoteke, poslane vam, pa samodejno pristanejo v `~/Downloads`. Obvestilo o prispetju počaka, dokler ga ne kliknete, da ga odprete ali opustite, zato je datoteka, ki prispe, ko vas ni pri računalniku, še vedno tam in čaka na vaš odziv, ko se vrnete.

Namestitev doda tudi spletno aplikacijo za skrbniško konzolo Tailscale.

## Ko neha delovati

Pred ponovnim zagonom poskusite znova zagnati samo povzročitelja težav. _Posodobitev > Strojna oprema_ ima Wi-Fi, Bluetooth, Zvok in Sledilno ploščico, ponovna nalaganje ene od teh možnosti pa odpravi večino situacij »pred petimi minutami je delovalo«. Glejte [odpravljanje težav](45-troubleshooting.md).
