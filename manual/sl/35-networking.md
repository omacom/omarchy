# Omrežje

Omrežje v Omarchyju upravlja NetworkManager, upravljate pa ga prek ikone omrežja v [vrstici](05-the-top-bar.md) ali s `Super + Ctrl + W`.

Ta plošča išče omrežja Wi-Fi, prikazuje moč signala in vzpostavi povezavo. Ethernet ne potrebuje ničesar — priklopite ga in deluje. Če raje ostanete v terminalu, vam `nmtui` ponuja iste kontrolnike, na voljo pa je tudi skupina ukazov `omarchy network`.

## Deljenje vašega Wi-Fi

Namesto da na glas berete dolgo geslo, zaženite _Nastavitve > Omrežje > Koda QR_, medtem ko ste povezani na Wi-Fi. Na zaslonu se prikaže koda QR, ki jo lahko vsaka kamera telefona skenira za pridružitev. To je ena tistih stvari, ki jih boste uporabljali pogosteje, kot bi pričakovali, ko enkrat veste, da je tam.

Če dejansko potrebujete samo geslo, ga `omarchy network password <interface>` izpiše.

## DNS

Omarchy uporablja tisti DNS, ki ga vaše omrežje ponudi prek DHCP. To lahko preglasite za celoten računalnik pod _Nastavitve > Omrežje > DNS_, kjer sta Cloudflare in Google oddaljena le en klik. Izberite _Po meri_ in vnesite svoje strežnike.

Iz terminala `omarchy dns` izpiše trenutnega ponudnika, `omarchy dns Cloudflare` pa enega nastavi.

## Pripnite pas Wi-Fi

Če vaš usmerjevalnik združuje 2,4 GHz, 5 GHz in 6 GHz pod istim imenom omrežja, se bo vaš prenosnik včasih oklenil počasnejšega. `omarchy network band` pokaže, na katerem pasu ste, `omarchy network band 5` pa ga pripne. Uporabite `auto`, da spet izbere sam.

S tem pripnete pas in ne določene dostopne točke, zato se še naprej normalno selite med dostopnimi točkami.

## Kako hitro je?

_Sproži > Preizkus hitrosti > Hitrost omrežja_ izmeri vašo dejansko hitrost prenosa v obe smeri s parom številčnic. Iz terminala je to `omarchy network speedtest down` ali `up`. (V istem meniju je poleg tega tudi preizkus hitrosti diska, če merite drugo ozko grlo.)

## Požarni zid

Požarni zid je privzeto vklopljen in blokira ves dohodni promet, z eno izjemo: vrata 53317, da [LocalSend](22-guis.md) deluje takoj po namestitvi.

SSH je izklopljen, dokler ga ne vklopite z _Nastavitve > Security > SSHD_, kar zažene demon, odpre vrata 22 z omejitvijo hitrosti proti napadom s surovo silo in pooblasti ključ. Tudi Docker je zaklenjen, tako da se vsebniki ne morejo pomotoma izpostaviti svetu. Za celotno zgodbo glejte [varnost](48-security.md).

## Tailscale

[Tailscale](https://tailscale.com/) je mesh VPN, ki poenostavi in zavaruje doseganje vseh vaših računalnikov in strežnikov prek interneta. Namestite ga z _Namesti > Service > Tailscale_.

S tem dobite ploščo Tailscale v vrstici, ki povezuje in prekinja povezavo s tailnetom, preklaplja med računi in izbira izhodno vozlišče — na seznamu se prikažejo tako vaše naprave kot regije Mullvad. Prebrska tudi vaše naprave in tam živi Taildrop: izberite napravo in pritisnite `s`, da ji pošljete datoteke, ali `c`, `n` in `d`, da kopirate njen IP, ime ali polno ime DNS. Ekvivalent v terminalu je `omarchy tailscale send <machine> [file...]`, datoteke, poslane vam, pa samodejno pristanejo v `~/Downloads`. Obvestilo o prihodu počaka, dokler ga ne kliknete ali zaprete, tako da je datoteka, ki prispe, medtem ko vas ni ob računalniku, še vedno tam, ko se vrnete.

Namestitev doda tudi spletno aplikacijo za skrbniško konzolo Tailscale.

## Ko preneha delovati

Pred ponovnim zagonom poskusite znova zagnati samo problematični del. _Posodobi > Hardware_ ima Wi-Fi, Bluetooth, Audio in Sledilna ploščica, ponovno nalaganje enega od teh odpravi večino situacij tipa »pet minut nazaj je delovalo«. Glejte [odpravljanje težav](45-troubleshooting.md).
