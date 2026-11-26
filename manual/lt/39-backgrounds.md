# Fonai

Kiekviena tema pateikiama su savo fonų rinkiniu, o papildomų galite pridėti patys į `~/.config/omarchy/backgrounds/[theme]`. Jei norite pridėti papildomą fono paveikslėlį, tarkime, nord temai, tiesiog įdėkite failą į `~/.config/omarchy/backgrounds/nord`.

Lengviausiai tai padarysite Omarchy Menu pasirinkę _Install > Style > Background_. Bus atvertas aplankas, kuriame saugomi tos temos fonai. Paspauskite `Super + Shift + F`, kad paleistumėte kitą failų tvarkyklę, susiraskite savo foną ir jį nukopijuokite. Dabar jis bus įtrauktas tarp fonų, kuriuos galite pasirinkti naudodami `Super + Ctrl + W`.

Tema, neturinti savų fonų, gauna vieną, nupieštą iš jos spalvų: Omarchy logotipą temos akcento spalva ant jos fono spalvos. Pridėkite savąjį, kad jį pakeistumėte.

Fonai gali būti ir vaizdo įrašai, ne tik nejudantys vaizdai. Įdėkite `mp4`, `m4v`, `mov`, `webm`, `mkv` arba `avi` failą į tą patį aplanką ir jis atsiras šalia paveikslėlių. Vaizdo įrašus groja OWE wallpaper engine. Jis vaizdo įrašą vieną kartą dekoduoja visiems monitoriams ir jo garsą leidžia per numatytąją garso išvestį, o atkūrimą sustabdo, kai jo niekas nemato. Vaizdo fonas vis tiek naudoja kur kas daugiau energijos negu nejudantis.

Temose gali būti trumpa nejudančio fono įžanga. Fonui `backgrounds/road.webp` skirtas atitinkamas vaizdo įrašas yra `backgrounds/intros/road.mp4`. Jis groja automatiškai įkrovos metu, perjungiant temą su tuo pasirinktu fonu ir renkantis tą foną, o paskui grįžtama prie nejudančio vaizdo. Įžanginiai vaizdo įrašai nerodomi fonų rinkiklyje ir niekada negrojami cikle.

Pasirinkus _Appearance > Animations Off_, taip pat išjungiamos fonų įžangos. Virtualioje mašinoje Omarchy taip daro pagal numatytuosius nustatymus. Komanda `omarchy theme bg intro toggle` įžangas gali perjungti atskirai. Atnaujinant temą, įžanga negrojama.

Nejudantis vaizdas gali turėti ir ciklą – ramią to paties paveikslėlio versiją, kuri nuolat juda, adresu `backgrounds/loops/road.mp4`. Jis grojamas vietoje nejudančio vaizdo, po įžangos, jei tokia yra, ir sustoja išjungus animacijas. Naudojant akumuliatorių, vietoje jo rodomas nejudantis vaizdas, o ciklas sugrįžta, kai vėl prijungiate įrenginį. Ciklai nerodomi fonų rinkiklyje.

Didžiulę šaunių, kruopščiai atrinktų fonų kolekciją galite rasti [dharmx/walls](https://github.com/dharmx/walls).

Užrakto ekranas rodo nejudantį vaizdo fono kadrą, taip pat kaip ir nejudantį animuoto GIF kadrą.
