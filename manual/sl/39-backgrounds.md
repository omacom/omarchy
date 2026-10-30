# Ozadja

Vsaka tema ima svoj nabor ozadij, svoja dodatna pa lahko dodate v `~/.config/omarchy/backgrounds/[theme]`. Če želite dodati dodatno sliko ozadja, recimo, temi nord, datoteko preprosto položite v `~/.config/omarchy/backgrounds/nord`.

To najlažje storite tako, da v meniju Omarchy odprete _Install > Style > Background_. Odprla se bo mapa, v kateri so shranjena ozadja za to temo. Pritisnite `Super + Shift + F`, da zaženete še en upravitelj datotek, poiščite svoje ozadje in ga prekopirajte tja. Zdaj bo vključeno med ozadja, med katerimi lahko izbirate z `Super + Ctrl + W`.

Ozadja so lahko tudi videoposnetki, ne le statične slike. V isto mapo odložite datoteko `mp4`, `m4v`, `mov`, `webm`, `mkv` ali `avi` in prikazala se bo poleg slik. Videoposnetke predvaja pogon za ozadja OWE. Videoposnetek dekodira enkrat za vse zaslone, njegov zvok predvaja prek privzetega zvočnega izhoda, predvajanje pa ustavi, kadar ga ni mogoče videti. Video ozadje še vedno porabi precej več energije kot statično.

Teme lahko vključujejo kratek uvod za statično ozadje. Za `backgrounds/road.webp` je pripadajoči videoposnetek shranjen na `backgrounds/intros/road.mp4`. Predvaja se samodejno ob zagonu, ob preklopu na temo s tem izbranim ozadjem in ob izbiri tega ozadja, nato pa se vrne na statično ozadje. Uvodni videoposnetki se ne prikažejo v izbirniku ozadij in se nikoli ne ponavljajo v zanki.

Izklop možnosti _Appearance > Animations_ izklopi tudi uvode ozadij. Omarchy to privzeto stori v navideznem stroju. Z ukazom `omarchy theme bg intro toggle` lahko uvode preklapljate ločeno. Osvežitev teme uvoda ne predvaja.

Ogromno zbirko kul skrbno izbranih ozadij najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zaklenjeni zaslon prikaže statični kader video ozadja, enako kot prikaže statični kader animiranega GIF-a.
