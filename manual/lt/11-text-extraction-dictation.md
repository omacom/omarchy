# Teksto išgavimas ir diktavimas

### Teksto išgavimas

Paspauskite `Super + Ctrl + PrtScr`, kad pasirinktumėte ekrano sritį tekstui išgauti. Tada atvirojo kodo OCR modelis tesseract greitai pavers tą pažymėtą sritį tekstu ir įdės jį į iškarpinę. Tada tiesiog paspauskite `Super + V`, kad įklijuotumėte.

Tai labai naudinga norint paimti adresus iš paveikslėlių poraščių ar telefono numerius, įterptus į svetainių antraštes.

 ![text-extraction](images/text-extraction.webp)

### Diktavimas

Naujuose įdiegimuose numatytasis diktavimo variklis yra [Superwhisper](https://superwhisper.com/), naudojantis apdorojimą debesyje be atsijungus veikiančių modelių atsisiuntimo. Pasirinkite Superwhisper, [Voxtype](https://voxtype.io/) arba [Hex](https://anoma.ly/hex/) Omarchy meniu per _Setup > Defaults > Dictation_. Pasirinkus variklį, jis prireikus įdiegiamas ir tampa numatytuoju diktavimui. Voxtype įkelia bazinį anglų kalbos modelį, kuris užima 150MB; modelį pakeiskite su `voxtype setup model`, o kitus nustatymus keiskite per `~/.config/voxtype/config.toml`. Superwhisper atveria savo nustatymus, kad pasirinktumėte apdorojimą debesyje arba vietinį apdorojimą, o OPR palaiko programą atnaujintą. Hex sąrankos metu atsisiunčia įrenginyje veikiantį kalbos modelį ir veikia kaip `hex.service` naudotojo paslauga; atidarykite jo langą iš juostos dėklo piktogramos arba paleidę `hex`, kad pakeistumėte modelį ir kitus nustatymus.

Diktuojate laikydami nuspaustą `Right Alt` arba perjungdami su `Alt + Space`, ir padiktuotas tekstas atsiras sufokusuotoje įvesties srityje. Šie spartieji klavišai naudoja pasirinktą variklį. Right Alt taip pat pradeda diktavimą, kai naudojamas modifikatoriaus derinyje; tiems deriniams naudokite Left Alt. Klaviatūros išdėstymuose, kuriuose Right Alt yra AltGr, naudokite `Alt + Space`, kad AltGr liktų pasiekiamas rašymui. Įdiegimai iš laikų, kai Alt + Space dar nebuvo numatytasis, išlaiko `F9` kalbėjimui laikant nuspaudus ir `Super + Ctrl + X` perjungimui, pridėtus prie `~/.config/hypr/bindings.lua`, kur tas `Super + Ctrl + X` užima agentų skydelio vietą; pašalinkite juos ten, kad grąžintumėte tuos klavišus programoms ir skydeliui.

Tie patys spartieji klavišai veikia su kiekvienu varikliu. Pasirinkite variklį per Setup > Defaults > Dictation. Variklio diegimo programa jį sukonfigūruoja ir išsaugo pasirinkimą. Paleiskite `omarchy default dictation`, kad pamatytumėte, kuris yra pasirinktas. Pasirinkimas išsaugomas `~/.config/omarchy/defaults/dictation`. Nauji įdiegimai automatiškai pasirenka Superwhisper.

Omarchy automatiškai įkelia pasirinkto variklio darbalaukio integraciją. Jokios Superwhisper konfigūracijos `~/.config/hypr/` nereikia.

Pasirinktiniai susiejimai ir scenarijai gali naudoti `omarchy dictation start`, `omarchy dictation stop` ir `omarchy dictation toggle`. Pasirinktas variklis atlieka įrašymą ir transkripciją. Pasirinkus Superwhisper, išjungiamas jo savasis laikymo spartusis klavišas ir jo savasis perjungimas nustatomas į `Ctrl + Alt + Space`, kad jis būtų atskirtas nuo Omarchy įrašymo klavišų. Superwhisper reikalauja bent vieno savajo įrašymo sparčiojo klavišo, o jo atšaukimo spartusis klavišas lieka pasiekiamas.

Papildomi varikliai gali integruotis nekeičiant Omarchy. Pateikite vykdomąjį failą pavadinimu `omarchy-dictation-<backend>` PATH, kuris priima `start`, `stop` ir `toggle` ir greitai grąžina valdymą, o gedimo atveju grąžina nulinės reikšmės neturintį būsenos kodą. Jo diegimo programa sukonfigūruoja teikėją ir po sėkmingos sąrankos iškviečia `omarchy-dictation-use <backend>`. Tai sustabdo ankstesnį variklį ir atomiškai išsaugo pasirinkimą; `stop` turi sėkmingai veikti, kai teikėjas yra nenaudojamas arba nepasiekiamas. Variklių pavadinimuose naudojamos mažosios raidės, skaitmenys ir brūkšneliai. Sąrankai pateikite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` jį paleidžia. Pridėkite Defaults meniu įrašą per Omarchy meniu plėtinį, kad jis iškviestų tą parinkiklį. Pasirinktinė darbalaukio integracija gali būti `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
