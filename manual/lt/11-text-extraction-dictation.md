# Teksto išgavimas ir diktavimas

### Teksto išgavimas

Paspauskite `Super + Ctrl + PrtScr`, kad pasirinktumėte ekrano sritį teksto išgavimui. Tada atvirojo kodo OCR modelis tesseract greitai pavers tą pasirinkimą tekstu ir įdės jį į iškarpinę. Tada tereikia paspausti `Super + V` ir įklijuoti.

Tai labai naudinga norint nukopijuoti adresus iš paveikslėlių poraščių ar telefono numerius, įterptus į svetainių antraštes.

 ![text-extraction](images/text-extraction.webp)

### Diktavimas

Naujai įdiegtoje sistemoje [Superwhisper](https://superwhisper.com/) yra numatytoji diktavimo posistemė, naudojanti apdorojimą debesyje be neprisijungus veikiančių modelių atsisiuntimų. Pasirinkite Superwhisper arba [Voxtype](https://voxtype.io/) per _Setup > Defaults > Dictation_ Omarchy meniu. Pasirinkus posistemę, ji prireikus įdiegiama ir tampa numatytąja diktavimui. Voxtype įkelia bazinį anglų kalbos modelį, kuris užima 150MB; modelį pakeiskite su `voxtype setup model`, o kitus nustatymus — per `~/.config/voxtype/config.toml`. Superwhisper atidaro savo nustatymus, kad pasirinktumėte apdorojimą debesyje arba vietoje, o OPR nuolat atnaujina programą.

Diktuojate laikydami nuspaudę `Right Alt` arba perjungdami su `Alt + Space`, ir padiktuotas tekstas atsiras fokusuotoje įvesties srityje. Šie spartieji klavišai naudoja pasirinktą posistemę. Right Alt taip pat paleidžia diktavimą, kai naudojamas modifikatoriaus derinyje; tiems deriniams naudokite Left Alt. Klaviatūros išdėstymuose, kuriuose Right Alt yra AltGr, naudokite `Alt + Space`, kad AltGr liktų prieinamas rašyti. Įdiegimai, atlikti prieš tai, kai Alt + Space tapo numatytuoju, išlaiko `F9` kalbėjimui laikant nuspaudus ir `Super + Ctrl + X` perjungimui, pridėtus į `~/.config/hypr/bindings.lua`; pašalinkite juos ten, kad grąžintumėte tuos klavišus programoms.

Tie patys spartieji klavišai veikia su bet kuria posisteme. Pasirinkite savo posistemę per Setup > Defaults > Dictation. Posistemės diegimo programa ją sukonfigūruoja ir išsaugo pasirinkimą. Paleiskite `omarchy default dictation`, kad pamatytumėte, kuri pasirinkta. Pasirinkimas išsaugomas `~/.config/omarchy/defaults/dictation`. Naujai įdiegtoje sistemoje Superwhisper pasirenkama automatiškai.

Omarchy automatiškai įkelia pasirinktos posistemės darbalaukio integraciją. Jokios Superwhisper konfigūracijos `~/.config/hypr/` nereikia.

Pasirinktiniai susiejimai ir scenarijai gali naudoti `omarchy dictation start`, `omarchy dictation stop` ir `omarchy dictation toggle`. Pasirinkta posistemė tvarko įrašymą ir transkripciją. Pasirinkus Superwhisper, išjungiamas jos savasis laikymo spartusis klavišas ir nustatomas jos savasis perjungimas į `Ctrl + Alt + Space`, atskiriant jį nuo Omarchy įrašymo klavišų. Superwhisper reikalauja bent vieno savojo įrašymo sparčiojo klavišo, o jos atšaukimo spartusis klavišas lieka prieinamas.

Papildomos posistemės gali integruotis nekeičiant Omarchy. Pateikite vykdomąjį failą pavadinimu `omarchy-dictation-<backend>` PATH, kuris priima `start`, `stop` ir `toggle` ir greitai grįžta, o gedimo atveju grąžina nenulinę būseną. Jo diegimo programa sukonfigūruoja teikėją ir po sėkmingo nustatymo iškviečia `omarchy-dictation-use <backend>`. Tai sustabdo ankstesnę posistemę ir atomiškai išsaugo pasirinkimą; `stop` turi sėkmingai veikti, kai teikėjas yra nenaudojamas arba neprieinamas. Posistemių pavadinimuose naudojamos mažosios raidės, skaitmenys ir brūkšneliai. Nustatymui pateikite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` jį paleidžia. Pridėkite Defaults meniu įrašą per Omarchy meniu plėtinį, kad iškviestumėte tą parinkiklį. Pasirinktinė darbalaukio integracija gali būti `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
