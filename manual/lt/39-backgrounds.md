# Fonai

Kiekviena tema pateikiama su savu fonų rinkiniu, o tu gali pridėti papildomų savų į `~/.config/omarchy/backgrounds/[theme]`. Jei nori pridėti papildomą fono paveikslėlį, tarkime, nord temai, tiesiog dedi failą į `~/.config/omarchy/backgrounds/nord`.

Lengviausia tai padaryti Omarchy meniu nuėjus į _Įdiegti > Stilius > Fonas_. Tai atidarys aplanką, kuriame saugomi tos temos fonai. Paspausk `Super + Shift + F`, kad paleistum kitą failų tvarkyklę, rask savo foną ir perkopijuok jį. Dabar jis bus įtrauktas į fonus, tarp kurių gali rinktis naudodamas `Super + Ctrl + Space`.

Fonai gali būti ir vaizdo įrašai, ne tik statiški paveikslėliai. Įmesk `mp4`, `m4v`, `mov`, `webm`, `mkv` arba `avi` failą į tą patį aplanką ir jis atsiras šalia paveikslėlių. Vaizdo įrašus groja OWE fono variklis. Jis dekoduoja vaizdo įrašą kartą visiems monitoriams ir jo garsą groja per numatytąją garso išvestį, o grojimą sustabdo, kai niekas jo negali matyti. Užrakinimo ekranas tą patį dekodavimą piešia nutildytą per OWE. Vaizdo fono energijos sąnaudos vis tiek daug didesnės nei statiško.

Temos statiškam fonui gali turėti trumpą intro. Failui `backgrounds/road.webp` atitinkamas vaizdo įrašas yra `backgrounds/intros/road.mp4`. Jis groja automatiškai įkrovos metu ir persijungiant prie temos su tuo pasirinktu fonu, tada grįžta prie statiško. Intro vaizdo įrašai nelieka fonų parinkiklyje ir niekad nesisuka cikle.

Išjungus _Veiksmai > Išvaizda > Animacijos_ išsijungia ir fonų intro. Omarchy tai virtualioje mašinoje daro pagal numatytuosius. Komanda `omarchy theme bg intro toggle` gali intro perjungti atskirai. Temos atnaujinimas arba kito fono pasirinkimas toje pačioje temoje intro negroja.

Didžiulę kolekciją šaunių atrinktų fonų rasi https://github.com/dharmx/walls.

Vaizdo fonai užrakinimo ekrane laiko talpyklon įdėtą statišką kadrą, kol grojimas pristabdytas arba nepasiekiamas. Animuoji GIF groja darbalaukyje, o užrakinimo ekrane rodo statišką kadrą.
