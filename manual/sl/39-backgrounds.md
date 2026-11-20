# Ozadja

Vsaka tema vključuje svoj nabor ozadij, dodate pa lahko tudi svoja v `~/.config/omarchy/backgrounds/[theme]`. Če želite dodati dodatno sliko ozadja na primer temi nord, preprosto položite datoteko v `~/.config/omarchy/backgrounds/nord`.

To najlažje storite tako, da v meniju Omarchy odprete _Install > Style > Background_. To bo odprlo mapo, v kateri so shranjena ozadja za to temo. Pritisnite `Super + Shift + F`, da zaženete drug upravitelj datotek, poiščite svoje ozadje in ga prekopirajte. Zdaj bo vključeno med ozadja, med katerimi lahko izbirate s `Super + Ctrl + W`.

Ozadja so lahko tudi videoposnetki, ne le statične slike. V isto mapo položite datoteko `mp4`, `m4v`, `mov`, `webm`, `mkv` ali `avi` in prikazala se bo poleg slik. Videoposnetke predvaja pogon za ozadja OWE. Videoposnetek dekodira enkrat za vse monitorje in njegov zvok predvaja prek privzetega zvočnega izhoda, predvajanje pa ustavi, kadar ga nič ne more videti. Video ozadje še vedno porabi precej več energije kot statično.

Teme lahko vključujejo kratek uvod za statično ozadje. Za `backgrounds/road.webp` je ustrezni videoposnetek na `backgrounds/intros/road.mp4`. Predvaja se samodejno ob zagonu, ob preklopu na temo z izbranim tem ozadjem in ob izbiri tega ozadja, nato pa se vrne na statično sliko. Uvodni videoposnetki se ne prikažejo v izbirniku ozadij in se nikoli ne ponavljajo v zanki.

Izklop _Appearance > Animations_ izklopi tudi uvode ozadij. Omarchy to privzeto stori v navideznem stroju. Ukaz `omarchy theme bg intro toggle` lahko uvode preklopi ločeno. Osvežitev teme uvoda ne predvaja.

Statična slika ima lahko tudi zanko, tiho različico iste slike, ki se nenehno premika, na `backgrounds/loops/road.mp4`. Predvaja se namesto statične slike, po njenem uvodu, če ga ima, in se ustavi, ko so animacije izklopljene. Zanke se ne prikažejo v izbirniku ozadij in, kot vsako video ozadje, porabijo več energije kot statična slika.

Ogromno zbirko kul kuriranih ozadij najdete v [dharmx/walls](https://github.com/dharmx/walls).

Zaklenjeni zaslon prikaže statični kader video ozadja, enako kot prikaže statični kader animiranega GIF.
