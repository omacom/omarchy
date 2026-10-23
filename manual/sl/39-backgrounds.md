# Ozadja

Vsaka tema prinaša svoj nabor ozadij, svoja dodatna pa lahko dodate v `~/.config/omarchy/backgrounds/[theme]`. Če želite dodati dodatno sliko ozadja, recimo, temi nord, datoteko preprosto postavite v `~/.config/omarchy/backgrounds/nord`.

Najlažje to storite tako, da v meniju Omarchy odprete _Namesti > Slog > Ozadje_. Odpre se mapa, v kateri so shranjena ozadja za to temo. Pritisnite `Super + Shift + F`, da zaženete drug upravitelj datotek, poiščete svoje ozadje in ga kopirate sem. Zdaj bo vključeno med ozadja, med katerimi lahko izbirate s `Super + Ctrl + Space`.

Ozadja so lahko tudi videoposnetki, ne le statične slike. V isto mapo spustite datoteko `mp4`, `m4v`, `mov`, `webm`, `mkv` ali `avi` in prikazala se bo poleg slik. Videoposnetke predvaja mehanizem ozadij OWE. Videoposnetek dekodira enkrat za vse zaslone in njegov zvok predvaja prek privzetega zvočnega izhoda, predvajanje pa ustavi, kadar koli ga nič ne vidi. Zaklepanje zaslona riše isto dekodiranje, nemo, prek OWE. Video ozadje še vedno stane precej več energije kot statično.

Teme lahko vključujejo kratek uvod za statično ozadje. Za `backgrounds/road.webp` ustrezen videoposnetek živi v `backgrounds/intros/road.mp4`. Samodejno se predvaja ob zagonu in pri preklopu na temo s tem izbranim ozadjem, nato se vrne na statično sliko. Uvodni videoposnetki ostanejo zunaj izbirnika ozadij in se nikoli ne predvajajo v zanki.

Izklop _Sproži > Videz > Animacije_ izklopi tudi uvode ozadij. Omarchy to privzeto naredi v navideznem računalniku. Ukaz `omarchy theme bg intro toggle` lahko preklopi uvode posebej. Osveževanje teme ali izbira drugega ozadja znotraj iste teme ne predvaja uvoda.

Ogromno zbirko kul izbranih ozadij najdete na https://github.com/dharmx/walls.

Video ozadja ohranijo predpomnjeno statično sliko na zaklepanju zaslona, medtem ko je predvajanje začasno ustavljeno ali ni na voljo. Animirani GIF-i se predvajajo na namizju in na zaklepanju zaslona prikažejo statično sliko.
