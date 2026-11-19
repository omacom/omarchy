# Fonai

Kiekviena tema pateikiama su savo fonų rinkiniu, o savų papildomų galite pridėti į `~/.config/omarchy/backgrounds/[theme]`. Jei norite pridėti papildomą fono paveikslėlį, tarkim, nord temai, tiesiog įdėkite failą į `~/.config/omarchy/backgrounds/nord`.

Lengviausia tai padaryti Omarchy meniu nuėjus į _Diegimas > Stilius > Fonas_. Bus atidarytas aplankas, kuriame saugomi tos temos fonai. Paspauskite `Super + Shift + F`, kad paleistumėte kitą failų tvarkyklę, suraskite savo foną ir jį nukopijuokite. Dabar jis bus įtrauktas į fonus, iš kurių galite rinktis naudodami `Super + Ctrl + W`.

Fonai gali būti ne tik nejudantys paveikslėliai, bet ir vaizdo įrašai. Į tą patį aplanką įdėkite `mp4`, `m4v`, `mov`, `webm`, `mkv` arba `avi` failą ir jis atsiras greta paveikslėlių. Vaizdo įrašus leidžia OWE wallpaper engine. Jis vieną kartą išdekoduoja vaizdo įrašą visiems monitoriams ir leidžia jo garsą per numatytąją garso išvestį, o atkūrimą sustabdo, kai niekas jo nemato. Vaizdo fonas vis tiek eikvoja gerokai daugiau energijos nei nejudantis.

Temose nejudančiam fonui gali būti numatyta trumpa įžanga. `backgrounds/road.webp` atveju atitinkamas vaizdo įrašas yra `backgrounds/intros/road.mp4`. Jis automatiškai leidžiamas paleidžiant sistemą, perjungiant į temą su pasirinktu tuo fonu ir pasirinkus tą foną, o paskui grįžtama prie nejudančio paveikslėlio. Įžangos vaizdo įrašai nerodomi fonų pasirinkime ir niekada nesikartoja.

Išjungus _Išvaizda > Animacijos_, taip pat išjungiamos fonų įžangos. Omarchy tai pagal numatytuosius nustatymus daro virtualioje mašinoje. Komanda `omarchy theme bg intro toggle` įžangas leidžia perjungti atskirai. Atnaujinant temą įžanga neleidžiama.

Nejudantis paveikslėlis taip pat gali turėti ciklą – ramią to paties paveikslėlio versiją, kuri nuolat juda, esančią `backgrounds/loops/road.mp4`. Ji leidžiama nejudančio paveikslėlio vietoje, po jo įžangos, jei tokią turi, ir sustabdoma išjungus animacijas. Ciklai nerodomi fonų pasirinkime ir, kaip ir bet kuris vaizdo fonas, eikvoja daugiau energijos nei nejudantis paveikslėlis.

Didžiulę kruopščiai atrinktų šaunių fonų kolekciją rasite [dharmx/walls](https://github.com/dharmx/walls).

Užrakto ekranas rodo nejudantį vaizdo fono kadrą, kaip ir nejudantį animuoto GIF kadrą.
