# Fonai

Kiekviena tema pateikiama su savo fonų rinkiniu, o papildomų galite pridėti patys į `~/.config/omarchy/backgrounds/[theme]`. Jei norite pridėti papildomą fono paveikslėlį, tarkim, nord temai, tiesiog įdėkite failą į `~/.config/omarchy/backgrounds/nord`.

Lengviausiai tai padarysite Omarchy meniu pasirinkę _Install > Style > Background_. Tai atvers aplanką, kuriame saugomi tos temos fonai. Paspauskite `Super + Shift + F`, kad paleistumėte kitą failų tvarkyklę, suraskite savo foną ir nukopijuokite jį ten. Dabar jis bus tarp fonų, kuriuos galite rinktis naudodami `Super + Ctrl + W`.

Fonai gali būti ne tik paveikslėliai, bet ir vaizdo įrašai. Įdėkite `mp4`, `m4v`, `mov`, `webm`, `mkv` arba `avi` failą į tą patį aplanką, ir jis atsiras greta paveikslėlių. Vaizdo įrašus leidžia OWE fonų variklis. Jis vieną kartą iškoduoją vaizdo įrašą visiems monitoriams, jo garsą leidžia per numatytąjį garso išvesties įrenginį ir sustabdo atkūrimą, kai jo niekas nemato. Vaizdo fonas vis tiek naudoja daug daugiau energijos nei statinis.

Temos gali turėti trumpą statinio fono įvadą. Failui `backgrounds/road.webp` atitinkamas vaizdo įrašas yra `backgrounds/intros/road.mp4`. Jis automatiškai leidžiamas paleidžiant sistemą, perjungiant į temą, kurioje pasirinktas tas fonas, ir pasirenkant tą foną, o tada grįžtama prie statinio paveikslėlio. Įvadiniai vaizdo įrašai nerodomi fonų pasirinkimo sąraše ir niekada neleidžiami ciklu.

Pasirinkus _Appearance > Animations Off_, taip pat išjungiami fonų įvadai. Omarchy tai pagal numatytuosius nustatymus daro virtualioje mašinoje. Komanda `omarchy theme bg intro toggle` gali atskirai perjungti įvadus. Atnaujinant temą įvadas neleidžiamas.

Statinis paveikslėlis taip pat gali turėti ciklą, ramią to paties paveikslėlio versiją, kuri nuolat juda, faile `backgrounds/loops/road.mp4`. Jis leidžiamas vietoj statinio paveikslėlio, po jo įvado, jei toks yra, ir sustoja, kai išjungiamos animacijos. Veikiant nuo baterijos, vietoj jo rodomas statinis paveikslėlis, o ciklas grįžta, kai tik prijungiate įrenginį prie maitinimo. Ciklai nerodomi fonų pasirinkimo sąraše.

Didelę šaunių, kruopščiai atrinktų fonų kolekciją rasite [dharmx/walls](https://github.com/dharmx/walls).

Užrakto ekrane rodomas statinis vaizdo fono kadras, lygiai taip pat, kaip rodomas statinis animuoto GIF kadras.
