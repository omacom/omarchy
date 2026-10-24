# TUI

## Lazygit

[Lazygit](https://github.com/jesseduffield/lazygit) yra maloni alternatyva kažkam panašaus į GitHub Desktop programą, ir jis veikia terminale.

Galite paleisti tiesiogiai: nueik į bet kurį git valdomą katalogą ir paleisk `lazygit`. Arba gali paleisti Neovim viduje, kur jį galima paleisti su `Space G G`.

Tarp skirtingų skydelių šokinėji naudodamas `Tab`. Files skydelyje failus ruošimui (staging) atrenki naudodamas `Space`, o tada gali sukurti naują commit naudodamas `c`. Visas prieinamas komandas gali pamatyti naudodamas `?`.

## Btop

[Btop](https://github.com/aristocratos/btop) yra gražus išteklių tvarkytuvas, rodantis atminties, CPU, disko ir tinklo naudojimą. Jis taip pat išvardija visus aktyvius procesus ir leidžia juos valdyti.

Omarchy jį vadina Activity ir paleidi jį paspausdamas `Super + Ctrl + T`. Jis atsidaro kaip plūduriuojantis langas, kurį gali išdėlioti plytelėmis su `Super + T`.

## Herdr

[Herdr](https://github.com/omacom-io/herdr) yra terminalo darbo sričių tvarkytuvas, suteikiantis darbo sritis, skirtukus ir skydelius bei laikantis juos visus veikiančius pastovioje sesijoje, nuo kurios gali atsijungti ir vėliau sugrįžti.

Jį paleidi (arba vėl prisijungi prie esamos sesijos) su `Super + Ctrl + Return`. Omarchy pristato Herdr konfigūraciją, atspindinčią jos Tmux konfigūraciją, tad priešdėlio klavišas čia taip pat yra `Ctrl + Space`. Visus klavišų susiejimus gali peržiūrėti su `Super + Ctrl + K`.

## Fastfetch

[Fastfetch](https://github.com/fastfetch-cli/fastfetch) rodo sistemos informaciją, pavyzdžiui, branduolio versiją, veikimo laiką, temą, CPU, atmintį ir daugiau. Tai populiaraus neofetch įrankio įpėdinis.

Omarchy tai supakavo kaip _Apie_ Omarchy meniu (`Super + Space`).

## Cliamp

[Cliamp](https://www.cliamp.stream/) yra retro terminalo muzikos grotuvas, įkvėptas Winamp 2.x, kartu su įtaisytosiomis radijo stotimis lo-fi ritmams. Paleisk jį su `Super + Shift + Alt + M` arba iš Omarchy meniu skiltyje _Programos_. Paspausk `?`, kad gautum visą klavišų susiejimų sąrašą.

## O kaip Wi-Fi ir Bluetooth?

Nerasi TUI, skirtų Wi-Fi ir Bluetooth — tie darbai priklauso Omarchy shell. Spustelėk Wi-Fi piktogramą meniu juostoje (arba paspausk `Super + Ctrl + W`), kad pamatytum tinklus ir prisijungtum, ir spustelėk Bluetooth piktogramą (arba paspausk `Super + Ctrl + B`), kad suporuotum ir prijungtum įrenginius. Žr. [tinklas](35-networking.md) visai istorijai sužinoti.

## Pridėti savo

Bet kuri terminalo programa gali gauti pilną programos traktavimą. Eik į _Įdiegti > TUI_ Omarchy meniu (`Super + Space`), suteik jai pavadinimą, paleidimo komandą, lango stilių ir piktogramą, ir ji atsiras programų paleidimo priemonėje kaip bet kuri kita programa. Gali ją vėl pašalinti skiltyje _Pašalinti > TUI_.
