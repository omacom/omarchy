# Neovim

[Neovim](https://neovim.io/) yra modernus [vi redaguoklio](<https://en.wikipedia.org/wiki/Vi_(text_editor)>), kurį Bill Joy sukūrė dar 1976 m., įgyvendinimas. Tai modalinis redaguoklis, kuriame įterpimo režimas ir komandų režimas yra atskirti, ir tai yra savotiška supergalia, kai išmokstate net tik dalį neįtikėtinai gilaus klavišų komandų rinkinio. Bet tai taip pat nemaža mokymosi kreivė!

Jei esate visiškai naujas vim stiliaus redagavime, rekomenduoju pažiūrėti [ThePrimeagen Vim As Your Editor seriją](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) YouTube. Tai išmokys jus pagrindų. Tik žinokite, kad, skirtingai nei panašesniuose pagrindiniuose redaguokliuose, jums prireiks daugiau laiko, kad įgytumėte bazinį vim mokėjimą. Bet kai tai padarysite, atsipirkimas taip pat didesnis.

Dabar Neovim galima konfigūruoti iš esmės be galo. Jei tikrai norite išprotėti, galite susikurti savo Neovim konfigūraciją nuo nulio. Yra puikus kursas iš [Typecraft apie Neovim nustatymą nuo nulio](https://www.youtube.com/watch?v=zHTeCSVAFNY). Ir [ThePrimeagen taip pat turi vieną](https://www.youtube.com/watch?v=w7i4amO_zaE).

Bet Omarchy pateikiama su visa Neovim sąranka — `omarchy-nvim` paketu — kuri su meile sureguliuota, kad parodytų geriausia, kas įmanoma iš karto. Jums nereikia parašyti nė vienos konfigūracijos eilutės! Ji sukurta ant [LazyVim](https://www.lazyvim.org/), Neovim papildinių ir konfigūracijų distribucijos. Tai nuostabu.

## LazyVim pagrindai

Kaip minėta, šioje trumpoje įžangoje jūsų nemokysiu vim, bet galiu parodyti kelis LazyVim pagrindus ir kaip jame orientuotis.

Pirma, Neovim turi lyderio klavišo idėją. Tai iš esmės yra vartai į visas komandas. LazyVim nustatė jį į `Space`. Taigi tiesiog paspauskite jį, palaukite sekundę ir pamatysite daugybę parinkčių, paaiškintų eilutėje, štai taip:

Štai kelios bazinės komandos, kurias naudoju visą laiką:

- `Space Space` - Fuzzy būdu rasti bet kurį failą dabartiniame kataloge.
- `Space S G` - Ieškoti visuose failuose naudojant grep su peržiūra.
- `Space E` - Perjungti failų medį įjungtą / išjungtą.
- `Ctrl + W W` - Šokinėti iš failų medžio į redaguoklį ir atgal.
- `Shift + H` - Judėti į kairę tarp atidarytų skirtukų (vim juos vadina buferiais).
- `Shift + L` - Judėti į dešinę tarp atidarytų skirtukų.
- `Space B D` - Uždaryti skirtuką.
- `Space B O` - Uždaryti visus kitus skirtukus, išskyrus dabartinį.
- `Space G G` - Paleisti LazyGit plūduriuojančioje srityje iš dabartinio katalogo.
- `Space U W` - Perjungti minkštą vyniojimą.

Kol esate failų medyje (`Space E`, kad atidengtumėte, `Ctrl + W W`, kad ten šoktumėte), galite pridėti naują failą su `a` arba naują katalogą su `A`. Būdami medyje paspauskite `?`, kad pamatytumėte visas komandas.

Jei norite išmokti bazinę vim kalbą, esu rašęs apie [trijų dalių sintaksę](https://world.hey.com/dhh/wonderful-vi-a1d034d3) ir kaip atlikti tuos ligotus kombinuotus judesius!

Visas galimas komandas galite pamatyti [LazyVim Keymaps puslapyje](https://www.lazyvim.org/keymaps).

## Neovim paleidimas

Neovim galite paleisti naudodami `Super + Shift + N` (susiejimas paleidžia jūsų numatytąjį redaguoklį, kuris iš karto yra Neovim), bet paprastai lengviau jį valdyti iš terminalo, nueinant į katalogą, kuriame norite dirbti, ir įrašant `n`. `n` yra `nvim` slapyvardis, kuris pagal numatytuosius nustatymus naudos dabartinį katalogą atidarymui. Vieną failą galite atidaryti su `n myfile.txt`.

## Neovim naudojimas sudo redagavimams

Jei jums reikia redaguoti failus, kuriuos galite keisti tik kaip supervartotojas, galite naudoti neovim su visais jūsų įdiegtais papildiniais paleisdami `sudoedit /etc/sudoers.d/00-sudo-only-file`.
