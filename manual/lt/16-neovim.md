# Neovim

[Neovim](https://neovim.io/) yra modernus [vi redaktoriaus](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), kurį Bill Joy sukūrė dar 1976 m., įgyvendinimas. Tai modalusis redaktorius, kuriame įterpimo režimas ir komandų režimas yra atskirti, ir tai yra savotiška supergalia, kai išmoksti bent dalį neįtikėtinai plataus klavišų komandų rinkinio. Bet mokymosi kreivė taip pat nemaža!

Jei vim stiliaus redagavimas tau visiškai naujas, rekomenduoju pažiūrėti [ThePrimeagen „Vim As Your Editor“ seriją](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) „YouTube“. Ji išmokys tave pagrindų. Tik žinok, kad, skirtingai nei su įprastesniais pagrindiniais redaktoriais, pagrindinių vim įgūdžių įgijimas tau užtruks ilgiau. Bet kai įgysi, atlygis taip pat bus didesnis.

Dabar Neovim galima konfigūruoti praktiškai be galo. Jei tikrai nori išprotėti, gali susikurti savo Neovim konfigūraciją nuo nulio. Yra puikus [Typecraft kursas apie Neovim nustatymą nuo nulio](https://www.youtube.com/watch?v=zHTeCSVAFNY). Ir [ThePrimeagen taip pat turi vieną](https://www.youtube.com/watch?v=w7i4amO_zaE).

Tačiau Omarchy pateikiama su pilna Neovim sąranka — `omarchy-nvim` paketu — kuri su meile suderinta taip, kad iškart parodytų geriausia, kas įmanoma, be jokio papildomo darbo. Tau nereikės parašyti nė vienos konfigūracijos eilutės! Ji sukurta ant [LazyVim](https://www.lazyvim.org/) — Neovim papildinių ir konfigūracijų distribucijos. Ji nuostabi.

## LazyVim pagrindai

Kaip minėjau, šiame trumpame įvade nemokysiu tavęs vim, bet galiu parodyti kelis LazyVim pagrindus ir kaip joje orientuotis.

Visų pirma, Neovim turi vadinamojo pagrindinio klavišo, leader, idėją. Tai iš esmės vartai į visas komandas. LazyVim jį nustatė į `Space`. Taigi tiesiog paspausk jį, palauk sekundę ir pamatysi daugybę parinkčių, paaiškintų tiesiog eilutėje štai taip:

Štai kelios pagrindinės komandos, kurias naudoju visą laiką:

- `Space Space` - Apytiksliai surasti bet kurį failą dabartiniame kataloge.
- `Space S G` - Ieškoti visuose failuose naudojant grep su peržiūra.
- `Space E` - Įjungti / išjungti failų medį.
- `Ctrl + W W` - Pereiti nuo failų medžio prie redaktoriaus ir atgal.
- `Shift + H` - Pereiti kairėn tarp atidarytų skirtukų (vim juos vadina buferiais).
- `Shift + L` - Pereiti dešinėn tarp atidarytų skirtukų.
- `Space B D` - Uždaryti skirtuką.
- `Space B O` - Uždaryti visus kitus skirtukus, išskyrus dabartinį.
- `Space G G` - Paleisti LazyGit slankiojoje srityje iš dabartinio katalogo.
- `Space U W` - Įjungti / išjungti minkštąjį eilučių laužymą.

Kai esi failų medyje (`Space E`, kad jį parodytum, `Ctrl + W W`, kad prie jo pereitum), gali pridėti naują failą su `a` arba naują katalogą su `A`. Paspausk `?` būdamas medyje, kad pamatytum visas komandas.

Jei nori perprasti pagrindinę vim kalbą, esu rašęs apie [trijų dalių sintaksę](https://world.hey.com/dhh/wonderful-vi-a1d034d3) ir kaip atlikti tuos įspūdingus kombinacinius judesius!

Visas galimas komandas gali pamatyti [LazyVim klavišų susiejimų puslapyje](https://www.lazyvim.org/keymaps).

## Neovim paleidimas

`Super + Shift + N` paleidžia tavo numatytąjį redaktorių, kuris naujuose įdiegimuose yra Plain; pasirink Neovim dalyje _Setup > Defaults > Editor_, kad vietoj jo būtų paleidžiamas Neovim. Bet paprastai lengviau jį valdyti iš terminalo: nueik į katalogą, kuriame nori dirbti, ir įvesk `n`. `n` yra `nvim` slapyvardis, kuris pagal numatytuosius nustatymus atidarys dabartinį katalogą. Vieną failą gali atidaryti su `n myfile.txt`.

## Neovim naudojimas sudo redagavimui

Jei reikia redaguoti failus, kuriuos gali keisti tik kaip supervartotojas, vykdyk `sudoedit /etc/sudoers.d/00-sudo-only-file`. Tai atidaro tavo numatytąjį redaktorių, todėl nustatyk Neovim dalyje _Setup > Defaults > Editor_, jei nori jį ten turėti su visais savo papildiniais.
