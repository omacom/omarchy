# Teksto išgavimas ir diktavimas

### Teksto išgavimas

Paspauskite `Super + Ctrl + PrtScr`, kad pasirinktumėte ekrano sritį teksto išgavimui. Atvirojo kodo OCR modelis tesseract tada greitai pavers tą pasirinkimą tekstu ir įdės jį į iškarpinę. Tuomet tiesiog paspauskite `Super + V`, kad įklijuotumėte.

Tai labai praverčia ištraukiant adresus iš paveikslėlių poraščių arba telefono numerius, įterptus į svetainių antraštes.

 ![text-extraction](images/text-extraction.webp)

### Diktavimas

Naujai įdiegtoje sistemoje [Superwhisper](https://superwhisper.com/) yra numatytoji diktavimo sistema, naudojanti apdorojimą debesyje be modelių atsisiuntimo naudojimui neprisijungus. Pasirinkite Superwhisper, [Voxtype](https://voxtype.io/) arba [Hex](https://anoma.ly/hex/) per _Setup > Defaults > Dictation_ Omarchy meniu. Pasirinkus sistemą, ji prireikus įdiegiama ir tampa numatytąja diktavimui. Voxtype įkelia bazinį anglų kalbos modelį, kuris užima 150MB; modelį pakeiskite su `voxtype setup model`, o kitus nustatymus – per `~/.config/voxtype/config.toml`. Superwhisper atidaro savo nustatymus, kuriuose galima pasirinkti apdorojimą debesyje arba vietoje, o OPR palaiko programą atnaujintą. Hex sąrankos metu atsisiunčia savo kalbos modelį, veikiantį pačiame įrenginyje, ir veikia kaip `hex.service` naudotojo paslauga; atidarykite jo langą iš juostos dėklo piktogramos arba paleidę `hex`, kad pakeistumėte modelį ir kitus nustatymus.

Diktuojate laikydami nuspaudę `Right Alt` arba perjungdami su `Alt + Space`, ir padiktuotas tekstas atsiras sufokusuotoje įvesties srityje. Šie spartieji klavišai naudoja pasirinktą sistemą. Right Alt taip pat pradeda diktavimą, kai naudojamas modifikatoriaus derinyje; tiems deriniams naudokite Left Alt. Klaviatūros išdėstymuose, kuriuose Right Alt yra AltGr, įskaitant atvejus, kai toks išdėstymas yra vienas iš tų, į kuriuos perjungiate, norėdami diktuoti, trumpam palaikykite jį nuspaudę vieną; AltGr, paspaustas kartu su kitu klavišu, vis tiek įveda jo simbolį. Įdiegtys, atliktos prieš Alt + Space tampant numatytuoju, išlaiko `F9` kalbėjimui laikant nuspaudus ir `Super + Ctrl + X` perjungimui, pridėtus į `~/.config/hypr/bindings.lua`, kur tas `Super + Ctrl + X` užima agentų skydelio vietą; pašalinkite juos ten, kad grąžintumėte tuos klavišus programoms ir skydeliui.

Tie patys spartieji klavišai veikia su kiekviena sistema. Pasirinkite savo sistemą per Setup > Defaults > Dictation. Sistemos diegimo programa ją sukonfigūruoja ir išsaugo pasirinkimą. Paleiskite `omarchy default dictation`, kad pamatytumėte, kuri pasirinkta. Pasirinkimas išsaugomas `~/.config/omarchy/defaults/dictation`. Naujose įdiegtyse Superwhisper pasirenkamas automatiškai.

Omarchy automatiškai įkelia pasirinktos sistemos darbalaukio integraciją. Jokios Superwhisper konfigūracijos `~/.config/hypr/` nereikia.

Pasirinktiniai susiejimai ir scenarijai gali naudoti `omarchy dictation start`, `omarchy dictation stop` ir `omarchy dictation toggle`. Pasirinkta sistema tvarko įrašymą ir transkripciją. Pasirinkus Superwhisper, išjungiamas jo savasis laikymo spartusis klavišas, o jo savasis perjungimas nustatomas į `Ctrl + Alt + Space`, taip jį atskiriant nuo Omarchy įrašymo klavišų. Superwhisper reikalauja bent vieno savaisio įrašymo sparčiojo klavišo, o jo atšaukimo spartusis klavišas lieka prieinamas.

Papildomos sistemos gali integruotis nekeičiant Omarchy. Pateikite vykdomąjį failą pavadinimu `omarchy-dictation-<backend>` PATH, kuris priima `start`, `stop` ir `toggle` ir greitai užbaigia vykdymą, o nesėkmės atveju grąžina nenulinę būseną. Jos diegimo programa sukonfigūruoja teikėją ir po sėkmingos sąrankos iškviečia `omarchy-dictation-use <backend>`. Tai sustabdo ankstesnę sistemą ir atomiškai išsaugo pasirinkimą; `stop` turi sėkmingai baigtis, kai teikėjas yra nenaudojamas arba nepasiekiamas. Sistemų pavadinimuose naudojamos mažosios raidės, skaitmenys ir brūkšneliai. Sąrankai pateikite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` jį paleidžia. Pridėkite Defaults meniu įrašą per Omarchy meniu plėtinį, kad jis iškviestų tą parinkiklį. Pasirinktinė darbalaukio integracija gali būti `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
