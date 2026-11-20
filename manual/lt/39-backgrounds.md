# Fonai

Kiekviena tema pateikiama su savo fonų rinkiniu, ir galite pridėti savų papildomų į `~/.config/omarchy/backgrounds/[theme]`. Jei norite pridėti papildomą fono paveikslėlį, tarkime, nord temai, tiesiog įdėkite failą į `~/.config/omarchy/backgrounds/nord`.

Lengviausiai tai padarysite nuėję į _Install > Style > Background_ Omarchy Menu. Atsidarys aplankas, kuriame saugomi tos temos fonai. Paspauskite `Super + Shift + F`, kad paleistumėte kitą failų tvarkyklę, raskite savo foną ir nukopijuokite jį ten. Dabar jis bus įtrauktas į fonų, iš kurių galite rinktis naudodami `Super + Ctrl + W`, pasirinkimus.

Fonai gali būti ir vaizdo įrašai, ne tik nejudantys paveikslėliai. Įdėkite `mp4`, `m4v`, `mov`, `webm`, `mkv` arba `avi` failą į tą patį aplanką, ir jis atsiras greta paveikslėlių. Vaizdo įrašus leidžia OWE fono variklis. Jis vieną kartą dekoduoja vaizdo įrašą visiems monitoriams, leidžia jo garsą per numatytąją garso išvestį ir sustabdo atkūrimą, kai niekas negali jo matyti. Vaizdo fonas vis tiek naudoja daug daugiau energijos nei nejudantis.

Temos gali turėti trumpą nejudančio fono įžangą. Failui `backgrounds/road.webp` atitinkamas vaizdo įrašas yra `backgrounds/intros/road.mp4`. Jis automatiškai leidžiamas įkrovos metu, perjungiant į temą su pasirinktu tuo fonu ir renkantis tą foną, o tada grįžtama prie nejudančio paveikslėlio. Įžanginiai vaizdo įrašai nerodomi fono rinkiklyje ir niekada nesikartoja.

Išjungus _Appearance > Animations_ taip pat išjungiamos fono įžangos. Virtualioje mašinoje Omarchy tai daro pagal numatytuosius nustatymus. Komanda `omarchy theme bg intro toggle` gali atskirai perjungti įžangas. Atnaujinant temą įžanga neleidžiama.

Nejudantis paveikslėlis taip pat gali turėti ciklą, ramią to paties paveikslėlio versiją, kuri nuolat juda, adresu `backgrounds/loops/road.mp4`. Jis leidžiamas vietoj nejudančio paveikslėlio, po jo įžangos, jei tokią turi, ir sustoja, kai animacijos išjungiamos. Maitinant iš akumuliatoriaus vietoje jo rodomas nejudantis paveikslėlis, o ciklas sugrįžta vos prijungus maitinimą. Ciklai nerodomi fono rinkiklyje.

Didžiulę šaunių, atrinktų fonų kolekciją rasite [dharmx/walls](https://github.com/dharmx/walls).

Užrakinimo ekranas rodo nejudantį vaizdo fono kadrą, taip pat kaip rodo nejudantį animuoto GIF kadrą.
