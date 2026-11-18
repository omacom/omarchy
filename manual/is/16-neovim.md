# Neovim

[Neovim](https://neovim.io/) er nútímaleg útfærsla á [vi-ritlinum](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) sem Bill Joy bjó til allt aftur árið 1976. Þetta er hamritill þar sem innsetningarhamur og skipanahamur eru aðskildir, og það er nokkurs konar ofurkraftur þegar þú lærir jafnvel bara undirmengi af ótrúlega djúpa lyklaskipanakerfinu. En það er líka ansi lærsluferill!

Ef þú ert alveg nýr í vim-stíl ritvinnslu mæli ég með að þú skoðir [Vim As Your Editor þáttaröð ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) á YouTube. Hún kennir þér grunnatriðin. Vitu bara að ólíkt líkari almennum ritlum mun það taka þig lengri tíma að ná grunnkunnáttu í vim. En þegar þú gerir það er ávinningurinn líka meiri.

Neovim er nú í grundvallaratriðum óendanlega stillanlegt. Ef þú vilt í alvöru fara alla leið geturðu búið til þína eigin Neovim-stillingu frá grunni. Það er frábært námskeið frá [Typecraft um að setja upp Neovim frá grunni](https://www.youtube.com/watch?v=zHTeCSVAFNY). Og [ThePrimeagen á eitt líka](https://www.youtube.com/watch?v=w7i4amO_zaE).

En Omarchy kemur með fullkláraða Neovim-uppsetningu — `omarchy-nvim`-pakkanum — sem hefur verið stilltur af ást til að sýna það besta sem er mögulegt úr kassanum. Án þess að þú þurfir að skrifa eina einustu línu af stillingum! Hann er byggður á [LazyVim](https://www.lazyvim.org/), dreifingu Neovim-viðbóta og stillinga. Hann er frábær.

## LazyVim-grunnatriði

Eins og getið var ætla ég ekki að kenna þér vim í þessari stuttu kynningu, en ég get sýnt þér nokkur grunnatriði LazyVim og hvernig á að komast um.

Í fyrsta lagi hefur Neovim hugmyndina um leiðtogalykilinn (leader key). Það er í grundvallaratriðum gáttin að öllum skipununum. LazyVim hefur stillt hann á `Space`. Svo ýttu bara á hann, bíddu í sekúndu og þú sérð fullt af valkostum útskýrðum innfellt svona:

Hér eru nokkrar grunnskipanir sem ég nota alltaf:

- `Space Space` - Finndu hvaða skrá sem er í núverandi möppu með óljósri leit.
- `Space S G` - Leitaðu í öllum skrám með grep með forskoðun.
- `Space E` - Víxlaðu skráatrénu á/af.
- `Ctrl + W W` - Hoppaðu úr skráatrénu yfir í ritilinn og til baka.
- `Shift + H` - Færðu til vinstri á milli opinna flipa (vim kallar þá biðminni).
- `Shift + L` - Færðu til hægri á milli opinna flipa.
- `Space B D` - Lokaðu flipa.
- `Space B O` - Lokaðu öllum öðrum flipum en þeim núverandi.
- `Space G G` - Ræstu LazyGit í fljótandi rúðu úr núverandi möppu.
- `Space U W` - Víxlaðu mjúkri umbrotun.

Á meðan þú ert í skráatrénu (`Space E` til að birta, `Ctrl + W W` til að hoppa þangað) geturðu bætt við nýrri skrá með `a` eða nýrri möppu með `A`. Ýttu á `?` á meðan þú ert í trénu til að sjá allar skipanir.

Ef þú vilt læra grunn-vim-tungumálið hef ég skrifað um [þríþætta setningafræðina](https://world.hey.com/dhh/wonderful-vi-a1d034d3) og hvernig á að framkvæma þessi flottu samsettu hreyfibrögð!

Þú getur séð allar mögulegar skipanir á [LazyVim Keymaps-síðunni](https://www.lazyvim.org/keymaps).

## Að ræsa Neovim

Þú getur ræst Neovim með `Super + Shift + N` (tengingin ræsir sjálfgefna ritilinn þinn, sem er Neovim úr kassanum), en það er venjulega auðveldara að keyra hann úr terminalnum með því að fara í möppuna sem þú vilt vinna í og slá inn `n`. `n` er samnefnið fyrir `nvim`, sem notar núverandi möppu til að opna sjálfgefið. Þú getur opnað eina skrá með `n myfile.txt`.

## Að nota Neovim fyrir sudo-breytingar

Ef þú þarft að breyta skrám sem þú getur aðeins breytt sem ofurnotandi geturðu notað neovim með allar viðbæturnar þínar uppsettar með því að keyra `sudoedit /etc/sudoers.d/00-sudo-only-file`.
