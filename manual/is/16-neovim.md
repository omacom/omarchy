# Neovim

[Neovim](https://neovim.io/) er nútímaleg útfærsla á [vi-ritlinum](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) sem Bill Joy bjó til allt aftur til ársins 1976. Þetta er hamstilltur ritill þar sem innsetningarhamur og skipanahamur eru aðskildir, og þetta er svolítill ofurkraftur þegar þú hefur lært jafnvel bara hluta af þessu ótrúlega djúpa safni lyklaskipana. En lærdómskúrfan er líka ansi brött!

Ef þú ert alveg nýr í ritvinnslu í vim-stíl mæli ég með að þú skoðir [þáttaröðina Vim As Your Editor eftir ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) á YouTube. Hún mun kenna þér grunninn. Hafðu bara í huga að ólíkt líkari almennum ritlum mun það taka þig lengri tíma að ná grunnfærni í vim. En þegar þú gerir það er ávinningurinn líka meiri.

Neovim er í raun óendanlega stillanlegt. Ef þú vilt virkilega láta vaða geturðu búið til þína eigin Neovim-stillingu frá grunni. Það er frábært námskeið frá [Typecraft um að setja upp Neovim frá grunni](https://www.youtube.com/watch?v=zHTeCSVAFNY). Og [ThePrimeagen er líka með eitt](https://www.youtube.com/watch?v=w7i4amO_zaE).

En Omarchy fylgir fullkomin Neovim-uppsetning — `omarchy-nvim` pakkinn — sem hefur verið stillt af kærleika til að sýna það besta sem hægt er beint úr kassanum. Án þess að þú þurfir að skrifa eina einustu línu af stillingum! Hún er byggð á [LazyVim](https://www.lazyvim.org/), dreifingu Neovim-viðbóta og stillinga. Það er æði.

## Grunnurinn í LazyVim

Eins og áður sagði ætla ég ekki að kenna þér vim í þessari stuttu kynningu, en ég get sýnt þér nokkur grunnatriði í LazyVim og hvernig á að fara um.

Í fyrsta lagi hefur Neovim hugmyndina um forlykilinn. Það er í raun gáttin að öllum skipununum. LazyVim hefur stillt hann á `Space`. Svo ýttu bara á hann, bíddu í sekúndu, og þú munt sjá fullt af valkostum útskýrðum á staðnum svona:

Hér eru nokkrar grunnskipanir sem ég nota stöðugt:

- `Space Space` - Leitaðu óljóst að hvaða skrá sem er í núverandi möppu.
- `Space S G` - Leitaðu í öllum skrám með grep með forskoðun.
- `Space E` - Kveiktu/slökktu á skráatrénu.
- `Ctrl + W W` - Hoppaðu frá skráatrénu yfir í ritilinn og til baka.
- `Shift + H` - Farðu til vinstri á milli opinna flipa (vim kallar þá biðminni).
- `Shift + L` - Farðu til hægri á milli opinna flipa.
- `Space B D` - Lokaðu flipa.
- `Space B O` - Lokaðu öllum öðrum flipum en núverandi.
- `Space G G` - Ræstu LazyGit í fljótandi glugga úr núverandi möppu.
- `Space U W` - Kveiktu/slökktu á mjúku línubroti.

Meðan þú ert í skráatrénu (`Space E` til að birta það, `Ctrl + W W` til að hoppa þangað) geturðu bætt við nýrri skrá með `a` eða nýrri möppu með `A`. Ýttu á `?` meðan þú ert í trénu til að sjá allar skipanir.

Ef þú vilt tileinka þér grunninn í vim-tungumálinu hef ég skrifað um [þrískiptu málskipanina](https://world.hey.com/dhh/wonderful-vi-a1d034d3) og hvernig á að framkvæma þessi sjúku kombó!

Þú getur séð allar mögulegar skipanir á [síðunni LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Að ræsa Neovim

`Super + Shift + N` ræsir sjálfgefna ritilinn þinn, sem er Plain í nýjum uppsetningum; veldu Neovim undir _Setup > Defaults > Editor_ til að láta hann ræsa Neovim í staðinn. En það er venjulega auðveldara að stjórna honum frá útstöðinni með því að fara í möppuna sem þú vilt vinna í og slá inn `n`. `n` er samnefni fyrir `nvim`, sem notar núverandi möppu til að opna sjálfgefið. Þú getur opnað eina skrá með `n myfile.txt`.

## Að nota Neovim fyrir sudo-breytingar

Ef þú þarft að breyta skrám sem þú getur aðeins breytt sem ofurnotandi skaltu keyra `sudoedit /etc/sudoers.d/00-sudo-only-file`. Það opnar sjálfgefna ritilinn þinn, svo stilltu Neovim undir _Setup > Defaults > Editor_ ef þú vilt hafa hann þar með öllum viðbótunum þínum.
