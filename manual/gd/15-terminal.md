# Tèirmineal

'S e [Foot](https://codeberg.org/dnkl/foot) an tèirmineal bunaiteach ann an Omarchy. Tha e luath, aotrom agus co-chòrdail fiù 's ri seann choimpiutairean. Ach cha chuir e taic ri tabaichean no sgoltaidhean dùthchasach.

Ma chleachdas tu Tmux, 's dòcha nach cuir sin dragh ort, ach mura cleachd, cuiridh sinn làn-taic ri _Alacritty_, _Ghostty_ agus _Kitty_ mar roghainnean cuideachd. Tagh an tè as fheàrr leat fo _Stàlaich > Tèirmineal_ ann an clàr-taice Omarchy.

Tòisichidh tu tèirmineal ùr le `Super + Return`. (Comharraichidh an ceangal seo gu fèin-obrachail cia b' e tèirmineal a stàlaich thu le _Stàlaich > Tèirmineal_, agus 's urrainn dhut leum eadar na tèirmineilean stàlaichte fo _Suidheachadh > Bun-roghainnean > Tèirmineal_.)

## Tmux

Bheir Tmux eadar-aghaidh chunbhalach a ghabhas prògramachadh dhut airson leòsain, uinneagan (no tabaichean) agus seiseanan a ghabhas leantainn, ge b' e dè an tèirmineal agad. Obraichidh e fiù 's air òstairean cèin, mar sin nuair a bhios tu a' dol a-steach do fhrithealaiche le SSH, 's urrainn dhut an aon dòigh-obrach a chleachdadh.

Tòisichidh tu seisean Tmux ùr ann an tèirmineal ùr le `Super + Alt + Return`, agus a chionn 's gur e pròiseas buan a th' ann an Tmux, 's urrainn dhut leantainn air an t-seisean agad fiù 's ma dhùineas tu an tèirmineal sin. Dìreach brùth `Ctrl + Space` (canar an iuchair ro-leasachain ris) agus an uairsin `s` airson na seiseanan gnìomhach agad uile fhaicinn.

Thig Omarchy le rèiteachadh Tmux a chaidh a dhealbhadh gu h-eirgonomaigeach, agus tha mòran cheanglaichean iuchrach ann ri ionnsachadh, mar sin cùm [an duilleag-cuideachaidh faisg ort](07-hotkeys.md#tmux).

## Foincseanan co-dhealbhachd Tmux

A chionn 's gun gabh Tmux prògramachadh, 's urrainn dhuinn foincseanan a chleachdadh airson co-dhealbhachdan a chruthachadh. Thig Omarchy le ceithir foincseanan eadar-dhealaichte airson co-dhealbhachdan cumanta luchd-leasachaidh.

Tòisichidh `tdl [agent]` eadar-aghaidh coltach ri IDE air a sgoltadh na trì, leis an `$EDITOR` air an taobh chlì, an t-àidseant AI a thagh thu air an taobh deas (mar `c` airson opencode no `cx` airson Claude no `codex` airson OpenAI), agus an uairsin tèirmineal aig a' bhonn.

Mar sin thòisicheadh `tdl c` seo (no dìreach `ic`):

 ![tmux-tdl](images/tmux-tdl.webp)

'S urrainn dhut dàrna àidseant a thòiseachadh cuideachd le `tdl c cx` (opencode + claude) (no dìreach `icx`):

 ![tmux-tdl2](images/tmux-tdl2.webp)

Tha `tds` ann cuideachd, a thòisicheas ceàrnag na ceithir leis an deasaiche gu h-àrd air an taobh chlì, sùil air na diffs beò gu h-àrd air an taobh deas, tèirmineal gu h-ìosal air an taobh chlì agus opencode gu h-ìosal air an taobh deas.

'S urrainn dhut an co-dhealbhachd seo a thòiseachadh cuideachd airson gach fo-phasgan sa phasgan làithreach le `tdlm [agent]`, agus an uairsin gluasad eatarra le `alt + 1/2/3/4/5/...`:

 ![tmux-tdlm](images/tmux-tdlm.webp)

Mu dheireadh, 's urrainn dhut sgaoth àidseantan a thòiseachadh le `tsl [panes] [command]`. Mar sin bheir `tsl 4 c` griod ceithir-fillte de dh'àidseantan opencode dhut:

 ![tmux-tsl](images/tmux-tsl.webp)
