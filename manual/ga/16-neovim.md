# Neovim

Is cur i bhfeidhm nua-aimseartha é [Neovim](https://neovim.io/) ar [eagarthóir vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) a chruthaigh Bill Joy an bealach ar fad siar i 1976. Is eagarthóir módach é ina bhfuil mód ionsáite agus mód ordaithe scartha, agus is cineál sárchumhachta é nuair a fhoghlaimíonn tú fiú fo-thacar den tacar ordaithe eochrach thar a bheith domhain. Ach is cuar foghlama suntasach é freisin!

Má tá tú go hiomlán nua d'eagarthóireacht ar stíl vim, molaim duit féachaint ar [shraith Vim As Your Editor le ThePrimeagen](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) ar YouTube. Múinfidh sin na bunghnéithe duit. Bíodh a fhios agat, murab ionann is eagarthóirí príomhshrutha níos cosúla, go dtógfaidh sé níos faide ort inniúlacht bhunúsach a fháil le vim. Ach nuair a dhéanann tú, tá an tairbhe níos mó freisin.

Anois tá Neovim in-chumraithe gan teorainn go bunúsach. Más mian leat dul ar mire i ndáiríre, is féidir leat do chumraíocht Neovim féin a chruthú ón tús. Tá cúrsa iontach ó [Typecraft ar Neovim a shocrú ón tús](https://www.youtube.com/watch?v=zHTeCSVAFNY). Agus [tá ceann ag ThePrimeagen freisin](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ach tagann socrú Neovim iomlán le Omarchy — an pacáiste `omarchy-nvim` — atá tiúnta go grámhar chun an chuid is fearr den mhéid is féidir a thaispeáint as an mbosca. Gan ort líne amháin cumraíochta a scríobh! Tá sé tógtha ar [LazyVim](https://www.lazyvim.org/), dáileadh de bhreiseáin agus cumraíochtaí Neovim. Tá sé iontach.

## Bunghnéithe LazyVim

Mar a luadh, nílim chun vim a mhúineadh duit sa réamhrá gearr seo, ach is féidir liom cúpla bunghné de LazyVim a thaispeáint duit, agus conas dul timpeall.

Ar dtús, tá smaoineamh na heochrach ceannaire ag Neovim. Sin go bunúsach an geata chuig na horduithe uile. Tá sin socraithe ag LazyVim go `Space`. Mar sin brúigh é sin, fan soicind, agus feicfidh tú braisle roghanna mínithe inlíne mar seo:

Seo roinnt bunordaithe a úsáidim i gcónaí:

- `Space Space` - Aimsigh go doiléir aon chomhad san eolaire reatha.
- `Space S G` - Cuardaigh gach comhad le grep le réamhamharc.
- `Space E` - Scoránaigh crann na gcomhad air/as.
- `Ctrl + W W` - Léim ó chrann na gcomhad chuig an eagarthóir agus ar ais.
- `Shift + H` - Bog ar chlé idir na cluaisíní oscailte (tugann vim maoláin orthu).
- `Shift + L` - Bog ar dheis idir na cluaisíní oscailte.
- `Space B D` - Dún cluaisín.
- `Space B O` - Dún gach cluaisín eile ach an ceann reatha.
- `Space G G` - Seol LazyGit i bpána ar foluain ón eolaire reatha.
- `Space U W` - Scoránaigh timfhilleadh bog.

Fad is atá tú i gcrann na gcomhad (`Space E` chun nochtadh, `Ctrl + W W` chun léim thall ann), is féidir leat comhad nua a chur leis le `a` nó eolaire nua le `A`. Brúigh `?` fad is atá tú sa chrann chun gach ordú a fheiceáil.

Más mian leat buntheanga vim a fhoghlaim, scríobh mé faoi [an chomhréir trí pháirt](https://world.hey.com/dhh/wonderful-vi-a1d034d3) agus conas na gluaiseachtaí teaglama iontacha sin a dhéanamh!

Is féidir leat na horduithe féideartha uile a fheiceáil ar [leathanach Keymaps LazyVim](https://www.lazyvim.org/keymaps).

## Neovim a Thosú

Is féidir leat Neovim a thosú le `Super + Shift + N` (seolann an ceangal d'eagarthóir réamhshocraithe, ar Neovim é as an mbosca), ach is gnách go mbíonn sé níos éasca é a thiomáint ón teirminéal trí nascleanúint chuig an eolaire inar mian leat oibriú agus `n` a chlóscríobh. Is é `n` an ailias do `nvim`, a úsáidfidh an t-eolaire láithreach chun oscailt de réir réamhshocraithe. Is féidir leat comhad amháin a oscailt le `n myfile.txt`.

## Neovim a úsáid d'eagarthóireachtaí sudo

Má theastaíonn uait comhaid a chur in eagar nach féidir leat a athrú ach mar shár-úsáideoir, is féidir leat neovim a úsáid le do bhreiseáin uile socraithe trí `sudoedit /etc/sudoers.d/00-sudo-only-file` a rith.
