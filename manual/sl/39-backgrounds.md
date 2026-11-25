# Ozadja

Vsaka tema je dobavljena s svojim naborom ozadij, dodatna pa lahko dodate tudi sami v `~/.config/omarchy/backgrounds/[theme]`. Če želite dodatno sliko ozadja dodati na primer temi nord, datoteko preprosto položite v `~/.config/omarchy/backgrounds/nord`.

To najlažje storite tako, da v meniju Omarchy Menu odprete _Install > Style > Background_. To bo odprlo mapo, v kateri so shranjena ozadja za to temo. Pritisnite `Super + Shift + F`, da zaženete še en upravitelj datotek, poiščite svoje ozadje in ga kopirajte tja. Zdaj bo vključeno med ozadja, med katerimi lahko izbirate s `Super + Ctrl + W`.

Tema brez lastnih ozadij dobi ozadje, narisano iz njenih barv: logotip Omarchy v poudarni barvi teme na njeni barvi ozadja. Dodajte svoje, da ga zamenjate.

Ozadja so lahko tudi videoposnetki, ne le statične slike. V isto mapo položite datoteko `mp4`, `m4v`, `mov`, `webm`, `mkv` ali `avi` in pojavila se bo ob slikah. Videoposnetke predvaja mehanizem za ozadja OWE. Videoposnetek dekodira enkrat za vse monitorje, njegov zvok predvaja prek privzetega zvočnega izhoda in predvajanje ustavi, kadar ga nič ne more videti. Video ozadje še vedno porabi precej več energije kot statično.

Teme lahko vsebujejo kratek uvod za statično ozadje. Za `backgrounds/road.webp` je ustrezen videoposnetek na `backgrounds/intros/road.mp4`. Predvaja se samodejno ob zagonu, ob preklopu na temo z izbranim tem ozadjem in ob izbiri tega ozadja, nato pa se vrne na statično sliko. Uvodni videoposnetki se ne pojavijo v izbirniku ozadij in se nikoli ne predvajajo v zanki.

Izbira _Appearance > Animations Off_ izklopi tudi uvode ozadij. Omarchy to privzeto stori v virtualnem stroju. Z ukazom `omarchy theme bg intro toggle` lahko uvode preklapljate ločeno. Osvežitev teme uvoda ne predvaja.

Statična slika ima lahko tudi zanko, tiho različico iste slike, ki se nenehno premika, na `backgrounds/loops/road.mp4`. Predvaja se namesto statične slike, za njenim uvodom, če ga ima, in se ustavi, ko so animacije izklopljene. Na bateriji se namesto nje pokaže statična slika, zanka pa se vrne, ko priključite napajanje. Zanke se ne pojavijo v izbirniku ozadij.

Ogromno zbirko kul kuriranih ozadij najdete v [dharmx/walls](https://github.com/dharmx/walls).

Na zaklenjenem zaslonu se pokaže statični okvir video ozadja, enako kot se pokaže statični okvir animiranega GIF-a.
