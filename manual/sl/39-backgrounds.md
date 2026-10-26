# Ozadja

Vsaka tema ima svoj nabor ozadij, dodate pa lahko tudi svoja dodatna v `~/.config/omarchy/backgrounds/[theme]`. Če želite dodatno sliko ozadja dodati na primer temi nord, datoteko preprosto položite v `~/.config/omarchy/backgrounds/nord`.

Najlažje to naredite tako, da v meniju Omarchy Menu odprete _Namesti > Slog > Ozadje_. Odpre se mapa, v kateri so shranjena ozadja za to temo. Pritisnite `Super + Shift + F`, da zaženete še en upravljalnik datotek, poiščite svoje ozadje in ga kopirajte tja. Zdaj bo vključeno med ozadja, med katerimi lahko izbirate s `Super + Ctrl + W`.

Ozadja so lahko videoposnetki in tudi mirujoče slike. V isto mapo položite datoteko `mp4`, `m4v`, `mov`, `webm`, `mkv` ali `avi` in pojavila se bo ob slikah. Videoposnetke predvaja pogon za ozadja OWE. Videoposnetek dekodira enkrat za vse zaslone, njegov zvok predvaja prek privzetega zvočnega izhoda in predvajanje ustavi, kadar ga ni mogoče videti. Video ozadje še vedno porabi veliko več energije kot mirujoče ozadje.

Teme lahko vključujejo kratek uvod za mirujoče ozadje. Za `backgrounds/road.webp` je ujemajoči se videoposnetek v `backgrounds/intros/road.mp4`. Samodejno se predvaja ob zagonu in ob preklopu na temo z izbranim tem ozadjem, nato pa se vrne na mirujočo sliko. Uvodni videoposnetki se ne pojavijo v izbirniku ozadij in se nikoli ne predvajajo v zanki.

Izklop možnosti _Videz > Animacije_ izklopi tudi uvode ozadij. Omarchy to privzeto naredi v virtualnem stroju. Ukaz `omarchy theme bg intro toggle` lahko uvode preklopi ločeno. Osvežitev teme ali izbira drugega ozadja znotraj iste teme uvoda ne predvaja.

Ogromno zbirko kul, skrbno izbranih ozadij najdete v repozitoriju [dharmx/walls](https://github.com/dharmx/walls).

Zaklenjeni zaslon prikaže mirujoči okvir video ozadja, tako kot prikaže mirujoči okvir animiranega GIF-a.
