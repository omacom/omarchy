# Neovim

[Neovim](https://neovim.io/) ni utekelezaji wa kisasa wa [kihariri cha vi](<https://en.wikipedia.org/wiki/Vi_(text_editor)>) kilichoanzishwa na Bill Joy huko nyuma mwaka 1976. Ni kihariri cha hali ambapo hali ya ingizo na hali ya amri zimetenganishwa, na ni kama nguvu ya juu ukishajifunza hata sehemu tu ya seti ya amri za vitufe yenye kina cha kushangaza. Lakini pia ni njia ya kujifunza yenye mteremko mkali!

Ikiwa mpya kabisa katika uhariri wa mtindo wa vim, ninapendekeza utazame [mfululizo wa ThePrimeagen wa Vim As Your Editor](https://www.youtube.com/watch?v=X6AR2RMB5tE&list=PLm323Lc7iSW_wuxqmKx_xxNtJC_hJbQ7R) kwenye YouTube. Huo utakufundisha mambo ya msingi. Jua tu kwamba tofauti na vihariri vikuu vilivyo sawa zaidi, itakuchukua muda mrefu zaidi kupata ufanisi wa msingi na vim. Lakini ukishapata, malipo ni makubwa zaidi pia.

Sasa Neovim kimsingi inaweza kusanidiwa bila mwisho. Ikiwa unataka kweli kuchachamaa, unaweza kuunda usanidi wako mwenyewe wa Neovim kutoka mwanzo. Kuna kozi bora kutoka [Typecraft ya kusanidi Neovim kutoka mwanzo](https://www.youtube.com/watch?v=zHTeCSVAFNY). Na [ThePrimeagen ina moja pia](https://www.youtube.com/watch?v=w7i4amO_zaE).

Lakini Omarchy hutumwa na usanidi kamili wa Neovim — kifurushi cha `omarchy-nvim` — ambacho kimepangwa kwa upendo kuonyesha bora zaidi ya kile kinachowezekana mara moja. Bila wewe kuandika mstari mmoja wa usanidi! Imejengwa juu ya [LazyVim](https://www.lazyvim.org/), usambazaji wa programu-jalizi na usanidi wa Neovim. Ni nzuri sana.

## Misingi ya LazyVim

Kama ilivyotajwa, sitakufundisha vim katika utangulizi huu mfupi, lakini naweza kukuonyesha misingi michache ya LazyVim, na jinsi ya kusogeza.

Kwanza, Neovim ina wazo la kitufe cha kiongozi. Hicho kimsingi ndicho lango la amri zote. LazyVim imeweka hilo kuwa `Space`. Kwa hiyo bonyeza tu hiyo, subiri sekunde moja, na utaona chaguo nyingi zimeelezwa ndani ya mstari kama hivi:

Hapa kuna amri za msingi ninazozitumia wakati wote:

- `Space Space` - Tafuta faili yoyote katika saraka ya sasa kwa utafutaji usio dhahiri.
- `Space S G` - Tafuta faili zote ukitumia grep na onyesho la kukagua.
- `Space E` - Badilisha mti wa faili kuwasha/kuzima.
- `Ctrl + W W` - Ruka kutoka mti wa faili kwenda kihariri na kurudi.
- `Shift + H` - Hamia kushoto kati ya vichupo vilivyo wazi (vim huviita bafa).
- `Shift + L` - Hamia kulia kati ya vichupo vilivyo wazi.
- `Space B D` - Funga kichupo.
- `Space B O` - Funga vichupo vyote vingine isipokuwa cha sasa.
- `Space G G` - Zindua LazyGit katika paneli inayoelea kutoka saraka ya sasa.
- `Space U W` - Badilisha ufungaji laini.

Unapokuwa katika mti wa faili (`Space E` kuonyesha, `Ctrl + W W` kuruka huko), unaweza kuongeza faili mpya kwa `a` au saraka mpya kwa `A`. Bonyeza `?` ukiwa katika mti kuona amri zote.

Ikiwa unataka kujifunza lugha ya msingi ya vim, nimeandika kuhusu [sintaksia ya sehemu tatu](https://world.hey.com/dhh/wonderful-vi-a1d034d3) na jinsi ya kufanya hatua hizo za mchanganyiko mzuri!

Unaweza kuona amri zote zinazowezekana kwenye [ukurasa wa Mikato ya Vitufe ya LazyVim](https://www.lazyvim.org/keymaps).

## Kuanzisha Neovim

Unaweza kuanzisha Neovim ukitumia `Super + Shift + N` (ufungaji huzindua kihariri chako chaguomsingi, ambicho ni Neovim mara moja), lakini kwa kawaida ni rahisi kuiendesha kutoka terminali kwa kusogeza hadi saraka unayotaka kufanyia kazi na kuandika `n`. `n` ni jina bandia la `nvim`, ambalo litatumia saraka ya sasa kufungua kwa chaguomsingi. Unaweza kufungua faili moja kwa `n myfile.txt`.

## Kutumia Neovim kwa uhariri wa sudo

Ikiwa unahitaji kuhariri faili ambazo unaweza kuzibadilisha tu kama mtumiaji mkuu, unaweza kutumia neovim na programu-jalizi zako zote zilizosanidiwa kwa kuendesha `sudoedit /etc/sudoers.d/00-sudo-only-file`.
