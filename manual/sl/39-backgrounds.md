# Ozadja

Vsaka tema ima svoj nabor ozadij, svoja dodatna pa lahko dodate v `~/.config/omarchy/backgrounds/[theme]`. Če želite dodati dodatno sliko ozadja, recimo, temi nord, datoteko preprosto odložite v `~/.config/omarchy/backgrounds/nord`.

To najlažje storite tako, da v meniju Omarchy odprete _Install > Style > Background_. Odprla se bo mapa, v kateri so shranjena ozadja za to temo. Pritisnite `Super + Shift + F`, da zaženete drug upravitelj datotek, poiščete svoje ozadje in ga kopirate tja. Zdaj bo vključeno med ozadja, med katerimi lahko izbirate z `Super + Ctrl + W`.

Ozadja so lahko tudi videoposnetki, ne le statične slike. V isto mapo odložite datoteko `mp4`, `m4v`, `mov`, `webm`, `mkv` ali `avi` in prikazala se bo poleg slik. Videoposnetke predvaja pogon za ozadja OWE. Videoposnetek dekodira enkrat za vse monitorje, njegov zvok predvaja prek privzetega zvočnega izhoda in predvajanje ustavi, kadar ga nič ne more videti. Video ozadje še vedno porabi precej več energije kot statično.

Teme lahko vključujejo kratek uvod za statično ozadje. Za `backgrounds/road.webp` je ustrezni videoposnetek shranjen na `backgrounds/intros/road.mp4`. Samodejno se predvaja ob zagonu, ob preklopu na temo z izbranim tem ozadjem in ob izbiri tega ozadja, nato pa se vrne na statično sliko. Uvodni videoposnetki se ne prikažejo v izbirniku ozadij in se nikoli ne predvajajo v zanki.

Izbira _Appearance > Animations Off_ izklopi tudi uvode ozadij. Omarchy to privzeto stori v VM. Ukaz `omarchy theme bg intro toggle` lahko uvode preklopi ločeno. Osvežitev teme uvoda ne predvaja.

Statična slika ima lahko tudi zanko, tiho različico iste slike, ki se nenehno premika, na `backgrounds/loops/road.mp4`. Predvaja se namesto statične slike, po njenem uvodu, če ga ima, in se ustavi, ko so animacije izklopljene. Na bateriji se namesto tega prikaže statična slika, zanka pa se vrne, ko napravo priključite na napajanje. Zanke se ne prikažejo v izbirniku ozadij.

Ogromno zbirko kul skrbno izbranih ozadij najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zaklenjeni zaslon prikaže statični kader video ozadja, na enak način, kot prikaže statični kader animiranega GIF.
