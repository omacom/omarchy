# Teksto išgavimas ir diktavimas

### Teksto išgavimas

Paspauskite `Super + Ctrl + PrtScr`, kad ekrane pasirinktumėte sritį teksto išgavimui. Tada atvirojo kodo OCR modelis tesseract greitai pavers tą pasirinkimą tekstu ir padės jį į iškarpinę. Tada tiesiog paspausite `Super + V`, kad įklijuotumėte.

Tai labai naudinga norint iš paveikslėlių poraščių paimti adresus arba telefono numerius, įterptus į svetainių antraštes.

 ![text-extraction](images/text-extraction.webp)

### Diktavimas

Naujuose diegimuose [Superwhisper](https://superwhisper.com/) yra numatytasis diktavimo vidinis variklis, naudojantis debesies apdorojimą be neprisijungusių modelių atsisiuntimų. Superwhisper arba [Voxtype](https://voxtype.io/) rinkitės per _Nuostatos > Numatytosios > Diktavimas_ Omarchy meniu. Pasirinkus vidinį variklį, jis įdiegiamas, jei reikia, ir paverčiamas numatytuoju diktavimui. Voxtype įkelia bazinį anglų kalbos modelį, kuris užima 150MB; modelį keiskite su `voxtype setup model`, o kitas nuostatas per `~/.config/voxtype/config.toml`. Superwhisper atidaro savo nuostatas, kad pasirinktumėte debesies arba vietinį apdorojimą, o OPR laiko programą atnaujintą.

Diktuojate laikydami nuspaudę `Right Alt` arba `F9` arba perjungdami su `Super + Ctrl + X`, ir padiktuotas tekstas pasirodys sufokusuotoje įvesties srityje. Šie spartieji klavišai naudoja pasirinktą vidinį variklį. Right Alt taip pat pradeda diktavimą, kai naudojamas modifikatoriaus akorde; tiems akordams naudokite Left Alt. Klaviatūros išdėstymuose, kur Right Alt yra AltGr, naudokite `F9`, kad AltGr liktų prieinamas rašymui.

Tie patys spartieji klavišai veikia su bet kuriuo vidiniu varikliu. Savo vidinį variklį rinkitės per Nuostatos > Numatytosios > Diktavimas. Vidinio variklio diegimo programa jį sukonfigūruoja ir išsaugo pasirinkimą. Paleiskite `omarchy default dictation`, kad pamatytumėte, kuris pasirinktas. Pasirinkimas išsaugomas `~/.config/omarchy/defaults/dictation`. Nauji diegimai Superwhisper pasirenka automatiškai.

Omarchy pasirinkto vidinio variklio darbalaukio integraciją įkelia automatiškai. `~/.config/hypr/` nereikia jokios Superwhisper konfigūracijos.

Pasirinktiniai susiejimai ir scenarijai gali naudoti `omarchy dictation start`, `omarchy dictation stop` ir `omarchy dictation toggle`. Pasirinktas vidinis variklis tvarko įrašymą ir transkripciją. Pasirinkus Superwhisper, jo natūralus laikymo spartusis klavišas išjungiamas, o jo natūralus perjungimas nustatomas į `Alt + Space`, laikant jį atskirai nuo Omarchy įrašymo klavišų. Superwhisper reikalauja bent vieno natūralaus įrašymo sparčiojo klavišo, o jo atšaukimo spartusis klavišas lieka prieinamas.

Papildomi vidiniai varikliai gali integruotis nekeičiant Omarchy. Pateikite vykdomąjį failą pavadinimu `omarchy-dictation-<backend>` PATH, kuris priima `start`, `stop` ir `toggle` ir nedelsdamas grįžta, su nenuline būsena nesėkmės atveju. Jo diegimo programa sukonfigūruoja tiekėją ir po sėkmingos sąrankos iškviečia `omarchy-dictation-use <backend>`. Tai sustabdo ankstesnį vidinį variklį ir atomiškai išsaugo pasirinkimą; `stop` turi pavykti, kai tiekėjas neveikia arba yra neprieinamas. Vidinių variklių pavadinimai naudoja mažąsias raides, skaitmenis ir brūkšnelius. Sąrankai pateikite `omarchy-install-dictation-<backend>`; `omarchy default dictation <backend>` jį paleidžia. Numatytųjų meniu įrašą pridėkite per Omarchy meniu papildinį, kad iškviestumėte tą parinkiklį. Neprivaloma darbalaukio integracija gali gyventi `${XDG_CONFIG_HOME:-$HOME/.config}/<backend>/shortcuts.lua`.
