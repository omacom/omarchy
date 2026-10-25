# Ozadja

Vsaka tema je opremljena z lastnim naborom ozadij, svoja dodatna ozadja pa lahko dodaš v `~/.config/omarchy/backgrounds/[theme]`. Če želiš, recimo, temi nord dodati dodatno sliko ozadja, datoteko preprosto odložiš v `~/.config/omarchy/backgrounds/nord`.

Najlažje to narediš tako, da v Omarchy Menu odpreš _Install > Style > Background_. Odprla se bo mapa, v kateri so shranjena ozadja za to temo. Pritisni `Super + Shift + F`, da zaženeš še en upravljalnik datotek, poišči svoje ozadje in ga prekopiraj tja.  Zdaj bo vključeno med ozadja, med katerimi lahko izbiraš s `Super + Ctrl + W`.

Ozadja so lahko videoposnetki in tudi statične slike. V isto mapo odloži datoteko `mp4`, `m4v`, `mov`, `webm`, `mkv` ali `avi` in pojavila se bo poleg slik. Videoposnetke predvaja mehanizem za ozadja OWE. Videoposnetek dekodira enkrat za vse zaslone, njegov zvok predvaja prek privzetega zvočnega izhoda, predvajanje pa ustavi, kadar ga nič ne more videti. Video ozadje še vedno porabi veliko več energije kot statično ozadje.

Teme lahko za statično ozadje vključujejo kratek uvod. Za `backgrounds/road.webp` je pripadajoči videoposnetek na `backgrounds/intros/road.mp4`. Samodejno se predvaja ob zagonu in pri preklopu na temo z izbranim tem ozadjem, nato pa se vrne na statično sliko. Uvodni videoposnetki ostanejo zunaj izbirnika ozadij in se nikoli ne predvajajo v zanki.

Izklop možnosti _Appearance > Animations_ izklopi tudi uvode ozadij. Omarchy to privzeto naredi v navideznem stroju. Z ukazom `omarchy theme bg intro toggle` lahko uvode preklapljaš ločeno. Osvežitev teme ali izbira drugega ozadja znotraj iste teme uvoda ne predvaja.

Ogromno zbirko kul, skrbno izbranih ozadij najdeš na https://github.com/dharmx/walls.

Zaklenjeni zaslon prikaže statični kader video ozadja, enako kot prikaže statični kader animiranega GIF.
