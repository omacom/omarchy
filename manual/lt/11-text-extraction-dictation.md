# Teksto išgavimas ir diktavimas

### Teksto išgavimas

Paspauskite `Super + Ctrl + PrtScr`, kad pasirinktumėte ekrano sritį teksto išgavimui. Atvirojo kodo OCR modelis tesseract tada greitai pavers tą pasirinkimą tekstu ir įdės jį į iškarpinę. Tada tereikia paspausti `Super + V`, kad įklijuotumėte.

Tai labai padeda ištraukiant adresus iš vaizdų poraščių ar telefono numerius, įterptus į svetainių antraštes.

 ![text-extraction](images/text-extraction.webp)

### Diktavimas

Naujai įdiegtose sistemose [Superwhisper](https://superwhisper.com/) yra numatytoji diktavimo posistemė, naudojanti debesies apdorojimą be neprisijungus naudojamų modelių atsisiuntimų. Pasirinkite Superwhisper, [Voxtype](https://voxtype.io/) arba [Hex](https://anoma.ly/hex/) per _Setup > Defaults > Dictation_ Omarchy meniu. Pasirinkus posistemę, ji, jei reikia, įdiegiama ir tampa numatytąja diktavimui. Voxtype įkelia bazinį anglų kalbos modelį, kuris užima 150MB; pakeiskite modelį su `voxtype setup model`, o kitus nustatymus — per `~/.config/voxtype/config.toml`. Superwhisper atidaro savo nustatymus, kad pasirinktumėte debesies arba vietinį apdorojimą, o OPR palaiko programą atnaujintą. Hex sąrankos metu atsisiunčia savo kalbos modelį įrenginyje ir veikia kaip `hex.service` naudotojo paslauga; atidarykite jo langą iš juostos dėklo piktogramos arba paleisdami `hex`, kad pakeistumėte modelį ir kitus nustatymus.

Diktuojate laikydami nuspaudę `Right Alt` arba perjungdami su `Alt + Space`, ir padiktuotas tekstas atsiras sufokusuotoje įvesties srityje. Šie spartieji klavišai naudoja pasirinktą posistemę. Right Alt taip pat paleidžia diktavimą, kai naudojamas modifikatoriaus derinyje; tiems deriniams naudokite Left Alt. Klaviatūros išdėstymuose, kuriuose Right Alt yra AltGr, naudokite `Alt + Space`, kad AltGr liktų prieinamas rašymui. Įdiegtys iš laikotarpio, kol Alt + Space tapo numatytuoju, išlaiko `F9` kalbėjimui laikant nuspaudus ir `Super + Ctrl + X` perjungimui, pridėtus prie `~/.config/hypr/bindings.lua`; pašalinkite juos ten, kad grąžintumėte tuos klavišus programoms.

Tie patys spartieji klavišai veikia su kiekviena posisteme. Pasirinkite posistemę per Setup > Defaults > Dictation. Posistemės diegimo programa ją sukonfigūruoja ir įrašo pasirinkimą. Paleiskite `omarchy default dictation`, kad pamatytumėte, kuri pasirinkta. Pasirinkimas įrašomas į `~/.config/omarchy/defaults/dictation`. Naujai įdiegtose sistemose Superwhisper pasirenkamas automatiškai.

Omarchy automatiškai įkelia pasirinktos posistemės darbalaukio integraciją. Jokios Superwhisper konfigūracijos `~/.config/hypr/` nereikia.

Pasirinktiniai susiejimai ir scenarijai gali naudoti `omarchy dictation start`, `omarchy dictation stop` ir `omarchy dictation toggle`. Pasirinkta posistemė tvarko įrašymą ir transkripciją. Pasirinkus Superwhisper, išjungiamas jo savasis laikymo spartusis klavišas ir jo savasis perjungimas nustatomas į `Ctrl + Alt + Space`, taip jį atskiriant nuo Omarchy įrašymo klavišų. Superwhisper reikia bent vieno sovojo įrašymo sparčiojo klavišo, o jo atšaukimo spartusis klavišas lieka prieinamas.

Papildomos posistemės gali integruotis nekeičiant Omarchy. Pateikite vykdomąjį failą pavadinimu `omarchy-dictation-<backend>` PATH, kuris priima `start`, `stop` ir `toggle` ir greitai baigia darbą, o nepavykus grąžina nenulinę būseną. Jo diegimo programa sukonfigūruoja teikėją ir po sėkmingos sąrankos iškviečia `omarchy-dictation-use <backend>`. Tai sustabdo ankstesnę posistemę ir atomiškai įrašo pasirinkimą; `stop` turi sėkmingai baigtis, kai teikėjas yra nenaudojamas arba neprieinamas. Posistemių pavadinimuose naudojamos mažosios raidės, skaitmenys ir brūkšneliai. Sąrankai pateikite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` jį paleidžia. Pridėkite Defaults meniu įrašą per Omarchy meniu plėtinį, kad iškviestumėte tą pasirinkiklį. Pasirinktinė darbalaukio integracija gali būti `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
