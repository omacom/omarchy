# Neovim

[Neovim](https://neovim.io/) ni utekelezaji wa kisasa wa [kihariri cha vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) kilichoundwa na Bill Joy tangu mwaka wa 1976. Ni kihariri cha modali ambapo hali ya kuingiza na hali ya amri zimetenganishwa, na ni kama nguvu ya ziada mara tu unapojifunza hata sehemu ndogo tu ya seti ya amri za vitufe yenye kina cha ajabu. Lakini pia ina mkondo mkali wa kujifunza!

Kama wewe ni mgeni kabisa katika uhariri wa mtindo wa vim, nakupendekezea uangalie [mfululizo wa ThePrimeagen wa Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) kwenye YouTube. Huo utakufundisha misingi. Fahamu tu kwamba tofauti na wahariri wa kawaida waliozoeleka zaidi, itakuchukua muda mrefu zaidi kupata umahiri wa msingi wa vim. Lakini mara utakapoupata, faida yake pia ni kubwa zaidi.

Sasa Neovim kimsingi inaweza kusanidiwa bila kikomo. Kama kweli unataka kwenda mbali kabisa, unaweza kuunda usanidi wako mwenyewe wa Neovim kuanzia mwanzo. Kuna kozi nzuri kutoka [Typecraft kuhusu kusanidi Neovim kuanzia mwanzo](https://www.youtube.com/watch?v=zHTeCSVAFNY). Na [ThePrimeagen pia ana yake](https://www.youtube.com/watch?v=w7i4amO_zaE).

Lakini Omarchy inakuja na usanidi kamili wa Neovim — kifurushi cha `omarchy-nvim` — ambacho kimetengenezwa kwa upendo kuonyesha kilicho bora zaidi kinachowezekana mara tu unapoanza kuitumia. Bila wewe kulazimika kuandika hata mstari mmoja wa usanidi! Imejengwa juu ya [LazyVim](https://www.lazyvim.org/), usambazaji wa programu-jalizi na usanidi wa Neovim. Ni ya ajabu.

## Misingi ya LazyVim

Kama ilivyotajwa, sitakufundisha vim katika utangulizi huu mfupi, lakini ninaweza kukuonyesha misingi michache ya LazyVim, na jinsi ya kuzunguka.

Kwanza, Neovim ina dhana ya kitufe kiongozi. Hicho kimsingi ndicho lango la amri zote. LazyVim imekiweka kuwa `Space`. Kwa hiyo kibonyeze tu, subiri sekunde moja, na utaona rundo la chaguo zikielezewa ndani ya mstari kama hivi:

Hapa kuna baadhi ya amri za msingi ninazozitumia kila wakati:

- `Space Space` - Tafuta faili yoyote katika saraka ya sasa kwa utafutaji wa fuzzy.
- `Space S G` - Tafuta faili zote ukitumia grep ukiwa na hakikisho la awali.
- `Space E` - Washa/zima mti wa faili.
- `Ctrl + W W` - Ruka kutoka kwenye mti wa faili kwenda kwa kihariri na kurudi.
- `Shift + H` - Sogea kushoto kati ya vichupo vilivyofunguliwa (vim huviita buffers).
- `Shift + L` - Sogea kulia kati ya vichupo vilivyofunguliwa.
- `Space B D` - Funga kichupo.
- `Space B O` - Funga vichupo vingine vyote isipokuwa cha sasa.
- `Space G G` - Zindua LazyGit katika kidirisha kinachoelea kutoka kwenye saraka ya sasa.
- `Space U W` - Washa/zima ukunjaji laini.

Ukiwa katika mti wa faili (`Space E` kuufunua, `Ctrl + W W` kuruka huko), unaweza kuongeza faili mpya kwa `a` au saraka mpya kwa `A`. Bonyeza `?` ukiwa katika mti kuona amri zote.

Kama unataka kujifunza lugha ya msingi ya vim, nimeandika kuhusu [sintaksia ya sehemu tatu](https://world.hey.com/dhh/wonderful-vi-a1d034d3) na jinsi ya kutekeleza miondoko hiyo mikali ya mchanganyiko!

Unaweza kuona amri zote zinazowezekana kwenye [ukurasa wa LazyVim Keymaps](https://www.lazyvim.org/keymaps).

## Kuanzisha Neovim

`Super + Shift + N` huzindua kihariri chako chaguo-msingi, ambacho ni Plain kwenye usakinishaji mpya; chagua Neovim chini ya _Setup > Defaults > Editor_ ili izindue Neovim badala yake. Lakini kwa kawaida ni rahisi zaidi kuiendesha kutoka kwenye terminali kwa kwenda kwenye saraka unayotaka kufanyia kazi na kuandika `n`. `n` ni alias ya `nvim`, ambayo itatumia saraka ya sasa kufungua kwa chaguo-msingi. Unaweza kufungua faili moja kwa `n myfile.txt`.

## Kutumia Neovim kwa uhariri wa sudo

Kama unahitaji kuhariri faili ambazo unaweza kuzibadilisha tu kama mtumiaji mkuu, endesha `sudoedit /etc/sudoers.d/00-sudo-only-file`. Hufungua kihariri chako chaguo-msingi, kwa hiyo weka Neovim chini ya _Setup > Defaults > Editor_ kama unaitaka huko ikiwa na programu-jalizi zako zote.
