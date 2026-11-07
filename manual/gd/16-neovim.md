# Neovim

'S e buileachadh ùr-nòsach de [dheasaiche vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) a th' ann an [Neovim](https://neovim.io/), deasaiche a chruthaich Bill Joy cho fada air ais ri 1976. 'S e deasaiche modhach a th' ann far a bheil modh a' chur a-steach agus modh nan àitheantan air leth, agus 's e cumhachd os-nàdarra a th' ann nuair a dh'ionnsaicheas tu fiù 's pàirt bheag dhen t-seata iongantach dhomhainn de dh'àitheantan iuchrach. Ach tha lùb ionnsachaidh gu math cas ann cuideachd!

Ma tha thu buileach ùr do dheasachadh ann an stoidhle vim, mholainn dhut sùil a thoirt air [sreath Vim As Your Editor aig ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) air YouTube. Ionnsaichidh sin am bunait dhut. Dìreach biodh fios agad, eu-coltach ri deasaichean prìomh-shruthach eile, gun toir e nas fhaide ort comas bunaiteach fhaighinn ann an vim. Ach nuair a gheibh, bidh an duais nas motha cuideachd.

Nise, gabhaidh Neovim rèiteachadh gu ìre cha mhòr gun chrìoch. Ma tha thu airson a dhol às do chiall dha-rìribh, 's urrainn dhut an rèiteachadh Neovim agad fhèin a chruthachadh o fhìor thoiseach. Tha cùrsa math ann [o Typecraft air Neovim a shuidheachadh o fhìor thoiseach](https://www.youtube.com/watch?v=zHTeCSVAFNY). Agus [tha fear aig ThePrimeagen cuideachd](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ach thig Omarchy le suidheachadh Neovim coileanta — a' phacaid `omarchy-nvim` — a chaidh a ghleusadh le gaol airson an rud as fheàrr a ghabhas dèanamh a shealltainn dìreach às a' bhogsa. Gun fheum agad air aon loidhne rèiteachaidh a sgrìobhadh! Tha e stèidhichte air [LazyVim](https://www.lazyvim.org/), cuairteachadh de phlugain is rèiteachaidhean Neovim. Tha e sgoinneil.

## Bunaitean LazyVim

Mar a thuirt mi, chan ionnsaich mi vim dhut san ro-ràdh ghoirid seo, ach seallaidh mi dhut beagan bhunaitean LazyVim, agus mar a gheibh thu do shlighe mun cuairt.

An toiseach, tha beachd na h-iuchrach-ceannais (leader key) aig Neovim. Sin, gu bunaiteach, an geata dha na h-àitheantan uile. Shuidhich LazyVim sin gu `Space`. Mar sin dìreach brùth i, fuirich diog, agus chì thu dòrlach roghainnean air am mìneachadh san loidhne mar seo:

Seo beagan àitheantan bunaiteach a chleachdas mi fad na h-ùine:

- `Space Space` - Lorg faidhle sam bith sa phasgan làithreach le lorg tuairmseach.
- `Space S G` - Lorg anns na faidhlichean uile le grep agus ro-shealladh.
- `Space E` - Toglaich craobh nam faidhlichean air/dheth.
- `Ctrl + W W` - Leum o chraobh nam faidhlichean dhan deasaiche is air ais.
- `Shift + H` - Gluais gu clì eadar na tabaichean fosgailte (canaidh vim bufairean riutha).
- `Shift + L` - Gluais gu deas eadar na tabaichean fosgailte.
- `Space B D` - Dùin taba.
- `Space B O` - Dùin a h-uile taba eile ach am fear làithreach.
- `Space G G` - Cuir LazyGit gu dol ann an leòsan air fleòdradh on phasgan làithreach.
- `Space U W` - Toglaich am pasgadh bog.

Fhad 's a bhios tu ann an craobh nam faidhlichean (`Space E` airson a nochdadh, `Ctrl + W W` airson leum a-null ann), 's urrainn dhut faidhle ùr a chur ris le `a` no pasgan ùr le `A`. Brùth `?` sa chraoibh airson na h-àitheantan uile fhaicinn.

Ma tha thu airson cànan bunaiteach vim a thogail, sgrìobh mi mu dhèidhinn [a' cho-chàraidh trì-phàirtich](https://world.hey.com/dhh/wonderful-vi-a1d034d3) agus mar a nì thu na gluasadan combo eireachdail sin!

Chì thu a h-uile àithne a ghabhas cleachdadh air [duilleag Keymaps LazyVim](https://www.lazyvim.org/keymaps).

## A' tòiseachadh Neovim

'S urrainn dhut Neovim a thòiseachadh le `Super + Shift + N` (cuiridh an ceangal an deasaiche bunaiteach agad gu dol, agus 's e Neovim a th' ann às a' bhogsa), ach mar as trice tha e nas fhasa a stiùireadh on tèirmineal le bhith a' seòladh dhan phasgan far a bheil thu airson obrachadh agus a' sgrìobhadh `n`. 'S e `n` an t-alias airson `nvim`, a chleachdas am pasgan làithreach airson fhosgladh a thaobh bun-roghainn. 'S urrainn dhut aon fhaidhle fhosgladh le `n myfile.txt`.

## A' cleachdadh Neovim airson deasachadh le sudo

Ma dh'fheumas tu faidhlichean a dheasachadh nach urrainn dhut atharrachadh ach mar shàr-chleachdaiche, 's urrainn dhut neovim a chleachdadh leis na plugain agad uile air an suidheachadh le bhith a' ruith `sudoedit /etc/sudoers.d/00-sudo-only-file`.
