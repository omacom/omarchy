# Neovim

Is cur i bhfeidhm nua-aimseartha ar [eagarthóir vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) é [Neovim](https://neovim.io/) a chruthaigh Bill Joy an bealach ar fad siar in 1976. Is eagarthóir módúil é ina bhfuil mód ionsáite agus mód ordaithe scartha óna chéile, agus is cineál sárchumhachta é nuair a fhoghlaimíonn tú fiú fothacar den tacar orduithe eochrach thar a bheith domhain. Ach tá cuar foghlama sách mór ag baint leis freisin!

Má tá tú go hiomlán nua don eagarthóireacht ar stíl vim, molaim duit féachaint ar shraith [ThePrimeagen's Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) ar YouTube. Múinfidh sé sin na bunghnéithe duit. Bí ar an eolas nach bhfaighidh tú inniúlacht bhunúsach le vim chomh tapa agus a gheofá le heagarthóirí príomhshrutha eile atá níos cosúla lena chéile. Ach nuair a bhaineann tú amach í, is mó an toradh freisin.

Anois is féidir Neovim a chumrú gan teorainn beagnach. Más mian leat dul thar fóir i ndáiríre, is féidir leat do chumraíocht Neovim féin a chruthú ón tús. Tá cúrsa iontach ó [Typecraft ar Neovim a shocrú ón tús](https://www.youtube.com/watch?v=zHTeCSVAFNY). Agus tá ceann ag [ThePrimeagen freisin](https://www.youtube.com/watch?v=w7i4amO_zaE).

Ach tagann cumraíocht iomlán Neovim le Omarchy — an pacáiste `omarchy-nvim` — atá tiúnta go cúramach chun an chuid is fearr den mhéid is féidir a thaispeáint díreach as an mbosca. Gan duit oiread agus líne amháin chumraíochta a scríobh! Tá sé tógtha ar [LazyVim](https://www.lazyvim.org/), dáileadh de bhreiseáin agus chumraíochtaí Neovim. Tá sé iontach.

## Buneolas LazyVim

Mar a luaigh mé, nílim chun vim a mhúineadh duit sa réamhrá gairid seo, ach is féidir liom roinnt buneolais faoi LazyVim a thaispeáint duit, agus conas do bhealach a dhéanamh timpeall.

Ar dtús, tá coincheap na heochrach ceannródaí ag Neovim. Is í sin an geata chuig na horduithe uile go bunúsach. Tá sin socraithe ag LazyVim go `Space`. Mar sin níl le déanamh agat ach é sin a bhrú, fanacht soicind, agus feicfidh tú scata roghanna arna míniú sa líne mar seo:

Seo roinnt orduithe bunúsacha a úsáidim an t-am ar fad:

- `Space Space` - Aimsigh go doiléir aon chomhad san eolaire reatha.
- `Space S G` - Cuardaigh na comhaid uile ag úsáid grep le réamhamharc.
- `Space E` - Cas an crann comhad air/as.
- `Ctrl + W W` - Léim ón gcrann comhad chuig an eagarthóir agus ar ais.
- `Shift + H` - Bog ar chlé idir na cluaisíní oscailte (buffers a thugann vim orthu).
- `Shift + L` - Bog ar dheis idir na cluaisíní oscailte.
- `Space B D` - Dún cluaisín.
- `Space B O` - Dún gach cluaisín eile seachas an ceann reatha.
- `Space G G` - Seol LazyGit i bpána ar snámh ón eolaire reatha.
- `Space U W` - Cas an timfhilleadh bog air/as.

Nuair a bhíonn tú sa chrann comhad (`Space E` chun é a thaispeáint, `Ctrl + W W` chun léim anonn chuige), is féidir leat comhad nua a chur leis le `a` nó eolaire nua le `A`. Brúigh `?` agus tú sa chrann chun na horduithe uile a fheiceáil.

Más mian leat teanga bhunúsach vim a fhoghlaim, tá scríofa agam faoin [gcomhréir trí chuid](https://world.hey.com/dhh/wonderful-vi-a1d034d3) agus faoi conas na gluaiseachtaí combó iontacha sin a bhaint amach!

Is féidir leat na horduithe uile is féidir a fheiceáil ar [leathanach Keymaps LazyVim](https://www.lazyvim.org/keymaps).

## Neovim a Thosú

Seolann `Super + Shift + N` d'eagarthóir réamhshocraithe, arb é Plain é ar shuiteálacha nua; roghnaigh Neovim faoi _Setup > Defaults > Editor_ chun go seolfaidh sé Neovim ina áit. Ach is gnách go mbíonn sé níos fusa é a thiomáint ón teirminéal trí dhul chuig an eolaire inar mian leat oibriú agus `n` a chlóscríobh. Is é `n` an t-ailias ar `nvim`, a úsáidfidh an t-eolaire reatha le hoscailt de réir réamhshocraithe. Is féidir leat comhad aonair a oscailt le `n myfile.txt`.

## Neovim a Úsáid le haghaidh Eagarthóireachtaí sudo

Más gá duit comhaid a chur in eagar nach féidir leat a athrú ach mar shárúsáideoir, rith `sudoedit /etc/sudoers.d/00-sudo-only-file`. Osclóidh sé d'eagarthóir réamhshocraithe, mar sin socraigh Neovim faoi _Setup > Defaults > Editor_ más mian leat é a bheith agat ansin le do bhreiseáin go léir.
